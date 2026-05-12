;;; Directory Local Variables
;;; For more information see (info "(emacs) Directory Variables")

;; subsidy-2026: Python Polylith (uv), namespace: subsidy
;; 组件: config, file_utils, form, ocr_namer, ooxml_utils, schema
;; base: etl

((python-mode
  . ((python-shell-interpreter . "ipython")
     (python-shell-interpreter-args . "--simple-prompt")
     ;; Polylith src roots — uv 用 PYTHONPATH=components:bases
     (python-shell-extra-pythonpaths . ("components" "bases"))
     ;; ruff 作为主要 linter/formatter
     (flycheck-python-ruff-executable . "ruff")
     ;; ty 作为 LSP（eglot）
     (eglot-server-programs . ((python-mode . ("ty" "server"))))
     ;; pytest
     (elpy-test-runner . elpy-test-pytest-runner)))
 (nil
  . ((projectile-project-type . python-pkg)
     (projectile-project-root-files . ("pyproject.toml"))
     ;; 告诉 auto-virtualenv 在哪找 .venv
     (auto-virtualenv-dir . ".venv"))))
