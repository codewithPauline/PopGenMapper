# PopGenMapper

**Population ancestry, checked before it is mapped.**

An R package in development by **Pauline Owusu-Ansah**, Ph.D. Candidate in Biology at Miami University.

PopGenMapper is being developed to connect ancestry estimates with sample geography through clear validation and consistent visualizations. This initial development version establishes the package structure, input checks, and a fictional example dataset.

## Current status

| Capability | Status |
| --- | --- |
| Check sample IDs and align coordinates | Implemented; automated R checks configured |
| Validate ancestry proportions and coordinate bounds | Implemented; automated R checks configured |
| Built-in fictional example data | Included |
| Ancestry barplots | Planned |
| Geographic pie maps and consistent palettes | Planned |
| Locality summaries and figure export | Planned |

**Development version: 0.0.0.9000.** This is not a CRAN release or a finished mapping package. Check [GitHub Actions](https://github.com/codewithPauline/PopGenMapper/actions) for the current package-check result. R was not available in the initial authoring environment, so local R execution was not performed.

## Try the development version

Requires R 4.1 or newer. From R:

```r
install.packages("remotes") # once, if needed
remotes::install_github("codewithPauline/PopGenMapper")

library(PopGenMapper)
demo <- example_ancestry()
checked <- validate_ancestry(demo$ancestry, demo$coordinates)
checked$coordinates
```

The example has six fictional samples and two ancestry clusters. Its coordinates are invented and do not disclose research localities.

## Input format

Provide two data frames with one row per individual:

| Table | Required columns |
| --- | --- |
| Ancestry | `sample_id`, `Cluster1`, `Cluster2`, … |
| Coordinates | `sample_id`, `longitude`, `latitude` |

Sample IDs must be unique character strings and match exactly between tables. Coordinate rows may be in any order: they are aligned to the ancestry rows by ID.

Proportions must be numeric, finite, between zero and one, and sum to one per sample within the selected tolerance. Coordinates must be decimal degrees with longitude in [-180, 180] and latitude in [-90, 90]. Coordinate reference systems are not inferred or transformed.

Custom column names are supported:

```r
checked <- validate_ancestry(
  ancestry = my_ancestry,
  coordinates = my_coordinates,
  id = "Site",
  clusters = c("Cluster1", "Cluster2", "Cluster3"),
  lon = "Lon",
  lat = "Lat"
)
```

`my_ancestry` and `my_coordinates` above are your own data frames, not bundled objects. See `?validate_ancestry` for the function reference.

## Design commitments

- Match samples by explicit IDs, not assumed row order.
- Fail clearly on invalid inputs; never silently drop samples or normalize proportions.
- Keep examples independent of unpublished research data.
- Distinguish ancestry visualization from ancestry inference and species delimitation.

The package does not estimate ancestry or infer migration. Future plotting functions will display estimates supplied by the user.

## Development

Clone this repository and run:

```bash
R CMD build .
R CMD check --no-manual PopGenMapper_0.0.0.9000.tar.gz
```

Tests cover shuffled coordinate rows, mismatched and duplicate IDs, invalid proportions, invalid coordinates, and custom cluster columns. They use base R without a testing framework dependency.

## Next milestone

Build an ancestry barplot and a geographic pie-map function around the validated data object. See the [roadmap](docs/ROADMAP.md) for scope.

## Author and license

**Pauline Owusu-Ansah** · Computational and evolutionary biology  
[GitHub](https://github.com/codewithPauline) · [LinkedIn](https://www.linkedin.com/in/pauline-owusu-ansah-010250192/)

MIT license. Contributions and reproducible bug reports are welcome through [GitHub Issues](https://github.com/codewithPauline/PopGenMapper/issues).
