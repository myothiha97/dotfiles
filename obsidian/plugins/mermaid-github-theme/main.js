'use strict'

/*
 * Mermaid GitHub Theme
 *
 * Obsidian draws every Mermaid diagram with Mermaid's light theme, then fakes
 * dark mode with a CSS invert filter. That filter turns pastel fills into
 * murky olive and navy, and inverts any colour a diagram sets itself. This
 * plugin gives Mermaid its real dark theme instead, the same one the Typora
 * theme uses, plus GitHub colours where that theme is weak. styles.css
 * removes the filter.
 *
 * Light mode keeps Obsidian's own setup (Mermaid's "default" theme).
 */

const { Modal, Plugin, debounce } = require('obsidian')

// Dark mode uses Mermaid's own "dark" theme, as the Typora theme does
// (~/.dotfiles/typora/themes/github-dark.css): neutral grey boxes and light
// grey lines. The colours below fill in only what that theme leaves weak.
// Mermaid works them out with its colour library, so they must be plain
// colour values, not CSS variables.
const fg = '#e6edf3'
const white = '#ffffff'

// Mindmap branches, timeline sections, pie slices and git lanes: GitHub's
// "emphasis" fills, which carry white text, with their brighter "fg" pair
// for lines drawn on top of them. The dark theme's own picks are murky.
const categorical = [
  { fill: '#1f6feb', fg: '#4493f8' }, // blue
  { fill: '#238636', fg: '#3fb950' }, // green
  { fill: '#8957e5', fg: '#ab7df8' }, // purple
  { fill: '#bd561d', fg: '#db6d28' }, // orange
  { fill: '#bf4b8a', fg: '#db61a2' }, // pink
  { fill: '#9e6a03', fg: '#d29922' }, // yellow
  { fill: '#da3633', fg: '#f85149' }, // red
  { fill: '#1b7c83', fg: '#39c5cf' }, // teal
]

const categoricalAt = index => categorical[index % categorical.length]

// Mermaid works out every colour of a theme, then re-applies anything set
// here, so these values always win
function buildDarkThemeVariables() {
  const variables = {
    // Edge labels on the Typora theme's box instead of a bright grey one
    edgeLabelBackground: '#30363d',
    // The dark theme leaves these unworked ("calculated" and "NaN%")
    labelColor: fg,
    quadrantPointFill: '#4493f8',
    pieSectionTextColor: white,
  }

  // Mindmap: the root uses git0 and branch n uses cScale(n + 1), so the root
  // is blue and branches start at green
  for (let i = 0; i < 12; i++) {
    const color = categoricalAt(i)
    variables[`cScale${i}`] = color.fill
    variables[`cScaleInv${i}`] = color.fg
    variables[`cScaleLabel${i}`] = white
    variables[`pie${i + 1}`] = color.fill
  }
  for (let i = 0; i < 8; i++) {
    const color = categoricalAt(i)
    variables[`git${i}`] = color.fill
    variables[`gitInv${i}`] = color.fg
    variables[`gitBranchLabel${i}`] = white
  }

  return variables
}

const darkThemeVariables = buildDarkThemeVariables()

// Mermaid adds this inside each diagram's own stylesheet, after its rules.
// It covers what the theme variables cannot reach in mindmaps: labels are
// HTML, coloured by CSS, and branch lines are 11px and 8px wide by default.
const darkThemeCss = `
  .mindmap-node span,
  .mindmap-node p {
    color: ${white};
  }
  .edge[class*="edge-depth-"] {
    stroke-width: 2px;
  }
  .edge.edge-depth-1 {
    stroke-width: 3px;
  }
`

const isDarkMode = () => document.body.classList.contains('theme-dark')

// The note's text size (Settings > Appearance > Font size)
const noteTextSize = () => parseFloat(getComputedStyle(document.body).getPropertyValue('--font-text-size')) || 16

// The note's column width (readable line length, set in base-style.css)
const noteLineWidth = () => getComputedStyle(document.body).getPropertyValue('--file-line-width').trim()

// Mermaid's text sizes, scaled so diagram labels match the note text. Mermaid
// draws with the scaled sizes, so layout and the fit-to-width checks use the
// real widths. Its smaller labels (gantt, ER, git) keep their proportion.
// Settings are [config section, key]; a missing section means the theme.
const SCALED_TEXT_SIZES = [
  [null, 'fontSize'],
  [null, 'pieTitleTextSize'],
  [null, 'pieSectionTextSize'],
  [null, 'pieLegendTextSize'],
  [null, 'commitLabelFontSize'],
  [null, 'tagLabelFontSize'],
  ['sequence', 'actorFontSize'],
  ['sequence', 'messageFontSize'],
  ['sequence', 'noteFontSize'],
  ['gantt', 'fontSize'],
  ['gantt', 'sectionFontSize'],
  ['er', 'fontSize'],
  ['journey', 'taskFontSize'],
  ['timeline', 'taskFontSize'],
]

// Mermaid's layout sizes that go with its text: box padding, the width labels
// wrap at, the space between nodes. They scale with the text too, so a
// diagram keeps the proportions Mermaid (and Typora) draw at 16px instead of
// fitting bigger text into the same boxes.
const SCALED_LAYOUT_SIZES = {
  flowchart: ['padding', 'wrappingWidth', 'nodeSpacing', 'rankSpacing', 'diagramPadding', 'titleTopMargin'],
  sequence: [
    'width',
    'height',
    'actorMargin',
    'boxMargin',
    'boxTextMargin',
    'noteMargin',
    'messageMargin',
    'wrapPadding',
    'labelBoxWidth',
    'labelBoxHeight',
    'activationWidth',
    'diagramMarginX',
    'diagramMarginY',
  ],
  state: ['padding', 'dividerMargin', 'noteMargin', 'textHeight', 'labelHeight', 'titleTopMargin'],
  er: ['minEntityWidth', 'minEntityHeight', 'entityPadding', 'nodeSpacing', 'rankSpacing', 'diagramPadding', 'titleTopMargin'],
  mindmap: ['padding', 'maxNodeWidth'],
  gantt: ['barHeight', 'barGap', 'topPadding', 'leftPadding', 'rightPadding', 'gridLineStartPadding', 'titleTopMargin'],
  timeline: ['width', 'height', 'leftMargin', 'boxMargin', 'boxTextMargin', 'taskMargin'],
  journey: ['width', 'height', 'leftMargin', 'maxLabelWidth', 'boxMargin', 'taskMargin'],
  gitGraph: ['diagramPadding', 'titleTopMargin'],
  kanban: ['padding', 'sectionWidth'],
  block: ['padding'],
  architecture: ['padding'],
}

// Mermaid's defaults are numbers (px) or "16px" strings; both scale
const scaleSize = (size, scale) => (typeof size === 'number' ? Math.round(size * scale) : `${Math.round(parseFloat(size) * scale)}px`)

function scaledSizes(defaults, textSize) {
  const scale = textSize / parseFloat(defaults.themeVariables.fontSize)
  const config = { fontSize: Math.round(defaults.fontSize * scale) }
  const themeVariables = {}
  for (const [section, key] of SCALED_TEXT_SIZES) {
    if (section) config[section] = { ...config[section], [key]: scaleSize(defaults[section][key], scale) }
    else themeVariables[key] = scaleSize(defaults.themeVariables[key], scale)
  }
  for (const [section, keys] of Object.entries(SCALED_LAYOUT_SIZES)) {
    for (const key of keys) config[section] = { ...config[section], [key]: scaleSize(defaults[section][key], scale) }
  }
  return { config, themeVariables }
}

// Diagram types that scale down to fit the note width, like on GitHub and in
// Typora. Obsidian turns this off for them, so a wide diagram overflows the
// note instead. The other types fit to width by default.
const FIT_TO_WIDTH_TYPES = ['flowchart', 'sequence', 'er', 'gitGraph']

// --- Responsive diagrams ---
// A diagram wider than the note scales down to fit, like in Typora, but its
// labels never get smaller than this. A sideways flowchart is first redrawn
// with tighter spacing; if that still needs more, it is redrawn top to
// bottom. Anything else stays at that size and scrolls sideways. 11px is
// about where Typora's fitted diagrams land.
const MIN_LABEL_SIZE = 11

// The smallest scale that keeps labels at MIN_LABEL_SIZE
const minScale = textSize => Math.min(1, MIN_LABEL_SIZE / textSize)

// The direction in a flowchart's header line, e.g. "flowchart LR"
const SIDEWAYS_FLOWCHART = /^(\s*(?:flowchart|graph)\s+)(?:LR|RL)\b/m

// Natural width of a rendered diagram, from its root viewBox ("x y w h")
function svgWidth(svg) {
  const match = /<svg[^>]*?\sviewBox="[-\d.]+[\s,]+[-\d.]+[\s,]+([\d.]+)/.exec(svg)
  return match ? Number(match[1]) : 0
}

// Pin the root <svg> at the minimum scale instead of shrinking to fit
function atMinimumScale(svg, width, scale) {
  return svg.replace(/<svg[^>]*>/, tag =>
    tag
      .replace(/\swidth="[^"]*"/, ` width="${Math.round(width * scale)}"`)
      .replace(/max-width:\s*[\d.]+px;?/, 'max-width: none;'),
  )
}

// The tighter redraw of a sideways flowchart: shorter arrows and less
// padding, as a share of the normal spacing
const COMPACT_SPACING = { rankSpacing: 0.45, nodeSpacing: 0.6, padding: 0.7 }

// Mermaid reads %%{init}%% directives anywhere in the text, so appending one
// keeps any frontmatter first
function compactVersion(text, flowchart) {
  const spacing = {}
  for (const [key, share] of Object.entries(COMPACT_SPACING)) spacing[key] = Math.round(flowchart[key] * share)
  return `${text}\n%%{init: ${JSON.stringify({ flowchart: spacing })}}%%`
}

// Added after each diagram drawn into a note (lucide "maximize-2" icon). It
// carries the diagram's source, so the expanded view can draw the diagram
// as written (normal spacing, own direction) rather than the fitted copy on
// the page. styles.css places it and one click handler serves them all.
const expandButton = source =>
  `<button class="mermaid-expand" type="button" aria-label="Expand diagram" data-source="${encodeURIComponent(source)}">` +
  '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" ' +
  'stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
  '<polyline points="15 3 21 3 21 9"/><polyline points="9 21 3 21 3 15"/>' +
  '<line x1="21" x2="14" y1="3" y2="10"/><line x1="3" x2="10" y1="21" y2="14"/></svg></button>'

// Limits for zooming in the expanded view
const ZOOM_RANGE = [0.2, 5]

// A diagram at full size in a large dialog, centred: pinch or Cmd+scroll
// zooms around the pointer, dragging pans, Esc closes. `draw` renders the
// source with Mermaid and resolves to the SVG markup.
class DiagramModal extends Modal {
  constructor(app, source, draw) {
    super(app)
    this.source = source
    this.draw = draw
  }

  async onOpen() {
    this.modalEl.addClass('mermaid-expand-modal')
    const view = this.contentEl.createDiv('mermaid-expand-view')
    try {
      // Mermaid's own output at securityLevel "strict" (labels sanitised),
      // placed the same way Obsidian places it on the page
      view.innerHTML = await this.draw(this.source)
    } catch (error) {
      view.setText(`Could not draw this diagram: ${error?.message ?? error}`)
      return
    }
    const svg = view.querySelector(':scope > svg')
    if (!svg) return

    const { width, height } = svg.viewBox.baseVal
    svg.removeAttribute('style')
    svg.removeAttribute('width')
    svg.removeAttribute('height')

    // Opens fitted to the dialog, never enlarged past full size
    let scale = Math.min(1, (view.clientWidth - 32) / width, (view.clientHeight - 32) / height)
    const applyScale = () => (svg.style.width = `${width * scale}px`)
    applyScale()

    view.addEventListener(
      'wheel',
      event => {
        if (!event.ctrlKey && !event.metaKey) return
        event.preventDefault()
        const box = view.getBoundingClientRect()
        const x = event.clientX - box.left
        const y = event.clientY - box.top
        const pointX = (view.scrollLeft + x) / scale
        const pointY = (view.scrollTop + y) / scale
        scale = Math.min(ZOOM_RANGE[1], Math.max(ZOOM_RANGE[0], scale * Math.exp(-event.deltaY * 0.01)))
        applyScale()
        view.scrollLeft = pointX * scale - x
        view.scrollTop = pointY * scale - y
      },
      { passive: false },
    )

    view.addEventListener('pointerdown', event => {
      const start = { x: event.clientX, y: event.clientY, left: view.scrollLeft, top: view.scrollTop }
      view.setPointerCapture(event.pointerId)
      view.addClass('is-dragging')
      const move = e => {
        view.scrollLeft = start.left - (e.clientX - start.x)
        view.scrollTop = start.top - (e.clientY - start.y)
      }
      const end = () => {
        view.removeClass('is-dragging')
        view.removeEventListener('pointermove', move)
      }
      view.addEventListener('pointermove', move)
      view.addEventListener('pointerup', end, { once: true })
    })
  }

  onClose() {
    this.contentEl.empty()
  }
}

const isPlainObject = value => Object.prototype.toString.call(value) === '[object Object]'

// The parts of `config` that differ from `defaults`. Mermaid treats some keys
// as chosen just because they are present (a mindmap switches from its radial
// layout to a tree when `layout` is set), so only real changes are passed on.
function changesFrom(defaults, config) {
  const changes = {}
  for (const [key, value] of Object.entries(config)) {
    const base = defaults?.[key]
    if (isPlainObject(value) && isPlainObject(base)) {
      const nested = changesFrom(base, value)
      if (Object.keys(nested).length > 0) changes[key] = nested
    } else if (value !== base) {
      changes[key] = value
    }
  }
  return changes
}

module.exports = class MermaidGithubThemePlugin extends Plugin {
  onload() {
    this.isDark = isDarkMode()
    this.textSize = noteTextSize()
    this.lineWidth = noteLineWidth()
    // Dragging the font size slider changes the size many times a second
    this.requestRedraw = debounce(() => this.redrawDiagrams(), 300, true)

    if (window.mermaid) {
      // Enabled after a diagram was already drawn
      this.takeOverMermaid(window.mermaid)
      this.readObsidianConfig()
      this.applyTheme()
      this.redrawDiagrams()
    } else {
      this.catchMermaidOnLoad()
    }

    this.registerEvent(this.app.workspace.on('css-change', () => this.onCssChange()))

    // Expand buttons. Capture, and mousedown too, so a click in live preview
    // opens the diagram instead of moving the cursor into the block.
    const onExpand = event => {
      const button = event.target instanceof Element ? event.target.closest('.mermaid-expand') : null
      if (!button) return
      event.preventDefault()
      event.stopPropagation()
      if (event.type !== 'click' || !button.dataset.source || !this.mermaid) return
      new DiagramModal(this.app, decodeURIComponent(button.dataset.source), source => this.drawExpanded(source)).open()
    }
    this.registerDomEvent(document, 'mousedown', onExpand, { capture: true })
    this.registerDomEvent(document, 'click', onExpand, { capture: true })
  }

  onunload() {
    if (!this.mermaid) return

    // Back to Obsidian's own setup: its sizes, light theme and invert filter
    this.mermaid.initialize = this.initialize
    this.mermaid.render = this.render
    this.initialize.call(this.mermaid, { ...this.obsidianConfig, themeVariables: { fontFamily: this.fontFamily } })
    this.redrawDiagrams()
  }

  // Obsidian loads Mermaid on the first diagram and straight away calls
  // mermaid.initialize() with no theme. Catching the library as its script
  // assigns window.mermaid lets that call carry the theme, so even the first
  // diagram is drawn with it.
  catchMermaidOnLoad() {
    const plugin = this
    Object.defineProperty(window, 'mermaid', {
      configurable: true,
      get: () => undefined,
      set(mermaid) {
        Object.defineProperty(window, 'mermaid', { value: mermaid, writable: true, configurable: true, enumerable: true })
        plugin.takeOverMermaid(mermaid)
      },
    })

    // Disabled before any diagram loaded Mermaid: drop the trap
    this.register(() => {
      if (Object.getOwnPropertyDescriptor(window, 'mermaid')?.set) delete window.mermaid
    })
  }

  takeOverMermaid(mermaid) {
    this.mermaid = mermaid
    this.initialize = mermaid.initialize
    this.render = mermaid.render

    mermaid.initialize = config => {
      this.initialize.call(mermaid, config)
      this.readObsidianConfig()
      this.applyTheme()
    }

    // Obsidian draws each diagram into a hidden box as wide as the note, so
    // the result can be checked against that width before it is shown
    // Only Obsidian's own calls pass a container, so other callers (exports,
    // other plugins) get Mermaid's plain result
    mermaid.render = async (id, text, container) => {
      const result = await this.render.call(mermaid, id, text, container)
      if (!container) return result
      const fitted = await this.fitToNote(result, id, text, container)
      return { ...fitted, svg: fitted.svg + expandButton(text) }
    }
  }

  // The expanded view's copy: Mermaid's plain render of the source, with no
  // container, so no fitting, compact spacing or direction change applies
  async drawExpanded(source) {
    this.expandCount = (this.expandCount ?? 0) + 1
    const { svg } = await this.render.call(this.mermaid, `mermaid-expand-${this.expandCount}`, source)
    return svg
  }

  // `container` is as wide as the text column (Obsidian sizes it so)
  async fitToNote(result, id, text, container) {
    const available = container.clientWidth
    const scale = minScale(this.textSize)
    let width = svgWidth(result.svg)
    if (!available || !width || width <= available) return result

    if (SIDEWAYS_FLOWCHART.test(text)) {
      // Tighter spacing first: it often keeps the row at a readable size
      const compact = await this.render.call(this.mermaid, id, compactVersion(text, this.mermaid.mermaidAPI.getSiteConfig().flowchart), container)
      const compactWidth = svgWidth(compact.svg)
      if (compactWidth && compactWidth < width) {
        result = compact
        width = compactWidth
      }
      if (width * scale <= available) return result

      const vertical = await this.render.call(this.mermaid, id, text.replace(SIDEWAYS_FLOWCHART, '$1TB'), container)
      const verticalWidth = svgWidth(vertical.svg)
      if (verticalWidth * scale <= available) return vertical
      if (verticalWidth < width) return { ...vertical, svg: atMinimumScale(vertical.svg, verticalWidth, scale) }
    } else if (width * scale <= available) {
      return result
    }

    return { ...result, svg: atMinimumScale(result.svg, width, scale) }
  }

  // Obsidian's own Mermaid settings (sizes, security level, font), read once
  // right after it sets them, so every later initialize() starts from them
  // and disabling the plugin can restore them
  readObsidianConfig() {
    const { defaultConfig, getSiteConfig } = this.mermaid.mermaidAPI
    const { theme, themeVariables, themeCSS, darkMode, ...siteConfig } = getSiteConfig()
    this.obsidianConfig = changesFrom(defaultConfig, siteConfig)
    this.fontFamily = themeVariables?.fontFamily
  }

  // mermaid.initialize() replaces the whole config, so each call is
  // Obsidian's settings plus fit-to-width, the note's text size and the theme
  applyTheme() {
    this.textSize = noteTextSize()
    const sizes = scaledSizes(this.mermaid.mermaidAPI.defaultConfig, this.textSize)
    const { fontSize, ...sectionSizes } = sizes.config

    const config = { ...this.obsidianConfig, fontSize }
    for (const type of FIT_TO_WIDTH_TYPES) config[type] = { ...config[type], useMaxWidth: true }
    for (const [type, values] of Object.entries(sectionSizes)) config[type] = { ...config[type], ...values }

    const theme = this.isDark ? { theme: 'dark', darkMode: true, themeCSS: darkThemeCss } : { theme: 'default' }
    const themeVariables = {
      ...(this.isDark ? darkThemeVariables : {}),
      ...sizes.themeVariables,
      fontFamily: this.fontFamily,
    }

    this.initialize.call(this.mermaid, { ...config, ...theme, themeVariables })
  }

  // Redraw when dark mode, the note's text size or its column width changes.
  // Diagrams are fitted to the column when drawn, so a new width needs a
  // redraw too.
  onCssChange() {
    const isDark = isDarkMode()
    const textSize = noteTextSize()
    const lineWidth = noteLineWidth()
    if (isDark === this.isDark && textSize === this.textSize && lineWidth === this.lineWidth) return

    this.isDark = isDark
    this.textSize = textSize
    this.lineWidth = lineWidth
    if (!this.mermaid) return
    this.applyTheme()
    this.requestRedraw()
  }

  // A drawn diagram keeps the colours it was drawn with, so rebuild the open
  // notes that show one. rebuildView() is Obsidian's internal leaf reload; it
  // keeps the scroll position.
  redrawDiagrams() {
    for (const leaf of this.app.workspace.getLeavesOfType('markdown')) {
      if (leaf.view.containerEl.querySelector('.mermaid')) leaf.rebuildView()
    }
  }
}
