-- Called by claude-split.sh: focus the Claude split whose id is `saved`, or
-- open a new one on the right. Returns the new split's id, or "" if focused.
-- argv: saved split id, shell command for the split, pixels to shrink it by
on run argv
	set saved to item 1 of argv
	tell application "Ghostty"
		set t to selected tab of front window
		repeat with x in terminals of t
			if id of x is saved then
				focus x
				return ""
			end if
		end repeat
		set cur to focused terminal of t
		set cfg to new surface configuration
		set wd to working directory of cur
		if wd is not missing value and wd is not "" then set initial working directory of cfg to wd
		set command of cfg to item 2 of argv
		set n to split cur direction right with configuration cfg
		perform action ("resize_split:right," & item 3 of argv) on n
		return id of n
	end tell
end run
