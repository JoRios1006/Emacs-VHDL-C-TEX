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
;; Load locally cached archive metadata so use-package can install newly
;; referenced packages without refreshing MELPA on every startup.
(unless (bound-and-true-p package-archive-contents)
  (package-read-all-archive-contents))

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
  (setq doom-themes-solarized-brighter-comments t)
  (load-theme 'doom-solarized-dark-high-contrast t)
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

    ;; VHDL / GHDL
    "v"  '(:ignore t :which-key "vhdl/ghdl")
    "va" '(ghdl-analyze                :which-key "analyze file")
    "vi" '(ghdl-import                 :which-key "import file")
    "ve" '(ghdl-elaborate              :which-key "elaborate")
    "vr" '(ghdl-run                    :which-key "run/simulate")
    "vx" '(ghdl-build-run              :which-key "build+run (binary)")
    "vc" '(ghdl-clean                  :which-key "clean work lib")

    ;; SDL3 project
    "d"  '(:ignore t :which-key "SDL3")
    "db" '(sdl-build                   :which-key "build")
    "dr" '(sdl-run                     :which-key "build+run")
    "dd" '(sdl-debug                   :which-key "debug + sanitizers")
    "dc" '(sdl-check                   :which-key "syntax check")
    "dx" '(sdl-clean                   :which-key "clean")

    ;; Raylib project
    "r"  '(:ignore t :which-key "Raylib")
    "rb" '(ray-build                   :which-key "build")
    "rr" '(ray-run                     :which-key "build+run")
    "rd" '(ray-debug                   :which-key "debug + sanitizers")
    "rc" '(ray-check                   :which-key "syntax check")
    "rx" '(ray-clean                   :which-key "clean")

    ;; Code folding
    "z"  '(:ignore t :which-key "folding")
    "za" '(my-fold-toggle               :which-key "toggle fold")
    "zc" '(my-fold-close                :which-key "close fold")
    "zo" '(my-fold-open                 :which-key "open fold")
    "zM" '(my-fold-hide-all             :which-key "close all")
    "zR" '(my-fold-show-all             :which-key "open all")
    "zl" '(my-fold-hide-level           :which-key "hide level")

    ;; Open / misc
    "o"  '(:ignore t :which-key "open")
    "oe" '(eshell                      :which-key "eshell")
    "ot" '(vterm                       :which-key "terminal")
    "."  '(find-file                   :which-key "find file")
    "SPC" '(execute-extended-command   :which-key "M-x")
    "q"  '(:ignore t :which-key "quit")
    "qq" '(save-buffers-kill-emacs     :which-key "quit"))

  ;; Familiar Evil/Vim fold keys.  SPC z remains available as a discoverable
  ;; alternative through which-key.
  (general-define-key
   :states '(normal visual)
   :keymaps 'override
   "za" #'my-fold-toggle
   "zc" #'my-fold-close
   "zo" #'my-fold-open
   "zM" #'my-fold-hide-all
   "zR" #'my-fold-show-all
   "zl" #'my-fold-hide-level))

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
  :config
  ;; Prepend our custom snippets directory so it takes priority over
  ;; yasnippet-snippets for any overrides.  The default entry
  ;; (expand-file-name "snippets/" user-emacs-directory) is already
  ;; included by yasnippet; adding it explicitly here ensures order.
  (add-to-list 'yas-snippet-dirs
               (expand-file-name "snippets/" user-emacs-directory) t)
  ;; AUCTeX uses LaTeX-mode (capital L) — teach yasnippet to also look
  ;; in latex-mode directory for that major mode.
  (add-hook 'LaTeX-mode-hook
            (lambda ()
              (yas-activate-extra-mode 'latex-mode)))
  ;; Emacs uses makefile-gmake-mode for GNU Makefiles; keep the snippets
  ;; directory named makefile-mode while activating it for both variants.
  (dolist (mode '(makefile-gmake-mode makefile-bsdmake-mode))
    (add-hook (intern (format "%s-hook" mode))
              (lambda ()
                (yas-activate-extra-mode 'makefile-mode))))
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

;; ── Code folding ───────────────────────────────────────────────────────────
;; hideshow is built into Emacs and folds structural blocks in C/C++.
(use-package hideshow
  :ensure nil
  :commands (hs-minor-mode hs-toggle-hiding hs-hide-block hs-show-block
                            hs-hide-all hs-show-all hs-hide-level)
  :hook ((c-mode                 . hs-minor-mode)
         (c++-mode               . hs-minor-mode))
  :custom
  (hs-hide-comments-when-hiding-all nil)
  (hs-isearch-open t)
  :config
  (defun my-hs-mode-setup ()
    "Allow nested folds and keep folding state local to each buffer."
    (setq-local hs-allow-nesting t))
  (add-hook 'hs-minor-mode-hook #'my-hs-mode-setup))

;; outline-minor-mode gives VHDL and Makefiles useful heading-based folding:
;; entities/architectures/processes for VHDL, and targets for Makefiles.
(use-package outline
  :ensure nil
  :commands (outline-minor-mode outline-cycle outline-hide-entry
                                 outline-show-entry outline-hide-sublevels
                                 outline-show-all)
  :config
  (defun my-vhdl-outline-setup ()
    "Configure foldable structural headings for VHDL buffers."
    (setq-local outline-regexp
                "^[ \t]*\\(architecture\\|entity\\|package\\|process\\|function\\|procedure\\|component\\|configuration\\|--[ \t]*[-=]+\\)\\_>")
    (outline-minor-mode 1))

  (defun my-makefile-outline-setup ()
    "Configure foldable target headings for Makefiles."
    (setq-local outline-regexp
                "^[ \t]*\\(?:[[:alnum:]_.-]+\\):")
    (outline-minor-mode 1))

  (defun my-tex-fold-setup ()
    "Enable AUCTeX folding when its optional TeX-fold library is loaded."
    (when (fboundp 'TeX-fold-mode)
      (TeX-fold-mode 1)))

  (add-hook 'vhdl-mode-hook #'my-vhdl-outline-setup)
  (add-hook 'makefile-gmake-mode-hook #'my-makefile-outline-setup)
  (add-hook 'makefile-bsdmake-mode-hook #'my-makefile-outline-setup)

  (defun my-fold-toggle ()
    "Toggle the fold at point for the current major mode."
    (interactive)
    (cond
     ((bound-and-true-p hs-minor-mode) (hs-toggle-hiding))
     ((bound-and-true-p outline-minor-mode) (outline-cycle))
     ((fboundp 'TeX-fold-dwim) (TeX-fold-dwim))
     (t (user-error "No folding support in %s" major-mode))))

  (defun my-fold-close ()
    "Close the fold at point."
    (interactive)
    (cond
     ((bound-and-true-p hs-minor-mode) (hs-hide-block))
     ((bound-and-true-p outline-minor-mode) (outline-hide-entry))
     ((fboundp 'TeX-fold-dwim) (TeX-fold-dwim))
     (t (user-error "No folding support in %s" major-mode))))

  (defun my-fold-open ()
    "Open the fold at point."
    (interactive)
    (cond
     ((bound-and-true-p hs-minor-mode) (hs-show-block))
     ((bound-and-true-p outline-minor-mode) (outline-show-entry))
     ((fboundp 'TeX-fold-dwim) (TeX-fold-dwim))
     (t (user-error "No folding support in %s" major-mode))))

  (defun my-fold-hide-all ()
    "Close all folds in the current buffer."
    (interactive)
    (cond
     ((bound-and-true-p hs-minor-mode) (hs-hide-all))
     ((bound-and-true-p outline-minor-mode) (outline-hide-sublevels 1))
     ((fboundp 'TeX-fold-buffer) (TeX-fold-buffer))
     (t (user-error "No folding support in %s" major-mode))))

  (defun my-fold-show-all ()
    "Open all folds in the current buffer."
    (interactive)
    (cond
     ((bound-and-true-p hs-minor-mode) (hs-show-all))
     ((bound-and-true-p outline-minor-mode) (outline-show-all))
     ((fboundp 'TeX-fold-clearout-buffer) (TeX-fold-clearout-buffer))
     (t (user-error "No folding support in %s" major-mode))))

  (defun my-fold-hide-level ()
    "Hide everything below the first outline level."
    (interactive)
    (cond
     ((bound-and-true-p hs-minor-mode) (hs-hide-level 1))
     ((bound-and-true-p outline-minor-mode) (outline-hide-sublevels 1))
     (t (user-error "No folding support in %s" major-mode)))))

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

;; VHDL Language Server — lsp-mode ships a built-in `lsp-vhdl` client
;; (see lsp-vhdl.el) supporting four backends: vhdl-tool (default),
;; hdl-checker, vhdl-ls, and ghdl-ls. We use VHDL-LS (rust_hdl), which is
;; installed via Nix (`vhdl_ls` binary) — a complete LSP implementation
;; with diagnostics, go-to-definition, and find-references.
(use-package lsp-vhdl
  :ensure nil                            ; bundled inside lsp-mode
  :after (lsp-mode vhdl-mode)
  :custom
  (lsp-vhdl-server 'vhdl-ls)
  (lsp-vhdl-server-path (executable-find "vhdl_ls")))

;; ── GHDL build helpers ────────────────────────────────────────────────────
;; All commands run in a *compilation* buffer so error lines are clickable.
;; Adjust `ghdl-std' to match your project's VHDL revision.

(defvar ghdl-std "--std=08"
  "VHDL standard flag passed to every GHDL invocation (--std=93|08|19).")

(defun ghdl--file ()
  "Return the current buffer's file path, or signal an error."
  (or (buffer-file-name)
      (user-error "Buffer is not visiting a file")))

(defun ghdl--entity-default ()
  "Guess the top-level entity name from the current buffer's file stem."
  (file-name-base (or (buffer-file-name) "")))

;;;###autoload
(defun ghdl-analyze ()
  "Analyze the current VHDL file: ghdl -a [std] <file>."
  (interactive)
  (compile (format "ghdl -a %s %s" ghdl-std
                   (shell-quote-argument (ghdl--file)))))

;;;###autoload
(defun ghdl-import ()
  "Import current VHDL file into the work library: ghdl -i [std] <file>."
  (interactive)
  (compile (format "ghdl -i %s %s" ghdl-std
                   (shell-quote-argument (ghdl--file)))))

;;;###autoload
(defun ghdl-elaborate (entity)
  "Elaborate design unit ENTITY: ghdl -e [std] <entity>."
  (interactive (list (read-string "Elaborate entity: " (ghdl--entity-default))))
  (compile (format "ghdl -e %s %s" ghdl-std
                   (shell-quote-argument entity))))

;;;###autoload
(defun ghdl-run (entity)
  "Simulate ENTITY with ghdl -r; optionally prompt for --stop-time."
  (interactive (list (read-string "Simulate entity: " (ghdl--entity-default))))
  (let* ((stop (read-string "Stop time (e.g. 1us, blank = none): "))
         (stop-flag (if (string-empty-p stop) ""
                      (format " --stop-time=%s" stop))))
    (compile (format "ghdl -r %s %s%s" ghdl-std
                     (shell-quote-argument entity) stop-flag))))

;;;###autoload
(defun ghdl-build-run (entity)
  "Analyze current file, elaborate, link to binary, then run it.
Equivalent to: ghdl -a <file> && ghdl -e -o <entity> <entity> && ./<entity>"
  (interactive (list (read-string "Top entity (= binary name): "
                                  (ghdl--entity-default))))
  (let ((q-file   (shell-quote-argument (ghdl--file)))
        (q-entity (shell-quote-argument entity)))
    (compile (format "ghdl -a %s %s && ghdl -e %s -o %s %s && ./%s"
                     ghdl-std q-file
                     ghdl-std q-entity q-entity
                     entity))))

;;;###autoload
(defun ghdl-clean ()
  "Remove GHDL work-library artifacts from the current directory."
  (interactive)
  (compile "ghdl --remove"))

;; ── SDL3 build helpers ────────────────────────────────────────────────────
;; These use the Makefile in the nearest ancestor directory.  The SDL3
;; snippets provide Makefiles based on pkg-config, so this also works when
;; SDL3 is installed outside the default compiler search path.

(defun sdl--project-directory ()
  "Return the nearest directory containing a Makefile.
Signal a user error when none can be found."
  (or (locate-dominating-file default-directory "Makefile")
      (user-error "No Makefile found above %s" default-directory)))

(defun sdl--make (target)
  "Run make TARGET from the nearest SDL project directory."
  (let ((default-directory (sdl--project-directory)))
    (compile (format "make %s" target))))

;;;###autoload
(defun sdl-build ()
  "Build the SDL3 project with its default Makefile target."
  (interactive)
  (sdl--make "all"))

;;;###autoload
(defun sdl-run ()
  "Build and run the SDL3 project."
  (interactive)
  (sdl--make "run"))

;;;###autoload
(defun sdl-debug ()
  "Build the SDL3 project with sanitizers and debug flags."
  (interactive)
  (sdl--make "debug"))

;;;###autoload
(defun sdl-check ()
  "Run the SDL3 project's compiler syntax checks."
  (interactive)
  (sdl--make "check"))

;;;###autoload
(defun sdl-clean ()
  "Remove SDL3 project build artifacts."
  (interactive)
  (sdl--make "clean"))

;; ── Raylib build helpers ──────────────────────────────────────────────────
;; Raylib snippets use pkg-config and the nearest Makefile, just like the
;; SDL3 helpers above, but remain separate so both project types can coexist.

(defun ray--project-directory ()
  "Return the nearest directory containing a Makefile."
  (or (locate-dominating-file default-directory "Makefile")
      (user-error "No Makefile found above %s" default-directory)))

(defun ray--make (target)
  "Run make TARGET from the nearest Raylib project directory."
  (let ((default-directory (ray--project-directory)))
    (compile (format "make %s" target))))

;;;###autoload
(defun ray-build ()
  "Build the Raylib project with its default Makefile target."
  (interactive)
  (ray--make "all"))

;;;###autoload
(defun ray-run ()
  "Build and run the Raylib project."
  (interactive)
  (ray--make "run"))

;;;###autoload
(defun ray-debug ()
  "Build the Raylib project with sanitizers and debug flags."
  (interactive)
  (ray--make "debug"))

;;;###autoload
(defun ray-check ()
  "Run the Raylib project's compiler syntax checks."
  (interactive)
  (ray--make "check"))

;;;###autoload
(defun ray-clean ()
  "Remove Raylib project build artifacts."
  (interactive)
  (ray--make "clean"))

;; ── LaTeX (AUCTeX) ────────────────────────────────────────────────────────
(use-package auctex
  :defer t
  :hook ((LaTeX-mode . lsp-deferred)
         (LaTeX-mode . flycheck-mode)
         (LaTeX-mode . flyspell-mode)
         (LaTeX-mode . LaTeX-math-mode)
         (LaTeX-mode . turn-on-reftex)
         ;; AUCTeX folds environments/macros with its own TeX-fold support.
         (LaTeX-mode . my-tex-fold-setup))
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

;; ── AI assistance: Gemini through gptel and minuet ─────────────────────────
;; The API key must live in Replit Secrets as GEMINI_API_KEY. These packages
;; stay inactive when the secret is absent, so a fresh clone still starts
;; normally without embedding credentials in this file.
(use-package gptel
  :if (getenv "GEMINI_API_KEY")
  :demand t
  :commands (gptel gptel-send gptel-menu)
  :custom
  (gptel-model 'gemini-3.6-flash)
  :config
  (setq gptel-backend
        (gptel-make-openai
         "Gemini-OAI"
         :host "generativelanguage.googleapis.com"
         :endpoint "/v1beta/openai/chat/completions"
         :stream t
         :key (getenv "GEMINI_API_KEY")
         :models '(gemini-3.6-flash)))
  (leader-def
    "a"  '(:ignore t :which-key "AI")
    "aa" '(gptel       :which-key "chat buffer")
    "as" '(gptel-send  :which-key "send to AI")
    "am" '(gptel-menu  :which-key "gptel menu")))

(use-package minuet
  :if (getenv "GEMINI_API_KEY")
  :demand t
  :bind (("M-i" . minuet-show-suggestion))
  :config
  (setq minuet-provider 'openai-compatible
        minuet-openai-compatible-options
        `(:end-point
          "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
          :api-key ,(getenv "GEMINI_API_KEY")
          :model "gemini-3.6-flash"
          :name "Gemini")))

;; Show git diffs in the gutter
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :custom (git-gutter:update-interval 0.3))

;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
