# FLEET OS

A high-fidelity, responsive B2C mobility booking demo for Taiwan. It includes a service-aware booking engine, capacity-filtered vehicle results, centralized price calculations, a six-step checkout, simulated payments, persisted bookings and favorites, fleet detail pages, global search, and account views.

## Run locally

```bash
npm install
npm run dev
```

Open `http://localhost:3000`. Other checks are available with `npm run build`, `npm run lint`, and `npm test`.

Zustand is used only for transient booking-wizard state. Persistent catalog, CMS, identity, operations, and financial data belongs in PostgreSQL. Payment abstractions never send or store raw card numbers or security codes.

## Database and administration

Fleet OS 2.0 uses PostgreSQL through Prisma as its authoritative business-data store. Copy `.env.example` to `.env`, provide a PostgreSQL connection and secure `AUTH_SECRET`, then run:

```bash
npm run db:migrate
npm run db:seed
```

The operations console is available at `/admin` (production: `https://fleet-b2-c.vercel.app/admin`). The development seed creates the following initial Super Admin:

- Email: `admin@fleetos.tw`
- Password: the value of `SEED_ADMIN_PASSWORD`, or `ChangeMe123!` when the variable is omitted

Set `SEED_ADMIN_PASSWORD` before production seeding and rotate the password after the first sign-in. Admin access is protected by an HTTP-only signed session and database-backed role permissions.

Vercel production must define `DATABASE_URL`, `AUTH_SECRET`, and persistent storage credentials. Uploaded media must use object storage rather than Vercel's ephemeral filesystem.

The repository pins Node.js 20, matching React type packages, and a compatible Prisma CLI/Client pair. `vercel.json` uses npm's legacy peer resolver so a stale Vercel dependency cache cannot reintroduce incompatible React type versions.
