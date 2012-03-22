#
#                             IPSTB Project
#                   ---------------------------------
#
# Copyright (C) 2007 NXP B.V.,
# All Rights Reserved.
#
# Filename: envs.mk
#
#
# Rev Date       Author      Comments
#-------------------------------------------------------------------------------
#   1 20060731   batelaan    Initial
#   2 20060809   batelaan    Crosscheck fix
#   4 20060824   batelaan    Added immediate command execution to %.shell target.
#                            Prevent unwanted output if running with -s or --silent or --quiet
#   5 20070111   batelaan    Check MAKEFLAGS.orig (MAKEFLAGS has been emptied by us).
#                            Use export command for printenv target.
#                            This prevent shell functions being printed.
#   6 20070315   batelaan    Add alias capability to setupEnvGoal

# File: envs.mk
# General make utility for manipulating the environment (variables).

# Macro: setenvVar
# Generates Make code to set a target-specific variable ($1) to a value ($2).
# The target for which this is done is $(target).
#
# Example:-
#   $(call setenvVar,KSRC,$$(CPUBUILDROOT)/packages/linux-2.6.10_MV)
setenvVar=$(call setenvVar1,$(strip $1),$2)
define setenvVar1
  $(call DOTRACE,'$(target): $1=$2')
  $(target): $1=$2
endef

# Macro: prependenvVar
# Generates Make code to set a target-specific variable ($1) to a new value,
# by prepending $2.
# The target for which this is done is $(target).
#
# Example:-
#   $(call prependenvVar,PATH,$(MYBIN):)
prependenvVar=$(call prependenvVar1,$(strip $1),$2)
define prependenvVar1
  $(call DOTRACE,'$1=$(value 2)$$$1')
  $(target): $1=$(value 2)$(value $1)
endef

ENVS_ENTER=$(call DOTRACE,'>> $1')$(call INDENT_INCR)
ENVS_LEAVE=$(call INDENT_DECR)$(call DOTRACE,'<< $1')

# Target: %.printenv
# Prints out the complete environment for %.

# Target: %.shell
# Run a shell or a command within the environment for %.
# If variable cmd exists, then execute its value, and return.
# Otherwise run /bin/bash.

# Macro: setupEnvGoal
# Defines $1 as a target which ensures that the right environment is set up.
# The name of the environment is $1. A variable named $1.env should exist which
# should expand to contain $(call <setenvVar>,...,...) statements.
#
# $2 can be a list of names, which will be treated as synonyms for $1.
#
# The following targets are also defined:-
# - $1.printenv (see <%.printenv>)
# - $1.shell (see <%.shell>)
setupEnvGoal=$(eval $(call setupEnvGoal1,$(strip $1),$2))
define setupEnvGoal1
  $(call DOTRACE,'setupEnvGoal $1 $2')
  envList+=$1

  $(eval env=$1)

  $(eval target=$1.goal)$(eval $($1.env))
  ifeq "$(findstring -s,$(MAKEFLAGS.orig))" "-s"
    $1:: $1.goal
  else
    $1:: $1.banner $1.goal
	@printf '\n\n=*=*=*=*=*=*=*=*=*=*=*= DONE $1 =*=*=*=*=*=*=*=*=*=*=*=\n\n'
    $1.banner::
	@printf '\n\n=*=*=*=*=*=*=*=*=*=*=*= START $1 =*=*=*=*=*=*=*=*=*=*=*=\n\n'
  endif
  $(if $2, $2: $1)

  $(eval target=$1.printenv)$(eval $($1.env))
  $(if $2, $(2:%=%.printenv): $1.printenv)
  $1.printenv:
	@export

  $(eval target=$1.shell)$(eval $($1.env))
  $(if $2, $(2:%=%.shell): $1.shell)
  $1.shell:
	$(if $(cmd),\
	  @$(if $(findstring -s,$(MAKEFLAGS.orig)),:,\
	    printf '\n\n\n ***** Invoking command(s) for environment $1 ****\n    $(cmd)\n\n');$(cmd),\
	  @$(if $(findstring -s,$(MAKEFLAGS.orig)),:,\
	    printf '\n\n\n ***** Invoking sub-shell for environment $1 ****\n\n\n');/bin/bash)
endef

# Target: envs.list
# Lists all environments that were defined using <setupEnvGoal>.
envs.list:
	@echo '$(envList)'

