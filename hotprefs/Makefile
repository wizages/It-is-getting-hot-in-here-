include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = hotprefs
hotprefs_FILES = hotdogitisRootListController.m
hotprefs_INSTALL_PATH = /Library/PreferenceBundles
hotprefs_FRAMEWORKS = UIKit
hotprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/hotprefs.plist$(ECHO_END)
