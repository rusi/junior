# Development Environment

> **Created:** [Date]
> **Last Updated:** [Date]

## Setup Overview

[How local development is expected to run]

## Prerequisites

**Required**
- [Tool 1] version [X+]
- [Tool 2] version [Y+]
- Git

**Optional**
- [IDE/extensions]
- [local tooling helpers]

## Quick Start

```bash
# Install dependencies
[install command]

# Configure environment
[setup command]

# Run development mode
[dev command]

# Run tests
[test command]
```

## Common Commands

**Strongly recommended task interface**

Create a `Makefile` (or equivalent task runner) and expose consistent commands:

```text
make dev      # start development mode
make test     # run tests
make lint     # run linter
make format   # format code
make build    # build for production
make clean    # clean build artifacts
```

**Development**
- [dev command] - start development mode
- [lint command] - run lint checks
- [format command] - format code

**Testing**
- [test command] - run all tests
- [test-watch command] - run tests in watch mode
- [coverage command] - generate coverage report

**Build**
- [build command] - build for production
- [build-dev command] - build for development

## Troubleshooting

**[Common Issue 1]**
- Symptom: [What you see]
- Solution: [How to fix]

**[Common Issue 2]**
- Symptom: [What you see]
- Solution: [How to fix]

## Environment Variables

Create `.env.example` with inline comments and document only key notes here:

- `VAR_NAME` - [purpose]
- `VAR_NAME` - [purpose]

## IDE Setup

- Recommended IDE/plugins
- Formatting, linting, and type-check settings
- Debug configuration expectations

## Deployment Notes

- Staging: [flow/command]
- Production: [flow/command]
