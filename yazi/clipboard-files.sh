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

	// The pasteboard server receives the items in the background, and any item
	// still in flight is dropped when this process exits. Reads from inside this
	// process only see a local cache, so a separate process does the check, and
	// this one stays alive until that process sees every item (capped at ~5s).
	const app = Application.currentApplication()
	app.includeStandardAdditions = true
	const countItems = `osascript -l JavaScript -e 'ObjC.import("AppKit"); $.NSPasteboard.generalPasteboard.pasteboardItems.count'`
	// Limits how many times the clipboard is checked, not how many files are copied
	const MAX_CHECKS = 50
	for (let checks = 0; checks < MAX_CHECKS; checks++) {
		if (Number(app.doShellScript(countItems)) >= argv.length) break
		delay(0.02)
	}
	return ''
}
JXA
