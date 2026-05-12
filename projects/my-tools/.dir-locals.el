;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

;; my-tools: 多语言 monorepo
;;   my-clj/  — Clojure Polylith, top-ns: my-clj
;;   my-py/   — Python Polylith, top-ns: toolbox
;;   my-fish/ my-nushell/ my-bash/ — shell scripts

((clojure-mode
  . (;; Polylith workspace root 是 my-clj/
     ;; CIDER 从 workspace.edn 发现 deps
     (cider-clojure-cli-global-options . "-A:dev")
     (cider-repl-history-file . "~/.emacs.d/cider-history-my-tools")
     ;; clj-kondo 用 workspace 级别配置
     (flycheck-clj-kondo-clj-kondo-executable . "clj-kondo")))
 (python-mode
  . ((python-shell-interpreter . "ipython")
     (python-shell-interpreter-args . "--simple-prompt")
     ;; my-py Polylith src roots
     (python-shell-extra-pythonpaths . ("components" "bases"))
     (eglot-server-programs . ((python-mode . ("ty" "server"))))
     (elpy-test-runner . elpy-test-pytest-runner)))
 (nil
  . ((projectile-project-type . generic)
     ;; 顶层 bb.edn 是入口
     (projectile-project-root-files . ("bb.edn")))))
