# my-emacs-config

个人 Emacs 配置 monorepo，基于 [DavidVujic/my-emacs-config](https://github.com/DavidVujic/my-emacs-config)。

针对以下项目的开发工作流定制：

- **subsidy-2026** — Python Polylith（uv），产业以奖代补 ETL
- **my-tools** — 多语言 monorepo（Clojure Polylith + Python Polylith + Fish/Nushell/Bash）
- **ariadne-fact** — TypeScript Polylith + Clojure bb-bricks，DataScript 知识库

## 结构

```
my-emacs-config/
├── init.el                  # 主入口
├── early-init.el            # 早期初始化
├── customizations/          # 功能模块
│   ├── setup-clojure.el     # Clojure/CIDER/clj-kondo
│   ├── setup-python.el      # Python/elpy/eglot/ty LSP
│   ├── setup-js.el          # TypeScript/tide/prettier
│   ├── setup-llm.el         # gptel (OpenAI/Anthropic)
│   └── ...
├── projects/                # 项目专属配置（dir-locals）
│   ├── subsidy-2026/        # Python Polylith ETL 项目
│   ├── my-tools/            # 多语言 monorepo
│   └── ariadne-fact/        # TypeScript + bb-bricks
└── snippets/                # yasnippet 片段
    ├── clojure-mode/
    ├── python-mode/
    └── typescript-mode/
```

## 安装

```bash
# 配置文件已在 ~/.emacs.d/ 中
# 首次启动 Emacs 会自动下载所有 package

# 系统依赖
# clj-kondo — Clojure linter（Nix home-manager 管理）
# ipython   — uv tool install ipython
# ty        — uv tool install ty（Python LSP）
```

## 项目工作流

### subsidy-2026 / my-tools (Python Polylith)

- `auto-virtualenv` 自动激活 `.venv`
- `ty` 作为 LSP server（eglot）
- `ruff` 格式化（`<f6>`）
- `pytest` 通过 elpy 运行

### my-tools / ariadne-fact (Clojure Polylith)

- CIDER 连接 nREPL
- `clj-kondo` flycheck 实时检查
- `.edn` 文件自动用 clojure-mode

### ariadne-fact (TypeScript)

- `tide` + TypeScript LSP
- `prettier-js` 格式化
- `flycheck` 实时检查

## 键位速查

| 键位 | 功能 |
|---|---|
| `C-;` | 注释/取消注释 |
| `C->` | 多光标选择下一个 |
| `C-shift-↑/↓` | 移动文本 |
| `<f5>` | Python: isort + black |
| `<f6>` | Python: ruff check + format |
| `C-M-r` | Clojure: cider-refresh |
| `C-c C-m` | Clojure: clj-refactor 前缀 |
