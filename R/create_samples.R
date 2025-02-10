create_samples = function(size){
  rast_grid = terra::rast(xmin = 0, xmax = 200, ymin = 0, ymax = 200, 
                          ncols = 200, nrows = 200, crs = "local")
  sampling = simsam::sam_field(rast_grid, size = size, type = "random")
  tibble::tibble(size = size, all_samples = list(sampling))
}