/* rw_ivshmem.c  –  build with:  gcc -O2 -Wall -o rw_ivshmem rw_ivshmem.c */
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include <getopt.h>
#include <stdint.h>
#include <sys/stat.h>

#define DEFAULT_SHM_SIZE   (64 * 1024 * 1024)
#define SHORT_LEN          4000
#define LONG_LEN           (64 * 1024 * 1024)

/* Simple header to make "any file" round-trip safely */
#define HDR_MAGIC "IVSHFILE"
#define HDR_MAGIC_LEN 8
#define HDR_SIZE  0x20   /* 32 bytes total */
#define PAYLOAD_OFF HDR_SIZE

typedef struct __attribute__((packed)) {
    char     magic[8];     /* "IVSHFILE" */
    uint64_t length;       /* payload length in bytes */
    uint32_t ready;        /* 0 while writing, 1 when complete */
    uint32_t reserved;     /* padding */
    uint8_t  pad[8];       /* pad to 0x20 */
} shm_hdr_t;

static void print_a(size_t len)
{
    for (size_t i = 0; i < len; ++i) putchar('A');
    putchar('\n');
}

static void usage(const char *prog, const char *def_path, size_t def_size)
{
    fprintf(stderr,
        "Usage:\n"
        "  %s -S                            # print 4000 × 'A'\n"
        "  %s -L                            # print LONG_LEN × 'A'\n"
        "  %s -R [short|long|N]             # read N bytes (default: SHM size)\n"
        "  %s -W <string>                   # write <string> into IVSHMEM BAR\n"
        "  %s -F <infile>                   # copy raw file -> shared mem (with header)\n"
        "  %s -D <outfile>                  # dump shared mem payload -> file (uses header)\n"
        "\n"
        "Options (apply to -R/-W/-F/-D modes):\n"
        "  -f <path>                        # BAR/resource file to mmap\n"
        "                                   # default: %s\n"
        "  -z <bytes>                       # set mmap length AND max R/W cap\n"
        "  -o <offset>                      # mmap file offset (page-aligned)\n"
        "                                   # default: %zu bytes\n"
        "  -p <byte>                        # (WRITE STRING mode) prewrite-fill entire region\n"
        "                                   # with <byte> (0..255, accepts hex like 0x00)\n"
        "  -h                               # show this help\n"
        "\n"
        "Notes:\n"
        "  • -F writes a header: magic, length, ready flag.\n"
        "  • -D requires that header (written by -F).\n"
        "  • Payload starts at offset 0x%X.\n"
        "  • 'short' = %d bytes, 'long' = %d bytes.\n",
        prog, prog, prog, prog, prog, prog,
        def_path, def_size, PAYLOAD_OFF, SHORT_LEN, LONG_LEN);
    exit(1);
}

static int write_file_to_shm(char *bar, size_t shm_size, const char *infile)
{
    int fd = open(infile, O_RDONLY);
    if (fd < 0) { perror("open infile"); return 1; }

    struct stat st;
    if (fstat(fd, &st) != 0) { perror("fstat infile"); close(fd); return 1; }
    if (!S_ISREG(st.st_mode)) {
        fprintf(stderr, "Input is not a regular file: %s\n", infile);
        close(fd);
        return 1;
    }

    uint64_t file_len = (uint64_t)st.st_size;

    if (shm_size < PAYLOAD_OFF) {
        fprintf(stderr, "SHM region too small for header (need >= %u)\n", PAYLOAD_OFF);
        close(fd);
        return 1;
    }

    uint64_t cap = (uint64_t)(shm_size - PAYLOAD_OFF);
    if (file_len > cap) {
        fprintf(stderr, "File too large for SHM payload: file=%llu, cap=%llu\n",
                (unsigned long long)file_len, (unsigned long long)cap);
        close(fd);
        return 1;
    }

    shm_hdr_t *h = (shm_hdr_t*)bar;

    /* publish "not ready" first */
    h->ready = 0;
    __sync_synchronize();

    memset(h, 0, sizeof(*h));
    memcpy(h->magic, HDR_MAGIC, HDR_MAGIC_LEN);
    h->length = file_len;
    h->ready = 0;
    __sync_synchronize();

    uint8_t *dst = (uint8_t*)bar + PAYLOAD_OFF;

    /* copy in chunks */
    uint64_t off = 0;
    while (off < file_len) {
        size_t chunk = (size_t)((file_len - off) > (1<<20) ? (1<<20) : (file_len - off));
        ssize_t r = pread(fd, dst + off, chunk, (off_t)off);
        if (r < 0) { perror("pread infile"); close(fd); return 1; }
        if (r == 0) break;
        off += (uint64_t)r;
    }
    close(fd);

    if (off != file_len) {
        fprintf(stderr, "Short read: copied %llu / %llu\n",
                (unsigned long long)off, (unsigned long long)file_len);
        return 1;
    }

    /* publish ready */
    __sync_synchronize();
    h->ready = 1;
    __sync_synchronize();

    return 0;
}

static int dump_shm_to_file(char *bar, size_t shm_size, const char *outfile)
{
    if (shm_size < PAYLOAD_OFF) {
        fprintf(stderr, "SHM region too small for header\n");
        return 1;
    }

    shm_hdr_t *h = (shm_hdr_t*)bar;

    /* basic header validation */
    if (memcmp(h->magic, HDR_MAGIC, HDR_MAGIC_LEN) != 0) {
        fprintf(stderr, "Bad/missing header magic (expected '%s')\n", HDR_MAGIC);
        return 1;
    }

    /* Ensure we read a consistent view of header */
    __sync_synchronize();
    if (h->ready != 1) {
        fprintf(stderr, "Shared memory not marked ready yet (ready=%u)\n", h->ready);
        return 1;
    }

    uint64_t len = h->length;
    uint64_t cap = (uint64_t)(shm_size - PAYLOAD_OFF);
    if (len > cap) {
        fprintf(stderr, "Header length exceeds SHM payload cap: len=%llu cap=%llu\n",
                (unsigned long long)len, (unsigned long long)cap);
        return 1;
    }

    int fd = open(outfile, O_CREAT | O_TRUNC | O_WRONLY, 0644);
    if (fd < 0) { perror("open outfile"); return 1; }

    uint8_t *src = (uint8_t*)bar + PAYLOAD_OFF;

    uint64_t off = 0;
    while (off < len) {
        size_t chunk = (size_t)((len - off) > (1<<20) ? (1<<20) : (len - off));
        ssize_t w = write(fd, src + off, chunk);
        if (w < 0) { perror("write outfile"); close(fd); return 1; }
        off += (uint64_t)w;
    }

    if (fsync(fd) != 0) { perror("fsync outfile"); /* continue */ }
    close(fd);
    return 0;
}

int main(int argc, char **argv)
{
    const char *default_bar_path = "/sys/bus/pci/devices/0000:00:02.0/resource2";
    const char *bar_path = default_bar_path;
    size_t shm_size = DEFAULT_SHM_SIZE;
    size_t max_rw_len = DEFAULT_SHM_SIZE;
    off_t map_off = 0;

    enum { MODE_NONE, MODE_S, MODE_L, MODE_R, MODE_W, MODE_F, MODE_D } mode = MODE_NONE;
    const char *read_arg = NULL;
    const char *write_arg = NULL;
    const char *file_in = NULL;
    const char *file_out = NULL;

    int prewrite_enabled = 0;
    uint8_t prewrite_byte = 0;

    int c;
    opterr = 0;
    while ((c = getopt(argc, argv, "SLR:W:F:D:f:z:o:p:h")) != -1) {
        switch (c) {
            case 'S': mode = MODE_S; break;
            case 'L': mode = MODE_L; break;
            case 'R': mode = MODE_R; read_arg = optarg; break;
            case 'W': mode = MODE_W; write_arg = optarg; break;
            case 'F': mode = MODE_F; file_in = optarg; break;
            case 'D': mode = MODE_D; file_out = optarg; break;
            case 'f': bar_path = optarg; break;
            case 'z': {
                char *end = NULL;
                errno = 0;
                unsigned long v = strtoul(optarg, &end, 0);
                if (errno || !optarg[0] || (end && *end)) {
                    fprintf(stderr, "Invalid -z <bytes>: '%s'\n", optarg);
                    usage(argv[0], default_bar_path, DEFAULT_SHM_SIZE);
                }
                shm_size = (size_t)v;
                max_rw_len = (size_t)v;
            } break;
            case 'o': {
                char *end = NULL;
                errno = 0;
                unsigned long long v = strtoull(optarg, &end, 0);
                if (errno || !optarg[0] || (end && *end)) {
                    fprintf(stderr, "Invalid -o <offset>: '%s'\n", optarg);
                    usage(argv[0], default_bar_path, DEFAULT_SHM_SIZE);
                }
                map_off = (off_t)v;
            } break;
            case 'p': {
                char *end = NULL;
                errno = 0;
                unsigned long v = strtoul(optarg, &end, 0);
                if (errno || !optarg[0] || (end && *end) || v > 255UL) {
                    fprintf(stderr, "Invalid -p <byte> (0..255): '%s'\n", optarg);
                    usage(argv[0], default_bar_path, DEFAULT_SHM_SIZE);
                }
                prewrite_enabled = 1;
                prewrite_byte = (uint8_t)v;
            } break;
            case 'h':
                usage(argv[0], default_bar_path, DEFAULT_SHM_SIZE);
                break;
            default:
                usage(argv[0], default_bar_path, DEFAULT_SHM_SIZE);
        }
    }

    if (mode == MODE_S) { print_a(SHORT_LEN); return 0; }
    if (mode == MODE_L) { print_a(LONG_LEN);  return 0; }

    if (mode != MODE_R && mode != MODE_W && mode != MODE_F && mode != MODE_D) {
        usage(argv[0], default_bar_path, DEFAULT_SHM_SIZE);
    }

    int fd = open(bar_path, O_RDWR);
    if (fd == -1) { perror("open"); return 1; }

    long pg = sysconf(_SC_PAGESIZE);
    if (pg <= 0) { fprintf(stderr, "sysconf(_SC_PAGESIZE) failed\n"); close(fd); return 1; }
    if (map_off % pg) {
        fprintf(stderr, "mmap offset must be page-aligned\n");
        close(fd);
        return 1;
    }

    int prot = (mode == MODE_R) ? PROT_READ : (PROT_READ | PROT_WRITE);
    char *bar = mmap(NULL, shm_size, prot, MAP_SHARED, fd, map_off);
    if (bar == MAP_FAILED) { perror("mmap"); close(fd); return 1; }

    int rc = 0;

    if (mode == MODE_R) {                                /* ---- READ ---- */
        size_t len = shm_size;
        if (read_arg && read_arg[0]) {
            if      (strcmp(read_arg, "short") == 0) len = SHORT_LEN;
            else if (strcmp(read_arg, "long")  == 0) len = LONG_LEN;
            else {
                char *end = NULL;
                errno = 0;
                unsigned long v = strtoul(read_arg, &end, 0);
                if (errno || (end && *end)) {
                    munmap(bar, shm_size); close(fd);
                    usage(argv[0], default_bar_path, DEFAULT_SHM_SIZE);
                }
                len = (size_t)v;
            }
        }
        if (len > max_rw_len) len = max_rw_len;
        if (len > shm_size)  len = shm_size;

        fwrite(bar, 1, len, stdout);
        putchar('\n');
    }
    else if (mode == MODE_W) {                           /* ---- WRITE STRING ---- */
        if (!write_arg) {
            fprintf(stderr, "Missing string to write.\n");
            rc = 1;
        } else {
            if (prewrite_enabled) {
                memset(bar, prewrite_byte, shm_size);
                __sync_synchronize();
            }

            size_t len = strlen(write_arg);
            if (len > max_rw_len) len = max_rw_len;
            if (len > shm_size)   len = shm_size;
            memcpy(bar, write_arg, len);
            __sync_synchronize();
        }
    }
    else if (mode == MODE_F) {                           /* ---- WRITE FILE ---- */
        if (!file_in) {
            fprintf(stderr, "Missing input file for -F.\n");
            rc = 1;
        } else {
            rc = write_file_to_shm(bar, shm_size, file_in);
        }
    }
    else if (mode == MODE_D) {                           /* ---- DUMP FILE ---- */
        if (!file_out) {
            fprintf(stderr, "Missing output file for -D.\n");
            rc = 1;
        } else {
            rc = dump_shm_to_file(bar, shm_size, file_out);
        }
    }

    munmap(bar, shm_size);
    close(fd);
    return rc;
}
