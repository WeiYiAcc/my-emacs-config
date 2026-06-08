;;; setup-ekg.el --- EKG + agent-shell 配置 -*- lexical-binding: t; -*-

;;; Commentary:
;; EKG (Emacs Knowledge Graph) 作为知识库 + org task 管理。
;; agent-shell 作为 AI agent 交互层。

;;; Code:

;; ─── EKG ───────────────────────────────────────────────────
(use-package ekg
  :ensure t
  :config
  (setq ekg-db-file (expand-file-name "~/.local/share/ekg/ekg.db"))
  (setq ekg-capture-default-mode 'org-mode)
  (setq ekg-logseq-dir (expand-file-name "~/sync/ekg-export/"))
  (require 'ekg-llm)
  (require 'ekg-embedding)
  (require 'ekg-logseq)
  (require 'ekg-org)
  (ekg-connect)

  ;; Org agenda 集成
  (add-to-list 'org-agenda-files "/ekg:tasks.org")

  :bind
  (("C-c t" . my/ekg-capture-task)
   ("C-c n" . my/ekg-capture-note)
   ("C-c d" . my/ekg-capture-decision)
   ("C-c e t" . ekg-show-notes-with-tag)
   ("C-c e l" . ekg-show-notes-latest-captured)
   ("C-c e s" . ekg-search)
   ("C-c e a" . org-agenda)))

;; ─── 快捷 capture ──────────────────────────────────────────
(defun my/ekg-capture-task ()
  "快速创建 org task。"
  (interactive)
  (ekg-capture :tags '("org/task" "org/state/todo")))

(defun my/ekg-capture-note ()
  "快速创建笔记。"
  (interactive)
  (ekg-capture :tags '("inbox")))

(defun my/ekg-capture-decision ()
  "快速创建 decision 笔记。"
  (interactive)
  (ekg-capture :tags '("decision")))

;; ─── agent-shell (以后启用) ─────────────────────────────────
;; (use-package agent-shell
;;   :ensure t
;;   :commands (agent-shell-start-claude-code-agent)
;;   :bind ("C-c a" . agent-shell-start-claude-code-agent))

(provide 'setup-ekg)

;;; setup-ekg.el ends here
