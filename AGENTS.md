# AGENTS.md — bd-pg

Pure PostgreSQL 16 / PL/pgSQL repo. No application code. The backend (Laravel) calls stored functions as a database API layer.

## Source of truth

Edit files in **`src/`** organized by domain schema, then generate a migration. **Do not edit `migrations/V1.0.0__baseline_schema.sql` manually.**

```
src/
  auth/           # Users, roles, permissions, tokens
  academic/       # Courses, syllabi, topics, cycles, universities
  questions/      # Question bank, alternatives, IA, digitalization
  materials/      # PDFs, ballots, templates, configurations
  exams/          # Exam areas, types
  organization/   # Companies, employees, teachers, headquarters
  audit/          # Trigger-based audit logging
  common/         # Cross-cutting (type_documents, plans, prospects, settings)
  schemas/        # extensions.sql, schemas.sql, types.sql, domains.sql, sequences.sql
  triggers/       # Trigger functions + bindings
  views/          # Views (vw_) and materialized views (mv_)
  roles/roles.sql # Database roles
```

## Key commands

```bash
# Start local Postgres
docker compose up -d

# Extract schema from running DB → schema_dump.sql + roles_dump.sql
bash extract_schema.sh

# Re-split schema_dump.sql into src/ (one-time after extract)
python split_schema.py

# Flyway migration (apply incremental migrations)
flyway migrate   # configured in conf/flyway.conf
```

## Migration workflow (declarative)

1. Modify source files in `src/` (tables, functions, etc.)
2. Apply current `src/` to a Shadow DB (temporary Docker Postgres)
3. Use **Atlas** or **Migra** to diff Shadow DB vs actual DB → generates incremental SQL
4. Place generated file in `migrations/` as `V1.0.X__description.sql`
5. Run `flyway migrate`

No manual migration writing. Only `src/` is the authoring surface.

## Conventions (enforced)

- **DDL keywords UPPERCASE** (`CREATE TABLE`, `NOT NULL`, `CONSTRAINT`)
- **Constraint prefixes:** `pk_`, `fk_`, `uq_`, `idx_`
- **Every FK column must have an index** (composite unique covering it, or standalone `idx_`)
- **Function names:** `fn_[verb]_[entity]_[condition]`
  - Read verbs: `get` (1 row), `list` (many), `paginate`, `search`, `count`, `exists`
  - Write verbs: `create`, `update`, `delete`, `archive`, `restore`, `upsert`
- **Returns:** `RETURNS TABLE(...)` — never `SETOF record`
- **Consolidate** get/search functions: use optional `DEFAULT NULL` params, avoid per-column variants
- **SQL injection:** always use `USING` in `EXECUTE`, never string concatenation
- **PL/pgSQL body style:** mixed case currently (lowercase keywords inside functions is common in this codebase despite DDL rule)

## Current state caveats

- **No incremental migrations exist** — only baseline `V1.0.0__baseline_schema.sql`
- **Still uses `postgres` superuser** in `.env` / `flyway.conf` — violates least-privilege rule documented in `rules/db-rules.md`. App should use a restricted role (`odiseo_app`).
- **Residual objects in `odiseo` schema** — domain refactor incomplete (some views, triggers, types still there)
- **`conf/postgresql.conf` referenced in docker-compose but missing** from repo
- **`scratch/` scripts** are one-time migration tools (used to split monolithic `odiseo.*` into domains), not part of regular workflow
- **Function bodies** use lowercase SQL keywords inconsistently with the DDL uppercase standard

## Reference

Full engineering standards (DDL, function contracts, security, indexes, query perf): **`rules/db-rules.md`**
