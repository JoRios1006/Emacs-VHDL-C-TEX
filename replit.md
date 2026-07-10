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

## VHDL Language Server

For full VHDL LSP support install `vhdl_ls`:

```bash
cargo install vhdl-ls
```

Then add `~/.cargo/bin` to your PATH and restart LSP (`SPC l R`).

## User preferences

- Vim (Evil) keybindings everywhere
- SPC as leader key
- 4-space indentation, no tabs
- Relative line numbers
- Doom One colour theme
