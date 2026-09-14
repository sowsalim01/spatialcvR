# Script pour créer le fichier sample_spatial_data.rda correctement
# Exécutez ce script dans R ou RStudio

set.seed(123)

# Nombre d'observations
n <- 200

# Créer des coordonnées spatiales dans un CRS projeté (UTM-like)
x_coords <- runif(n, min = 0, max = 1000)
y_coords <- runif(n, min = 0, max = 1000)

# Créer des variables avec une structure spatiale
variable1 <- 50 + 0.05 * x_coords + rnorm(n, mean = 0, sd = 10)
variable2 <- 30 + 0.03 * y_coords + rnorm(n, mean = 0, sd = 8)

# Variable cible : combinaison des variables avec autocorrélation spatiale
target <- 10 + 0.8 * variable1 + 0.5 * variable2 + 
          0.01 * x_coords + 0.02 * y_coords + 
          rnorm(n, mean = 0, sd = 5)

# Créer le data frame
sample_spatial_data <- data.frame(
  id = 1:n,
  longitude = x_coords,
  latitude = y_coords,
  variable1 = variable1,
  variable2 = variable2,
  target = target
)

# Ajouter quelques valeurs manquantes pour les tests
sample_spatial_data$variable1[sample(1:n, 5)] <- NA
sample_spatial_data$target[sample(1:n, 3)] <- NA

# Sauvegarder avec la version actuelle de save()
save(sample_spatial_data, file = "D:/M-SOW/mamadou/sow/plugin/r/spatialcvR/data/sample_spatial_data.rda", version = 3)

cat("Sample spatial data créé avec succès:\n")
cat("  Nombre d'observations:", nrow(sample_spatial_data), "\n")
cat("  Nombre de variables:", ncol(sample_spatial_data), "\n")
cat("  Plage des coordonnées:\n")
cat("    X:", range(sample_spatial_data$longitude), "\n")
cat("    Y:", range(sample_spatial_data$latitude), "\n")
cat("  Valeurs manquantes:\n")
cat("    variable1:", sum(is.na(sample_spatial_data$variable1)), "\n")
cat("    target:", sum(is.na(sample_spatial_data$target)), "\n")