FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://0001-arm64-dts-renesas-sparrow-hawk-Reserve-first-128-MiB.patch \
"
SRC_URI:append = " \
    file://r8a779g3-xen-chosen.dtsi;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-domd.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://r8a779g3-sparrow-hawk-xen.dts;subdir=git/arch/arm64/boot/dts/renesas \
    file://append.cfg \
    ${@bb.utils.contains('DISTRO_FEATURES', 'enable_virtio', ' file://vsock.cfg', '', d)} \
    file://0001-xen-Initial-version-of-Xen-passthrough-helper-driver.patch \
    file://0002-PCIe-MSI-support.${MACHINE}.patch \
    file://0003-xen-pciback-allow-compiling-on-other-archs-than-x86.patch \
    file://0004-HACK-Allow-DomD-enumerate-PCI-devices.patch \
    file://0001-Fix-build-error-for-kernel-6.12.34.patch \
"

# Port Xen patch from v6.1.102/rcar-6.0.0.rc5-xt on xen-troops/linux
SRC_URI:append = " \
    file://xen_patchset/0001-xen-unpopulated-alloc-Introduce-helpers-for-contiguo.patch \
    file://xen_patchset/0002-xen-grant-table-Use-unpopulated-contiguous-pages-ins.patch \
    file://xen_patchset/0003-unpopulated-alloc.c-Drop-restriction-for-DMA_BIT_MAS.patch \
    file://xen_patchset/0004-vhost_xen-Implement-Xen-grant-mappings-module-for-vh.patch \
    file://xen_patchset/0005-vhost_xen-Get-the-guest-domid-from-Xenstore.patch \
    file://xen_patchset/0006-vhost_xen-Implement-Xen-foreign-mappings-along-with-.patch \
    file://xen_patchset/0007-vhost_xen-Adapt-net-for-Xen-specific-mappings.patch \
    file://xen_patchset/0008-vhost_xen-Change-a-logic-to-get-the-guest-domid.patch \
    file://xen_patchset/0009-Use-mhp_get_pluggable_range-in-balloon-as-well.patch \
    file://xen_patchset/0011-vhost_xen-Fix-build-error.patch \
"

SRC_URI:remove = "file://0002-PCIe-MSI-support.sparrow-hawk.patch"
SRC_URI:remove = "file://0003-xen-pciback-allow-compiling-on-other-archs-than-x86.patch"

do_compile:prepend:sparrow-hawk () {
    # WA for Xen DomD
    sed -i -e "s/1, 0, 1, 4/1, -1, 1, 4/" ${S}/drivers/gpu/drm/renesas/rcar-du/rcar_mipi_dsi.c
}

ADDITIONAL_DEVICE_TREES = "${XT_DEVICE_TREES}"

# Ignore in-tree defconfig
KBUILD_DEFCONFIG = ""

# Don't build defaul DTBs
KERNEL_DEVICETREE = ""

# Add ADDITIONAL_DEVICE_TREES to SRC_URIs and to KERNEL_DEVICETREEs
python __anonymous () {
    for fname in (d.getVar("ADDITIONAL_DEVICE_TREES") or "").split():
        dts = fname[:-3] + "dts"
        d.appendVar("SRC_URI", " file://%s;subdir=git/arch/${ARCH}/boot/dts/renesas"%dts)
        dtb = fname[:-3] + "dtb"
        d.appendVar("KERNEL_DEVICETREE", " renesas/%s"%dtb)
}

# For dt-overlay
KERNEL_DTC_FLAGS += "-@"

