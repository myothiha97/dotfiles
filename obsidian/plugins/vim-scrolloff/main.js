'use strict'

/*
 * Vim Scrolloff
 *
 * Obsidian's Vim mode has no "set scrolloff". This follows Vim's own rules:
 * - When the cursor moves (j, k, search, any motion) and lands within
 *   SCROLL_OFF lines of the top or bottom, the note scrolls to keep that
 *   gap.
 * - When the note scrolls by key (Ctrl-E, Ctrl-Y, Ctrl-D, Ctrl-U, Ctrl-F,
 *   Ctrl-B), the cursor moves instead, so it stays SCROLL_OFF lines from
 *   the edge. Scrolling the view back to the cursor here would undo the
 *   scroll, which is what made the earlier version stutter.
 * Mouse and trackpad scrolling are left alone, as before.
 */

const { Plugin } = require('obsidian')
const { ViewPlugin } = require('@codemirror/view')

// Lines kept between the cursor and the top or bottom edge, like
// "set scrolloff=13"
const SCROLL_OFF = 13

// Ctrl+key scrolls in Vim
const SCROLL_KEYS = new Set(['e', 'y', 'd', 'u', 'f', 'b'])

// How long after a scroll key its scroll events count as key scrolling
const KEY_SCROLL_WINDOW_MS = 400

class ScrolloffView {
  constructor(view) {
    this.view = view
    this.keyScrollUntil = 0

    this.onKeyDown = event => {
      if (event.ctrlKey && !event.metaKey && !event.altKey && SCROLL_KEYS.has(event.key)) {
        this.keyScrollUntil = performance.now() + KEY_SCROLL_WINDOW_MS
      }
    }
    this.onScroll = () => {
      if (performance.now() < this.keyScrollUntil) this.cursorFollowsView()
    }

    // Capture: key presses inside table cells (nested editors) count too
    view.dom.addEventListener('keydown', this.onKeyDown, true)
    view.scrollDOM.addEventListener('scroll', this.onScroll, { passive: true })
  }

  update(update) {
    if (update.selectionSet && performance.now() >= this.keyScrollUntil) this.viewFollowsCursor()
  }

  destroy() {
    this.view.dom.removeEventListener('keydown', this.onKeyDown, true)
    this.view.scrollDOM.removeEventListener('scroll', this.onScroll)
  }

  // Vim editors only (Vim keeps its state on view.cm), and not the small
  // editors inside table cells
  vimState() {
    const vim = this.view.cm?.state?.vim
    return vim && !this.view.dom.closest('.cm-table-widget') ? vim : null
  }

  // Where the cursor sits in the pane, and the gap to keep. The gap stays
  // under half the pane, so the top and bottom rules can never both apply.
  measure() {
    const { view } = this
    const cursor = view.coordsAtPos(view.state.selection.main.head)
    if (!cursor) return null

    const pane = view.scrollDOM.getBoundingClientRect()
    const lineHeight = view.defaultLineHeight
    const margin = Math.min(SCROLL_OFF * lineHeight, (pane.height - lineHeight) / 2)
    return { cursor, pane, margin, lineHeight }
  }

  viewFollowsCursor() {
    if (!this.vimState()) return
    this.view.requestMeasure({
      read: () => {
        const m = this.measure()
        if (!m) return 0
        if (m.cursor.top < m.pane.top + m.margin) return m.cursor.top - (m.pane.top + m.margin)
        if (m.cursor.bottom > m.pane.bottom - m.margin) return m.cursor.bottom - (m.pane.bottom - m.margin)
        return 0
      },
      // The browser stops at the start and end of the note, as Vim does
      write: delta => {
        if (Math.abs(delta) > 1) this.view.scrollDOM.scrollTop += delta
      },
    })
  }

  cursorFollowsView() {
    const vim = this.vimState()
    if (!vim || vim.insertMode || vim.visualMode) return
    this.view.requestMeasure({
      read: () => {
        const m = this.measure()
        if (!m) return null
        const { scrollTop, scrollHeight, clientHeight } = this.view.scrollDOM
        const atTop = scrollTop <= 0
        const atBottom = scrollTop + clientHeight >= scrollHeight - 1

        let y = null
        if (!atTop && m.cursor.top < m.pane.top + m.margin) y = m.pane.top + m.margin + m.lineHeight / 2
        else if (!atBottom && m.cursor.bottom > m.pane.bottom - m.margin) y = m.pane.bottom - m.margin - m.lineHeight / 2
        return y === null ? null : this.view.posAtCoords({ x: m.cursor.left, y }, false)
      },
      write: pos => {
        if (pos !== null && pos !== this.view.state.selection.main.head) this.view.dispatch({ selection: { anchor: pos } })
      },
    })
  }
}

module.exports = class VimScrolloffPlugin extends Plugin {
  onload() {
    this.registerEditorExtension(ViewPlugin.fromClass(ScrolloffView))
  }
}
