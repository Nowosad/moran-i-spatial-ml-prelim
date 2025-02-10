create_rasters = function(rep, range, ...){
  rast_grid = terra::rast(xmin = 0, xmax = 200, ymin = 0, ymax = 200, 
                          ncols = 200, nrows = 200, crs = "local")
  covariates = simsam::sim_covariates(rast_grid, range = range, n = 6)
  noise = simsam::sim_covariates(rast_grid, range = range, n = 1)
  names(noise) = "noise"
  outcome = simsam::blend_rasters(c(covariates, noise), ~ cov1 + cov2 * cov3 + cov4 + cov5 * cov6)# + noise)
  dir.create("data/rasters", showWarnings = FALSE, recursive = TRUE)
  covariates_fn = paste0("data/rasters/covariates_", range, "_", rep, ".tif")
  outcome_fn = paste0("data/rasters/outcome_", range, "_", rep, ".tif")
  terra::writeRaster(covariates, covariates_fn, overwrite = TRUE)
  terra::writeRaster(outcome, outcome_fn, overwrite = TRUE)
  tibble::tibble(rep = rep, range = range, outcome = outcome_fn, predictors = covariates_fn)
}