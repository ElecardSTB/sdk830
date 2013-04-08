
LINUXTV_ENABLED=n
# LINUXTV_V4L2_ENABLED=n
# LINUXTV_DVB_ENABLED=n

ifeq ($(LINUXTV_ENABLED),y)
LINUXTV_PATH=$(BUILDROOT)/packages/buildroot/output_rootfs/build/media_build

ccflags-y += -include $(LINUXTV_PATH)/v4l/compat.h

# Needed for kernel 2.6.29 or up
LINUXINCLUDE := -I$(LINUXTV_PATH)/linux/include -I$(LINUXTV_PATH)/linux/include/uapi/linux $(LINUXINCLUDE) -I$(LINUXTV_PATH)/v4l
endif
