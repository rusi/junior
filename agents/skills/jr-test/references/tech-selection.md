# Technology Guidance Selection

## Goal

After choosing app-type playbook, select technology guidance files that match the codebase.

## Rules

1. Detect stack from repository evidence (lock files, configs, framework imports, CI commands).
2. Load all matching guidance files.
3. Prefer modern, actively maintained tools unless project compatibility requires otherwise.
4. If legacy tooling is already entrenched, keep compatibility and improve test quality within that toolchain.

## Selection Examples

- Python backend/API:
  - Load `tech-python-backend.md`
- Node.js backend/API:
  - Load `tech-node-backend.md`
- TypeScript frontend:
  - Load `tech-frontend-typescript.md`
- C/C++:
  - Load `tech-cpp-tooling.md`
- Swift/iOS:
  - Load `tech-swift-tooling.md`

## Multi-Stack Projects

- Web apps often require multiple files:
  - Backend guidance (Python or Node)
  - Frontend guidance (TypeScript)
  - Keep e2e strategy aligned with app playbook and existing infrastructure.
