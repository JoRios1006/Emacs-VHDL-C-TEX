---
name: Emacs batch validation
description: Reliable validation of this workspace's Emacs configuration and package metadata.
---

When validating the full Emacs configuration non-interactively, load
`early-init.el` and `init.el` explicitly with `emacs --batch -Q`; plain batch
mode skips the normal init and produces false negatives for package loading.

**Why:** A plain batch invocation reported missing packages even though the
interactive workflow loaded them correctly. The project-local ELPA archive can
also contain stale MELPA entries, so package installation may require one
explicit `package-refresh-contents` before installing newly referenced
packages.

**How to apply:** Use explicit init loading for smoke tests, and refresh the
package archive only when a package install reports a missing tar or stale
archive entry. For commands that invoke `compile`, inspect the buffer returned
by the command; repeated compile calls can reuse or rename compilation buffers,
so a fixed `*compilation*` lookup can read stale output. Do not print secret
values while testing API-backed packages.