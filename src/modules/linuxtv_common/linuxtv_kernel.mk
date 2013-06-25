
include $(PRJROOT)/src/modules/linuxtv_common/linuxtv_common.mk

ifeq ($(if $(call get_linuxtv_config_variable,CONFIG_DVB_CORE),$(ELC_DVB_DRIVER)),y)
  ADD_LINUXTV_ENV := y
endif
ifeq ($(if $(call get_linuxtv_config_variable,CONFIG_VIDEO_V4L2),$(ELC_V4L_DRIVER)),y)
  ADD_LINUXTV_ENV := y
endif

ifeq ($(ADD_LINUXTV_ENV),y)
  ELC_KERNEL_INCLUDE_PATH := $(LINUXTV_PATH)/linux
  ccflags-y += -include $(LINUXTV_PATH)/v4l/compat.h

  # Needed for kernel 2.6.29 or up
  LINUXINCLUDE := -I$(LINUXTV_PATH)/linux/include -I$(LINUXTV_PATH)/linux/include/uapi $(LINUXINCLUDE) -I$(LINUXTV_PATH)/v4l
  
  CUR_KERNEL_VERSION := $(shell grep "V4L2_VERSION" $(LINUXTV_PATH)/linux/kernel_version.h | cut -d ' ' -f 3)
else
  ELC_KERNEL_INCLUDE_PATH := $(KDIR)
  CUR_KERNEL_VERSION := $(shell grep "LINUX_VERSION_CODE" $(KDIR)/include/linux/version.h | cut -d ' ' -f 3)
endif
ccflags-y += -I$(ELC_KERNEL_INCLUDE_PATH)
ccflags-y += -I$(PRJROOT)/src/modules

ifeq ($(ELC_DVB_DRIVER),y)
  VER_3_7=0x030700
  ifeq ($(shell let VER_3_7=$(VER_3_7); expr $(CUR_KERNEL_VERSION) \>= $$VER_3_7),1)
    #new paths, from 3.7
    ccflags-y += -I$(ELC_KERNEL_INCLUDE_PATH)/drivers/media/dvb-core
    ccflags-y += -I$(ELC_KERNEL_INCLUDE_PATH)/drivers/media/dvb-frontends
  else
    #old paths
    ccflags-y += -I$(ELC_KERNEL_INCLUDE_PATH)/drivers/media/dvb/dvb-core
    ccflags-y += -I$(ELC_KERNEL_INCLUDE_PATH)/drivers/media/dvb/frontends
  endif
endif

# $(info "BR2_PACKAGE_LINUXTV=$(call get_rootfs_config_variable,BR2_PACKAGE_LINUXTV)")
# $(info "ADD_LINUXTV_ENV=$(ADD_LINUXTV_ENV)")
# $(info "ELC_KERNEL_INCLUDE_PATH=$(ELC_KERNEL_INCLUDE_PATH)")
# $(error "")
