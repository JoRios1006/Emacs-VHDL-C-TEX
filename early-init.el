;;; early-init.el --- Early initialization -*- lexical-binding: t -*-
;;; Commentary:
;; Loaded before init.el and before the package system and GUI is initialized.
;; Use this for performance tweaks and UI suppression.

;;; Code:

;; ── Performance ────────────────────────────────────────────────────────────
;; Defer GC during startup; restore afterward (see init.el gc-cons-threshold hook)
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Don't load outdated byte-compiled files
(setq load-prefer-newer t)

;; ── Disable package.el early (straight.el / use-package takes over) ────────
;; We still use package.el but we disable it here to control init order.
;; Re-enabled in init.el.
(setq package-enable-at-startup nil)

;; ── UI suppressions (before frame paint) ───────────────────────────────────
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message (user-login-name))

;;; early-init.el ends here
