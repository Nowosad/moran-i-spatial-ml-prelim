library(targets)
library(tarchetypes)

# Set target options:
tar_option_set(
  packages = c("tibble", "purrr"), # Packages that your targets need for their tasks.
  seed = 3,
  format = "qs"
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()

# Targets:
list(
  tar_target(
    name = rasters_df,
    command = tidyr::expand_grid(rep = 1:100, range = c(10, 50, 100)) |>
      purrr::pmap_df(create_rasters)
  ),
  tar_target(
    name = sample_df,
    command = purrr::map_df(350, create_samples)
  ),
  tar_target(
    name = raster_sample_df,
    command = tidyr::expand_grid(rasters_df, sample_df) |>
      dplyr::mutate(model_id = dplyr::row_number())
  ),
  tar_target(
    name = extracted_df,
    command = purrr::pmap(raster_sample_df[c("outcome", "predictors", "all_samples")], extract_from_raster)
  ),
  tar_target(
    name = extracted_df_sf,
    command = purrr::map(extracted_df, sf::st_as_sf, coords = c("x", "y"))
  ),
  tar_target(
    name = models,
    command = map(extracted_df, tune_mod, paste0("cov", 1:6))
  ),
  tar_target(
    name = pred_and_diff,
    command = purrr::pmap_df(list(models, raster_sample_df$predictors, raster_sample_df$outcome), predict_and_diff)
  ),
  tar_target(
    name = moran_global,
    command = purrr::map_dbl(pred_and_diff$difference, get_morani)
  ),
  tar_target(
    name = residuals_training,
    command = purrr::map2(models, extracted_df, get_residuals)
  ),
  tar_target(
    name = moran_training_residuals,
    command = purrr::map2_dbl(extracted_df_sf, residuals_training, get_morani)
  ),
  tar_target(
    name = testing_sample_df,
    command = purrr::map_df(150, create_samples)
  ),
  tar_target(
    name = raster_testing_sample_df,
    command = tidyr::expand_grid(raster_sample_df[c("rep", "range", "outcome", "predictors", "size", "model_id")], testing_sample_df |> 
                                   setNames(c("testing_size", "testing_sampling")))
  ),
  tar_target(
    name = extracted_testing_df,
    command = purrr::pmap(dplyr::select(raster_testing_sample_df, outcome, predictors, all_samples = testing_sampling), extract_from_raster)
  ),
  tar_target(
    name = extracted_testing_df_sf,
    command = purrr::map(extracted_testing_df, sf::st_as_sf, coords = c("x", "y"))
  ),
  tar_target(
    name = residuals_testing,
    command = purrr::pmap(list(raster_testing_sample_df$model_id, extracted_testing_df),
                          function(model_id, data, models) {
                            model = models[[model_id]]
                            get_residuals(model, data)}, models = models) 
  ),
  tar_target(
    name = moran_testing_residuals,
    command = purrr::map2_dbl(extracted_testing_df_sf, residuals_testing, get_morani)
  ),
  tar_target(
    name = rmse_global,
    command = purrr::map2_dbl(raster_sample_df$outcome, pred_and_diff$prediction, get_raster_rmse)
  ),
  tar_target(
    name = rmse_training,
    command = purrr::pmap_dbl(list(raster_sample_df$model_id, extracted_df),
                          function(model_id, data, models) {
                            model = models[[model_id]]
                            post_resample_rmse(model, data)
                          }, models = models)
  ),
  tar_target(
    name = rmse_testing,
    command = purrr::pmap_dbl(list(raster_testing_sample_df$model_id, extracted_testing_df),
                          function(model_id, data, models) {
                            model = models[[model_id]]
                            post_resample_rmse(model, data)
                          }, models = models)  
  ),
  tar_quarto(figures, "figures.qmd")
)

