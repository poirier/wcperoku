#
#  Copyright (c) 2015 Roku, Inc. All rights reserved.
#  Simple Makefile for Roku Channel Development
#

APPNAME = the-classical-station
IMPORTS =
ZIP_EXCLUDE = --quiet -x .git/\* .idea/\* .envrc dist/\* oldimages/\* app.mk .gitignore Makefile
include app.mk

debug:
	@echo "Control-] q" to exit
	telnet $(ROKU_DEV_TARGET) 8085
