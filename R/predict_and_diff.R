predict_and_diff = function(model, predictors, outcome){
  pred = terra::predict(terra::rast(predictors), model)
  diff = pred - terra::rast(outcome)
  pred_fn = paste0("data/rasters/prediction_", stringr::str_remove(predictors, "data/rasters/covariates_"))
  diff_fn = paste0("data/rasters/difference_", stringr::str_remove(predictors, "data/rasters/covariates_"))
  terra::writeRaster(pred, pred_fn, overwrite = TRUE)
  terra::writeRaster(diff, diff_fn, overwrite = TRUE)
  tibble::tibble(prediction = pred_fn, difference = diff_fn)
}
