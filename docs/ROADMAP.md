# Development roadmap

## Foundation — this revision

- R package metadata, namespace, documentation, and MIT license.
- Input validator for individual ancestry and decimal-degree coordinates.
- Six-sample fictional example.
- Automated package checks and validation tests.

## First plotting milestone

- Ancestry barplots with explicit individual order and a named cluster palette.
- Geographic pie maps using a user-supplied basemap.
- Consistent cluster colors across both plot types.
- A complete example from validation to exported figures.

## Later work

- Explicit locality mapping and aggregation; never infer locality by deleting
  arbitrary parts of sample identifiers.
- CSV import helpers with clear column selection.
- Projection handling and geographic layout tests.
- Installation checks across operating systems and a tutorial.

No release date or CRAN acceptance is promised. The first usable mapping
release should follow passing package checks and visual inspection of outputs.
