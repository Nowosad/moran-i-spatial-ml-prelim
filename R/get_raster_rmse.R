get_raster_rmse = function(outcome_path, prediction_path){
  outcome = terra::rast(outcome_path)
  prediction = terra::rast(prediction_path)
  sqrt(mean((terra::values(outcome) - terra::values(prediction))^2))
}