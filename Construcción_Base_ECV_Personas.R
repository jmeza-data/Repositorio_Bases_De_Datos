################################################################################
# CONSTRUCCIÓN DE BASE_FINAL CORREGIDA PARA IPM - ECV 2024 DEPARTAMENTAL
# Autor: Dr. Jhoan Sebastián Meza García
# Adaptado del código oficial DANE
# Fecha: Octubre 2025
################################################################################

# 1. CARGAR LIBRERÍAS ----
library(tidyverse)
library(readr)

cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║   INICIO DEL PROCESO - CONSTRUCCIÓN DE BASE_FINAL (ECV)    ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# 2. CARGAR BASES DEPARTAMENTALES ----
cat("Cargando bases de datos...\n")

hogares <- read_csv("C:/Users/Jhoan meza/Desktop/BasesDatos-IMP-2024/Departamentos/Hogares (Departamental) 2024.csv",
                    show_col_types = FALSE)
personas <- read_csv("C:/Users/Jhoan meza/Desktop/BasesDatos-IMP-2024/Departamentos/Personas (Departamental) 2024.csv",
                     show_col_types = FALSE)
viviendas <- read_csv("C:/Users/Jhoan meza/Desktop/BasesDatos-IMP-2024/Departamentos/Viviendas (Departamental) 2024.csv",
                      show_col_types = FALSE)

cat("✓ Viviendas:", nrow(viviendas), "registros,", ncol(viviendas), "variables\n")
cat("✓ Hogares:", nrow(hogares), "registros,", ncol(hogares), "variables\n")
cat("✓ Personas:", nrow(personas), "registros,", ncol(personas), "variables\n\n")

# 3. CREAR LLAVES ÚNICAS ----
cat("Creando llaves únicas...\n")

viviendas <- viviendas %>%
  mutate(llave_vivienda = as.character(DIRECTORIO))

hogares <- hogares %>%
  mutate(llavehog = paste(DIRECTORIO, SECUENCIA_ENCUESTA, sep = "_"))

personas <- personas %>%
  mutate(llavehog = paste(DIRECTORIO, SECUENCIA_ENCUESTA, sep = "_"),
         llave_persona = paste(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN, sep = "_"))

cat("✓ Llaves creadas correctamente\n\n")

# 4. UNIR VIVIENDAS CON HOGARES ----
cat("Uniendo viviendas con hogares...\n")

viviendas_para_merge <- viviendas %>%
  select(DIRECTORIO, P3, P4005, P4015, P8520S3, P8520S5)

hogares_viviendas <- hogares %>%
  left_join(viviendas_para_merge, by = "DIRECTORIO") %>%
  rename(CLASE = P3)

cat("✓ Unión viviendas-hogares completada:", nrow(hogares_viviendas), "hogares\n\n")

# 5. AGREGAR CONTEO DE PERSONAS POR HOGAR ----
cat("Calculando cantidad de personas por hogar...\n")

personas_por_hogar <- personas %>%
  group_by(DIRECTORIO, SECUENCIA_ENCUESTA) %>%
  summarise(CANT_PERSONAS_HOGAR = n(), .groups = "drop")

hogares_viviendas <- hogares_viviendas %>%
  left_join(personas_por_hogar, by = c("DIRECTORIO", "SECUENCIA_ENCUESTA"))

cat("✓ CANT_PERSONAS_HOGAR añadida\n\n")

# 6. PREPARAR HOGARES PARA UNIÓN CON PERSONAS ----
cat("Preparando hogares para merge final...\n")

hogares_para_personas <- hogares_viviendas %>%
  select(DIRECTORIO, SECUENCIA_ENCUESTA, CLASE, P4005, P4015, P8520S3,
         P8520S5, P5010, P8526, P8530, P1075, P1077S21, P1077S22,
         P1077S23, CANT_PERSONAS_HOGAR, FEX_C, DEPARTAMENTO)

cat("✓ Estructura lista para unión con personas\n\n")

# 7. CREAR BASE_FINAL ----
cat("Creando base_final (personas + hogares)...\n")

base_final <- personas %>%
  left_join(hogares_para_personas,
            by = c("DIRECTORIO", "SECUENCIA_ENCUESTA"),
            suffix = c("_persona", "_hogar"))

# Renombrar FEX_C si quedó duplicado
if("FEX_C_persona" %in% names(base_final)) {
  base_final <- base_final %>%
    select(-FEX_C_hogar) %>%
    rename(FEX_C = FEX_C_persona)
}

cat("✓ BASE_FINAL creada con:", nrow(base_final), "personas y", ncol(base_final), "variables\n\n")

# 8. CREAR HOGARES_0 PARA DIMENSIÓN VIVIENDA ----
hogares_0 <- hogares_viviendas %>%
  mutate(llavehog = paste(DIRECTORIO, SECUENCIA_ENCUESTA, sep = "_"))

cat("✓ hogares_0 creada con:", nrow(hogares_0), "registros\n\n")

# 9. VERIFICACIÓN BÁSICA ----
cat("Verificando estructura...\n")
cat("Total personas:", nrow(base_final), "\n")
cat("Total hogares únicos:", n_distinct(base_final$llavehog), "\n")
cat("Total viviendas únicas:", n_distinct(base_final$DIRECTORIO), "\n\n")

cat("Variables clave presentes:\n")
vars <- c("DIRECTORIO", "SECUENCIA_ENCUESTA", "ORDEN", "P6040", "P6020", "llavehog", "CLASE", "FEX_C")
for(v in vars){
  if(v %in% names(base_final)) cat("  ✓", v, "\n") else cat("  ✗", v, "FALTA\n")
}

cat("\n╔════════════════════════════════════════════════════════════╗\n")
cat("║   ✓ BASE_FINAL CORREGIDA Y LISTA PARA EL CÁLCULO DEL IPM  ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# 10. GUARDAR BASE FINAL ----
write_csv(base_final, "base_final_corregida.csv")
cat("Archivo guardado como base_final_corregida.csv en el directorio actual.\n")
getwd()

