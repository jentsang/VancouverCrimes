# VancouverCrimes

> Interactive geospatial dashboard for visualizing crime patterns across Vancouver neighbourhoods.

[Live App](https://jentsang-vancouvercrimes.share.connect.posit.cloud/)

## Motivation

Choosing a location for a new business requires understanding local safety conditions. VancouverCrimes helps new business owners and community members visualize which areas in Vancouver are more prone to specific types of crimes, enabling informed risk assessments for business placement decisions.

Using publicly available data from the Vancouver Police Department (2025), the dashboard provides:

- **Crime Type Filters** -- Drill down into specific offence types.
- **Interactive Map** -- Geospatial view of crime hotspots across Vancouver neighbourhoods.
- **Comparative KPIs** — Instant tracking of the highest and lowest crime counts and their respective neighbourhoods.

## Installation & Local Development

### 1. Install R
Ensure you have [R installed](https://cran.r-project.org/) on your system.

### 2. Clone the repository

```bash
git clone https://github.com/jentsang/VancouverCrimes.git
cd VancouverCrimes
```

### 3. Install Dependencies
Open an R session and run the following command to install the required libraries:

```bash
install.packages(c("shiny", "bslib", "leaflet", "sf", "dplyr", "readr"))
```

### 4. Run the dashboard
You can run the app from your terminal:

```bash
R -e "shiny::runApp()"
```

Or open the `app.R` script in **RStudio** and click the **Run App** button at the top of the editor.