get_residuals = function(model, data){
  pred = predict(model, data)
  obs = data$outcome
  residuals = obs - pred
  return(residuals)
}
