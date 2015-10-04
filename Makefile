export TARGET := iphone:clang
export ARCHS = armv7 arm64
PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VolumeBar
VolumeBar_FILES = Tweak.xm VolumeBar.xm GMPVolumeView.xm
VolumeBar_FRAMEWORKS = UIKit CoreGraphics MediaPlayer
VolumeBar_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS += volumebar

include $(THEOS_MAKE_PATH)/aggregate.mk
