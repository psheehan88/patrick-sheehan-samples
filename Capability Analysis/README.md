# CapTrack – Capability & SPC (WLanguage / WinDev)

CapTrack is a lightweight capability and SPC module written in **WLanguage (WinDev)** used to
analyze measurement datasets, calculate **Pp / Ppk**, and visualize distributions for quality
and compliance reporting.

## What this shows
- Clean WLanguage code style and modular procedures
- Statistical calculations (mean, sample standard deviation, Pp, Ppk)
- Spec-limit checks (defect rate estimates)
- Basic chart export for a histogram with spec lines (for reports)

## Features
- CSV ingestion (`value` column)
- Descriptive stats (N, mean, stdev)
- Capability indices: **Pp**, **Ppk**
- Defect counts inside/outside LSL/USL
- Optional histogram export to PNG (for report attachments)

## Example
**Input CSV** (`data/sample.csv`)
```csv
value
9.97
10.12
9.88
10.03
