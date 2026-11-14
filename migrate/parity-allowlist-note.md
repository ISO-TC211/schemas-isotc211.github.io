
## Upstream drift in parity allowlist

The parity baseline (`manifest-old.json`) was captured from a build whose
`schemas/` clone and live deployment predate today's upstream state. Files
added under `19178/**`, `json/19178/**`, `19115/resources/**`,
`json/19123/**`, `19115/-1/{mdb,mcc,srv}/1.3.0/**`, `19115/-2/mac/**` and
`assets/**` are byte-copies of today's upstream schemas repo (staged by
`scripts/prepare-public.mjs`), not migration changes. Data-file parity is
additionally verified 1:1 against the clone by
`migrate/verify-data-parity.mjs`.


## Removed hub pages (upstream drift, matches live)

The upstream ISO-TC211/schemas main removed packages from lxr_packages.yml (mdb, part of json/19115, 19115 cit/gex/lan 1.3 hubs) between the old deployment and today. The live production site 404s these identically (verified 2026-11-14); the new build matches upstream exactly.
