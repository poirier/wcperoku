#
#  Copyright (c) 2015 Roku, Inc. All rights reserved.
#  Simple Makefile for Roku Channel Development
#

APPNAME = the-classical-station
IMPORTS =
ZIP_EXCLUDE = --quiet -x .git/\* .idea/\* .envrc dist/\* oldimages/\* app.mk .gitignore Makefile README.md fonts/\* charsused.txt venv/\*
include app.mk

debug:
	@echo "Control-] q" to exit
	telnet $(ROKU_DEV_TARGET) 8085

# Per https://developer.roku.com/docs/references/brightscript/components/rofontregistry.md
# try to keep font files under 50K or so. This removes all glyphs except the basic ASCII chars
# and the most common accented chars.  Edit charsused.txt to add any missing chars.
shrink_fonts:
	pyftsubset fonts/Source_Sans_Pro/SourceSansPro-Regular.ttf --text-file=charsused.txt --output-file=font-subsets/SourceSansPro-Regular-subset.ttf
	pyftsubset fonts/SourceSerifPro/SourceSerifPro-Regular.ttf --text-file=charsused.txt --output-file=font-subsets/SourceSerifPro-Regular-subset.ttf
	pyftsubset fonts/SourceSerifPro/SourceSerifPro-Italic.ttf  --text-file=charsused.txt --output-file=font-subsets/SourceSerifPro-Italic-subset.ttf
	pyftsubset fonts/Roboto_Mono/RobotoMono-Regular.ttf        --text-file=charsused.txt --output-file=font-subsets/RobotoMono-Regular-subset.ttf
