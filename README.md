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

The operations console is available at `/admin`. The seed creates `admin@fleetos.tw`; set `SEED_ADMIN_PASSWORD` before seeding and rotate it after first sign-in. Admin access is protected by an HTTP-only signed session and database-backed role permissions.

Vercel production must define `DATABASE_URL`, `AUTH_SECRET`, and persistent storage credentials. Uploaded media must use object storage rather than Vercel's ephemeral filesystem.
Client-side booking state is persisted in browser storage.
