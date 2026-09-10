# Connecta Monorepo

Connecta is a production-grade full-stack social networking platform built as a monorepo.

## Monorepo Layout

- `apps/web/`: Next.js user-facing web application.
- `apps/mobile/`: Flutter mobile application (iOS & Android).
- `apps/admin/`: Next.js web-only admin & moderation dashboard.
- `server/`: Django REST Framework & Channels API server.
- `packages/`: Shared packages (`api-contracts`, `shared-types`, `design-tokens`).
- `infrastructure/`: Docker, Nginx, and deployment configs.
- `docs/`: Technical and architectural documentation.
- `tests/`: End-to-end and cross-client integration tests.

## Getting Started

Refer to `.env.example` to set up your local environment configuration.
