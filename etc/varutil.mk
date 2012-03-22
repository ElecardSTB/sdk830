#
#                             IPSTB Project
#                   ---------------------------------
#
# Copyright (C) 2005 Koninklijke Philips Electronics N.V., 
# All Rights Reserved. 
#
# Filename: varutil.mk
#
#
# Rev Date       Author      Comments
#-------------------------------------------------------------------------------
#   1 20061025   batelaan    Initial
#   2 20061026   batelaan    Improve way of detecting variable refs in %.vardefs target.
#   3 20070115   batelaan    Print to stdout, not stderr. Simplify quoting.

# File: varutil.mk
# General make utility macros and functions for Make variables/expression.

################################################################################
# Variable value/definition printing
################################################################################

help.util::
	@printf "<var>.var\t\t- Prints definition of make variable\n"
	@printf "<var>.varvalue\t\t- Ditto\n"
	@printf "<var>.vardef\t\t- Prints definition of make variable\n"
	@printf "<var>.vardefs\t\t- Prints definition of make variable, recursively\n"

# Target: %.vardef
# Echos variable definition (unexpanded).
# See also: <%.varvalue> <%.var> <%.vardefs>
%.vardef:
	@$(call varutil.printvardef,$*,)

# Target: %.vardefs
# Recursively (TODO: currently only one level!) echos variable definitions (unexpanded), to stderr.
# See also: <%.varvalue> <%.var> <%.vardef>
%.vardefs:
	@$(call varutil.printvardef,$*,)
	@$(call varutil.printvarrefsrecursively,$(value $*),)

varutil.checkundefined=$(if $(filter undefined,$(origin $1)),$(shell echo >&2 '\#\#\#\# Warning: variable $1 is undefined'))
varutil.printvardef=$(call varutil.checkundefined,$1)echo "$2$1='"'$($1)'"'";
varutil.printvarrefsrecursively=$(foreach v,$(call varutil.varrefs,$1),$(if $(filter-out automatic undefined,$(origin $v)),$(call varutil.printvardef,$v,  $2)$(if $(filter-out automatic,$(origin $v)),$(call varutil.printvarrefsrecursively,$(value $v),  $2))))

varutil.varrefs=$(shell perl -e '$$_=shift; s/[\$$(){}]/ /g; print; exit;' -- '$(subst ','"'"',$1)')

varutil.printvarvalue=$(call varutil.checkundefined,$1)echo "$2$1='"'$($1)'"'";

# Target: %.varvalue
# Echos variable definition (unexpanded). Alias for <%.var>.
# See also: <%.vardef> <%.var>
%.varvalue:
	@$(call varutil.printvarvalue,$*,)

# Target: %.var
# Echos variable definition (unexpanded). Alias for <%.varvalue>.
# See also: <%.vardef> <%.varvalue>
%.var:
	@$(call varutil.printvarvalue,$*,)

################################################################################
# Make expression printing
################################################################################

# Target: printexpr
# Prints the value of a make expression. This is useful to check how complex
# make constructs evaluate, e.g.:-
# KMODULE=true EXPORTS=a,b,c make printexpr expr='$(if $(filter true,$(KMODULE)),$(filter-out true,$(EXPORTS)))'
#
# Causes an error if the variable named 'expr' is not defined.
#
# Usage:
# make printexpr expr=someexpr
printexpr:
	@$(if $(filter undefined,$(origin expr)),$(error Variable expr must be defined for printexpr target))
%.expr:
	@echo '$(eval ___expression=$*!!!)$(patsubst %!!!,%,$(___expression))'
help.varutil::
	@printf "<expr>.expr\t\t- Prints make expression value\n"
	@printf "printexpr expr=<expr>\t- Prints make expression value\n"

################################################################################
# Variable definition checks
################################################################################

# Function: CHECK_VAR_DEFINED
# Checks if variable name given by first argument is defined. 
# Prints error message and exits make if not.
#
# Error message:
# Variable $(1) not set: $(2)
CHECK_VAR_DEFINED=$(eval $(call CHECK_VAR_DEFINED1,$(strip $(1)),$(strip $(2))))
define CHECK_VAR_DEFINED1
  $(call DOTRACE,'CHECK_VAR_DEFINED $1=$($1) origin=$(origin $(1))')
  ifeq "$(origin $(1))" "undefined"
    $$(error Variable $(1) not set: $(2))
  endif
endef

# Function: CHECK_VAR_UNDEFINED
# Checks if variable name given by first argument is undefined. 
# Prints error message and exits make if not.
#
# Error message:
# Variable $(1) is set: $(2)
CHECK_VAR_UNDEFINED=$(eval $(call CHECK_VAR_UNDEFINED1,$(strip $(1)),$(strip $(2))))
define CHECK_VAR_UNDEFINED1
  $(call DOTRACE,'CHECK_VAR_UNDEFINED $1=$($1) origin=$(origin $(1))')
  ifdef $(1)
    $$(error Variable $(1) is set: $(2))
  endif
endef

# Function: CHECK_VAR_VALUE
# Checks if variable name given by first argument has one of the values given by the second argument.
# Prints error message and exits make if not.
#
# Error message:
# Variable $(1) not one of: $(2)
CHECK_VAR_VALUE=$(eval $(call CHECK_VAR_VALUE1,$(strip $(1)),$(strip $(2))))
define CHECK_VAR_VALUE1
  $(call DOTRACE,'CHECK_VAR_VALUE $1=$($1) origin=$(origin $(1))')
  ifeq ($(filter $($(1)),$(2)),)
    $$(error Variable $(1) not one of: $(2))
  endif
endef

# Function: UNDEF_VAR_WARN_IF_DEFINED
# Checks if the variable given by first argument is defined, if so, then set it to an empty value.
# Prints a warning message if it the variable was defined.
#
# Warning message:
# Unsetting variable $(1) ($($(1)))
UNDEF_VAR_WARN_IF_DEFINED=$(eval $(call UNDEF_VAR_WARN_IF_DEFINED1,$(strip $(1))))
define UNDEF_VAR_WARN_IF_DEFINED1
  $(call DOTRACE,'UNDEF_VAR_WARN_IF_DEFINED $1=$($1) origin=$(origin $(1))')
  ifneq "$(origin $(1))" "undefined"
    $(warning Unsetting variable $(1) ($($(1))))
    $(1):=
  endif
endef

################################################################################
