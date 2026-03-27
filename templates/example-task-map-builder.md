# Geographic Visualization: Sample City Data

> Task agent: `@task-agent-map-builder`
> This is an example task description demonstrating all features.

---

## Basemap
CartoDB Positron

## Data Layers

### City Districts
- **file**: data/districts.gpkg
- **type**: polygon
- **style**: color by "district_type"
  - residential: #f39c12
  - commercial: #e74c3c
  - industrial: #3498db
  - park: #27ae60
  - default: #bdc3c7
- **style**: opacity 0.6, stroke #2c3e50 1px
- **tooltip**: name, district_type, area_km2
- **popup**: all attributes

### Points of Interest
- **file**: data/poi.csv
- **lat_column**: latitude
- **lon_column**: longitude
- **type**: point
- **style**: circle radius 6, color by "category"
  - restaurant: #e67e22
  - museum: #8e44ad
  - hospital: #c0392b
  - school: #2980b9
  - default: #7f8c8d
- **tooltip**: name, category
- **popup**: name, category, address, phone, website

### Road Network
- **file**: data/roads.shp
- **type**: line
- **style**: color by "road_class"
  - highway: #e74c3c, width 3
  - primary: #f39c12, width 2
  - secondary: #f1c40f, width 1.5
  - default: #bdc3c7, width 1
- **tooltip**: name, road_class
- **min_zoom**: 12

## Map Settings
- **center**: [12.4964, 41.9028]
- **zoom**: 12
- **min_zoom**: 10
- **max_zoom**: 18
- **title**: Sample City Data Visualization
- **layer_control**: true

## Output
- **path**: output/sample-city-map.html

---

## Notes

This example uses fictional data paths. To run it:

1. Replace `data/districts.gpkg`, `data/poi.csv`, and `data/roads.shp` with your actual files
2. Update column names to match your data
3. Adjust center coordinates and zoom to your area of interest
4. Run:

```
@task-agent-map-builder Generate map from tasks/example-task-map-builder.md
```

The agent will produce a single `output/sample-city-map.html` file you can open in any browser.
