get_morani = function(data, outcome, k = 8){
  if (inherits(data, "character")){
    data = terra::rast(data)
    data = terra::as.data.frame(data, xy = TRUE)
    data = na.omit(data)
    coords = data[, 1:2]
    outcome = data[, 3, drop = TRUE]
  } else {
    coords = sf::st_coordinates(data)
    if (missing(outcome)){
      outcome = data$outcome
    }
  }
  nb = spdep::knn2nb(spdep::knearneigh(coords, k = k))
  lw = spdep::nb2listw(nb, style = "C", zero.policy = FALSE)
  moran = spdep::moran.test(outcome, lw)$estimate[[1]]
  return(moran)
}
