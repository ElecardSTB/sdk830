#
#                             IPSTB Project
#                   ---------------------------------
#
# Copyright (C) 2009 NXP B.V.,
# All Rights Reserved.
#
# Filename: util.mk
#
#
# Rev Date        Author      Comments
#-------------------------------------------------------------------------------
#  10 20061025    batelaan    Use new varutil.mk file (split off so it can be used in SDE2).
#  11 20070124    batelaan    Update BUILDCONFIG_ID for new build tree; Add STBPLF variable.
#                             Add BUILDCONFIG_ID_ENDIAN_INDEPENDENT.
#  12 20070419    batelaan    Cygwin/Windows port of HOSTIP.
#  13 20070620    batelaan    Cope with cygwin.
#  14 20070629    batelaan    Remove check for current dir versus PRJROOT, too many problems
#                             with it (symlinks, Windows, Cygwin). Hardly ever useful anyway.
#  15 20070706    batelaan    Add CONFIG_DEPENDENT_* macros.
#  15.1 20070831  steel       remove HOSTIP 127.0.0.1 check as it kills standalone laptop builds
#  16 20070823    batelaan    Add <PKG> BEFORE and AFTER customisation calls.
#                             Removed unused HOSTIP variable. Doc update.
#  17 20070904    amccurdy    Merge redundant r15.1 back into r16
#  17 20070904    barnish     Merged 15.1 & 16
#  18 20070905    amccurdy    Merge Soton r17 into r17
#  19 20080213    batelaan    Add ci release spec file stuff.
#  20 20080527    batelaan    Add CHECK_FILE_IS_NOT_CHANGED and CONFEDIT macros.
#  21 20080619    batelaan    Use prjfilter on ci_release_spec_file file.
#  22 20081009    batelaan    Make CONF_EDIT macros correct.
#  23 20081015    batelaan    Add CHECK_MAKE_OLDCONFIG_ERRORS
#  24 20081210    amccurdy    Improve warnings filtering in CHECK_MAKE_OLDCONFIG_ERRORS
#  24 20081209    batelaan    Merge with caen version 22.
#  25 20090116    batelaan    Improve and document printdeps target.
#  26 20090123    batelaan    merge v24/amccurdy
#  27 20090123    batelaan    Fix grep error (missing -E)
#  28 20090227    amccurdy    Filter more warnings in CHECK_MAKE_OLDCONFIG_ERRORS, improve comment wording.
#  29 20090327    batelaan    Add GET_TOOLCHAIN_SETUP_FILE macro

# File: util.mk
# General make utility macros and functions.

include $(PRJROOT)/etc/varutil.mk
help.util::help.varutil


# Variable: STB_DISTCC_OPTIONS
# If not defined then define as empty. Certain makefiles will benefit from
# faster compilation with DISTCC.
STB_DISTCC_OPTIONS ?=

# Variable: V
# Verbose flag. If empty (the default) then commands may not be printed
# (see <Q>). If not empty, then echo commands. It also sets <_TMECHO>
# in if verbose mode.
V=

help.util::
	@printf "V=1\t\t\t- If set then be verbose (prints all commands)\n"

# Define: Q
# Used for controlling the printing of commands.
# If in verbose mode (<V> not empty), then Q is empty, otherwise it is @.
# Use this at the beginning of a Make command line: the command won't be
# printed out if Q expands to @.
Q=$(if $V,,@)

# Define: _TMECHO
# Controls verbosity of SDE2 builds. Exported as an environment variable
# if <V> is not empty.
ifneq ($(V),)
  export _TMECHO=1
endif

# Indent for TRACE macro. Updated by INCLUDE_MAKEFILE
INDENT=

INDENT_INCR=$(eval INDENT:=__$(INDENT))
INDENT_DECR=$(eval INDENT:=$(patsubst __%,%,$(INDENT)))

help.util::
	@printf "TRACE=1\t\t\t- If set then traces certain makefile constructs\n"
# Variable: TRACE
# If defined and non-empty, then makefile tracing is enabled using <DOTRACE>.
# Expands to an empty string, to can be called anywhere.
# Usage:
# shell> make TRACE=1 ...
TRACE=

# Function: DOTRACE
# Makefile tracing. If <TRACE> is non-empty, the argument will be printed
# to stderr, using the echo command. Messages are automatically indented by
# their makefile include nesting (see <INCLUDE_MAKEFILE>).
#
# Example:
# $(call DOTRACE,'message....')
DOTRACE = $(if $(TRACE),$(shell echo '$(subst __,  ,$(INDENT))'$(1) 1>&2))

# Define: FORCE
# Set to true if 'force' is specified as one of the make command line arguments.
# Otherwise empty.
FORCE:=$(if $(filter force,$(MAKECMDGOALS)),true)

# Target: force
# Targets defined with <OBJ_TARGETSETUP> (or its derivatives)
# will be 'forced' when they appear on the make command line.
# This means that they will be executed again, whether or not
# they have run successfully before.
force: ;
.PHONY: force

# Define: NODEPS
# Set to true if 'nodeps' is specified as one of the make command line arguments.
# Otherwise empty.
NODEPS:=$(if $(filter nodeps,$(MAKECMDGOALS)),true)
nodeps:; @true
.PHONY: nodeps

# Define: IFNOEXEC
# Expands to 'true' if the -n option has been passed, otherwise it is empty.
IFNOEXEC := $(if $(findstring n,$(word 1,$(MAKEFLAGS))),true)

# Define: ECHOIFNOEXEC
# Expands to 'echo' if the -n option has been passed.
# Useful in $(shell $(ECHOIFNOEXEC) command ...) constructs.
ECHOIFNOEXEC := $(if $(findstring n,$(word 1,$(MAKEFLAGS))),echo 1>&2)

# Define: YYMMDD_HHMM
# Output of date command giving a 'unique' string.
#
# Note:
# May return a different value everytime referenced.
#
# See Also:
# <YYMMDD_HHMMSS>
YYMMDD_HHMM = $(shell date '+%y%m%d_%H%M')

# Define: YYMMDD_HHMMSS
# Output of date command giving a 'unique' string.
#
# Note:
# May return a different value everytime referenced.
#
# See Also:
# <YYMMDD_HHMM>
YYMMDD_HHMMSS = $(shell date '+%y%m%d_%H%M%S')

# Variable: SUDO
# Execute a command as a superuser.
#
# If user has "sudo" capability, then SUDO should expand to sudo. Otherwise, it should have been
# defined externally. Thus SUDO is only set to sudo here if SUDO is not yet defined.
# The external definition can then be a script that circumvents the need for the sudo capability.
# Usage: $(SUDO) command....
ifeq "$(origin SUDO)" "undefined"
  SUDO = sudo
endif

# Macro: LIST2INDENTEDLINES
# A perl one-liner which converts a list of words on stdin to an indented list of lines on stdout.
# Each word is printed on a separate line preceded with a tab character.
#
# Example: echo '$(ALL_ORDER)' | $(LIST2INDENTEDLINES)
LIST2INDENTEDLINES=perl -pe 's/^ *| +/\n\t/g;'

# Macro: MAKECMD
# Same as '$(MAKE) -$(MAKEFLAGS)', except that if one runs "make -n" to see what make would execute,
# using $(MAKECMD) on a target's command line should not invoke the command line
# (using $(MAKE) is invoked even if -n is used).
MAKECMD := $(MAKE) -$(MAKEFLAGS)

# Macro: CHECK_FILE_IS_NOT_CHANGED
# Checks that a file (argument 1) has not changed relative to
# a reference copy (argument 2) of the file.
# If it has, it prints an error message,
# executes the shell statements of argument 3,
# and exits with an error code.
#
# Usage: $(call CHECK_FILE_IS_NOT_CHANGED,filename,refcopy,echo "Advice on what to do...")
CHECK_FILE_IS_NOT_CHANGED=$(call CHECK_FILE_IS_NOT_CHANGED1,$(strip $1),$(strip $2),$(strip $3))
define CHECK_FILE_IS_NOT_CHANGED1
	if [ -f $1 -a -f $2 ] && ! cmp -s $1 $2; then \
		printf "\n**ERROR: File $1 has changed!\n"; \
		printf "    (compared with $2)\n"; \
		$3; \
		exit 1; \
	fi
endef

################################################################################
# Config File Modification
################################################################################

# $1 = always a directory, e.g. $(KSRC)
# See also perllib/ConfEdit.pm
CONFEDIT_INIT            = cd $1 && printf 'use ConfEdit;\nrun();\n__DATA__\n' >confedit.pl && cp -f $2 .config.tmp
CONFEDIT_EXECUTE 	 = \
  cd $1 && perl -w confedit.pl < .config.tmp > .config.tmp2 && \
  if ! cmp -s .config.tmp2 .config; then \
    test -f .config && mv -f .config .config_`date '+%Y%m%d_%H%M%S'`; \
    cp -f .config.tmp2 .config || exit 1; \
  fi
# $2 is a variable name to set to y
CONFEDIT_SET             = echo >>$(strip $1)/confedit.pl 'SET $(strip $2)'

# $2 is a variable name to set to m
CONFEDIT_SET_M           = echo >>$(strip $1)/confedit.pl 'SET_M $(strip $2)'

# $2 is a variable name to set to a string value $3
CONFEDIT_SET_STRING      = echo >>$(strip $1)/confedit.pl 'SET_STRING $(strip $2) $(strip $3)'

# $2 is a variable name to set to a string value calculated by doing a Perl eval on $3,
# with $_ set to the current value (undef if not defined).
CONFEDIT_SET_STRING_EVAL = echo >>$(strip $1)/confedit.pl 'SET_STRING_EVAL $(strip $2) $(strip $3)'

# $2 is a variable name to set to an empty string
CONFEDIT_CLEAR_STRING    = echo >>$(strip $1)/confedit.pl 'CLEAR_STRING $(strip $2)'

# $2 is a variable name to unset
CONFEDIT_UNSET           = echo >>$(strip $1)/confedit.pl 'UNSET $(strip $2)'

# $2 is a variable name to delete
CONFEDIT_DELETE          = echo >>$(strip $1)/confedit.pl 'DELETE $(strip $2)'

# $2 is a variable name after which variable $3 is to be set to value $4
CONFEDIT_ADD_AFTER_RAW   = echo >>$(strip $1)/confedit.pl 'ADD_AFTER_RAW $(strip $2) $(strip $3)'

# $2 is a variable name after which variable $3 is to be set to y
CONFEDIT_ADD_AFTER_SET   = echo >>$(strip $1)/confedit.pl 'ADD_AFTER_SET $(strip $2) $(strip $3)'

# $2 is a variable name after which variable $3 is to be unset
CONFEDIT_ADD_AFTER_UNSET = echo >>$(strip $1)/confedit.pl 'ADD_AFTER_UNSET $(strip $2) $(strip $3)'

# Do not do anything.
CONFEDIT_NOP =

################################################################################
# Macro: CHECK_MAKE_OLDCONFIG_ERRORS
# Checks that the error file (pathname: "$2/$3") is empty (or contains only warnings).
# If not, then print error message mentioning $1 and abort the build.
#
# Example: $(call CHECK_MAKE_OLDCONFIG_ERRORS,Linux make oldconfig,$(KSRC),oldconfig.err)

CHECK_MAKE_OLDCONFIG_ERRORS = \
	cd $2 && if [ `grep -E -v '\.c:[0-9][0-9]*: warning:|\.c: At top level|\.c: In function|In file included from' $3 | wc -l` != 0 ]; then \
		echo '**ERROR: warnings detected during $1! These are:'; \
		cat $3; \
		echo 'See $(strip $2)/$3'; \
		exit 1; \
	fi

################################################################################
# Makefile Including
################################################################################

# Define: THISDIR
# The absolute directory of the current Makefile. Should not be used in
# recursively expanded macro definitions or target command lines
# (consider using <xxx_SRCDIR> instead).
THISDIR:=$(CURDIR)

DIRSTACK:=

THIS_MAKEFILE := $(word 1,$(MAKEFILE_LIST))
MAKEFILE_STACK := $(THIS_MAKEFILE)

# Function: INCLUDE_MAKEFILE
# Included another Makefile. Path can be relative or absolute.
#
# Example:
# $(call INCLUDE_MAKEFILE, subdir/Makefile)
#
# See also:
# - <INCLUDE_MAKEFILES>
# - <INCLUDE_SUBDIR_FILES>
# - <INCLUDE_SUBDIR_FILESX>
INCLUDE_MAKEFILE = $(eval $(value INCLUDE_MAKEFILE1))
define INCLUDE_MAKEFILE1
  THIS_MAKEFILE := $(word 1,$(wildcard $(THISDIR)/$(strip $(1))) $(wildcard $(1)))
  MAKEFILE_STACK := $(THIS_MAKEFILE) $(MAKEFILE_STACK)
  DIRSTACK := $(THISDIR) $(DIRSTACK)
  THISDIR:=$(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
  INDENT:=__$(INDENT)
  $(call DOTRACE,'>>$(THIS_MAKEFILE)')
  include $(THIS_MAKEFILE)
  THISDIR := $(word 1,$(DIRSTACK))
  DIRSTACK := $(wordlist 2,999999,$(DIRSTACK))
  $(call DOTRACE,'<<$(THIS_MAKEFILE)')
  INDENT:=$(patsubst __%,%,$(INDENT))
  THIS_MAKEFILE := $(word 1,$(MAKEFILE_STACK))
  MAKEFILE_STACK := $(wordlist 2,999999,$(MAKEFILE_STACK))
endef

# Function: INCLUDE_MAKEFILES
# Include all files specified.
#
# Example:
# $(call INCLUDE_MAKEFILES, file1 file2...)
#
# See also:
# - <INCLUDE_MAKEFILE>
# - <INCLUDE_SUBDIR_FILES>
# - <INCLUDE_SUBDIR_FILESX>
INCLUDE_MAKEFILES = $(foreach f,$(1),$(call INCLUDE_MAKEFILE, $(f)))

# Function: INCLUDE_SUBDIR_FILES
# Include all files that match in subdirectories.
#
# Example:
# $(call INCLUDE_SUBDIR_FILES, Makefile)
#
# See also:
# - <INCLUDE_MAKEFILE>
# - <INCLUDE_MAKEFILES>
# - <INCLUDE_SUBDIR_FILESX>
INCLUDE_SUBDIR_FILES = $(foreach f,$(sort $(wildcard $(THISDIR)/*/$(strip $(1)))),$(call INCLUDE_MAKEFILE, $(f)))

# Function: INCLUDE_SUBDIR_FILESX
# Include all files that match in subdirectories, except those specified.
#
# Example:
# $(call INCLUDE_SUBDIR_FILESX, Makefile, subdir1/Makefile ...)
#
# See also:
# - <INCLUDE_MAKEFILE>
# - <INCLUDE_MAKEFILES>
# - <INCLUDE_SUBDIR_FILES>
INCLUDE_SUBDIR_FILESX = \
$(foreach f,\
          $(filter-out $(foreach x,$(2),$(wildcard $(THISDIR)/$(strip $x))),\
		               $(sort $(wildcard $(THISDIR)/*/$(strip $(1))))\
		    ),\
		  $(call INCLUDE_MAKEFILE, $(f))\
)

################################################################################

# Target: shell
# Runs an interactive shell, so one could see what the environment is that commands
# are executed in by make.
#
# If variable cmd exists, then execute its value, and return.
# Otherwise run /bin/bash.
shell:
	$(Q)PS1="(In Make!)-\!: " \
	$(if $(cmd),\
	  $(if $(findstring s,$(MAKEFLAGS)),,\
	    printf '\n\n\n ***** Invoking command(s) ****\n    $(cmd)\n\n';)$(cmd),\
	  $(if $(findstring s,$(MAKEFLAGS)),,\
	    printf '\n\n\n ***** Invoking sub-shell ****\n\n\n';)/bin/bash)
help.util::
	@printf "shell\t\t\t- Runs an interactive shell, so one could see what the environment is that commands are executed in by make.\n"
	@printf "\t\t\t  If argument cmd=... then just run the command specified.\n"

################################################################################
# TIMESTAMP FILES FOR DEPENDENCY TRACKING
################################################################################

# Define: TSDIR
# Directory where timestamp files are stored, which indicate
# whether a make target has been completed. Default value is {<BUILDROOT>}/timestamps
TSDIR=$(firstword $(CPUBUILDROOT) $(BUILDROOT))/timestamps
$(shell mkdir -p $(TSDIR))

# Function: TSFILE
# Expands to the timestamp file for a make target. Argument: a make target.
#
# See: <TSDIR>
TSFILE=$(TSDIR)/$(strip $(1))

# Define: TSSET
# Command to touch a timestamp file. Argument: a make target.
#
# See: <TSFILE> <TSUNSET>
TSSET=mkdir -p $(TSDIR); /bin/touch $(call TSFILE,$(1))

# Define: TSUNSET
# Command to remove a timestamp file. Argument: a make target.
#
# See: <TSFILE> <TSSET>
TSUNSET=rm -f $(call TSFILE,$(1))

ifneq "$(TSDIR)" ""
  clean::
	$(Q)rm -rf $(TSDIR); mkdir -p $(TSDIR)
endif

# Define: OBJ_TARGETSETUP
# Creates a make goal ($1, also called <ttt>), which depends on $2.
# If the goal is executed it:-
# - runs <USERRCCMD> with argument $1_BEFORE
# - executes contents of optional $(1)_CMDSBEFORE variable
# - executes contents of required $(1)_CMDS variable
# - executes contents of optional $(1)_CMDSAFTER variable
# - runs <USERRCCMD> with argument $1_AFTER
#
# Arguments:-
# - target name
# - dependency names (may be empty)
# - object type (PKG|MODULE)
#
# Usually called from <PKG_TARGET> or <MODULE_TARGET>.
#
# See also: <OBJ_TARGET_DEPS> <OBJ_TARGET_OTHER_DEPS>
define OBJ_TARGETSETUP
  $(eval OBJTYPE=$(3))
  $(eval OBJNAME=$($(OBJTYPE)))
  $(call DOTRACE,'Defining $(OBJTYPE)/$(OBJNAME) target $(1) (depends on $(2))')
  ifeq "$(origin $(1)_CMDS)" "undefined"
    $$(error $(1)_CMDS is undefined)
  endif
  $(1): $(call TSFILE,$(1))
  $(call TSFILE,$(1)): $(if $(NODEPS),,$(if $(2),$(foreach d,$(2),$(call TSFILE,$d))))
  $(if $(filter $(1),$(MAKECMDGOALS)),$(if $(IFNOEXEC),$(call TSFILE,$(1)):force)$(shell $(ECHOIFNOEXEC) $(call TSUNSET,$(1)) 1>&2))
  $(call TSFILE,$(1)):
	@echo; echo; echo "############################## $(strip $(1)) ##############################"
	@if [ -e $(call TSFILE,$(1)) -a "$$($(1)_OK2RERUN)" != "true" ]; then \
	  echo '$(1) - out of date, but $$$$($(1)_OK2RERUN) != true'; \
	  echo 'Please run $(OBJNAME).clean first, then rebuild.'; \
	  exit 1; \
	fi
	$$(call USERRCCMD,$(1)_BEFORE)
	$$($(1)_CMDSBEFORE)
	$$($(1)_CMDS)
	$$($(1)_CMDSAFTER)
	$$(call USERRCCMD,$(1)_AFTER)
	$(Q)$(call TSSET,$(1))
  .PHONY: $(1)
  $(1)_CMDSBEFORE?=
  $(1)_CMDSAFTER?=
  $(1)_OK2RERUN?=true
  $($(OBJTYPE))_MAKETARGETS += $(1)
  $(1)_DEPENDENCIES += $(2)
endef

# Name: ttt_BEFORE
# Argument passed to <USERRCCMD>, at the very start of the commands for <ttt>.
# Runs before <ttt_CMDSBEFORE>.

# Define: ttt_CMDSBEFORE
# Optional shell commands to execute for target <ttt>, as defined by <OBJ_TARGETSETUP>.
# Runs before <ttt_CMDS>.
# Can be a single or multiline define.

# Define: ttt_CMDS
# Shell commands to execute for target <ttt>, as defined by <OBJ_TARGETSETUP>.
# Can be a single or multiline define.

# Define: ttt_CMDSAFTER
# Optional shell commands to execute for target <ttt>, as defined by <OBJ_TARGETSETUP>.
# Runs after <ttt_CMDS>.
# Can be a single or multiline define.

# Name: ttt_AFTER
# Argument passed to <USERRCCMD>, at the very end of the commands for <ttt>.
# Runs after <ttt_CMDSAFTER>.

# Define: ttt
# Placeholder for a make target name.
# For example, linux.make rootfs.copy buildroot.untar .
# Defined by <OBJ_TARGETSETUP>.

# Define: ttt_OK2RERUN
# If true, then target ttt (as defined by <OBJ_TARGETSETUP>)
# can be automatically remade if it is out of date.
# Otherwise the user is told that he has to clean the item first.
#
# Default value is true.

# Define: ttt_DEPENDENCIES
# List of dependencies of target ttt, if ttt is defined by
# <OBJ_TARGETSETUP>.

# Function: OBJ_TARGET_DEPS
# Specifies dependencies between targets declared with the special macros.
#
# Usage: $(call OBJ_TARGET_DEPS,target, dependent1...)
#
# See also: <OBJ_TARGET_OTHER_DEPS>
OBJ_TARGET_DEPS=$(eval $(call TSFILE,$(1)): $(foreach d,$(2),$(call TSFILE,$(d))))$(eval $(strip $(1))_DEPENDENCIES += $(2))

# Function: OBJ_TARGET_OTHER_DEPS
# Specifies dependencies between a target and anything not declared with a special macro
# (see also <OBJ_TARGET_DEPS>).
#
# Usage: $(call OBJ_TARGET_OTHER_DEPS,target, dependent1...)
OBJ_TARGET_OTHER_DEPS=$(eval $(call TSFILE,$(1)): $(2))$(eval $(strip $(1))_DEPENDENCIES += $(2))

# Function: OBJ_TARGET_OVERRIDES
# Specifies variable overrides for a target ttt (as defined by <OBJ_TARGETSETUP>).
# Must be executed before <OBJ_TARGETSETUP>.
#
# Usage: $(call OBJ_TARGET_OVERRIDES,target, var1=value1 var=value2 ...)
OBJ_TARGET_OVERRIDES=$(foreach override,$(value 2),\
	$(call DOTRACE,'OVERRIDE setup $1 $(value override)')\
	$(eval $(1): $(override))\
	$(eval $(call TSFILE,$(1)): $(override))\
	$(eval $(1): dummy=$$(call DOTRACE,'OVERRIDE $(1) $(value override)'))\
	$(eval $(call TSFILE,$(1)): dummy=$$(call DOTRACE,'OVERRIDE $(call TSFILE,$(1)) $(value override)')))

# Function: OBJ_AUTO_FORCE_DEPS
# Ensures that when target arg1 is currently in <MAKECMDGOALS> (i.e. specified on the command line),
# that all arg1's dependencies will also be 'forced' (see <force>).
#
# Calls <OBJ_AUTO_FORCE> with argument <ttt_DEPENDENCIES>.
#
# Usage: $(call OBJ_AUTO_FORCE_DEPS, ttt)
OBJ_AUTO_FORCE_DEPS=$(call OBJ_AUTO_FORCE,$(strip $(1)),$($(strip $(1))_DEPENDENCIES))

# Target: OBJ_AUTO_FORCE
# Ensures that if target arg1 is currently in <MAKECMDGOALS> (i.e. specified on the command line),
# that the list of targets specified by arg2 will also be 'forced' (see <force>).
#
# Usage: $(call OBJ_AUTO_FORCE,ttt,aaa bbb ccc ...)
OBJ_AUTO_FORCE=$(if $(filter $(strip $(1)),$(MAKECMDGOALS)),$(call OBJ_FORCE,$(2)))

# Function: OBJ_FORCE_DEPS
# Ensures that all ttt's dependencies are be 'forced' (see <force>).
#
# Calls <OBJ_FORCE> with <ttt_DEPENDENCIES>.
#
# Usage: $(call OBJ_FORCE_DEPS, ttt)
OBJ_FORCE_DEPS=$(call OBJ_FORCE,$($(strip $(1))_DEPENDENCIES))

# Target: OBJ_FORCE
# Ensure that the list of targets specified by arg1 is 'forced' (see <force>).
# Calls <OBJ_FORCE1> for each target.
#
# Usage: $(call OBJ_FORCE,aaa bbb ccc)
OBJ_FORCE=$(foreach t,$(1),$(call OBJ_FORCE1,$(t)))

# Target: OBJ_FORCE1
# Ensure that the target arg1 is 'forced' (see <force>).
# This is implemented by making the timestamp file (see <TSFILE>) for arg1 dependent on target <force>.
#
# Usage: $(call OBJ_FORCE1,ttt)
OBJ_FORCE1=$(eval $(call TSFILE,$(1)): force)

# Target: printdeps
# Prints indented dependency tree for target given by make variable t.
#
# Usage: make printdeps t=someTargetName
printdeps:
	$(call CHECK_VAR_DEFINED,t,make printdeps t=someTargetName)
	$(call PRINTDEPS,$(t),)
# Usage: $(call PRINTDEPS,ttt,indentation)
PRINTDEPS=$(shell echo "$(2)$(1)" 1>&2)$(foreach d,$($(1)_DEPENDENCIES),\
  $(if $(printdeps.done.$(1)),$(shell echo "    $(2)$(d) (see above)" 1>&2),$(call PRINTDEPS,$(d),    $(2))))$(eval printdeps.done.$(1)=1)
help.util::
	@printf '%-23s - %s\n' 'printdeps t=xxx.yyy' 'Prints indented dependency tree for package given by t.'
	@printf '%-23s - %s\n' '' 'Example: printdeps t=linux.make'

# Function: OBJ_EXPAND_DEPENDENCIES
# Expands a package or other type of object (e.g. module) into a list of dependency targets.
#
# Example: $(call OBJ_EXPAND_DEPENDENCIES,DirectFB)
#
# See also: <OBJ_TGT_EXPAND_DEPENDENCIES>
OBJ_EXPAND_DEPENDENCIES=$(foreach t,$($(strip $(1))_MAKETARGETS),$(call OBJ_TGT_EXPAND_DEPENDENCIES,$(t)))

# Function: OBJ_TGT_EXPAND_DEPENDENCIES
# Expands a target of a package or other type of object (e.g. module) into a list of dependency targets.
#
# Example: $(call OBJ_TGT_EXPAND_DEPENDENCIES,DirectFB.config)
#
# See also: <OBJ_EXPAND_DEPENDENCIES>
OBJ_TGT_EXPAND_DEPENDENCIES=$(foreach t,$($(strip $(1))_DEPENDENCIES),$(t) $(call OBJ_TGT_EXPAND_DEPENDENCIES,$(t)))

# Macro: _TMDIVERSITY.addValue
# Expands to makefile text which when evaluated would add $1 to
# environment variable _TMDIVERSITY as a target specific variable.
# It will expect $(target) to contain the target name.
#
# $1 may or may not have surrounding underscores.
#
# Example:-
# $(call _TMDIVERSITY.addValue,pnx8335x)
_TMDIVERSITY.addValue=$(call _TMDIVERSITY.addValue1,$(strip $1))
define _TMDIVERSITY.addValue1
  $(call DOTRACE,'Appending $1 to _TMDIVERSITY')
  $(target): _TMDIVERSITY:=$$(subst __,_,$$(_TMDIVERSITY)_$(1)_)
endef

# Macro: CONFIG_DEPENDENT_FILENAMES
# Wildcard matching a filename which is considered a
# configuration-dependent alternative file.
# These files will generally be ignored unless they start with
# <CONFIG_DEPENDENT_FILENAME_PREFIX> .
CONFIG_DEPENDENT_FILENAMES=config_*.*

# Macro: CONFIG_DEPENDENT_FILENAME_PREFIX
# Prefix for a filename that indicates a configuration-dependent
# alternative file for the current configuration,
# as specified in the variable <CONFIG_NAME>.
# These files all match the <CONFIG_DEPENDENT_FILENAMES> wildcard.
CONFIG_DEPENDENT_FILENAME_PREFIX=config_$(patsubst "%",%,$(CONFIG_NAME)).

# Macro: SWPLF
# Extracts value of swplf... from <_TMDIVERSITY>, e.g. swplf225.
#
# See: <STBPLF>
SWPLF=$(filter swplf%,$(subst _,$(SPACE) $(SPACE),$(_TMDIVERSITY)))

# Macro: STBPLF
# Similar to <SWPLF>, but with swplf replaced by stb, e.g. stb225.
STBPLF=$(patsubst swplf%,stb%,$(SWPLF))

# Macro: BUILDCONFIG_ID
# Identifier for (cpu) build configuration. Consists of <STBPLF> plus relative path from <BUILDROOT> to <CPUBUILDROOT>,
# with / replaced by _.
#
# See: <BUILDCONFIG_ID_ENDIAN_INDEPENDENT>
BUILDCONFIG_ID=$(STBPLF)$(subst /,_,$(patsubst $(BUILDROOT)%,%,$(CPUBUILDROOT)))

# Macro: BUILDCONFIG_ID_ENDIAN_INDEPENDENT
# Identifier for build configuration without endianness indication.
# This is derived from <BUILDCONFIG_ID> by removing any endianness indication.
#
# See <BUILDCONFIG_ID>
BUILDCONFIG_ID_ENDIAN_INDEPENDENT=$(patsubst $(STBPLF)_$(_TMTGTENDIANX)%,$(STBPLF)%,$(BUILDCONFIG_ID))

# Variable: _TMTGTENDIAN
# SDE2 environment variable indicating CPU endianness (el/eb).

# Macro: _TMTGTENDIANX
# Reverse of SDE2 environment variable <_TMTGTENDIAN> indicating CPU endianness (le/be).

# Convert from SDE2 endianness (el/eb) to the reverse for MontaVista (le/be).
el.reverse:=le
eb.reverse:=be
le.reverse:=el
be.reverse:=eb
_TMTGTENDIANX=$($(_TMTGTENDIAN).reverse)

################################################################################
# CI release spec file
################################################################################

# Define: CI_RELEASE_SPEC_FILE
# Path to CI release spec file.
# Value is: etc/ci_release_$(<STBPLF>).spec
CI_RELEASE_SPEC_FILE = etc/ci_release_$(STBPLF).spec

# Define: CHECK_CI_RELEASE_SPEC_FILE
# Command to check that the CI release spec file is correct.
# The file (<CI_RELEASE_SPEC_FILE>) is filtered through the prjfilter command.
CHECK_CI_RELEASE_SPEC_FILE = \
  perl -MSDE2::CIReleaseSpec -e 'SDE2::CIReleaseSpec::validateFile("prjfilter <$(CI_RELEASE_SPEC_FILE)|");'

# Target: check_ci_release_spec_file
# Runs <CHECK_CI_RELEASE_SPEC_FILE>.
#
# See: <check_ci_release_spec_file_warning_only>
check_ci_release_spec_file:
	$(Q)$(CHECK_CI_RELEASE_SPEC_FILE)

# Target: check_ci_release_spec_file_warning_only
# Runs <CHECK_CI_RELEASE_SPEC_FILE>.
# Any error is ignored.
#
# See: <check_ci_release_spec_file>
check_ci_release_spec_file_warning_only:
	$(Q)-$(CHECK_CI_RELEASE_SPEC_FILE)

################################################################################
# toolchain
################################################################################

# Macro: GET_TOOLCHAIN_SETUP_FILE
# Checks if a toolchain variable is valid,
# and returns the toolchain setup file name.
#
# Usage: $(call GET_TOOLCHAIN_SETUP_FILE,varName).
#
# VarName is the name of the variable containing the toolchain name.
GET_TOOLCHAIN_SETUP_FILE=$(eval $(call CHECK_TOOLCHAIN1,$(strip $1)))$(TOOLCHAIN_SETUP_FILE)
define CHECK_TOOLCHAIN1
  TOOLCHAIN_SETUP_FILE = etc/toolchains/$(patsubst "%",%,$($1)).mk
  ifeq "$$(wildcard $$(TOOLCHAIN_SETUP_FILE))" ""
    $$(error $1 ($($1)) refers to non-existant toolchain file ($$(TOOLCHAIN_SETUP_FILE)))
  endif
endef

################################################################################
# TAR'ING
################################################################################

# Define: TAR_EXCLUDE_FILES_OPTS
# Used by target <tar> to exclude some files.
TAR_EXCLUDE_FILES_OPTS=--exclude='*\#' --exclude='*~'

# Target: tar
# Create a project_$({<YYMMDD_HHMM>}).tar.bz2 file with the contents of ${<PRJROOT>},
# except build*.
#
# See <TAR_EXCLUDE_FILES_OPTS>
tar:
	$(eval f=project_$(YYMMDD_HHMM).tar.bz2)
	shopt -s extglob;  cd $(PRJROOT) && \
	  tar --create --bzip2 --file=$f $(TAR_EXCLUDE_FILES_OPTS) !(build_*)
	ls -l $(PRJROOT)/$f

help.util::
	@printf 'tar\t\t\t- Create a project_<YYMMDD_HHMM>.tar.bz2 file with the contents of $$PRJROOT except build*.\n'
