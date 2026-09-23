#!/bin/sh
# Put files on the macOS clipboard as real file references, so Cmd+V in Finder
# pastes the files themselves. Yazi's own `y` only fills yazi's internal
# register, which no other app can see.
#
# Usage: clipboard-files.sh --hovered <path> [selected paths...]
# Yazi's %s is empty when nothing is selected, so the hovered file is passed
# separately and used as the fallback.
#
# The pasteboard is written through AppKit via JavaScript for Automation.
# Plain AppleScript ("set the clipboard to POSIX file ...") holds only one
# file, and a list of them lands on the clipboard as a list type that Finder
# refuses to paste.

hovered=""
if [ "$1" = "--hovered" ]; then
	hovered="$2"
	shift 2
fi

if [ "$#" -eq 0 ]; then
	[ -n "$hovered" ] || exit 0
	set -- "$hovered"
fi

osascript -l JavaScript - "$@" <<'JXA'
function run(argv) {
	ObjC.import('AppKit')
	const pb = $.NSPasteboard.generalPasteboard
	pb.clearContents
	pb.writeObjects($(argv.map(p => $.NSURL.fileURLWithPath(p))))
	return ''
}
JXA
