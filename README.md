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

Vercel Preview and Production must each define `DATABASE_URL` and `AUTH_SECRET`. Run
`npm run db:migrate` against each target database before deploying and run
`npm run db:seed` once with a temporary `SEED_ADMIN_PASSWORD` of at least 12
characters. The idempotent seed updates the dedicated admin password, so remove
`SEED_ADMIN_PASSWORD` after the seed completes. `BLOB_READ_WRITE_TOKEN` is required
when media uploads use the configured `vercel-blob` storage provider.

The public homepage reads published CMS/catalog records from PostgreSQL. If those
optional records have not been seeded yet, it renders the bundled public catalog
instead of failing the entire route; database connectivity and schema migrations
remain required for administration and authentication.
Client-side booking state is persisted in browser storage.
