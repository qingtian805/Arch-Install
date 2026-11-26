## Kernel and out-tree module
Arch Linux builds out-tree module against kernel version. Which means you should:
1. Check `/usr/lib/modules` has only one directory that matches installed kernel version.
2. If not, rollback kernel or out-tree module which recently updated.

- Common out-tree module packages: nvidia-open
- DKMS package is not restricted.
