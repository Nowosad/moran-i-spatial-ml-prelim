tune_mod = function(train_data, covariates){
  tune_ctrl = caret::trainControl(method = "oob")
  mtry = round(seq(2, length(covariates), length.out = 5))
  mtry = mtry[!duplicated(mtry)]
  tune_grid = data.frame(mtry = mtry, splitrule = "variance", min.node.size = 5)
  tune_mod = caret::train(train_data[covariates], train_data[, "outcome"],
                          method = "ranger", importance = "impurity",
                          num.trees = 500, trControl = tune_ctrl, tuneGrid = tune_grid)
  return(tune_mod)
}