import { View, div } from "gpui-kit";
import { run, layout, props, closeOverlay, checking } from "herdr";

// Opened by a key (keys.json: "mod.open:panel-files"). Does what the tab bar's
// Files button does (show the right panel on Files, or hide it if Files is
// already shown), then closes itself. Same as mods/panel-changes except PANEL.
const PANEL = "files";

/** @param {any} node @param {string} id @returns {any} */
function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

export default class PanelFiles extends View {
  init() {
    if (checking()) return;
    const root = layout();
    const panel = find(root, "panel");
    const body = find(root, "panel-body");
    if (panel && body) {
      if (!panel.hidden && body.active === PANEL) {
        run("layout.hide", { id: "panel" });
      } else {
        run("layout.select", { stack: "panel-body", child: PANEL });
        run("layout.show", { id: "panel" });
      }
    }
    closeOverlay(props().overlay);
  }

  render() {
    return div();
  }
}
