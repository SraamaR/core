# -*- Mode: makefile-gmake; tab-width: 4; indent-tabs-mode: t -*-
#
# This file is part of the LibreOffice project.
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

$(eval $(call gb_Module_Module,shell))

ifeq ($(gb_Side),host)

$(eval $(call gb_Module_add_targets,shell,\
	$(if $(filter-out MACOSX WNT,$(OS)),Library_desktopbe) \
	Library_localebe \
))

ifneq ($(filter DRAGONFLY FREEBSD LINUX NETBSD OPENBSD,$(OS)),)
ifeq ($(ENABLE_GIO),TRUE)
$(eval $(call gb_Module_add_targets,shell,\
	Library_losessioninstall \
))
endif
endif

ifeq ($(OS),SOLARIS)
ifeq ($(ENABLE_GIO),TRUE)
$(eval $(call gb_Module_add_targets,shell,\
    Library_losessioninstall \
))
endif
endif

ifeq ($(filter DESKTOP,$(BUILD_TYPE)),DESKTOP)

$(eval $(call gb_Module_add_targets,shell,\
	Library_syssh \
))

ifneq ($(OS),WNT)

$(eval $(call gb_Module_add_targets,shell,\
	StaticLibrary_xmlparser \
	Executable_uri_encode \
	Library_cmdmail \
	$(if $(ENABLE_MACOSX_SANDBOX),,Package_senddoc) \
))

endif

endif

$(eval $(call gb_Module_add_l10n_targets,shell,\
    AllLangMoTarget_shell \
))

endif # $(gb_Side) == host

# vim: set shiftwidth=4 tabstop=4 noexpandtab:
