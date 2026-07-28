# MediCore Pharmaceutical Analytics

A self-built data analytics project simulating a pharmaceutical distributor operating across six regional warehouses in Nigeria. Covers database design, data generation, data cleaning, and business analysis using PostgreSQL — plus a custom dashboard and a Power BI report built on top of it.

I designed the schema, generated the seed data (with deliberate, realistic data-quality issues built in), cleaned it by hand, wrote every analysis query, and debugged two real bugs in my own data-generation logic along the way. Full writeup of the process is in [`/report`](./report).

## What this project covers

- Relational schema design (7 tables, foreign keys, CHECK constraints, computed columns)
- Synthetic data generation (~15,000 sales transactions, deliberately messy on purpose)
- Data cleaning: duplicate detection, whitespace/casing normalization, missing-data standardization, outlier flagging
- Debugging two real PostgreSQL data-generation bugs (see below)
- Business analysis across 7 KPIs
- A custom-coded dashboard (HTML/JS) and a Power BI report, both built on the live database

## Tech stack

`PostgreSQL` · `SQL` · `VS Code + SQLTools` · `Power BI` · `HTML/CSS/JS + Chart.js`

## Key findings

| Metric | Result |
|---|---|
| Total revenue (36 months) | ₦208.6M, steady month to month |
| Top product category | Medical consumables outsell individual drug lines |
| Top region | South West — ₦51.3M (Lagos hub) |
| Customer concentration | Top 10 customers tightly clustered, no single client dominates |
| Sales rep spread | All 10 reps within ₦19.8M–22M — consistent performance |
| **Expired stock value** | **₦28.9M sitting across all 6 warehouses, 246 batches** |

The expired-stock number is the strongest actionable finding — every warehouse is carrying expired inventory, pointing to a real gap in rotation and expiry monitoring.

## A bug worth mentioning

My first products-by-revenue query returned one row with 288,054 units sold — clearly broken. Root cause: a `random()` call inside a `JOIN` condition wasn't being re-evaluated per row in PostgreSQL, so nearly every sale ended up linked to the same product. Fixed by picking the random value first, then joining. The same underlying issue then showed up again in different logic used for `customer_id`, which I recognized as the same category of bug and fixed with a more robust pattern — indexing into an array with `random()` written directly in the expression, guaranteed to re-evaluate per row.

Full breakdown of this and the data cleaning process is in the [project report](./report/MediCore_Analytics_Report.docx).

## Repo structure

```
sql/         → schema, seed data, cleaning, and analysis scripts, in order
dashboard/   → standalone HTML dashboard (open directly in a browser)
report/      → full written report (design decisions, cleaning process, findings)
screenshots/ → dashboard previews
```

## Running it yourself

1. Create a PostgreSQL database
2. Run the scripts in `/sql` in numbered order
3. Open `/dashboard/MediCore_Analytics_Dashboard.html` in a browser to view the results, or connect Power BI to the database directly

## Live dashboard

Open [`dashboard/MediCore_Analytics_Dashboard.html`](./dashboard/MediCore_Analytics_Dashboard.html) directly, or view a preview below.

<!-- Add a screenshot here once uploaded, e.g.: -->
<!-- ![Dashboard preview](./screenshots/dashboard.png) -->
