# Emacs VHDL / C / Lua / LaTeX Environment

A complete Emacs configuration for VHDL, C, and Lua development with LaTeX support, running on Replit.

## How to run

Click **Run** (or start the `Start application` workflow). Emacs opens in the terminal in `no-window` mode (`-nw`).

On the **very first launch** Emacs will fetch and install all MELPA packages automatically — this takes ~1–3 minutes depending on network speed. Subsequent launches are instant.

```
emacs -nw --init-directory .
```

## Config files

| File | Purpose |
|------|---------|
| `early-init.el` | Performance tweaks + UI suppression before GUI |
| `init.el` | Full configuration (evil, LSP, VHDL, C, LaTeX, …) |

## Key bindings (SPC leader)

All major commands are behind `SPC` in Normal mode.

| Prefix | Group |
|--------|-------|
| `SPC b` | Buffers |
| `SPC f` | Files |
| `SPC w` | Windows |
| `SPC s` | Search (ripgrep) |
| `SPC p` | Projectile (projects) |
| `SPC g` | Magit (git) |
| `SPC l` | LSP (go-to-def, rename, format…) |
| `SPC u` | Lua scripting and Busted tests |
| `SPC t` | Toggles (focus mode, line numbers…) |
| `SPC z` | Code folding |
| `SPC h` | Help |
| `SPC SPC` | `M-x` (command palette) |

## Installed features

- **Evil** — full Vim keybindings via `evil` + `evil-collection`
- **LSP** — `lsp-mode` with `clangd` (C/C++), `vhdl_ls` (VHDL), and
  LuaLS (Lua 5.2)
- **Lua** — `lua-mode`, LuaLS completion/diagnostics, script execution, and
  Busted file/project test commands
- **C / C++** — `cc-mode`, clangd LSP, cmake-mode
- **SDL3 / C** — SDL3 lifecycle, event loop, rendering, input, textures,
  timing, logging, and asset snippets; SDL3-aware Makefile templates
- **Raylib / C** — Raylib window lifecycle, drawing, input, textures, cameras,
  collision, audio, timing, logging, and Raylib-aware Makefile templates
- **Visual novel patterns** — scene nodes, choices, flags, typewriter text,
  screen dispatch, resource bundles, UI widgets, and transitions
- **VHDL** — `vhdl-mode` (built-in), stutter mode, electric mode, LSP-ready
- **LaTeX** — AUCTeX, RefTeX, company-auctex, flyspell
- **Flycheck** — live syntax checking with inline error display
- **Snippets** — YASnippet + yasnippet-snippets collection
- **Magit** — full git porcelain (`SPC g g`)
- **Projectile** — project management (`SPC p`)
- **Company** — in-buffer completion with company-box UI
- **Vertico / Orderless / Consult** — minibuffer completion
- **Doom Solarized High Contrast theme** + doom-modeline
- **Olivetti** — distraction-free focus mode (`SPC t f`)
- **Which-key** — popup showing available key bindings
- **Code folding** — structural folds for C/C++, heading folds for VHDL and
  Makefiles, and AUCTeX folds for LaTeX
- **AI assistance** — optional Gemini integration through `gptel` and
  `minuet`, enabled only when `GEMINI_API_KEY` exists in Replit Secrets

## System dependencies (installed via Nix)

- `emacs` (30.x)
- `gcc`, `clang-tools` (clangd), `cmake`, `gnumake`
- `ghdl` — VHDL simulator (for FPGA/simulation workflows)
- `raylib`, `pkg-config` — Raylib C development and Makefile discovery
- Lua 5.2 (Replit Lua Tools module), `lua-language-server`, and `busted` —
  Lua scripting and tests
- `ripgrep`, `fd`, `ispell`

## SDL3 projects

The SDL3 snippets target **SDL3**, not SDL2. In a C buffer, type a snippet key
and press `TAB`; useful keys include:

| Key | Expansion |
|-----|-----------|
| `sdlmain` | Complete SDL3 window, renderer, event loop, and cleanup program |
| `sdlinit` / `sdlwindow` / `sdlrenderer` | Initialization building blocks |
| `sdlevent` / `sdlkey` / `sdlmouse` | SDL3 event handling |
| `sdldraw` / `sdlrect` / `sdltexture` / `sdlcopy` | Rendering helpers |
| `sdlloop` / `sdlticks` | Frame loop and frame timing |
| `sdlcleanup` / `sdlerr` / `sdllog` | Resource cleanup and diagnostics |

For a project Makefile, use `sdlproj` for a multi-file `src/` project or
`sdlsingle` for a single `main.c`. Both use:

```make
pkg-config --cflags sdl3
pkg-config --libs sdl3
```

The generated targets are `make`, `make run`, `make debug`, `make check`, and
`make clean`. If SDL3 is installed in a non-standard prefix, set
`PKG_CONFIG_PATH` before starting Emacs. The `sdlflags` snippet is useful when
adding SDL3 to an existing Makefile.

SDL3 commands are available through the leader key:

| Key | Command |
|-----|---------|
| `SPC d b` | Build nearest Makefile project |
| `SPC d r` | Build and run |
| `SPC d d` | Sanitized debug build |
| `SPC d c` | Syntax check |
| `SPC d x` | Clean build artifacts |

## Code folding

Folding is available with familiar Evil/Vim keys:

| Key | Action |
|-----|--------|
| `za` | Toggle fold at point |
| `zc` | Close fold |
| `zo` | Open fold |
| `zM` | Close all folds |
| `zR` | Open all folds |
| `zl` | Hide below the first outline level |

The same commands are also available under `SPC z` and appear in which-key.
C/C++ use structural brace folding. VHDL folds common declarations such as
entities, architectures, processes, packages, functions, and procedures.
Makefiles fold target sections. LaTeX uses AUCTeX's environment/macro folding
when the TeX-fold library is available.

## AI assistance

When `GEMINI_API_KEY` is configured as a Replit Secret, the optional Gemini
tools are enabled:

| Key | Action |
|-----|--------|
| `SPC a a` | Open a gptel chat buffer |
| `SPC a s` | Send the current context to Gemini |
| `SPC a m` | Open the gptel menu |
| `M-i` | Show a Minuet inline completion |

The key is intentionally not stored in `init.el`, uploaded files, or Git.

## Raylib projects

The Raylib snippets target current Raylib C APIs. In a C buffer, type a
snippet key and press `TAB`; useful keys include:

| Key | Expansion |
|-----|-----------|
| `raymain` | Complete Raylib window, game loop, drawing, and cleanup program |
| `raywindow` / `rayloop` / `raydraw` | Window and frame-loop building blocks |
| `rayinput` / `raykey` / `raymouse` | Keyboard and mouse input |
| `rayrect` / `raycircle` / `rayline` / `raytext` | 2D drawing helpers |
| `raytexture` / `raytexturedraw` | Texture loading and drawing |
| `raycamera` / `raycamdraw` | 2D camera setup and world drawing |
| `raycollision` / `raydelta` | Collision and frame-independent movement |
| `rayaudio` / `rayaudiocleanup` | Sound initialization and cleanup |
| `raycleanup` / `raylog` | Resource cleanup and diagnostics |

Use `rayproj` for a multi-file `src/` project or `raysingle` for a single
`main.c`. Both use:

```make
pkg-config --cflags raylib
pkg-config --libs raylib
```

Available targets are `make`, `make run`, `make debug`, `make release`,
`make check`, and `make clean`. Raylib commands use the nearest ancestor
`Makefile`:

| Key | Command |
|-----|---------|
| `SPC r b` | Build nearest Raylib Makefile project |
| `SPC r r` | Build and run |
| `SPC r d` | Sanitized debug build |
| `SPC r c` | Syntax check |
| `SPC r x` | Clean build artifacts |

## Patterns from the current Raylib game

The uploaded game source is intentionally ignored by Git through
`attached_assets/`. Its architecture suggests a few patterns that are now
available as snippets:

| Key | Pattern |
|-----|---------|
| `raystate` / `rayscreen` / `raygoto` | Validated game states and dispatch table |
| `raycontext` | One application context instead of scattered globals |
| `rayresources` / `rayloadresources` / `rayunloadresources` | Matched asset ownership |
| `raycenter` / `raybg` | Reusable drawing helpers |
| `raybutton` / `rayslider` / `raytoggle` | UI widgets with input handling |
| `rayfade` / `raymusic` | Transitions and audio lifecycle |
| `vnscene` / `vnchoice` / `vntype` / `vnflag` | Visual-novel data and progression |
| `rayassets` | Makefile asset-directory validation |
| `rayrunargs` | Makefile run target with configurable arguments |

### Source review notes

The uploaded file is not modified or tracked. Before using it as the long-term
base, I recommend these small cleanups:

1. Move the `NodoEscena` and `OpcionDecision` typedefs above the TODO
   prototypes that use them, or add forward declarations.
2. Keep resource ownership symmetric: every successful load should have one
   matching unload. The current `UnloadResources` unloads `marcoTexture` twice.
3. Replace scattered mutable globals with an `AppContext`/game-state struct
   gradually; this makes save/load, testing, and adding screens much easier.
4. Let screen update functions receive a context pointer instead of relying on
   global state. A table of function pointers can remain, but become
   `void (*ScreenFunc)(AppContext *)`.
5. Use designated initializers for sliders and toggles so future struct fields
   cannot silently change their meaning:

   ```c
   static Slider sldMaster = {
       .label = "MASTER VOLUME",
       .value = 1.0f
   };
   ```

6. Keep content data separate from rendering code. Scene nodes, choices,
   flags, localization keys, and save data will eventually be easier to
   validate and edit outside the main C file.

## VHDL Language Server

VHDL LSP is fully configured out of the box. `lsp-mode` ships a built-in
`lsp-vhdl` client supporting four backends (`vhdl-tool`, `hdl-checker`,
`vhdl-ls`, `ghdl-ls`); this project uses **VHDL-LS** (`rust_hdl`), installed
via Nix as the `vhdl_ls` binary, and pins it explicitly in `init.el`:

```elisp
(lsp-vhdl-server 'vhdl-ls)
(lsp-vhdl-server-path (executable-find "vhdl_ls"))
```

Opening a `.vhd`/`.vhdl` file should show `LSP[vhdl-ls]` in the modeline with
diagnostics, go-to-definition, and find-references working immediately.

## Lua scripting and tests

Lua buffers use `lua-mode` with the bundled `lsp-mode` LuaLS client, configured
for the installed Lua 5.2 runtime. The project provides `lua`, LuaLS, and
Busted; missing executables are reported explicitly by the run commands.

| Key | Action |
|-----|--------|
| `SPC u f` | Run the current Lua file |
| `SPC u T` | Run the current file with Busted |
| `SPC u t` | Run the project's Busted test suite |

Test commands use Emacs compilation buffers. Busted discovers the suite using
its standard project conventions; use a `.busted` file or Git root to mark the
project directory.

## User preferences

- Vim (Evil) keybindings everywhere
- SPC as leader key
- 4-space indentation, no tabs
- Relative line numbers
- Doom Solarized High Contrast colour theme
