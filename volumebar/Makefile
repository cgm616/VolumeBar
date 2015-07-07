include theos/makefiles/common.mk

BUNDLE_NAME = VolumeBar
VolumeBar_FILES = VolumeBar.mm
VolumeBar_INSTALL_PATH = /Library/PreferenceBundles
VolumeBar_FRAMEWORKS = UIKit
VolumeBar_PRIVATE_FRAMEWORKS = Preferences
VolumeBar_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/VolumeBar.plist$(ECHO_END)
