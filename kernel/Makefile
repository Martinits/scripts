# boot compiled linux kernel with busybox image using qemu
# minimal test environment for kernel module

ZIMAGE = ./bzImage
ROOTFS = ./rootfs.img

QEMU = qemu-system-x86_64
QEMU_ARGS = -m 2G \
	-kernel $(ZIMAGE) \
	-initrd $(ROOTFS) \
	-append "root=/dev/ram rw oops=panic panic=1 kalsr console=ttyS0" \
	-netdev user,id=t0, -device e1000,netdev=t0,id=nic0 \
	-monitor /dev/null \
	-smp cores=4,threads=1 \
	-cpu kvm64,+smep \
	-nographic

QEMU_GDB_ARGS = -S -s


build:
	cd rootfs && rm -rf rootfs.img && (find . | cpio -o --format=newc > $(ROOTFS))

qemu: build $(ZIMAGE) $(ROOTFS)
	$(QEMU) $(QEMU_ARGS)

qemu-gdb: build $(ZIMAGE) $(ROOTFS)
	$(QEMU) $(QEMU_ARGS) $(QEMU_GDB_ARGS)

.PHONY: build qemu qemu-gdb
