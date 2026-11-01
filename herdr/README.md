# herdr

The user-owned part of `~/.config/herdr-app`, the Herdr desktop app's configuration.
Only files Herdr does not rewrite are kept here; shipped layouts, mods, icons, themes and the app's own bookkeeping stay out.
The live `~/.config/herdr-app/AGENTS.md` documents the whole surface and is rewritten on every start, so it is read in place rather than copied.

| path | what |
| --- | --- |
| `settings.json` | zoom, sounds, terminal font, theme |
| `keys.json` | every key binding |
| `layouts/amadej.json` | the `main` layout cloned |
| `themes/ghostty.json` | a GitHub-dark terminal theme |

## Sync

```
herdr/sync.sh pull   # ~/.config/herdr-app -> this folder
herdr/sync.sh push   # this folder -> ~/.config/herdr-app
```

Herdr applies pushed files live.
An invalid file is kept aside and the reason lands in `<name>.error` next to it.
