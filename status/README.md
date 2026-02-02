**Feature 1: Single RMI to create shared channels (RMI_DATA_CREATE_UNKNOWN_SHARED)**
- Host: modify KVM to support single RMI logic (to replace mark + bind) -> DONE
- RMM: modify logic to mark granule as shared, track granule in SGT, RTT update to make IPA point to PA -> DONE 

**Feature 2: SGT to track shared memory granules**
- Host: add logic to delegate one SGT granule per realm, new RMI to mark the granule as belonging to SGT -> DONE
- RMM: add new RMI to track SGT granules, add new helpers to add/remove/query SGT -> DONE  

**Feature 3: Policy upload**
- Guest: 
 - align JSON-to-binary parser to current spec -> DONE
 - add shared memory pre-faulting -> **TODO**
- RMM: 
 - Policy validation:
  - Validate policy binary syntax -> DONE
  - If self is strict:
   - Gather all peers configs -> DONE
   - Check that all configs in peers only list channels with self explicitly listed in the policy -> DONE
   - Shared memory channels: check that all the shared memory IPAs are filled with a PA using SGT -> DONE
   - Shared memory channels: check that no other mappings involving self are present in SGT -> **TODO**
   - Transition channels: check that all the peers have compatible configs with self -> **TODO**
   - Transition channels: track the allowed transitions for the group -> **TODO**   
  - Else:
   - Gather all peers configs -> DONE
   - Shared memory channels: check that all the shared memory IPAs are filled with a PA -> DONE
   - Transition channels: check that all the peers have compatible transitions with self -> **TODO**
   - Transition channels: track the policy transitions for the group -> **TODO** 
 - Action after validation:
  - If peer is gateway and strict, unmap all unprotected memory not listed in policy file -> **TODO**
  - If peer is not gateway, unmap all unprotected memory -> **TODO**
  - If strict, only allow/treat those transitions listed in the policy file -> **TODO**
  - If not strict, set policy for listed transition in self -> **TODO**  
  - Activate shared memory channels by assigning correct access right -> **TODO**

**Feature 4: Attestation**
- RMM: adapt metadata navigation to find groups -> **TODO**

**Usecases**
- Debos-fs: update disk with new usecases code -> **TODO**

**Polishing**
- remove dangling RMIs
- remove unused code/imports