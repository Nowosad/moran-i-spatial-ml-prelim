extract_from_raster = function(outcome, predictors, all_samples){
  allrast = c(terra::rast(outcome), terra::rast(predictors))
  terra::extract(allrast, all_samples, ID = FALSE, xy = TRUE)
}