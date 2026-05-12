;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

;; ariadne-fact: TypeScript Polylith + Clojure bb-bricks
;;   bases/         — TypeScript (fact-manager, fact-hooks, polylith-lint)
;;   lib/           — TypeScript components (fact, hooks, store, lint)
;;   bb-bricks/     — Clojure Polylith, top-ns: af
;;   server/        — Clojure DataScript HTTP server (port 7735, nREPL 7736)

((typescript-mode
  . (;; tide + TypeScript LSP
     (tide-tsserver-executable . "tsserver")
     ;; prettier 格式化
     (prettier-js-args . ("--single-quote" "--trailing-comma" "all"))
     ;; flycheck
     (flycheck-checker . typescript-tide)))
 (clojure-mode
  . (;; bb-bricks workspace
     (cider-clojure-cli-global-options . "-A:dev")
     (cider-repl-history-file . "~/.emacs.d/cider-history-ariadne-fact")
     ;; nREPL port 7736（server 运行时）
     (cider-nrepl-port . 7736)))
 (nil
  . ((projectile-project-type . generic)
     (projectile-project-root-files . ("bb.edn" "package.json")))))
