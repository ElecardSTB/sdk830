
include $(PRJROOT)/etc/envvars.mk

ROOTFS_OUTPUT_DIR := $(PACKAGES_DIR)/buildroot/output_rootfs
LINUXTV_VERSION := $(shell grep "^LINUXTV_VERSION" $(PACKAGES_DIR)/buildroot/package/elecard/linuxtv/linuxtv.mk | sed "s/^LINUXTV_VERSION.*= *//")
LINUXTV_PATH := $(ROOTFS_OUTPUT_DIR)/build/linuxtv-$(LINUXTV_VERSION)

ADD_LINUXTV_ENV := n

# get_config_variable - return value of variable setted in config file
#   1 - variable name
#   2 - config file
get_config_variable = $(shell grep -E "^$1=" $2 | cut -d = -f 2)

get_rootfs_config_variable = $(call get_config_variable,$1,$(ROOTFS_OUTPUT_DIR)/.config)
get_linuxtv_config_variable = $(if $(call get_rootfs_config_variable,BR2_PACKAGE_LINUXTV),$(call get_config_variable,$1,$(LINUXTV_PATH)/v4l/.config))

