library(tidycensus)
library(tigris)
library(dplyr)
library(sf)
library(tidyr)

options(tigris_use_cache = TRUE)
options(tigris_class = "sf")

# Set your Census API key
census_api_key("2599edd9b7d100bcf3d6894676ccdd86672199c1", install = TRUE, overwrite = TRUE)

#TIGER server down
pa_geom <- st_read("rdata/tl_2020_42_bg.shp") %>%
  select(GEOID, geometry)

philly_geom <- pa_geom %>%
  filter(substr(GEOID, 1, 5) == "42101")

vars <- c(med_income = "B19013_001", med_home_value = "B25077_001")
years <- 2015:2023

# Pull ACS data for all years and bind
acs_list <- lapply(years, function(y) {
  get_acs(
    geography = "block group",
    variables = vars,
    state = "PA",
    county = "Philadelphia",
    year = y,
    geometry = FALSE
  ) %>%
    mutate(year = y)
})

acs_all <- bind_rows(acs_list)

# Pivot wider: one row per GEOID + year
acs_wide <- acs_all %>%
  select(GEOID, year, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) 

# Join to geometry (many-to-many: each year per GEOID)
philly_acs <- philly_geom %>%
  left_join(acs_wide, by = "GEOID")

philly_acs_df <- philly_acs %>%
  pivot_wider(
    id_cols = c(GEOID, geometry),
    names_from = year,
    values_from = c(med_income, med_home_value),
    names_glue = "{.value}_{year}"
  )
#Write this in the morning!! 

# Save to GeoPackage (better than shapefile for multi-year data)
st_write(philly_acs_df, "philly_acs.gpkg")
