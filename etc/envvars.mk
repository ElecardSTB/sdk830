

ifneq "$(__ENVVARS_DEFINED__)" "y"
export __ENVVARS_DEFINED__:=y

define ECHO_SETUP_ENVIRONMENT_MESSAGE
$(info === For SDK build:)
$(info source <SDK_PATH>/SDK_stb830_setup.sh)
$(info === For FULL build:)
$(info source <SDK_PATH>/setup_stb830.sh)
$(error )
endef

# Variable: PRJROOT
# The root of the project tree. All makefiles must be inside this root.
# Must be set by the environment.
ifeq "$(origin PRJROOT)" "undefined"
$(info === Variable PRJROOT not set: root of the project)
$(info === Setup environment first.)
$(ECHO_SETUP_ENVIRONMENT_MESSAGE)
endif

# Variable: BUILDROOT
# The directory in which all build results are stored.
# Must be set by the environment.
ifeq "$(origin BUILDROOT)" "undefined"
$(info === Variable BUILDROOT not set: directory uses for building)
$(info === Setup environment first.)
$(ECHO_SETUP_ENVIRONMENT_MESSAGE)
endif

# File: $(BUILDROOT)/timestamps/.stamp_validenvironment
# Timestamp that identify validity curent config.
# It can be removed from scripts, for force resetup environment.
ifeq "$(wildcard $(BUILDROOT)/timestamps/.stamp_validenvironment)" ""
$(info === Environment is obsolete! Please setup environment again.)
$(ECHO_SETUP_ENVIRONMENT_MESSAGE)
endif

ifeq "$(wildcard $(BUILDROOT)/.prjconfig)" ""
$(info === $(BUILDROOT)/.prjconfig does not exist!)
$(info === Setup environment first.)
$(ECHO_SETUP_ENVIRONMENT_MESSAGE)
endif

ifneq ($(shell grep "CONFIG_VERSION" $(PRJROOT)/etc/configs/config_stb830_template), $(shell grep "CONFIG_VERSION" $(BUILDROOT)/.prjconfig))
$(info === Build configuration is updated! Please setup environment again!!!)
$(ECHO_SETUP_ENVIRONMENT_MESSAGE)
endif

endif #ifneq $(__ENVVARS_DEFINED__) "y"

define ECHO_MESSAGE
	@echo
	@echo   "************************************************************************"
	@printf "##   %-65s##\n" "$(1)"
	@echo   "************************************************************************"
endef

TARBALLS_DIR := $(PRJROOT)/tarballs
FIRMWARE_DIR := $(BUILDROOT)/firmware
COMPONENT_DIR := $(BUILDROOT)/comps
TIMESTAMPS_DIR := $(BUILDROOT)/timestamps
PACKAGES_DIR := $(BUILDROOT)/packages
SDK_PACKAGES_DIR := $(BUILDROOT)/sdk_packages

#define first default target
all:
