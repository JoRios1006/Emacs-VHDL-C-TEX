;;; init.el --- Main Emacs configuration -*- lexical-binding: t -*-
;;; Commentary:
;; A complete Emacs environment for VHDL, C, and LaTeX development.
;; Features: Evil (Vim keys), LSP, VHDL, C/clangd, AUCTeX, Flycheck,
;;           Snippets, Magit, Projectile, Company, Doom theme, Focus mode.

;;; Code:

;; ── GC restore after startup ───────────────────────────────────────────────
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

;; ── Package bootstrap ──────────────────────────────────────────────────────
(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/packages/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t          ; auto-install missing packages
      use-package-always-defer  nil        ; load eagerly unless :defer given
      use-package-verbose       nil)

;; ── Core / defaults ────────────────────────────────────────────────────────
(use-package emacs
  :ensure nil
  :custom
  (user-full-name    "")
  (user-mail-address "")
  ;; Files
  (backup-directory-alist `(("." . ,(expand-file-name "backups/" user-emacs-directory))))
  (auto-save-file-name-transforms `((".*" ,(expand-file-name "auto-save/" user-emacs-directory) t)))
  (create-lockfiles nil)
  ;; Editing
  (indent-tabs-mode nil)
  (tab-width         4)
  (fill-column      80)
  (sentence-end-double-space nil)
  (require-final-newline t)
  ;; Display
  (display-line-numbers-type 'relative)
  (column-number-mode t)
  (show-paren-delay 0)
  ;; Scrolling
  (scroll-conservatively 101)
  (scroll-margin 3)
  :config
  (global-display-line-numbers-mode 1)
  (show-paren-mode 1)
  (electric-pair-mode 1)
  (delete-selection-mode 1)
  ;; Ensure backup/autosave dirs exist
  (make-directory (expand-file-name "backups/"   user-emacs-directory) t)
  (make-directory (expand-file-name "auto-save/" user-emacs-directory) t))

;; ── Theme & appearance ─────────────────────────────────────────────────────
(use-package doom-themes
  :config
  (setq doom-themes-enable-bold   t
        doom-themes-enable-italic t)
  (load-theme 'doom-one t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-height 28)
  (doom-modeline-bar-width 4)
  (doom-modeline-icon t)
  (doom-modeline-buffer-file-name-style 'truncate-upto-project))

(use-package nerd-icons
  :config
  ;; Install fonts on first run: M-x nerd-icons-install-fonts
  )

;; Show colour of hex colour strings inline
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; ── Evil (Vim keybindings) ────────────────────────────────────────────────
(use-package evil
  :init
  (setq evil-want-integration      t
        evil-want-keybinding       nil   ; evil-collection handles this
        evil-want-C-u-scroll       t
        evil-want-C-d-scroll       t
        evil-undo-system           'undo-redo
        evil-respect-visual-line-mode t
        evil-cross-lines           t)
  :config
  (evil-mode 1)
  ;; Make C-g always escape
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-replace-state-map (kbd "C-g") 'evil-normal-state))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))

(use-package evil-commentary
  :after evil
  :config (evil-commentary-mode 1))

;; ── Leader keys (SPC-centric) ──────────────────────────────────────────────
(use-package general
  :after evil
  :config
  (general-evil-setup t)

  (general-create-definer leader-def
    :states  '(normal visual emacs)
    :keymaps 'override
    :prefix  "SPC")

  (general-create-definer local-leader-def
    :states  '(normal visual emacs)
    :keymaps 'override
    :prefix  "SPC m")

  ;; ── Top-level SPC bindings ────────────────────────────────────────────
  (leader-def
    ;; Buffers
    "b"  '(:ignore t :which-key "buffer")
    "bb" '(switch-to-buffer            :which-key "switch")
    "bd" '(kill-current-buffer         :which-key "kill")
    "bn" '(next-buffer                 :which-key "next")
    "bp" '(previous-buffer             :which-key "prev")
    "bs" '(save-buffer                 :which-key "save")

    ;; Files
    "f"  '(:ignore t :which-key "file")
    "ff" '(find-file                   :which-key "find file")
    "fr" '(recentf-open-files          :which-key "recent")
    "fs" '(save-buffer                 :which-key "save")

    ;; Window
    "w"  '(:ignore t :which-key "window")
    "wh" '(windmove-left               :which-key "←")
    "wj" '(windmove-down               :which-key "↓")
    "wk" '(windmove-up                 :which-key "↑")
    "wl" '(windmove-right              :which-key "→")
    "ws" '(split-window-below          :which-key "split ↓")
    "wv" '(split-window-right          :which-key "split →")
    "wd" '(delete-window               :which-key "delete")
    "wD" '(delete-other-windows        :which-key "delete others")

    ;; Search (grep)
    "s"  '(:ignore t :which-key "search")
    "ss" '(consult-line                :which-key "line")
    "sg" '(consult-ripgrep             :which-key "ripgrep")
    "si" '(consult-imenu               :which-key "imenu")

    ;; Project (Projectile)
    "p"  '(:ignore t :which-key "project")
    "pp" '(projectile-switch-project   :which-key "switch")
    "pf" '(projectile-find-file        :which-key "find file")
    "pb" '(projectile-switch-to-buffer :which-key "buffer")
    "ps" '(projectile-ripgrep          :which-key "search")
    "pc" '(projectile-compile-project  :which-key "compile")

    ;; Git (Magit)
    "g"  '(:ignore t :which-key "git")
    "gg" '(magit-status                :which-key "status")
    "gb" '(magit-blame                 :which-key "blame")
    "gl" '(magit-log-current           :which-key "log")
    "gd" '(magit-diff-working-tree     :which-key "diff")

    ;; LSP
    "l"  '(:ignore t :which-key "lsp")
    "ld" '(lsp-find-definition         :which-key "definition")
    "lr" '(lsp-find-references         :which-key "references")
    "ln" '(lsp-rename                  :which-key "rename")
    "la" '(lsp-execute-code-action     :which-key "action")
    "lf" '(lsp-format-buffer           :which-key "format")
    "lh" '(lsp-describe-thing-at-point :which-key "hover")
    "le" '(flycheck-list-errors        :which-key "errors")
    "lR" '(lsp-restart-workspace       :which-key "restart lsp")

    ;; Toggle
    "t"  '(:ignore t :which-key "toggle")
    "tf" '(olivetti-mode               :which-key "focus")
    "tn" '(display-line-numbers-mode   :which-key "line numbers")
    "tw" '(whitespace-mode             :which-key "whitespace")
    "ts" '(flyspell-mode               :which-key "spell")

    ;; Help
    "h"  '(:ignore t :which-key "help")
    "hf" '(describe-function           :which-key "function")
    "hv" '(describe-variable           :which-key "variable")
    "hk" '(describe-key                :which-key "key")
    "hm" '(describe-mode               :which-key "mode")

    ;; Open / misc
    "o"  '(:ignore t :which-key "open")
    "oe" '(eshell                      :which-key "eshell")
    "ot" '(vterm                       :which-key "terminal")
    "."  '(find-file                   :which-key "find file")
    "SPC" '(execute-extended-command   :which-key "M-x")
    "q"  '(:ignore t :which-key "quit")
    "qq" '(save-buffers-kill-emacs     :which-key "quit")))

;; ── Which-key ─────────────────────────────────────────────────────────────
(use-package which-key
  :init (which-key-mode)
  :custom
  (which-key-idle-delay 0.4)
  (which-key-sort-order 'which-key-key-order-alpha))

;; ── Completion framework ───────────────────────────────────────────────────
(use-package vertico
  :init (vertico-mode)
  :custom (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles             '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :after vertico
  :init (marginalia-mode))

(use-package consult
  :bind (("C-s"     . consult-line)
         ("C-x b"   . consult-buffer)
         ("C-x r b" . consult-bookmark)
         ("M-g g"   . consult-goto-line)
         ("M-g o"   . consult-outline)))

;; ── In-buffer auto-completion (Company) ───────────────────────────────────
(use-package company
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay            0.2)
  (company-minimum-prefix-length 1)
  (company-tooltip-align-annotations t)
  (company-selection-wrap-around t)
  :bind (:map company-active-map
         ("C-n" . company-select-next)
         ("C-p" . company-select-previous)
         ("<tab>" . company-complete-selection)))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; ── Snippets ───────────────────────────────────────────────────────────────
(use-package yasnippet
  :config (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

;; ── Flycheck ───────────────────────────────────────────────────────────────
(use-package flycheck
  :hook (after-init . global-flycheck-mode)
  :custom
  (flycheck-display-errors-delay 0.3))

(use-package flycheck-pos-tip
  :after flycheck
  :config (flycheck-pos-tip-mode))

;; ── LSP ────────────────────────────────────────────────────────────────────
(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((c-mode        . lsp-deferred)
         (c++-mode      . lsp-deferred)
         (vhdl-mode     . lsp-deferred))
  :custom
  (lsp-keymap-prefix        "C-c l")
  (lsp-idle-delay           0.3)
  (lsp-log-io               nil)
  (lsp-completion-provider  :company-capf)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-modeline-diagnostics-enable  t)
  (lsp-enable-snippet               t)
  ;; Performance
  (lsp-enable-file-watchers         nil)
  (read-process-output-max          (* 1024 1024)))

(use-package lsp-ui
  :after lsp-mode
  :custom
  (lsp-ui-doc-enable            t)
  (lsp-ui-doc-position          'at-point)
  (lsp-ui-doc-delay             0.5)
  (lsp-ui-sideline-enable       t)
  (lsp-ui-sideline-show-hover   nil)
  (lsp-ui-peek-always-show      t))

;; ── C / C++ ────────────────────────────────────────────────────────────────
(use-package cc-mode
  :ensure nil
  :hook ((c-mode   . (lambda ()
                       (setq c-basic-offset 4
                             c-default-style "linux")))
         (c++-mode . (lambda ()
                       (setq c-basic-offset 4
                             c-default-style "stroustrup"))))
  :config
  ;; clangd is picked up automatically by lsp-mode when on PATH
  )

(use-package cmake-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'"         . cmake-mode)))

;; ── VHDL ───────────────────────────────────────────────────────────────────
(use-package vhdl-mode
  :ensure nil                            ; built-in
  :mode ("\\.vhd\\'" "\\.vhdl\\'")
  :custom
  (vhdl-electric-mode      t)            ; smart electric characters
  (vhdl-stutter-mode       t)            ; -- on ;; etc.
  (vhdl-indent-tabs-mode   nil)
  (vhdl-basic-offset       4)
  (vhdl-upper-keywords     'upcase)
  (vhdl-upper-types        'upcase)
  (vhdl-upper-attributes   'upcase)
  (vhdl-upper-enum-values  'upcase)
  (vhdl-upper-constants    'upcase))

;; VHDL Language Server (vhdl_ls) — install separately: cargo install vhdl-ls
;; lsp-mode will pick it up automatically when 'vhdl-ls' is on PATH.
;; No extra Emacs package required; lsp-mode ships built-in vhdl-ls support.

;; ── LaTeX (AUCTeX) ────────────────────────────────────────────────────────
(use-package auctex
  :defer t
  :hook ((LaTeX-mode . lsp-deferred)
         (LaTeX-mode . flycheck-mode)
         (LaTeX-mode . flyspell-mode)
         (LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . turn-on-reftex))
  :custom
  (TeX-auto-save          t)
  (TeX-parse-self         t)
  (TeX-master             nil)           ; ask for master file
  (TeX-PDF-mode           t)             ; compile to PDF
  (TeX-source-correlate-mode t)          ; SyncTeX
  (reftex-plug-into-AUCTeX t))

(use-package company-auctex
  :after (company auctex)
  :config (company-auctex-init))

;; ── Magit ──────────────────────────────────────────────────────────────────
(use-package magit
  :commands (magit-status magit-blame magit-log-current magit-diff-working-tree)
  :custom
  (magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1))

;; evil-collection already provides Magit Evil integration — no evil-magit needed.

;; ── Projectile ────────────────────────────────────────────────────────────
(use-package projectile
  :init (projectile-mode +1)
  :custom
  (projectile-project-search-path '("~/projects" "~/src"))
  (projectile-completion-system   'default)
  :bind-keymap
  ("C-c p" . projectile-command-map))

(use-package consult-projectile
  :after (consult projectile))

;; ── Focus mode ────────────────────────────────────────────────────────────
(use-package olivetti
  :commands olivetti-mode
  :custom
  (olivetti-body-width 100))

;; ── Terminal ───────────────────────────────────────────────────────────────
(use-package vterm
  :commands vterm
  :custom (vterm-max-scrollback 10000))

;; ── Misc QoL ───────────────────────────────────────────────────────────────
(use-package recentf
  :ensure nil
  :config
  (recentf-mode 1)
  (setq recentf-max-saved-items 200))

(use-package savehist
  :ensure nil
  :init (savehist-mode))

(use-package saveplace
  :ensure nil
  :init (save-place-mode))

;; Highlight TODO/FIXME/HACK keywords
(use-package hl-todo
  :hook (prog-mode . hl-todo-mode)
  :custom
  (hl-todo-keyword-faces
   '(("TODO"   . "#FFB86C")
     ("FIXME"  . "#FF5555")
     ("HACK"   . "#8BE9FD")
     ("NOTE"   . "#50FA7B")
     ("REVIEW" . "#BD93F9"))))

;; Dim non-active windows
(use-package dimmer
  :config
  (dimmer-configure-which-key)
  (dimmer-configure-magit)
  (dimmer-mode t)
  :custom (dimmer-fraction 0.25))

;; Show git diffs in the gutter
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :custom (git-gutter:update-interval 0.3))

;;; init.el ends here
