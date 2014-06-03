BUILDDIR=build
CONF=$(BUILDDIR)/.env_config

ifeq ($(wildcard $(CONF)),)
$(error Configuration file not found, You must run the "configure" script first)
endif

.PHONY: components-% xvisor-% busybox-% openocd-% qemu-% uboot-% \
  prepare compile rootfs rootfs-img xvisor openocd debug qemu-img \
  clean% distclean% help


include $(CONF)
include $(MAKEDIR)/common.mk
include $(MAKEDIR)/components.mk
include $(MAKEDIR)/xvisor.mk
include $(MAKEDIR)/busybox.mk
include $(MAKEDIR)/openocd.mk
include $(MAKEDIR)/qemu.mk
include $(MAKEDIR)/uboot.mk

export PATH := $(PATH):$(BUILDDIR)/$(TOOLCHAIN_PATH)/bin:$(HOSTDIR)/bin/
export ARCH
export CROSS_COMPILE=$(TOOLCHAIN_PREFIX)


# Prepare all the components, the prepare rule depend on each component path
# to be ready
prepare: $(foreach component,$(COMPONENTS),$(component)-prepare)
compile: xvisor-compile
rootfs: busybox-install
rootfs-img: $(BUILDDIR)/$(ROOTFS_IMG)
xvisor: xvisor-compile
openocd: openocd-compile
debug: openocd-run
qemu-img: $(BUILDDIR)/qemu.img

ifeq ($(BOARD_QEMU),1)
run: $(BUILDDIR)/$(ROOTFS_IMG)
	@echo "$@ for $(BOARD)"
else # BOARD_QEMU != 1
run:
	@echo "This board is not emulated with Qemu"
	$(Q)exit 1
endif # BOARD_QEMU

clean:
	$(Q)find . -name "*~" -delete

distclean-prepare:
	$(Q)rm -rf $(foreach component,$(COMPONENTS),\
		$(BUILDDIR)/\$($(component)_PATH))

distclean:
	$(Q)rm -rf $(BUILDDIR)

help:
	@printf "Board			$(BOARDNAME)\n"
	@printf "Toolchain:		$(TOOLCHAIN_PREFIX)\n"
	@printf "Enabled components:	$(COMPONENTS)\n"
	@printf "\n"
	@printf "Available rules:\n"
	@printf "  prepare		- Get component source code\n"
	@printf "  configure		- Configure components\n"
	@printf "  compile		- Compile components\n"
ifeq ($(BOARD_BUSYBOX),1)
	@printf "  rootfs		- Generate the rootfs\n"
	@printf "  rootfs-img		- Generate the rootfs\n"
endif
ifeq ($(BOARD_QEMU),1)
	@printf "  run			- Start the board emulation\n"
endif
ifeq ($(BOARD_LOADER),1)
	@printf "  load			- Load xVisor on the board\n"
endif
	@printf "\n"
	@printf "  [COMPONENT]_prepare	- Get the component COMPONENT source "
	@printf "code\n"
	@printf "  [COMPONENT]_configure	- Configure the component\n"
	@printf "  [COMPONENT]_compile	- Compile the component\n"
	@printf "\n"
	@printf "  clean			- remove built file.\n"
	@printf "  distclean		- remove all non source file.\n"