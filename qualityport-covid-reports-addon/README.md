# QualityPort Add-On – Reports by City & COVID Map

Custom module built for the **QualityPort SaaS system** to extend reporting visibility during
factory inspections and COVID-19 disruptions.

## Overview
This add-on provides **monthly report breakdowns by city** across all factories and integrates
real-time COVID outbreak data during 2020–2021 to help clients assess supply chain risks.

## Features
- **City/Factory Monthly Reports**
  - Aggregates number of inspection reports by city and factory
  - Tabular view with filters by date range, data type, and report attributes
  - Interactive chart view for monthly totals across multiple cities/factories

- **COVID Outbreak Visualization**
  - Overlayed outbreak data with confirmed/recovered/active counts
  - Interactive Google Map with colored bubbles per city:
    - Green = <100 cases
    - Yellow = 100–500 cases
    - Red = >500 cases
  - Tooltip per city with active case counts, number of factories, and reports

## Screenshots
### Factories by City – COVID Outbreak Map
<img width="1907" height="845" alt="unnamed2" src="https://github.com/user-attachments/assets/b6375021-2740-4d08-af3c-f269a1800161" />

### Interactive Report – City Monthly
![unnamed](https://github.com/user-attachments/assets/32c9b143-0a1b-45b8-931d-c7f2faf3400f)

## Technology
- **Platform**: PCSoft WinDev / WebDev (QualityPort SaaS)
- **Frontend**: HTML, CSS, JavaScript, Google Maps API
- **Backend**: WLanguage (WL), SQL database integration
- **Reporting**: Interactive grid + chart controls

## Impact
- Allowed clients to **visualize inspection reports geographically**
- Supported **risk assessments during COVID outbreaks** by linking case data to factory locations
- Improved decision-making for sourcing, quality, and compliance teams

## Notes
- This add-on was fully integrated into the QualityPort platform and deployed internationally.
- Data shown is sample/obfuscated for demo purposes only.
