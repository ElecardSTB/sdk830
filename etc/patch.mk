
# Macro: createPatchOverlayScriptTarget
# Creates target dependence from patches, overlays and scripts.
# $1 - timestamp file name
# $2 - package version
# $3 - package output directory
# $4 - description. Should be without spaces
# $5 - dependences
#
# Example:-
#   $(eval $(call createPatchOverlayScriptTarget,$(_ts_patchbuildroot)_rootfs,$(BUILDROOT_VERSION),$(BUILDROOT_ROOT),buildroot))
define createPatchOverlayScriptTarget
patch_$(4): $1

#$(1): force
$(4)_OVERLAY_FILES=$(shell find ./$(2)_overlay/ -not -regex ".*.svn.*" -type f)
$(4)_PATCH_FILES=$(sort $(wildcard ./$(2)_patch/*.patch))
$(4)_SCRIPT_FILES=$(sort $(wildcard ./$(2)_script/*.sh))
$(1): $(5) $$($(4)_OVERLAY_FILES) $$($(4)_PATCH_FILES) $$($(4)_SCRIPT_FILES)
	$(call ECHO_MESSAGE,Patching/overlaying $(4))
#	@has_newer_patches=`echo $$? | tr ' ' '\n' | grep "$(2)_patch/.*.patch"`; echo Patches: $$$$has_newer_patches;
	-@has_newer_patches=`echo $$? | tr ' ' '\n' | grep "$(2)_patch/.*.patch"`; \
		if [ -n "$$$$has_newer_patches" ]; then echo -e "\nPatches:"; fi; \
		for i in $$$$has_newer_patches; do \
			echo -e "\n ***Applying $$$$i\n"; \
			patch --directory=$(3) -N -p1 < $$$$i; \
			script=`echo $$$$i | sed s/.patch$$$$/.sh/`; \
			if [ -x $$$$script ]; then eval ./$$$$script; fi \
		done;
#	@has_newer_overlays=`echo $$? | tr ' ' '\n' | grep "$(2)_overlay/"`; echo Overlays: $$$$has_newer_overlays;
	@has_newer_overlays=`echo $$? | tr ' ' '\n' | grep "$(2)_overlay/"`; \
		if [ -n "$$$$has_newer_overlays" ]; then echo -e "\nOverlays:"; fi; \
		for i in $$$$has_newer_overlays; do \
			echo -e "\t$$$$i"; \
			target_dir=$(3)/`dirname $$$${i#*/}`; \
			if [ ! -d $$$$target_dir ]; then rm -f $$$$target_dir; mkdir -p $$$$target_dir; fi; \
			cp $$$$i $$$$target_dir; \
		done;
#	@has_newer_scripts=`echo "$$?" | tr ' ' '\n' | grep "$(2)_script/.*.sh"`; echo Scripts: $$$$has_newer_scripts;
	-@has_newer_scripts=`echo "$$?" | tr ' ' '\n' | grep "$(2)_script/.*.sh"`; \
		if [ -n "$$$$has_newer_scripts" ]; then echo -e "\nScripts:"; fi; \
		for i in $$$$has_newer_scripts; do \
			if [ -x $$$$i ]; then \
				echo -e "\n ***Execute $$$$i\n"; \
				eval $$$$i; \
			else \
				echo -e "\n ***No permisions for execute $$$$i !!!\n"; \
			fi \
		done;
	touch $(1)

endef


