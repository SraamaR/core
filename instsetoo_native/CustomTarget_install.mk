# -*- Mode: makefile-gmake; tab-width: 4; indent-tabs-mode: t -*-
#
# This file is part of the LibreOffice project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

$(eval $(call gb_CustomTarget_CustomTarget,instsetoo_native/install))

$(eval $(call gb_CustomTarget_register_targets,instsetoo_native/install,\
	install.phony \
	bin/find-requires-gnome.sh \
	bin/find-requires-x11.sh \
))

.PHONY: $(gb_CustomTarget_workdir)/instsetoo_native/install/install.phony

$(gb_CustomTarget_workdir)/instsetoo_native/install/bin/find-requires-%.sh: $(SRCDIR)/instsetoo_native/inc_openoffice/unix/find-requires-%.sh
	cat $< | tr -d "\015" > $@
	chmod a+x $@

export ENABLE_DOWNLOADSETS ?= TRUE
ifeq ($(OS),LINUX)
export DONT_REMOVE_PACKAGE := TRUE
endif
export instsetoo_OUT := $(WORKDIR)/installation
export LOCAL_OUT := $(instsetoo_OUT)
export LOCAL_COMMON_OUT := $(instsetoo_OUT)

instsetoo_installer_langs := en-US

# delimiter is U+2027 Hyphenation point - files with colon in their name confuse the heck out of
# make and cannot be used as targets or prerequisites. For passing to call_installer.sh it is
# substituted by the : so that cut doesn't stumble over the delimiter
instsetoo_installer_targets := $(foreach pkgformat,$(PKGFORMAT),\
        openoffice‧$(instsetoo_installer_langs)‧‧‧$(pkgformat)‧$(if $(filter-out archive,$(pkgformat)),strip,nostrip) \
        $(if $(filter ODK,$(BUILD_TYPE)),sdkoo‧en-US‧_SDK‧‧$(pkgformat)‧nostrip) \
        $(if $(and $(filter HELP,$(BUILD_TYPE)),$(filter-out MACOSX,$(OS))), \
            $(foreach lang,$(gb_HELP_LANGS),ooohelppack‧$(lang)‧‧-helppack‧$(pkgformat)‧nostrip)) \
        $(foreach lang,$(filter-out en-US,$(gb_WITH_LANG)),ooolangpack‧$(lang)‧‧-languagepack‧$(pkgformat)‧nostrip))

instsetoo_wipe:
	$(call gb_Output_announce,wiping installation output dir,$(true),WPE,6)
	rm -rf $(instsetoo_OUT)

$(instsetoo_installer_targets): export FAKEROOT:=$(FAKEROOT)
$(instsetoo_installer_targets): $(SRCDIR)/solenv/bin/make_installer.pl \
        $(addprefix $(gb_CustomTarget_workdir)/instsetoo_native/install/,\
            bin/find-requires-gnome.sh \
            bin/find-requires-x11.sh) \
        $(call gb_Postprocess_get_target,AllModulesButInstsetNative) \
        | instsetoo_wipe
	$(call gb_Output_announce,$@,$(true),INS,1)
	$(call gb_Trace_StartRange,$@,INSTALLER)
	$(call gb_Helper_print_on_error, \
	    $(SRCDIR)/solenv/bin/call_installer.sh $(if $(verbose),-verbose,-quiet) $(subst ‧,:,$@),\
	    $(gb_CustomTarget_workdir)/instsetoo_native/install/$@.log)
	$(call gb_Trace_EndRange,$@,INSTALLER)

$(gb_CustomTarget_workdir)/instsetoo_native/install/install.phony: $(instsetoo_installer_targets)
	$(call gb_Output_announce,$(subst $(WORKDIR)/,,$@),$(true),PRL,2)
	$(call gb_Trace_StartRange,$(subst $(WORKDIR)/,,$@),PRL)
	touch $@
	$(call gb_Trace_EndRange,$(subst $(WORKDIR)/,,$@),PRL)

# vim: set noet sw=4 ts=4:
