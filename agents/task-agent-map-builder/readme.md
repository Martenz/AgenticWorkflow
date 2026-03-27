# Task Agent: Map Builder

**Agent file**: `task-agent-map-builder.agent.md`

Generates self-contained, portable HTML files with interactive map visualizations from local geospatial data. Uses **MapLibre GL JS** exclusively with a locked **Design System** — every map shares the same fonts, colors, UI chrome, and component layout for a consistent visual identity.

---

## Quick Start

### 1. Create a task description

Create a markdown file in `tasks/` describing your map:

```markdown
# My City Map

## Basemap
OpenStreetMap

## Data Layers

### Buildings
- **file**: data/buildings.gpkg
- **type**: polygon
- **style**: fill #3498db, opacity 0.6, stroke #2c3e50 1px
- **tooltip**: name, address
- **popup**: all attributes

### Points of Interest
- **file**: data/poi.csv
- **lat_column**: latitude
- **lon_column**: longitude
- **type**: point
- **style**: circle radius 6, color by "category"
- **tooltip**: name, category

## Map Settings
- **center**: [12.4964, 41.9028]
- **zoom**: 13
- **title**: My City Map

## Output
- **path**: output/city-map.html
```

### 2. Run the agent

```
@task-agent-map-builder Generate map from tasks/my-city-map.md
```

The agent produces a single HTML file you can open in any browser and share.

---

## Supported Data Formats

| Format | Extension | Notes |
|--------|-----------|-------|
| Shapefile | `.shp` | Requires `.shx`, `.dbf` alongside |
| GeoPackage | `.gpkg` | Multiple layers supported |
| GeoJSON | `.geojson`, `.json` | Native format, no conversion needed |
| CSV | `.csv` | Requires latitude/longitude columns |

---

## Standalone Usage

Run the agent by itself for one-off map generation:

```
@task-agent-map-builder Generate map from tasks/my-task.md
```

### Regenerate after data updates

```
@task-agent-map-builder Regenerate map from tasks/my-task.md
```

---

## Usage with Other Agents

### With Plan Orchestrator

Add a map builder step in your roadmap and reference the task agent:

```markdown
## Milestones

1. Prepare spatial data
2. Generate interactive map visualization
   - Use @task-agent-map-builder with tasks/dashboard-map.md
3. Integrate map into documentation
```

Then run:

```
@plan-orchestrator Run workflow from docs/roadmaps/spatial-dashboard.md
```

The orchestrator will invoke `@task-agent-map-builder` when it reaches the map generation step.

### With Plan Implementer

During plan implementation, the implementer can delegate map tasks:

```
@plan-implementer Start plan spatial-dashboard
```

When the implementer encounters a step that requires map visualization, it invokes:

```
@task-agent-map-builder Generate map from tasks/dashboard-map.md
```

### Chaining with Other Task Agents

Task agents can be composed. For example, if you have a data-processing task agent:

```
@task-agent-data-prep Process data from tasks/clean-geodata.md
@task-agent-map-builder Generate map from tasks/visualize-results.md
```

---

## Customization

### Custom Basemaps

Specify any XYZ tile URL:

```markdown
## Basemap
- **url**: https://tiles.example.com/{z}/{x}/{y}.png
- **attribution**: © Example Tiles
```

Or use a named style:

| Name | Description |
|------|-------------|
| `OpenStreetMap` | Default OSM tiles |
| `CartoDB Positron` | Light, minimal style |
| `CartoDB DarkMatter` | Dark style |
| `CartoDB Voyager` | Colorful, detailed style |

### Styling Rules

#### Static styling

```markdown
- **style**: fill #e74c3c, opacity 0.5, stroke #c0392b 2px
```

#### Data-driven styling

```markdown
- **style**: color by "land_use"
  - residential: #f1c40f
  - commercial: #e74c3c
  - industrial: #3498db
  - default: #95a5a6
```

#### Graduated styling

```markdown
- **style**: graduated by "population"
  - breaks: [100, 500, 1000, 5000]
  - colors: ["#feedde", "#fdbe85", "#fd8d3c", "#e6550d", "#a63603"]
```

### Interactivity Options

#### Tooltip (hover)

```markdown
- **tooltip**: name, address, category
```

Shows a small popup on mouse hover with the listed fields.

#### Popup (click)

```markdown
- **popup**: all attributes
```

Or specify fields:

```markdown
- **popup**: name, description, website
```

#### Modal (click — detailed view)

```markdown
- **modal**: true
- **modal_fields**: name, description, image_url, website, phone
```

Opens a larger overlay panel with formatted attribute details.

#### Layer Toggle

```markdown
## Settings
- **layer_control**: true
```

Adds a layer switcher panel to toggle data layers on/off.

### Design System

All maps use a locked design system defined in the agent definition. This includes:

- **Font**: Inter (Google Fonts) with system fallbacks
- **Color tokens**: CSS custom properties (`--mb-bg`, `--mb-text`, `--mb-accent`, etc.)
- **Components**: title bar, layer control, tooltip, popup, modal, legend — all with fixed CSS classes
- **Layout**: title top-left, layer control top-right, legend bottom-left, nav control bottom-right

The design system cannot be overridden via the task description. To change it, edit the agent definition at `agents/task-agent-map-builder/task-agent-map-builder.agent.md`.

---

## Task Description Reference

Full specification of all supported fields in a task description:

```markdown
# {Map Title}

## Basemap
{name or URL}
- **url**: {XYZ tile URL}         # optional, overrides name
- **attribution**: {text}         # optional

## Data Layers

### {Layer Name}
- **file**: {relative path to data file}
- **type**: point | line | polygon           # auto-detected if omitted
- **lat_column**: {column name}              # CSV only
- **lon_column**: {column name}              # CSV only
- **layer_name**: {layer within file}        # GeoPackage with multiple layers
- **style**: {styling rules}
- **tooltip**: {field1}, {field2}            # hover
- **popup**: {field list or "all attributes"} # click
- **modal**: true | false
- **modal_fields**: {field list}
- **min_zoom**: {number}
- **max_zoom**: {number}
- **filter**: {attribute} = {value}          # simple filter

## Map Settings
- **center**: [{longitude}, {latitude}]
- **zoom**: {number}
- **min_zoom**: {number}
- **max_zoom**: {number}
- **bounds**: [[{sw_lng}, {sw_lat}], [{ne_lng}, {ne_lat}]]  # fit to bounds
- **title**: {map title}
- **layer_control**: true | false

## Output
- **path**: {output file path}
- **open**: true | false                     # auto-open in browser after generation
```

---

## Example

See the included example task at [templates/example-task-map-builder.md](../../templates/example-task-map-builder.md) which demonstrates:

- Multiple data layers (polygon + point from different formats)
- Data-driven styling
- Tooltips and popups
- Layer toggle control
- Custom map bounds

After installation, find a copy at `tasks/example-task-map-builder.md` in your project.
