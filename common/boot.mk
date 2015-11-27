#
# Copyright (C) 2015 FriendlyARM (www.arm9.net)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

ifeq ($(TARGET_NO_KERNEL),true)

ifeq ($(BOARD_BOOTIMAGE_FILE_SYSTEM_TYPE),ext4)

TARGET_OUT_BOOT := $(PRODUCT_OUT)/boot
BUILT_BOOTEXT4IMAGE_TARGET := $(PRODUCT_OUT)/boot.img

INSTALLED_KERNEL_IMAGE := $(TARGET_OUT_BOOT)/uImage

ifeq ($(INSTALLED_RECOVERY_RAMDISK_TARGET),)
# See @recovery.mk
INSTALLED_RECOVERY_RAMDISK_TARGET := $(PRODUCT_OUT)/ramdisk-recovery.img
endif

define build-bootext4image-target
  $(call pretty,"Target boot ext4fs image: $(INSTALLED_BOOTIMAGE_TARGET)")
  $(MAKE_EXT4FS) -s -l $(BOARD_BOOTIMAGE_PARTITION_SIZE) -a boot \
      $(INSTALLED_BOOTIMAGE_TARGET) \
      $(TARGET_OUT_BOOT)
endef

# We just build this directly to the install location.
INSTALLED_BOOTIMAGE_TARGET := $(BUILT_BOOTEXT4IMAGE_TARGET)
$(INSTALLED_BOOTIMAGE_TARGET): $(INSTALLED_RAMDISK_TARGET) \
		$(INSTALLED_KERNEL_IMAGE) \
		$(INSTALLED_RECOVERY_RAMDISK_TARGET)
	$(hide) ln -sf uImage $(TARGET_OUT_BOOT)/uImage.hdmi
	$(hide) cp -f $(INSTALLED_RAMDISK_TARGET) $(TARGET_OUT_BOOT)/root.img.gz
	$(hide) cp -f $(INSTALLED_RECOVERY_RAMDISK_TARGET) $(TARGET_OUT_BOOT)/
	$(build-bootext4image-target)

endif

endif # TARGET_NO_KERNEL
