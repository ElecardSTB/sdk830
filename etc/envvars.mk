

ifneq "$(__ENVVARS_DEFINED__)" "y"
export __ENVVARS_DEFINED__:=y

# Variable: PRJROOT
# The root of the project tree. All makefiles must be inside this root.
# Must be set by the environment.
ifeq "$(origin PRJROOT)" "undefined"
$(info === Variable PRJROOT not set: root of the project)
$(error )
endif

# Variable: BUILDROOT
# The directory in which all build results are stored.
# Must be set by the environment.
ifeq "$(origin BUILDROOT)" "undefined"
$(info === Variable BUILDROOT not set: directory uses for building)
$(error )
endif


ifeq "$(wildcard $(BUILDROOT)/.prjconfig)" ""
$(info === $(BUILDROOT)/.prjconfig does not exist!)
$(info === Setup environment first:)
$(info . ./setup_stb830.sh $(notdir $(BUILDROOT)))
$(error )
endif

ifneq ($(shell grep "CONFIG_VERSION" $(PRJROOT)/etc/configs/config_stb830_template), $(shell grep "CONFIG_VERSION" $(BUILDROOT)/.prjconfig))
$(info === Configuration is updated! You should reset stb830 environment!!!)
$(info === Please run next command in $(PRJROOT):)
$(info . ./setup_stb830.sh $(notdir $(BUILDROOT)))
$(error )
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
