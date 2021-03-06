# SMAP - Small area estimation for policy makers
# Delen van dit script mogen gekopieerd worden voor eigen gebruik
# onder vermelding van de auteur en een referentie naar het SMAP artikel in IJHG (2017)
# Auteur: Jan van de Kassteele - RIVM

# Fit parallel random forest

rfparallel <- function(formula, data, ntree = 200, ncores = 4, importance = FALSE) {
  # formula    = random forest formule
  # data       = data om te fitten
  # ntree      = aantal bomen om te groeien
  # ncores     = aantal CPUs (CBS computer heeft 4 CPU's)
  # importance = variable importance bijhouden?
  
  # Laad packages
  require(parallel)
  require(doParallel)
  require(foreach)
  
  # Maak cluster met ncores nodes (CBS computer heeft 4 CPU's)
  cl <- makeCluster(ncores)
  registerDoParallel(cl)
  
  # Fit Random Forest model aan data
  # Omdat we het parallel doen mag je ntree delen door ncores
  rf.model <- foreach(
    i = 1:ncores,
    .combine = combine,
    .packages = "randomForest") %dopar%
    randomForest(
      formula = formula,
      data = data,
      ntree = round(ntree/ncores),
      importance = importance)
  
  # Stop cluster
  stopCluster(cl)
  
  # Return modelfit
  return(rf.model)
}
