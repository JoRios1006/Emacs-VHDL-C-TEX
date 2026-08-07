# Emacs VHDL / C / LaTeX Environment

A complete Emacs configuration for VHDL and C development with LaTeX support, running on Replit.

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
| `SPC t` | Toggles (focus mode, line numbers…) |
| `SPC h` | Help |
| `SPC SPC` | `M-x` (command palette) |

## Installed features

- **Evil** — full Vim keybindings via `evil` + `evil-collection`
- **LSP** — `lsp-mode` with `clangd` (C/C++) and `vhdl_ls` (VHDL)
- **C / C++** — `cc-mode`, clangd LSP, cmake-mode
- **SDL3 / C** — SDL3 lifecycle, event loop, rendering, input, textures,
  timing, logging, and asset snippets; SDL3-aware Makefile templates
- **VHDL** — `vhdl-mode` (built-in), stutter mode, electric mode, LSP-ready
- **LaTeX** — AUCTeX, RefTeX, company-auctex, flyspell
- **Flycheck** — live syntax checking with inline error display
- **Snippets** — YASnippet + yasnippet-snippets collection
- **Magit** — full git porcelain (`SPC g g`)
- **Projectile** — project management (`SPC p`)
- **Company** — in-buffer completion with company-box UI
- **Vertico / Orderless / Consult** — minibuffer completion
- **Doom One theme** + doom-modeline
- **Olivetti** — distraction-free focus mode (`SPC t f`)
- **Which-key** — popup showing available key bindings

## System dependencies (installed via Nix)

- `emacs` (30.x)
- `gcc`, `clang-tools` (clangd), `cmake`, `gnumake`
- `ghdl` — VHDL simulator (for FPGA/simulation workflows)
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

## User preferences

- Vim (Evil) keybindings everywhere
- SPC as leader key
- 4-space indentation, no tabs
- Relative line numbers
- Doom One colour theme
