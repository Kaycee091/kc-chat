# Connecta — Product Requirements Document (PRD)

**Document owner:** Product/Engineering
**Status:** Draft v1.0
**Last updated:** September 7, 2026

---

## 1. Executive Summary

Connecta is a full-stack social networking platform providing Facebook-class functionality — feed, profiles, friends/follows, messaging, stories, groups, pages, events, marketplace, notifications, and admin moderation — delivered across a responsive web app, a native Flutter mobile app (iOS/Android), and a separate web-only admin dashboard, all backed by a single Django REST/Channels API and PostgreSQL database.

This is a **real, production-grade system**, not a prototype: every feature must be backed by real authentication, a real database, real WebSocket-based realtime messaging, real background jobs, and real server-side authorization. No mocked data, fake APIs, or client-only permission checks are acceptable in the shipped product.

The platform ships as a **single monorepo** containing four applications (web, mobile, admin, server) plus shared packages and infrastructure config, all communicating exclusively through the Django API.

---

## 2. Goals & Non-Goals

### 2.1 Goals
- Deliver a functionally complete social network: identity, content, relationships, messaging, communities, commerce (marketplace), and moderation.
- Guarantee **one source of truth** — PostgreSQL via Django — for web, mobile, and admin clients.
- Enforce all privacy, permission, and moderation rules server-side; never rely on frontend hiding.
- Support real-time interactions (messaging, presence, notifications) via Django Channels + Redis.
- Ship an **original visual identity** — comparable in function to Facebook but not a visual clone.
- Provide a fully documented, testable, containerized system a new developer can run locally with `docker compose up`.

### 2.2 Non-Goals (for initial release)
- Real payment processing in Marketplace (unless explicitly configured later).
- Elasticsearch/OpenSearch search (PostgreSQL full-text search is the v1 approach; architecture must allow a later swap).
- Video transcoding pipelines beyond basic thumbnail/metadata extraction.
- Native admin mobile app (admin is web-only, by design).

---

## 3. Users & Personas

| Persona | Description | Primary surface |
|---|---|---|
| **End User** | Registers, builds a profile, connects with friends, posts, messages, joins groups/events, browses marketplace | Web + Mobile |
| **Page/Group Admin** | Manages a Page or Group's content, members, and settings | Web + Mobile |
| **Platform Moderator** | Reviews reports, takes content/user actions | Admin Web only |
| **Platform Admin (Super Admin/Admin/Support/Analyst)** | Full or scoped operational control, analytics, audit review | Admin Web only |
| **Developer/Operator** | Clones repo, configures environment, deploys, maintains system | N/A (internal) |

---

## 4. Scope Overview

Four applications in one monorepo, sharing one backend:

1. **User Web App** — Next.js/React/TypeScript/Tailwind, responsive (desktop/tablet/mobile browser).
2. **Mobile App** — Flutter/Dart, Android + iOS, native shell.
3. **Admin Web App** — Next.js/React, strictly web, isolated from the user-facing app (separate route or subdomain).
4. **Server** — Django + DRF + Channels + Celery + PostgreSQL + Redis, the sole source of truth and business logic.

All clients must consume the same versioned REST/WebSocket API contracts (`/api/v1/...`). No client may talk to PostgreSQL directly, and no business logic may be duplicated independently across clients.

---

## 5. System Architecture

```
                   ┌───────────────┐
                   │   PostgreSQL  │
                   └───────┬───────┘
                           │ Django ORM
                    ┌──────▼──────┐
                    │    Django   │
                    │   Backend   │
                    └──────┬──────┘
                           │
          ┌────────────────┼─────────────────┐
          ▼                ▼                 ▼
     Web User         Flutter App       Admin Web
```

Redis + Django Channels handle realtime pub/sub and presence; Celery + Redis handle background/async jobs (email, push, story expiry, media processing, cleanup).

### 5.1 Monorepo Layout
```
connecta/
├── apps/
│   ├── web/        # Next.js user web app
│   ├── mobile/     # Flutter mobile app
│   └── admin/      # Next.js admin dashboard (web only)
├── server/
│   ├── config/
│   └── apps/ (users, posts, comments, reactions, friends, follows,
│              stories, messaging, notifications, groups, pages,
│              events, marketplace, media, reports, moderation,
│              search, saved, memories, analytics)
├── packages/
│   ├── api-contracts/
│   ├── shared-types/
│   └── design-tokens/
├── infrastructure/
│   ├── docker/
│   ├── nginx/
│   └── deployment/
├── docs/
├── tests/
├── docker-compose.yml
├── .env.example
└── README.md
```
One Git repository. No separate repos for web, mobile, admin, or server.

### 5.2 Backend Stack
Django, Django REST Framework, PostgreSQL, Redis, Django Channels, Celery.

Key dependency groups: DRF + `djangorestframework-simplejwt` + `django-cors-headers` + `django-filter` + `drf-spectacular` (API/auth/docs); `psycopg[binary]` (DB); `channels` + `channels-redis` (realtime); `celery` + `redis` (jobs); `Pillow` + `boto3` + `django-storages` (media); `argon2-cffi` + `cryptography` (security); `django-environ` (config); `gunicorn`/`uvicorn`/`whitenoise` (prod serving); `phonenumbers`, `python-dateutil` (validation); `firebase-admin` (push); `pytest`/`pytest-django`/`pytest-cov`/`factory-boy` (testing); `ruff`/`black`/`isort`/`pre-commit` (quality). Use current stable versions compatible with the chosen Python/Django version, not pinned-obsolete ones.

### 5.3 Mobile Stack (Flutter)
Riverpod (state), GoRouter (navigation), Dio (HTTP), Freezed/json_serializable (models), flutter_secure_storage (tokens), WebSocket channel (realtime), Firebase Messaging + flutter_local_notifications (push), cached_network_image, image_picker/image_cropper/file_picker, video_player, connectivity_plus, share_plus, emoji_picker_flutter, permission_handler, intl, uuid, url_launcher. Add packages only when genuinely needed.

Architecture:
```
lib/
├── core/ (networking, storage, routing, theme, constants, errors, utils)
├── features/ (auth, home, profiles, friends, posts, stories, messaging,
│              notifications, groups, pages, events, marketplace,
│              search, saved, memories, settings)
└── main.dart
```
Use presentation/domain/data separation where it adds real value.

### 5.4 Web Stack
Next.js, React, TypeScript, Tailwind CSS, TanStack Query, Axios/Fetch, Zod, React Hook Form, a WebSocket client, date-fns, Lucide icons, accessibility utilities.

```
app/  components/  features/  lib/  hooks/  services/  types/  providers/  utils/
```
Keep UI, API access, state, validation, and business-presentation logic separated; avoid giant components.

### 5.5 API Conventions
- Versioned REST namespace: `/api/v1/{auth,users,profiles,posts,comments,reactions,friends,follows,stories,messages,conversations,notifications,groups,pages,events,search,marketplace,media,reports,admin}/`.
- OpenAPI documentation via `drf-spectacular`, served at `/api/docs/` and `/api/schema/`.
- Consistent envelope:
```json
// success
{ "success": true, "data": {}, "message": null }
// error
{ "success": false, "error": { "code": "VALIDATION_ERROR", "message": "Invalid request", "details": {} } }
```
No internal stack traces exposed to clients.

### 5.6 Realtime Architecture
```
Flutter/Web → WebSocket → Django Channels → Redis → Connected clients
```
Core WS events: `message.created/updated/deleted/read/reaction`, `typing.started/stopped`, `presence.online/offline`, `notification.created`, `reaction.created`, `friend_request.created`.
Guard against duplicate connections/events, memory leaks, and unclosed subscriptions. On disconnect: exponential-backoff reconnect → re-authenticate → restore subscriptions → sync missed state, without duplicating subscriptions or messages.

### 5.7 Health & Observability
- `/api/health/` and `/api/ready/` checking Django, PostgreSQL, Redis.
- Log errors, API/auth failures, background job failures, WebSocket failures, upload failures, and admin actions.
- Never log passwords, tokens, secrets, or unnecessary private message content.

---

## 6. Data Model (Core Entities)

Custom user model from day one (never Django's default `User`, never swapped later):
`id, email, username, phone_number, password, first_name, last_name, date_of_birth, gender, is_active, is_verified, is_staff, is_superuser, created_at, updated_at, last_login`.

Additional core entities (Django models with proper FKs, unique constraints, composite indexes, soft-deletion where relevant, timestamps, and cascade rules):

`Profile, Friendship, Follow, Block, Post, PostMedia, PostPrivacy, Reaction, Comment, CommentReply, Share, Story, StoryView, Conversation, ConversationMember, Message, MessageAttachment, MessageReaction, MessageRead, Group, GroupMember, GroupRole, GroupPost, GroupRule, Page, PageFollower, PageAdmin, Event, EventAttendee, Notification, SavedItem, SavedCollection, Memory, Album, Photo, Video, MarketplaceListing, MarketplaceImage, Report, ModerationAction, Tag, Poll, PollOption, PollVote, UserSession, Device, NotificationPreference, PrivacySetting`.

Indexing priorities: `username`, `email`, `created_at`, `post.author`, `post.created_at`, `conversation_member.user`, `message.conversation`, `message.created_at`, `notification.user`, `notification.created_at`, `story.expires_at`, `marketplace.category`, `event.date`. Use `select_related`, `prefetch_related`, `annotate`, `exists`, `bulk_create`, `bulk_update` to avoid N+1 queries.

Django applications should be modular (`users`, `profiles`, `posts`, `comments`, `reactions`, `friendships`, `follows`, `stories`, `messaging`, `notifications`, `groups`, `pages`, `events`, `marketplace`, `media`, `search`, `reports`, `moderation`, `saved`, `memories`, `analytics`), each with its own `models.py`, `serializers.py`, `views.py`, `urls.py`, `permissions.py`, `services.py`, `selectors.py`, `tasks.py`, `tests/`. Complex logic lives in a **service layer** (`PostService`, `FriendshipService`, `FollowService`, `StoryService`, `MessageService`, `NotificationService`, `ModerationService`, `MarketplaceService`) — views stay thin.

---

## 7. Functional Requirements

### 7.1 Authentication & Account Lifecycle
- **Registration** requires: first/last name, username, email, phone, password, date of birth, gender/profile option, terms acceptance. Validate email format, username uniqueness, phone format, password strength, age, and required fields.
- **Email verification**: real, single-use, expiring, rate-limited codes; support resend; brute-force protection. Flow: register → account created → code generated → email sent → code entered → verified → onboarding → home feed.
- **Login**: email, username, or phone + password. Flow: validate credentials → check account status → issue access + refresh JWTs → return session → load profile → navigate home. Access tokens short-lived; refresh tokens handled securely.
- **Password reset**: request → code → validate → new password → confirm → invalidate relevant sessions → login. Never reveal whether an email/phone is registered (no account enumeration).
- **Token/session management**: secure cookie strategy (web) or secure storage (mobile); support token refresh, logout, session invalidation, multi-device sessions, and a user-facing "active sessions/devices" view with "log out this device / log out all devices."
- **Onboarding** (skippable, optional steps): profile picture → bio → find friends → interests → suggested users/pages → finish → home feed.

### 7.2 Profiles
Photo, cover photo, name, username, bio, location, education, work, relationship info (voluntary), website, social links, joined date; tabs for Posts/About/Friends/Photos/Videos/More.

### 7.3 Friends & Follows
Send/accept/reject/cancel/remove/block friend requests; friend requests, suggestions, and full friends list pages; independent follow/unfollow with follower/following control settings; notifications on key actions.

### 7.4 Posts, Reactions, Comments, Sharing
- Posts support text, multiple images, video, GIFs, links, polls, feelings/activities, location, tagged users, and text/background styling; every post tracks author, content, media, privacy, timestamps, and reaction/comment/share counts.
- Privacy: Public, Friends, Friends-except, Specific friends, Only me, Custom — **enforced server-side**, never trusted from the client.
- Post actions (only shown/allowed when authorized): save, edit, delete, report, copy link, mute notifications, change audience, share.
- Reactions: Like, Love, Care, Haha, Wow, Sad, Angry — add/change/remove, one reaction per user per post (DB-constrained), efficient count updates.
- Comments: create/edit/delete/react, nested replies, mentions, image attachments, paginated (never load full thread at once).
- Sharing: to profile, group, or private message, with optional message and share tracking; shares must respect original post's privacy.

### 7.5 Stories
Auto-expire after 24 hours; support images, short video, text; view/react/reply; viewer list visible to the story owner; privacy (Public/Friends/Custom); expiration handled by a scheduled/background job, not client-side hiding.

### 7.6 Real-Time Messaging
Django Channels + Redis (no polling). Direct and group conversations; images/video/files/GIFs/emoji; replies, reactions, edit, delete, forward, search. Message states: Sending → Sent → Delivered → Read → Failed. Typing indicators, online status, last-seen, read receipts. Chat pagination: most recent first, older messages loaded on scroll-up, never the full history at once.

### 7.7 Group Chat / Groups
Group chat: name, photo, members, admins, moderators, add/remove members, leave, permissions, media.
Groups (Public/Private/Hidden): posts, comments, reactions, members, admins, moderators, rules, announcements, events, media, files. Admins can approve/remove/ban members, delete posts, manage moderators, change settings.

### 7.8 Pages
Profile/cover image, name, username, description, followers, posts, photos, videos, events; page admins can publish content.

### 7.9 Events
Online or physical; name, date, start/end time, location, description, cover image, organizer, privacy; RSVP states Interested/Going/Not going.

### 7.10 Notifications
Triggers: friend requests/acceptances, likes/reactions, comments, replies, mentions, shares, messages, group activity, events, story interactions, page activity. Channels: in-app, push, email — each independently user-configurable. Flow: action → business logic → Notification created → preference check → in-app → WebSocket delivery if online → push if enabled → email if configured. Deduplicate/group notifications for high-volume events (e.g., 100 reactions on one post).

### 7.11 Push Notifications
Firebase Cloud Messaging. Devices register `device_id, user_id, FCM token, platform, device info, last_active`. Handle foreground/background notifications, taps, deep links, and token refresh.

### 7.12 Search
Global search across People, Posts, Groups, Pages, Events, Marketplace with debouncing, pagination, filters, sorting, and (where appropriate) search history. PostgreSQL search for v1; layer must be swappable for Elasticsearch/OpenSearch later. Search results must respect privacy, blocks, and group/page visibility at all times — a private post must never be discoverable by an unauthorized user.

### 7.13 Memories
Surface past posts from the same calendar date in prior years (background job driven); user can share, hide, or delete a memory.

### 7.14 Saved Items
Save posts, videos, marketplace listings, events; organize into collections (All/Posts/Videos/Products/Events).

### 7.15 Video/Watch
Upload, view, react, comment, share, save; lazy loading, thumbnail generation, responsive players, no autoplay-with-sound.

### 7.16 Marketplace
Listings: name, price, images, description, category, location, condition, seller. Users can search, filter, save, contact seller, report a listing. No real payment processing unless explicitly configured.

### 7.17 Media, Albums, Tagging, Location, Polls
- Media stored in secure object storage (S3/R2/GCS/Azure Blob) — never large production media on the app server; validate MIME type, size, extension; generate thumbnails.
- Albums: name, description, privacy, multiple photos.
- Tagging in posts/photos/comments with notifications and user-controlled tagging permissions.
- Location on posts is opt-in and explicit; never auto-attached or auto-exposed.
- Polls: question, options, one vote per user (unless configured otherwise), vote counts, expiration, privacy.

### 7.18 Privacy & Blocking
User-controlled settings: profile visibility, post visibility, friend requests, followers, friends list, email/phone/birthday visibility, tagging, messaging — all enforced at the API/DB/business-logic layer. Blocked users are prevented from messaging, friend-requesting, following, or accessing restricted content; managed under Settings → Privacy → Blocked Users.

### 7.19 Reporting & Moderation
Reportable objects: posts, comments, profiles, messages, groups, pages, marketplace listings. Categories: Spam, Harassment, Hate, Violence, Scam, Impersonation, Inappropriate content, Other. Reports feed the admin moderation queue.

### 7.20 Admin Dashboard (Web Only)
Sections: Dashboard, Users, Posts, Comments, Reports, Groups, Pages, Events, Marketplace, Messages/Moderation, Media, Notifications, Moderation, Analytics, System Settings, Audit Logs.
Dashboard metrics: total/active/new users, posts/comments/messages today, pending reports, groups/pages/events/marketplace counts, with charts where useful.
User management: search, view, suspend, ban, restore, verify (where authorized), review moderation history — with minimum necessary visibility into sensitive data.
Moderation tools: reports queue, content review, user review, suspension/ban, content removal/restoration, warnings, moderation history — every action logged.
Roles: Super Admin, Admin, Moderator, Support, Analyst, each with explicit permissions (never a blanket `is_staff == true` check for sensitive operations).
Audit logging: admin, action, target, reason, timestamp, IP metadata (where appropriate) — immutable to normal admins.

The admin app must be **completely separated** from the user-facing app (e.g., `admin.connecta.com` vs. `app.connecta.com`, or a clearly isolated route), must never expose admin functionality to normal users, and every admin action must be independently authorized server-side.

---

## 8. Design System

Connecta must have an **original visual identity** — comparable in capability to Facebook, but never a visual clone. Do not use Facebook's logo, wordmark, layouts, or any proprietary/copyrighted assets.

### 8.1 Foundational Tokens
Deliver as a shared `packages/design-tokens` package consumed by both web and mobile:
- **Logo & wordmark** — original design.
- **Typography system** — type scale, font family, weights, line-heights.
- **Color system** — brand palette, semantic colors (success/warning/error/info), light/dark variants.
- **Spacing system** — consistent spacing scale (e.g., 4/8px base).
- **Border-radius system** — consistent corner-rounding scale.
- **Elevation/shadow system** for cards, modals, dropdowns.

### 8.2 Component Library
Buttons, inputs, cards, dialogs, bottom sheets, navigation (top nav + sidebar + bottom nav), avatars, badges, toasts, and skeleton loaders — all built from the shared tokens, implemented natively in both the Next.js and Flutter codebases (not literally shared code, but visually/behaviorally consistent).

### 8.3 Layouts
- **Desktop web** — responsive three-column layout: left sidebar (Home, Friends, Groups, Saved, Memories, Events, Marketplace, Messages, Settings), center feed (Stories, Create Post, Posts), right panel (Contacts, Events, Birthdays, Suggestions); top bar with logo, search, notifications, messages, profile.
- **Tablet web** — two-column layout.
- **Mobile web / Flutter** — single-column layout with bottom navigation: Home, Friends, Create, Notifications, Menu (Menu expands to Profile, Groups, Pages, Events, Marketplace, Saved, Memories, Messages, Settings, Help, Logout). Full-screen pages for chat, media viewer, stories, profile, and settings; bottom sheets for contextual actions. No unintended horizontal scrolling.

### 8.4 Theming
Light, Dark, and System modes, consistent across web and mobile, with the user's preference persisted server-side and applied locally.

### 8.5 States & Feedback
- **Loading**: skeleton loaders (never blank screens) for feed, profiles, comments, messages, search, groups, marketplace, notifications, events, pages.
- **Empty states**: meaningful messaging + actions for no friends/messages/notifications/saved posts/groups/events/search results/marketplace listings/followers/following.
- **Error states**: clear, specific messaging for 400/401/403/404/409/413/429/500/503, network timeouts, WebSocket disconnects, and upload failures — never a silent failure.

### 8.6 Accessibility
- **Web**: keyboard navigation, visible focus states, screen-reader support, ARIA labels, semantic HTML, accessible forms/dialogs, sufficient contrast, reduced-motion support.
- **Flutter**: semantic labels, screen-reader accessibility, adequately sized touch targets, text scaling, contrast compliance.

### 8.7 Reference Home Feed Composition
A representative, polished (not literal) example of the top-of-feed experience: app header with logo/search/nav icons → stories rail → composer ("What's on your mind?") → post card (author, timestamp, privacy indicator, content/media, reaction/comment/share counts, Like/Comment/Share actions).

---

## 9. Non-Functional Requirements

### 9.1 Security
HTTPS in production; JWT security; secure cookies where applicable; CSRF protection; CORS configuration; rate limiting on login, registration, verification codes, resend, password reset, friend requests, messaging, reports, uploads, and search; input/output validation; permission checks with **object-level authorization**; file validation; ORM-only DB access (SQL-injection protection); XSS protection; secure headers; password hashing (argon2); session management; account lockout/rate-limiting. Secrets (Django secret key, DB password, JWT signing secret, storage credentials, Firebase keys, third-party API secrets) are environment-variable only, never committed or hardcoded.

Enforcement pattern for every protected resource:
```
Authenticate → Identify user → Check block relationship → Check privacy →
Check ownership/permission → Return resource
```
Frontend button-hiding is never treated as a security control.

### 9.2 Performance
Cursor pagination and infinite scroll for feed and chat (never load full history at once); lazy loading; image compression/thumbnails; video thumbnails; Redis caching (never caching private data in a way exposable to another user); debounced search; optimistic UI only where safe; database indexing and query optimization (`select_related`/`prefetch_related`/`annotate`/`exists`/bulk ops); background jobs for expensive/async work; CDN/media optimization.

### 9.3 Reliability & Duplicate Prevention
Prevent duplicate posts, messages, friend requests, reactions, notifications, poll votes, and uploads via DB constraints, idempotency keys, and both client- and server-side safeguards. WebSocket reconnection uses exponential backoff with state resync and no duplicate subscriptions.

### 9.4 Offline & Error Handling (Mobile)
Network detection, cached feed/profile data, safe pending-action handling, retry logic for failed requests/uploads, and clear offline/error indicators. Never show an action as completed when the backend rejected it.

### 9.5 Testing
- **Backend**: pytest/pytest-django/factory-boy covering authentication, social features (posts/reactions/comments/replies/sharing/saving), friends/follows/blocking, messaging (realtime delivery, read receipts, typing, reactions, attachments), stories (creation/viewing/reactions/replies/expiration), groups, events, and privacy (private posts, blocked users, restricted profiles, private groups, private messages).
- **Web**: unit, component, integration, and end-to-end tests.
- **Flutter**: unit, widget, and integration tests.
- **Cross-client**: the same core flows must be verified across Web↔Web, Mobile↔Web, Web↔Mobile, and Mobile↔Mobile.

### 9.6 Background Jobs (Celery + Redis)
Email verification, password reset emails, push notifications, email notifications, story expiration, media processing/thumbnailing, cleanup jobs, memory generation, notification processing, and search indexing as needed.

### 9.7 Deployment & Environments
Docker Compose for local dev (`web`, `admin`, `server`, `postgres`, `redis`, `worker`, `nginx`, plus a mobile build environment where needed) launchable via `docker compose up`. Django migrations only (no manual schema edits) — `makemigrations`/`migrate` must be clean before release. Documented `createsuperuser` flow for the first admin (no hardcoded admin credentials). Support Development/Staging/Production environments for both web (env-var-driven API URL) and Flutter (separate base URLs per environment, no embedded production secrets). Architecture must support a generic production topology (CDN → Django API → PostgreSQL → Redis → Celery workers → object storage) without hardcoding a specific hosting provider.

---

## 10. Environment Configuration

`.env.example` must define (values left blank, documented):
```
DEBUG=
SECRET_KEY=
DATABASE_URL=
REDIS_URL=
ALLOWED_HOSTS=
CORS_ALLOWED_ORIGINS=
JWT_ACCESS_LIFETIME=
JWT_REFRESH_LIFETIME=
EMAIL_HOST=
EMAIL_PORT=
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=
EMAIL_USE_TLS=
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_STORAGE_BUCKET_NAME=
AWS_S3_REGION_NAME=
FIREBASE_CREDENTIALS=
NEXT_PUBLIC_API_URL=
FLUTTER_API_URL=
```
`.env` itself is never committed. Any feature dependent on an unavailable external credential must remain a real, fully implemented integration — never replaced with fake functionality — and must be documented as: required service, required environment variable, where to obtain the credential, and which feature depends on it.

---

## 11. Explicitly Disallowed Approaches

- Supabase, Firebase-as-primary-database, or LocalStorage as the system of record.
- Mock APIs, static JSON data, fake authentication, fake realtime (e.g., polling dressed up as realtime).
- Frontend-only permission checks.
- Hardcoded credentials of any kind.
- Fake buttons, fake notifications, fake messages, fake admin actions, or any UI wired to nothing.
- Separate repositories per app, or a separate backend for mobile.
- Visual cloning of Facebook's branding or layout.

Firebase is permitted **only** for mobile push notification delivery; Django + PostgreSQL remain the backend and system of record regardless.

---

## 12. Delivery Roadmap (Phased)

| Phase | Scope |
|---|---|
| 1 | Monorepo scaffold (web/mobile/admin/server/packages/infrastructure/docs) |
| 2 | Backend foundation: Django, PostgreSQL, Redis, env config, custom User, DRF, JWT, API docs |
| 3 | Authentication: registration, email verification, login/logout, refresh tokens, password reset, sessions |
| 4 | Web app: design system, auth UI, shell, navigation, responsive layout |
| 5 | Flutter app: architecture, theme, routing, auth, secure storage, API client, shell |
| 6 | Profiles: view/edit, avatar/cover, about, privacy |
| 7 | Friends & follows: requests, friends, follow/followers, suggestions, blocking |
| 8 | Posts: feed, create, media, privacy, edit/delete, reactions, comments, replies, sharing, saving |
| 9 | Stories: creation, viewer, reactions, replies, views, expiration |
| 10 | Messaging: conversations, WebSockets, typing, presence, read receipts, attachments, reactions, edit/delete |
| 11 | Notifications: in-app, WebSocket, push, preferences, email |
| 12 | Groups: creation, joining, members, roles, posts, moderation, announcements, events |
| 13 | Pages: creation, profiles, followers, admins, content |
| 14 | Events: creation, pages, RSVP, discovery |
| 15 | Search: people, posts, groups, pages, events, marketplace |
| 16 | Saved items & memories |
| 17 | Marketplace: listings, search, filters, seller profiles, contact, reporting |
| 18 | Media: albums, photos, videos, uploads, secure storage, management |
| 19 | Admin: dashboard, users, reports, moderation, groups, pages, marketplace, analytics, audit logs |
| 20 | Security audit: permissions, auth, privacy, API access, uploads, rate limiting, admin access |
| 21 | Performance optimization: DB, API, feed, images, video, search, WebSockets, mobile |
| 22 | Full test pass: backend, API, web, Flutter, admin, integration, end-to-end |
| 23 | Production readiness: env vars, Docker, migrations, static/media, HTTPS, logging, health checks, jobs, push |

---

## 13. Acceptance Criteria

### 13.1 Feature Acceptance (must all pass before release sign-off)
- **Auth**: registration, email verification, login, logout, password reset, and token refresh all function against the real backend.
- **Social**: posts, reactions, comments, replies, sharing, and saving all function end-to-end.
- **Identity/Relationships**: profiles, friend requests, following, blocking, and privacy rules all function and are enforced server-side.
- **Stories**: creation, viewing, reactions, replies, view tracking, and 24-hour expiration all function.
- **Messaging**: direct and group messages, WebSocket delivery, typing indicators, presence, read receipts, and attachments all function.
- **Notifications**: in-app, realtime, push (when configured), and email (when configured) all function.
- **Groups / Pages / Events**: creation, membership/following, moderation, and RSVP all function.
- **Marketplace**: listings, search, filters, and contact-seller all function.
- **Search**: people, posts, groups, pages, events, and marketplace all return privacy-correct results.
- **Admin**: login, dashboard, user management, reports, moderation, audit logs, and role-based permissions all function.
- **Mobile**: verified on Android and iOS.
- **Web**: verified on desktop, laptop, tablet, and mobile browser widths.

### 13.2 Cross-Client End-to-End Scenario (mandatory, must run against the live backend/DB)
```
User A registers → verifies email → completes onboarding
User B registers
User A sends friend request → User B accepts
User A creates post → User B sees it in feed → reacts → comments
User A receives a realtime notification
User B sends a message → User A receives it in realtime
```
Must pass across all four client pairings: Web→Web, Mobile→Web, Web→Mobile, Mobile→Mobile. A build that only demonstrates this in a single-client demo does not satisfy acceptance.

### 13.3 Definition of Done
The project is not considered complete until:
1. All sections in 13.1 pass against the real Django backend and a real PostgreSQL database (no fixtures standing in for live behavior).
2. The cross-client scenario in 13.2 has been executed and observed to work, not merely coded.
3. `docker compose up` brings up a working local environment for a new developer with no manual workarounds beyond documented `.env` configuration.
4. No fake/mocked functionality remains in any production code path.

---

## 14. Documentation Deliverables

`README.md` covering: project overview, architecture, repo structure, prerequisites, installation, environment setup, database/Redis setup, Django/web/Flutter/admin setup, running locally, running tests, Docker, API docs, deployment, environment variables, push notification setup, storage configuration, and troubleshooting.

`docs/` folder: `architecture.md`, `api.md`, `authentication.md`, `realtime.md`, `database.md`, `media.md`, `notifications.md`, `admin.md`, `mobile.md`, `deployment.md`, `security.md`, `testing.md`.

---

## 15. Risks & Open Questions

| Risk/Question | Notes |
|---|---|
| Search scalability | PostgreSQL search is v1; confirm trigger point for Elasticsearch/OpenSearch migration |
| Media/CDN provider | Not hardcoded per spec — needs a decision per environment (S3 vs. R2 vs. GCS vs. Azure) before infra work starts |
| Marketplace payments | Explicitly out of scope for v1 — confirm whether a later phase adds real payment processing |
| Hosting provider(s) for Django/Next.js | Spec intentionally provider-agnostic — needs an infra decision (e.g., Render/Fly/AWS for Django, Vercel for Next.js) |
| Admin domain separation | Decide between subdomain (`admin.connecta.com`) vs. isolated route (`/connecta-admin`) early, since it affects auth/session/cookie scoping |
| Push notification credentials | Firebase project setup and credential provisioning is a blocking dependency for Phase 11 |
