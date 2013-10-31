# ****************************************************************************
# File Name   : compile.mk
# Copyright (C) 2013 Elecard Devices
# *****************************************************************************
#
# Include this file and define minimum variables:
# 	PROGRAM_NAME or LIB_NAME_STATIC or LIB_NAME_SHARED
# 	C_SOURCES, CXX_SOURCES
#
# Optional variables, defined in makefile:
#	LOCAL_CFLAGS, LOCAL_CXXFLAGS, LOCAL_LDFLAGS
#	ADD_LIBS
#
# External variables, setted from called programm:
#	ARCH
#	CFLAGS, CXXFLAGS, LDFLAGS
#

# Force use bash
SHELL := /bin/bash

ifeq ($(ARCH),)
    ARCH=x86
else
    CROSS_COMPILE?=$(ARCH)-linux-
endif
BUILD_DIR?=$(ARCH)

CC=$(CROSS_COMPILE)gcc
CXX=$(CROSS_COMPILE)g++
AR=$(CROSS_COMPILE)ar
LD=$(CROSS_COMPILE)gcc

CFLAGS += -Wall -Wextra $(LOCAL_CFLAGS)
CXXFLAGS += -Wall -Wextra $(LOCAL_CXXFLAGS)
LDFLAGS += $(LOCAL_LDFLAGS)


## Default target, must be first ##
all: build

PHONY += all build install clean force
V ?= 0
ifeq ($(V),1)
  quiet=
  Q = 
else
  quiet=quiet_
  Q = @
endif
squote := '
escsq = $(subst $(squote),'\$(squote)',$1)
get_cmd_file = $(dir $1).$(notdir $1).cmd
get_cmd_file_4target = $(call get_cmd_file,$@)

any-prereq = $(filter-out $(PHONY),$?) $(filter-out $(PHONY) $(wildcard $^),$^)
arg-check = $(strip $(filter-out $(cmd_$(1)), $(cmd_$@)) \
                    $(filter-out $(cmd_$@),   $(cmd_$(1))) )

echo-cmd = $(if $($(quiet)cmd_$(1)),\
	echo '  $(call escsq,$($(quiet)cmd_$(1)))$(echo-why)';)

make-cmd = $(subst \#,\\\#,$(subst $$,$$$$,$(call escsq,$(cmd_$(1)))))

if_changed = $(if $(strip $(any-prereq) $(arg-check)),					\
	@set -e;									\
	rm -f $(get_cmd_file_4target);							\
	$(echo-cmd) $(cmd_$(1));							\
	if [ -e "$(get_cmd_file_4target)" ]; then					\
		sed -i "s%.*:%deps_$@ :=%" $(get_cmd_file_4target);			\
		echo -e "\n$@: \$$(deps_$@)\n\$$(deps_$@):" >>$(get_cmd_file_4target);	\
	fi;										\
	echo -e '\n\ncmd_$@ := $(make-cmd)' >> $(get_cmd_file_4target);)

#	echo "$(any-prereq) $(arg-check)"; \


GEN_DEP_FILE_FLAGS = -MD -MF $(get_cmd_file_4target)
## C compiler
quiet_cmd_cc_o_c = CC $@
cmd_cc_o_c = $(CC) $(GEN_DEP_FILE_FLAGS) $(CFLAGS) $(SEP_FLAGS_$(notdir $<)) -c $< -o $@
## C++ compiler
quiet_cmd_cxx_o_cpp = CPP $@
cmd_cxx_o_cpp = $(CXX) $(GEN_DEP_FILE_FLAGS) $(CXXFLAGS) $(SEP_FLAGS_$(notdir $<)) -c $< -o $@

## linker
quiet_cmd_ld_out_o = LD $@
cmd_ld_out_o = $(LD) -o $@ $(OBJECTS) $(ADD_LIBS) $(LDFLAGS)
## archivator
quiet_cmd_archive_o = AR $@
cmd_archive_o = $(AR) rcs $@ $(filter-out $(PHONY) $(DIRECTORIES),$^)


$(BUILD_DIR)/%.o: %.c force
	$(call if_changed,cc_o_c)

$(BUILD_DIR)/%.o: %.cpp force
	$(call if_changed,cxx_o_cpp)

force:
.PHONY: $(PHONY)

