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
S #,Size,Component,UOM,Spec,Tolerance,Finding
1,XS,HPS Length,Inch,27,1/2,27 1/4
1,XS,Chest – 1” Below arm hole,Inch,16,1/2,16
1,XS,Front cross – 5” from HPS,Inch,13.625,1/2,13
1,XS,Neck width – seam to seam,Inch,6,1/4,6 '1/2
,,(Not including Rib Trim),,,,
1,XS,Sleeve length – from shoulder seam,Inch,7 '1/4,1/4,7

<img width="692" height="649" alt="cap_login" src="https://github.com/user-attachments/assets/ed2b4484-3b6c-496e-a6e4-8d830a8de667" />

<img width="1358" height="786" alt="cap_graph" src="https://github.com/user-attachments/assets/f2a32393-6902-45fb-be78-36780ebe8711" />

<img width="323" height="318" alt="cap_details" src="https://github.com/user-attachments/assets/c397b1b7-bd18-4ef7-b78e-296761177842" />
