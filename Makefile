include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iTeleport
iTeleport_FILES = main.m iTeleportApplication.mm RootViewController.mm
iTeleport_FRAMEWORKS = UIKit CoreGraphics CoreLocation Foundation MapKit
iTeleport_LIBRARIES += cephei cepheiprefs
iTeleport_CODESIGN_FLAGS = -Sentitlements.xml iTeleport

include $(THEOS_MAKE_PATH)/application.mk

SUBPROJECTS += iteleporttweak
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "uicache"
