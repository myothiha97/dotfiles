'use strict'

/*
 * Vim Table Scroll
 *
 * In live preview a table cell is edited in its own small editor, so Vim's
 * Ctrl-E and Ctrl-Y scroll that cell (which has nothing to scroll) instead of
 * the note. While the cursor is in a table cell and Vim is not in insert
 * mode, this scrolls the note one line instead. Everywhere else Vim handles
 * the keys as usual, and in insert mode macOS keeps Ctrl-E (end of line).
 */

const { Plugin } = require('obsidian')
const { EditorView } = require('@codemirror/view')

// Key -> scroll direction
const SCROLL_KEYS = { e: 1, y: -1 }

// The note's own scroller, the one the table widget sits in
const NOTE_SCROLLER = '.view-content > .markdown-source-view > .cm-editor > .cm-scroller'

module.exports = class VimTableScrollPlugin extends Plugin {
  onload() {
    // Capture phase, so this runs before the cell editor's Vim sees the key
    this.registerDomEvent(document, 'keydown', event => this.onKeyDown(event), { capture: true })
  }

  onKeyDown(event) {
    const direction = SCROLL_KEYS[event.key]
    if (!direction || !event.ctrlKey || event.metaKey || event.altKey || event.shiftKey) return

    const cellEditor = event.target instanceof Element ? event.target.closest('.cm-editor') : null
    if (!cellEditor?.closest('.cm-table-widget')) return

    // Vim keeps its state on the editor (view.cm.state.vim)
    const vim = EditorView.findFromDOM(cellEditor)?.cm?.state?.vim
    if (!vim || vim.insertMode) return

    const scroller = cellEditor.closest('.workspace-leaf-content')?.querySelector(NOTE_SCROLLER)
    if (!scroller) return

    event.preventDefault()
    event.stopPropagation()
    scroller.scrollBy(0, direction * parseFloat(getComputedStyle(scroller).lineHeight))
  }
}
