include theos/makefiles/common.mk

APPLICATION_NAME = TeleportMe
TeleportMe_FILES = main.m TeleportMeApplication.mm RootViewController.mm
TeleportMe_FRAMEWORKS = UIKit CoreGraphics CoreLocation Foundation

include $(THEOS_MAKE_PATH)/application.mk
