// Multi-select tabs via term-pick (television in a foot popup), then act.
// Load:  :js -f /home/xfo/.config/tridactyl/scripts/tab-multi.js
// Preset action / extra picker flags before loading:
//   window.tabMultiAction = "close"           // skip action picker
//   window.tabMultiPicker = "term-pick -m"    // override default picker
// Default picker is `term-pick` (nix-managed, wrapping `tv` in footclient).
// TV multi-select: Tab to toggle, Enter to confirm.

(async () => {
  const PICKER = (typeof window !== "undefined" && window.tabMultiPicker) || "term-pick";

  const ACTIONS = {
    close:    "close selected tabs",
    give:     "move to new window",
    take:     "pull into current window",
    pin:      "toggle pin",
    mute:     "toggle mute",
    reload:   "reload",
    bookmark: "bookmark",
  };

  async function pick(lines) {
    const res = await tri.native.run(PICKER, lines.join("\n"));
    if (res.code !== 0 || !res.content.trim()) return [];
    return res.content.trim().split("\n");
  }

  let action = (typeof window !== "undefined" && window.tabMultiAction) || null;
  if (typeof window !== "undefined") window.tabMultiAction = null; // consume
  if (!action) {
    const lines = Object.entries(ACTIONS).map(([k, v]) => `${k}\t${v}`);
    const picked = await pick(lines);
    if (!picked.length) return;
    action = picked[0].split("\t")[0];
  }
  if (!ACTIONS[action]) {
    tri.excmds.fillcmdline_tmp(3000, `tab-multi: unknown action '${action}'`);
    return;
  }

  const tabs = await browser.tabs.query({});
  if (!tabs.length) return;

  tabs.sort((a, b) =>
    (b.pinned - a.pinned) ||
    ((b.mutedInfo?.muted | 0) - (a.mutedInfo?.muted | 0)) ||
    (a.windowId - b.windowId) ||
    (a.index - b.index)
  );

  const lines = tabs.map(t => {
    let flags = "";
    if (t.mutedInfo?.muted) flags += "[M] ";
    else if (t.audible)     flags += "[A] ";
    if (t.pinned)           flags += "[P] ";
    return `${t.id}\t${t.windowId}/${t.index}\t${flags}${t.title}\t${t.url}`;
  });
  const picked = await pick(lines);
  if (!picked.length) return;
  const ids = picked.map(l => parseInt(l.split("\t")[0])).filter(n => !Number.isNaN(n));
  if (!ids.length) return;

  const getMany = () => Promise.all(ids.map(id => browser.tabs.get(id)));

  switch (action) {
    case "close":
      await browser.tabs.remove(ids);
      break;

    case "give": {
      const w = await browser.windows.create({ tabId: ids[0] });
      for (const id of ids.slice(1)) {
        await browser.tabs.move(id, { windowId: w.id, index: -1 });
      }
      break;
    }

    case "take": {
      const cur = await browser.windows.getCurrent();
      for (const id of ids) {
        await browser.tabs.move(id, { windowId: cur.id, index: -1 });
      }
      break;
    }

    case "pin": {
      for (const t of await getMany()) {
        await browser.tabs.update(t.id, { pinned: !t.pinned });
      }
      break;
    }

    case "mute": {
      for (const t of await getMany()) {
        await browser.tabs.update(t.id, { muted: !t.mutedInfo?.muted });
      }
      break;
    }

    case "reload":
      for (const id of ids) await browser.tabs.reload(id);
      break;

    case "bookmark": {
      for (const t of await getMany()) {
        await browser.bookmarks.create({ title: t.title, url: t.url });
      }
      break;
    }
  }

  tri.excmds.fillcmdline_tmp(2000, `tab-multi: ${action} on ${ids.length} tab(s)`);
})();
