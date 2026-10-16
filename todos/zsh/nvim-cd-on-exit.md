# `n`: cd the shell into nvim's last cwd on exit

WIP, not in `zshrc`. Pulled out on 2026-10-15 because it did not work in
daily use.

Goal: like `f()` for yazi. After `:cd` in nvim, or `` ` `` (oil's default
`actions.cd`), quitting nvim leaves the shell in that folder.

```zsh
function n() {
	local tmp="$(mktemp -t nvim-cwd.XXXXXX)" dir
	nvim -c "autocmd VimLeave * call writefile([getcwd()], '$tmp')" "$@"
	IFS= read -r dir < "$tmp"
	[ -n "$dir" ] && [ "$dir" != "$PWD" ] && builtin cd -- "$dir"
	rm -f -- "$tmp"
}
```

What is known:

- Works on an isolated tmux server with a fresh `zsh -i`: both `:cd` and oil
  `` ` `` followed by `:qa!` left the shell in the new folder.
- Fails in the user's live panes: the shell stays in the old folder.
- Not yet ruled out: the live pane still has an older broken `n` loaded
  (check with `whence -f n`), or the quit path differs (`:q`, `ZZ`, a
  keymap, a session plugin changing cwd on exit).

Next step: in a failing pane, run `whence -f n`, then reproduce and note the
exact quit command. Cost: none at startup; one `mktemp` per `n` call.
