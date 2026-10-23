'use strict'

/*
 * Focus Mode
 *
 * One command (Cmd+Shift+H by default) hides the left icon ribbon, each
 * note's breadcrumb bar and the status bar, so only tabs and the note stay,
 * like Typora's plain window. Press it again to bring them back. The choice
 * is saved, so it survives a restart. styles.css does the hiding.
 */

const { Plugin } = require('obsidian')

const BODY_CLASS = 'focus-mode'

module.exports = class FocusModePlugin extends Plugin {
  async onload() {
    const { enabled = false } = (await this.loadData()) ?? {}
    this.setFocusMode(enabled)

    this.addCommand({
      id: 'toggle',
      name: 'Toggle focus mode',
      hotkeys: [{ modifiers: ['Mod', 'Shift'], key: 'H' }],
      callback: () => this.toggle(),
    })
  }

  onunload() {
    document.body.classList.remove(BODY_CLASS)
  }

  async toggle() {
    const enabled = !document.body.classList.contains(BODY_CLASS)
    this.setFocusMode(enabled)
    await this.saveData({ enabled })
  }

  setFocusMode(enabled) {
    document.body.classList.toggle(BODY_CLASS, enabled)
  }
}
