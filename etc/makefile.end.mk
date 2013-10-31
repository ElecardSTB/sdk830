# ****************************************************************************
# File Name   : compile_end.mk
# Copyright (C) 2013 Elecard Devices
# *****************************************************************************


OBJECTS := $(patsubst %.c,$(BUILD_DIR)/%.o,$(C_SOURCES))
OBJECTS += $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(CXX_SOURCES))
OBJECTS_DIRS := $(sort $(BUILD_DIR)/ $(dir $(OBJECTS)))
DIRECTORIES += $(OBJECTS_DIRS)

$(OBJECTS): | $(OBJECTS_DIRS)

$(DIRECTORIES):
	$(Q)mkdir -p $@

TARGETS :=

# program
ifneq ($(PROGRAM_NAME),)
TARGET_PROGRAMM := $(BUILD_DIR)/$(PROGRAM_NAME)
$(TARGET_PROGRAMM): $(OBJECTS) $(ADD_LIBS) $(DEPENDS_EXTRA) force
	$(call if_changed,ld_out_o)
TARGETS += $(TARGET_PROGRAMM)
endif

# static library
ifneq ($(LIB_NAME_STATIC),)
TARGET_LIB_STATIC := $(BUILD_DIR)/$(LIB_NAME_STATIC)
$(TARGET_LIB_STATIC): $(OBJECTS) $(ADD_LIBS) $(DEPENDS_EXTRA) force
	$(call if_changed,archive_o)
TARGETS += $(TARGET_LIB_STATIC)
endif

# shared library
ifneq ($(LIB_NAME_SHARED),)
TARGET_LIB_SHARED := $(BUILD_DIR)/$(LIB_NAME_SHARED)
$(TARGET_LIB_SHARED): LDFLAGS += -shared
$(TARGET_LIB_SHARED): $(OBJECTS) $(ADD_LIBS) $(DEPENDS_EXTRA) force
	$(call if_changed,ld_out_o)
TARGETS += $(TARGET_LIB_SHARED)
endif

cmd_files += $(wildcard $(foreach f,$(OBJECTS) $(TARGETS),$(call get_cmd_file,$(f))))
ifneq ($(cmd_files),)
  include $(cmd_files)
endif

build: $(TARGETS)

clean:
	rm -f $(ADD_LIBS) $(OBJECTS) $(cmd_files) $(TARGETS)

install:
	@echo "Nothing to install yet. Fix it!!!"

