################################################################################
#
# qemu
#
################################################################################

QEMU_CCA_VERSION = cca/2025-06-12
QEMU_CCA_SITE = ssh://git@gitlab.doc.ic.ac.uk/aalsadi/qemu-private.git
QEMU_CCA_SITE_METHOD = git
QEMU_CCA_SELINUX_MODULES = qemu virt
QEMU_CCA_LICENSE = GPL-2.0, LGPL-2.1, MIT, BSD-3-Clause, BSD-2-Clause, Others/BSD-1c
QEMU_CCA_LICENSE_FILES = COPYING COPYING.LIB
# NOTE: there is no top-level license file for non-(L)GPL licenses;
#       the non-(L)GPL license texts are specified in the affected
#       individual source files.
QEMU_CCA_CPE_ID_VENDOR = qemu

#-------------------------------------------------------------

# The build system is now partly based on Meson.
# However, building is still done with configure and make as in previous versions of QEMU.

# Target-qemu
QEMU_CCA_DEPENDENCIES = \
	host-meson \
	host-pkgconf \
	host-python3 \
	host-python-distlib \
	libglib2 \
	zlib

# Need the LIBS variable because librt and libm are
# not automatically pulled. :-(
QEMU_CCA_LIBS = -lrt -lm

QEMU_CCA_OPTS =

QEMU_CCA_VARS = LIBTOOL=$(HOST_DIR)/bin/libtool

# If we want to build all emulation targets, we just need to either enable -user
# and/or -system emulation appropriately.
# Otherwise, if we want only a subset of targets, we must still enable all of
# them, so that QEMU properly builds a list of default targets from which it
# checks if the specified sub-set is valid.

ifeq ($(BR2_PACKAGE_QEMU_CCA_SYSTEM),y)
QEMU_CCA_DEPENDENCIES += pixman
QEMU_CCA_OPTS += --enable-system
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_AARCH64) += aarch64-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_ALPHA) += alpha-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_ARM) += arm-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_AVR) += avr-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_CRIS) += cris-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_HPPA) += hppa-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_I386) += i386-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_LOONGARCH64) += loongarch64-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_M68K) += m68k-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MICROBLAZE) += microblaze-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MICROBLAZEEL) += microblazeel-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPS) += mips-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPS64) += mips64-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPS64EL) += mips64el-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPSEL) += mipsel-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_OR1K) += or1k-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_PPC) += ppc-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_PPC64) += ppc64-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_RISCV32) += riscv32-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_RISCV64) += riscv64-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_RX) += rx-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_S390X) += s390x-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SH4) += sh4-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SH4EB) += sh4eb-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SPARC) += sparc-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SPARC64) += sparc64-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_TRICORE) += tricore-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_X86_64) += x86_64-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_XTENSA) += xtensa-softmmu
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_XTENSAEB) += xtensaeb-softmmu
else
QEMU_CCA_OPTS += --disable-system
endif

ifeq ($(BR2_PACKAGE_QEMU_CCA_LINUX_USER),y)
QEMU_CCA_OPTS += --enable-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_AARCH64) += aarch64-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_AARCH64_BE) += aarch64_be-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_ALPHA) += alpha-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_ARM) += arm-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_ARMEB) += armeb-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_CRIS) += cris-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_HEXAGON) += hexagon-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_HPPA) += hppa-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_I386) += i386-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_LOONGARCH64) += loongarch64-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_M68K) += m68k-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MICROBLAZE) += microblaze-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MICROBLAZEEL) += microblazeel-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPS) += mips-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPS64) += mips64-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPS64EL) += mips64el-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPSEL) += mipsel-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPSN32) += mipsn32-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_MIPSN32EL) += mipsn32el-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_OR1K) += or1k-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_PPC) += ppc-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_PPC64) += ppc64-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_PPC64LE) += ppc64le-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_RISCV32) += riscv32-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_RISCV64) += riscv64-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_S390X) += s390x-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SH4) += sh4-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SH4EB) += sh4eb-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SPARC) += sparc-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SPARC32PLUS) += sparc32plus-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_SPARC64) += sparc64-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_X86_64) += x86_64-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_XTENSA) += xtensa-linux-user
QEMU_CCA_TARGET_LIST_$(BR2_PACKAGE_QEMU_CCA_TARGET_XTENSAEB) += xtensaeb-linux-user
else
QEMU_CCA_OPTS += --disable-linux-user
endif

# Build the list of desired targets, if any.
ifeq ($(BR2_PACKAGE_QEMU_CCA_CHOOSE_TARGETS),y)
QEMU_CCA_TARGET_LIST = $(strip $(QEMU_CCA_TARGET_LIST_y))
ifeq ($(BR_BUILDING).$(QEMU_CCA_TARGET_LIST),y.)
$(error "No emulator target has ben chosen")
endif
QEMU_CCA_OPTS += --target-list="$(QEMU_CCA_TARGET_LIST)"
endif

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
QEMU_CCA_OPTS += --disable-vhost-user
else
QEMU_CCA_OPTS += --enable-vhost-user
endif

ifeq ($(BR2_PACKAGE_QEMU_CCA_SLIRP),y)
QEMU_CCA_OPTS += --enable-slirp
QEMU_CCA_DEPENDENCIES += slirp
else
QEMU_CCA_OPTS += --disable-slirp
endif

ifeq ($(BR2_PACKAGE_QEMU_CCA_SDL),y)
QEMU_CCA_OPTS += --enable-sdl
QEMU_CCA_DEPENDENCIES += sdl2
QEMU_CCA_VARS += SDL2_CONFIG=$(STAGING_DIR)/usr/bin/sdl2-config
else
QEMU_CCA_OPTS += --disable-sdl
endif

ifeq ($(BR2_PACKAGE_QEMU_CCA_FDT),y)
QEMU_CCA_OPTS += --enable-fdt
QEMU_CCA_DEPENDENCIES += dtc
else
QEMU_CCA_OPTS += --disable-fdt
endif

ifeq ($(BR2_PACKAGE_QEMU_CCA_TRACING),y)
QEMU_CCA_OPTS += --enable-trace-backends=log
else
QEMU_CCA_OPTS += --enable-trace-backends=nop
endif

ifeq ($(BR2_PACKAGE_QEMU_CCA_TOOLS),y)
QEMU_CCA_OPTS += --enable-tools
else
QEMU_CCA_OPTS += --disable-tools
endif

ifeq ($(BR2_PACKAGE_QEMU_CCA_GUEST_AGENT),y)
QEMU_CCA_OPTS += --enable-guest-agent
else
QEMU_CCA_OPTS += --disable-guest-agent
endif

ifeq ($(BR2_PACKAGE_LIBFUSE3),y)
QEMU_CCA_OPTS += --enable-fuse --enable-fuse-lseek
QEMU_CCA_DEPENDENCIES += libfuse3
else
QEMU_CCA_OPTS += --disable-fuse --disable-fuse-lseek
endif

ifeq ($(BR2_PACKAGE_LIBSECCOMP),y)
QEMU_CCA_OPTS += --enable-seccomp
QEMU_CCA_DEPENDENCIES += libseccomp
else
QEMU_CCA_OPTS += --disable-seccomp
endif

ifeq ($(BR2_PACKAGE_LIBSSH),y)
QEMU_CCA_OPTS += --enable-libssh
QEMU_CCA_DEPENDENCIES += libssh
else
QEMU_CCA_OPTS += --disable-libssh
endif

ifeq ($(BR2_PACKAGE_LIBUSB),y)
QEMU_CCA_OPTS += --enable-libusb
QEMU_CCA_DEPENDENCIES += libusb
else
QEMU_CCA_OPTS += --disable-libusb
endif

ifeq ($(BR2_PACKAGE_LIBVNCSERVER),y)
QEMU_CCA_OPTS += \
	--enable-vnc \
	--disable-vnc-sasl
QEMU_CCA_DEPENDENCIES += libvncserver
ifeq ($(BR2_PACKAGE_LIBPNG),y)
QEMU_CCA_OPTS += --enable-png
QEMU_CCA_DEPENDENCIES += libpng
else
QEMU_CCA_OPTS += --disable-png
endif
ifeq ($(BR2_PACKAGE_JPEG),y)
QEMU_CCA_OPTS += --enable-vnc-jpeg
QEMU_CCA_DEPENDENCIES += jpeg
else
QEMU_CCA_OPTS += --disable-vnc-jpeg
endif
else
QEMU_CCA_OPTS += --disable-vnc
endif

ifeq ($(BR2_PACKAGE_NETTLE),y)
QEMU_CCA_OPTS += --enable-nettle
QEMU_CCA_DEPENDENCIES += nettle
else
QEMU_CCA_OPTS += --disable-nettle
endif

ifeq ($(BR2_PACKAGE_NUMACTL),y)
QEMU_CCA_OPTS += --enable-numa
QEMU_CCA_DEPENDENCIES += numactl
else
QEMU_CCA_OPTS += --disable-numa
endif

ifeq ($(BR2_PACKAGE_PIPEWIRE),y)
QEMU_CCA_OPTS += --enable-pipewire
QEMU_CCA_DEPENDENCIES += pipewire
else
QEMU_CCA_OPTS += --disable-pipewire
endif

ifeq ($(BR2_PACKAGE_SPICE),y)
QEMU_CCA_OPTS += --enable-spice
QEMU_CCA_DEPENDENCIES += spice
else
QEMU_CCA_OPTS += --disable-spice
endif

ifeq ($(BR2_PACKAGE_USBREDIR),y)
QEMU_CCA_OPTS += --enable-usb-redir
QEMU_CCA_DEPENDENCIES += usbredir
else
QEMU_CCA_OPTS += --disable-usb-redir
endif

ifeq ($(BR2_STATIC_LIBS),y)
QEMU_CCA_OPTS += --static
endif

ifeq ($(BR2_PACKAGE_QEMU_CCA_BLOBS),y)
QEMU_CCA_OPTS += --enable-install-blobs
else
QEMU_CCA_OPTS += --disable-install-blobs
endif

# Override CPP, as it expects to be able to call it like it'd
# call the compiler.
# Override GIT_DIR, since configure needs to download subprojects using git.
define QEMU_CCA_CONFIGURE_CMDS
	unset TARGET_DIR; \
	cd $(@D); \
		LIBS='$(QEMU_CCA_LIBS)' \
		$(filter-out GIT_DIR=%,$(TARGET_CONFIGURE_OPTS)) \
		$(TARGET_CONFIGURE_ARGS) \
		CPP="$(TARGET_CC) -E" \
		$(QEMU_CCA_VARS) \
		./configure \
			--prefix=/usr \
			--cross-prefix=$(TARGET_CROSS) \
			--audio-drv-list= \
			--python=$(HOST_DIR)/bin/python3 \
			--ninja=$(HOST_DIR)/bin/ninja \
			--disable-alsa \
			--disable-bpf \
			--disable-brlapi \
			--disable-bsd-user \
			--disable-cap-ng \
			--disable-capstone \
			--disable-containers \
			--disable-coreaudio \
			--disable-curl \
			--disable-curses \
			--disable-dbus-display \
			--disable-docs \
			--disable-dsound \
			--disable-hvf \
			--disable-jack \
			--disable-libiscsi \
			--disable-linux-aio \
			--disable-linux-io-uring \
			--disable-malloc-trim \
			--disable-membarrier \
			--disable-mpath \
			--disable-netmap \
			--disable-opengl \
			--disable-oss \
			--disable-pa \
			--disable-plugins \
			--disable-rbd \
			--disable-selinux \
			--disable-sparse \
			--disable-strip \
			--disable-vde \
			--disable-vhost-crypto \
			--disable-vhost-user-blk-server \
			--disable-virtfs \
			--disable-whpx \
			--disable-xen \
			--enable-attr \
			--enable-kvm \
			--enable-vhost-net \
			--disable-hexagon-idef-parser \
			$(QEMU_CCA_OPTS)
endef

define QEMU_CCA_BUILD_CMDS
	unset TARGET_DIR; \
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)
endef

define QEMU_CCA_INSTALL_TARGET_CMDS
	unset TARGET_DIR; \
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) $(QEMU_CCA_MAKE_ENV) DESTDIR=$(TARGET_DIR) install
endef

$(eval $(generic-package))

#-------------------------------------------------------------
# Host-qemu

HOST_QEMU_CCA_DEPENDENCIES = \
	host-libglib2 \
	host-meson \
	host-pixman \
	host-pkgconf \
	host-python3 \
	host-python-distlib \
	host-slirp \
	host-zlib

#       BR ARCH         qemu
#       -------         ----
#       arm             arm
#       armeb           armeb
#       i486            i386
#       i586            i386
#       i686            i386
#       x86_64          x86_64
#       m68k            m68k
#       microblaze      microblaze
#       mips            mips
#       mipsel          mipsel
#       mips64          mips64
#       mips64el        mips64el
#       nios2           nios2
#       or1k            or1k
#       powerpc         ppc
#       powerpc64       ppc64
#       powerpc64le     ppc64 (system) / ppc64le (usermode)
#       sh2a            not supported
#       sh4             sh4
#       sh4eb           sh4eb
#       sh4a            sh4
#       sh4aeb          sh4eb
#       sparc           sparc
#       sparc64         sparc64
#       xtensa          xtensa

HOST_QEMU_CCA_ARCH = $(ARCH)
ifeq ($(HOST_QEMU_CCA_ARCH),armeb)
HOST_QEMU_CCA_SYS_ARCH = arm
endif
ifeq ($(HOST_QEMU_CCA_ARCH),i486)
HOST_QEMU_CCA_ARCH = i386
endif
ifeq ($(HOST_QEMU_CCA_ARCH),i586)
HOST_QEMU_CCA_ARCH = i386
endif
ifeq ($(HOST_QEMU_CCA_ARCH),i686)
HOST_QEMU_CCA_ARCH = i386
endif
ifeq ($(HOST_QEMU_CCA_ARCH),powerpc)
HOST_QEMU_CCA_ARCH = ppc
endif
ifeq ($(HOST_QEMU_CCA_ARCH),powerpc64)
HOST_QEMU_CCA_ARCH = ppc64
endif
ifeq ($(HOST_QEMU_CCA_ARCH),powerpc64le)
HOST_QEMU_CCA_ARCH = ppc64le
HOST_QEMU_CCA_SYS_ARCH = ppc64
endif
ifeq ($(HOST_QEMU_CCA_ARCH),sh4a)
HOST_QEMU_CCA_ARCH = sh4
endif
ifeq ($(HOST_QEMU_CCA_ARCH),sh4aeb)
HOST_QEMU_CCA_ARCH = sh4eb
endif
HOST_QEMU_CCA_SYS_ARCH ?= $(HOST_QEMU_CCA_ARCH)

HOST_QEMU_CCA_CFLAGS = $(HOST_CFLAGS)

ifeq ($(BR2_PACKAGE_HOST_QEMU_CCA_SYSTEM_MODE),y)
HOST_QEMU_CCA_TARGETS += $(HOST_QEMU_CCA_SYS_ARCH)-softmmu
HOST_QEMU_CCA_OPTS += --enable-system --enable-fdt
HOST_QEMU_CCA_CFLAGS += -I$(HOST_DIR)/include/libfdt
HOST_QEMU_CCA_DEPENDENCIES += host-dtc
else
HOST_QEMU_CCA_OPTS += --disable-system
endif

ifeq ($(BR2_PACKAGE_HOST_QEMU_CCA_LINUX_USER_MODE),y)
HOST_QEMU_CCA_TARGETS += $(HOST_QEMU_CCA_ARCH)-linux-user
HOST_QEMU_CCA_OPTS += --enable-linux-user

HOST_QEMU_CCA_HOST_SYSTEM_TYPE = $(shell uname -s)
ifneq ($(HOST_QEMU_CCA_HOST_SYSTEM_TYPE),Linux)
$(error "qemu-user can only be used on Linux hosts")
endif

else # BR2_PACKAGE_HOST_QEMU_CCA_LINUX_USER_MODE
HOST_QEMU_CCA_OPTS += --disable-linux-user
endif # BR2_PACKAGE_HOST_QEMU_CCA_LINUX_USER_MODE

ifeq ($(BR2_PACKAGE_HOST_QEMU_CCA_VDE2),y)
HOST_QEMU_CCA_OPTS += --enable-vde
HOST_QEMU_CCA_DEPENDENCIES += host-vde2
endif

# virtfs-proxy-helper is the only user of libcap-ng.
ifeq ($(BR2_PACKAGE_HOST_QEMU_CCA_VIRTFS),y)
HOST_QEMU_CCA_OPTS += --enable-virtfs --enable-cap-ng
HOST_QEMU_CCA_DEPENDENCIES += host-libcap-ng
else
HOST_QEMU_CCA_OPTS += --disable-virtfs --disable-cap-ng
endif

ifeq ($(BR2_PACKAGE_HOST_QEMU_CCA_USB),y)
HOST_QEMU_CCA_OPTS += --enable-libusb
HOST_QEMU_CCA_DEPENDENCIES += host-libusb
else
HOST_QEMU_CCA_OPTS += --disable-libusb
endif

# Override CPP, as it expects to be able to call it like it'd
# call the compiler.
define HOST_QEMU_CCA_CONFIGURE_CMDS
	unset TARGET_DIR; \
	cd $(@D); $(HOST_CONFIGURE_OPTS) CPP="$(HOSTCC) -E" \
		./configure \
		--target-list="$(HOST_QEMU_CCA_TARGETS)" \
		--prefix="$(HOST_DIR)" \
		--interp-prefix=$(STAGING_DIR) \
		--cc="$(HOSTCC)" \
		--host-cc="$(HOSTCC)" \
		--extra-cflags="$(HOST_QEMU_CCA_CFLAGS)" \
		--extra-ldflags="$(HOST_LDFLAGS)" \
		--python=$(HOST_DIR)/bin/python3 \
		--ninja=$(HOST_DIR)/bin/ninja \
		--disable-alsa \
		--disable-bpf \
		--disable-bzip2 \
		--disable-containers \
		--disable-coreaudio \
		--disable-curl \
		--disable-dbus-display \
		--disable-docs \
		--disable-dsound \
		--disable-jack \
		--disable-libssh \
		--disable-linux-aio \
		--disable-linux-io-uring \
		--disable-netmap \
		--disable-oss \
		--disable-pa \
		--disable-pipewire \
		--disable-sdl \
		--disable-selinux \
		--disable-vde \
		--disable-vhost-user-blk-server \
		--disable-vnc-jpeg \
		--disable-plugins \
		--disable-png \
		--disable-vnc-sasl \
		--enable-slirp \
		--enable-tools \
		--disable-guest-agent \
		$(HOST_QEMU_CCA_OPTS)
endef

define HOST_QEMU_CCA_BUILD_CMDS
	unset TARGET_DIR; \
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_QEMU_CCA_INSTALL_CMDS
	unset TARGET_DIR; \
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install
endef

# install symlink to qemu-system
ifeq ($(BR2_PACKAGE_HOST_QEMU_CCA_SYSTEM_MODE),y)
define HOST_QEMU_CCA_POST_INSTALL_SYMLINK
	ln -sf ./qemu-system-$(HOST_QEMU_CCA_ARCH) $(HOST_DIR)/bin/qemu-system
endef
HOST_QEMU_CCA_POST_INSTALL_HOOKS += HOST_QEMU_CCA_POST_INSTALL_SYMLINK
endif

$(eval $(host-generic-package))

# variable used by other packages
QEMU_CCA_USER = $(HOST_DIR)/bin/qemu-$(HOST_QEMU_CCA_ARCH)
