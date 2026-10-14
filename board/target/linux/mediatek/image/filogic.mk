DTS_DIR := $(DTS_DIR)/mediatek
DEVICE_VARS += SUPPORTED_TELTONIKA_DEVICES
DEVICE_VARS += SUPPORTED_TELTONIKA_HW_MODS

define Image/Prepare
	# For UBI we want only one extra block
	rm -f $(KDIR)/ubi_mark
	echo -ne '\xde\xad\xc0\xde' > $(KDIR)/ubi_mark
endef

# =================================================================
# NUR DAS GL-MT5000 TARGET BEHALTEN, ALLES ANDERE ENTFERNT
# =================================================================

define Device/glinet_gl-mt5000
  DEVICE_VENDOR := GL.iNet
  DEVICE_MODEL := GL-MT5000
  DEVICE_DTS := mt7987a-gl-mt5000
  DEVICE_DTS_DIR := ../dts
  SUPPORTED_DEVICES := glinet,gl-mt5000
  DEVICE_PACKAGES := mkf2fs blkid blockdev kmod-fs-ext4 mt7987-2p5g-phy-firmware \
                     kmod-mmc kmod-fs-f2fs kmod-fs-vfat
  IMAGES += factory.bin
  IMAGE/factory.bin := append-kernel | pad-to 32M | append-rootfs
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-gl-metadata
endef
TARGET_DEVICES += glinet_gl-mt5000
