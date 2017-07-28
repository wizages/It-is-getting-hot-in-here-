SDKVERSION = 10.1
SYSROOT = $(THEOS)/sdks/iPhoneOS10.1.sdk
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ItGettingHotinHere
ItGettingHotinHere_FILES = Tweak.xm HDPreferencesManager.m
ItGettingHotinHere_PRIVATE_FRAMEWORKS = Weather
ItGettingHotinHere_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

include $(THEOS_MAKE_PATH)/aggregate.mk
