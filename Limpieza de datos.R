################################################################################
# CONSTRUCCIÓN DE BASE_FINAL PARA IPM - ECV 2024 DEPARTAMENTAL
# Autor: Adaptado del código DANE
# Fecha: Octubre 2025
################################################################################

# 1. CARGAR LIBRERÍAS NECESARIAS ----
library(tidyverse)  # Para manipulación de datos
library(readr)      # Para leer CSVs

# 2. CARGAR LAS TRES BASES DEPARTAMENTALES ----
cat("Cargando bases de datos...\n")

# Ajusta las rutas según donde tengas guardados los archivos
hogares <- read_csv("C:\\Users\\Jhoan meza\\Desktop\\BasesDatos-IMP-2024\\Departamentos\\Hogares (Departamental) 2024.csv")
personas   <- read_csv("C:\\Users\\Jhoan meza\\Desktop\\BasesDatos-IMP-2024\\Departamentos\\Personas (Departamental) 2024.csv")
viviendas  <- read_csv("C:\\Users\\Jhoan meza\\Desktop\\BasesDatos-IMP-2024\\Departamentos\\Viviendas (Departamental) 2024.csv")

# 3. VERIFICAR ESTRUCTURA DE LAS BASES ----
cat("Verificando estructura de las bases...\n")
cat("Columnas en viviendas:", ncol(viviendas), "\n")
cat("Columnas en hogares:", ncol(hogares), "\n")
cat("Columnas en personas:", ncol(personas), "\n\n")

# 4. CREAR LLAVE ÚNICA PARA CADA BASE ----
# Según el instructivo del DANE:
# - Vivienda: DIRECTORIO
# - Hogares: DIRECTORIO + SECUENCIA_ENCUESTA
# - Personas: DIRECTORIO + SECUENCIA_P + SECUENCIA_ENCUESTA

viviendas <- viviendas %>%
  mutate(llave_vivienda = paste(DIRECTORIO, sep = "_"))

hogares <- hogares %>%
  mutate(llave_hogar = paste(DIRECTORIO, SECUENCIA_ENCUESTA, sep = "_"))

personas <- personas %>%
  mutate(llave_persona = paste(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA, sep = "_"),
         llavehog = paste(DIRECTORIO, SECUENCIA_P, sep = "_"))

# 5. UNIR VIVIENDAS CON HOGARES ----
cat("Uniendo viviendas con hogares...\n")

# Primero preparamos viviendas para el merge
viviendas_para_merge <- viviendas %>%
  select(DIRECTORIO, P3, P4005, P4015, P8520S3, P8520S5)

# Unimos hogares con viviendas por DIRECTORIO
hogares_viviendas <- hogares %>%
  left_join(viviendas_para_merge, by = "DIRECTORIO")

cat("✓ Hogares con info de vivienda:", nrow(hogares_viviendas), "registros\n\n")

# 6. CREAR VARIABLES NECESARIAS PARA HOGARES ----
# Según el código del DANE necesitamos:
# - CLASE (urbano/rural) viene de P3
# - CANT_PERSONAS_HOGAR viene de personas en hogares

hogares_viviendas <- hogares_viviendas %>%
  rename(CLASE = P3) %>%
  mutate(CANT_PERSONAS_HOGAR = personas)

# 7. PREPARAR HOGARES PARA MERGE CON PERSONAS ----
cat("Preparando merge final con personas...\n")

# Seleccionamos solo las variables de hogares que necesitamos
hogares_para_personas <- hogares_viviendas %>%
  select(DIRECTORIO, SECUENCIA_ENCUESTA, CLASE, P4005, P4015, P8520S3, 
         P8520S5, P5010, P8526, P8530, P1075, P1077S21, P1077S22, 
         P1077S23, CANT_PERSONAS_HOGAR, FEX_C, DEPARTAMENTO)

# 8. UNIR PERSONAS CON HOGARES (BASE_FINAL) ----
cat("Creando base_final...\n")

base_final <- personas %>%
  left_join(hogares_para_personas, 
            by = c("DIRECTORIO", "SECUENCIA_P" = "SECUENCIA_ENCUESTA"),
            suffix = c("_persona", "_hogar"))

# Renombrar FEX_C si quedó duplicado
if("FEX_C_persona" %in% names(base_final)) {
  base_final <- base_final %>%
    select(-FEX_C_hogar) %>%
    rename(FEX_C = FEX_C_persona)
}

cat("✓ BASE_FINAL creada con:", nrow(base_final), "registros (personas)\n")
cat("✓ Variables totales:", ncol(base_final), "\n\n")

# 9. VERIFICACIÓN DE LA BASE_FINAL ----
cat("=== VERIFICACIÓN DE BASE_FINAL ===\n")
cat("Registros totales:", nrow(base_final), "\n")
cat("Personas únicas:", n_distinct(base_final$DIRECTORIO, base_final$SECUENCIA_ENCUESTA, base_final$ORDEN), "\n")
cat("Hogares únicos:", n_distinct(base_final$llavehog), "\n")
cat("Viviendas únicas:", n_distinct(base_final$DIRECTORIO), "\n\n")

# Verificar variables clave
variables_clave <- c("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA", "ORDEN",
                     "P6040", "P6020", "llavehog", "CLASE", "FEX_C", 
                     "P4005", "P4015", "P8520S3", "P8520S5")

cat("Verificando variables clave:\n")
for(var in variables_clave) {
  if(var %in% names(base_final)) {
    cat("✓", var, "- OK\n")
  } else {
    cat("✗", var, "- FALTA\n")
  }
}

# 10. CREAR HOGARES_0 PARA LA DIMENSIÓN 5 ----
# El código del DANE usa una base llamada hogares_0 para vivienda y servicios
hogares_0 <- hogares_viviendas %>%
  mutate(llavehog = paste(DIRECTORIO, SECUENCIA_ENCUESTA, sep = "_"))

cat("\n✓ hogares_0 creada con:", nrow(hogares_0), "registros\n")

# 11. MOSTRAR RESUMEN DE BASE_FINAL ----
cat("\n=== RESUMEN DE BASE_FINAL ===\n")
cat("Primeras columnas:\n")
print(names(base_final)[1:20])

cat("\nPrimeros registros:\n")
print(head(base_final %>% select(DIRECTORIO, SECUENCIA_P, SECUENCIA_ENCUESTA, 
                                 ORDEN, P6040, P6020, llavehog, CLASE)))

cat("\n¡BASE_FINAL LISTA PARA CONSTRUIR LOS INDICADORES DEL IPM! ✓\n")
cat("Puedes continuar con el código del DANE para crear los 15 indicadores.\n")



# Exportar base_final
write_csv(base_final, "base_final.csv")
getwd()  # Te muestra la ruta donde se guardó











################################################################################
# LIMPIAR DUPLICADOS DE BASE_FINAL
# Elimina registros duplicados manteniendo solo uno por persona
################################################################################

library(tidyverse)

cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║            LIMPIEZA DE REGISTROS DUPLICADOS                ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# 1. VERIFICAR ESTADO ACTUAL ----
cat("1. ESTADO ACTUAL DE BASE_FINAL\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("Registros totales:", format(nrow(base_final), big.mark = ","), "\n")

# Contar duplicados
duplicados_count <- base_final %>%
  group_by(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN) %>%
  filter(n() > 1) %>%
  nrow()

cat("Registros duplicados:", format(duplicados_count, big.mark = ","), "\n")

personas_unicas <- base_final %>%
  distinct(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN) %>%
  nrow()

cat("Personas únicas:", format(personas_unicas, big.mark = ","), "\n\n")

# 2. IDENTIFICAR Y MOSTRAR DUPLICADOS ----
if(duplicados_count > 0) {
  cat("2. ANALIZANDO DUPLICADOS\n")
  cat("─────────────────────────────────────────────────────────────\n")
  
  ejemplo_duplicados <- base_final %>%
    group_by(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN) %>%
    filter(n() > 1) %>%
    arrange(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN) %>%
    head(10)
  
  cat("Primeros casos de duplicados:\n")
  print(ejemplo_duplicados %>% 
          select(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN, P6040, P6020, llavehog))
  
  cat("\n")
}

# 3. ELIMINAR DUPLICADOS ----
cat("3. ELIMINANDO DUPLICADOS\n")
cat("─────────────────────────────────────────────────────────────\n")

# Guardar copia de seguridad
base_final_con_duplicados <- base_final

# Método 1: distinct() mantiene el primer registro de cada grupo
base_final_limpia <- base_final %>%
  distinct(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN, .keep_all = TRUE)

cat("✓ Duplicados eliminados usando distinct()\n")
cat("  Registros antes:", format(nrow(base_final), big.mark = ","), "\n")
cat("  Registros después:", format(nrow(base_final_limpia), big.mark = ","), "\n")
cat("  Registros eliminados:", format(nrow(base_final) - nrow(base_final_limpia), big.mark = ","), "\n\n")

# 4. VERIFICAR QUE NO QUEDEN DUPLICADOS ----
cat("4. VERIFICACIÓN POST-LIMPIEZA\n")
cat("─────────────────────────────────────────────────────────────\n")

duplicados_restantes <- base_final_limpia %>%
  group_by(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN) %>%
  filter(n() > 1) %>%
  nrow()

if(duplicados_restantes == 0) {
  cat("✓✓✓ ¡ÉXITO! No quedan duplicados\n\n")
} else {
  cat("⚠️ Aún quedan", duplicados_restantes, "duplicados\n\n")
}

# 5. REEMPLAZAR BASE_FINAL CON LA VERSIÓN LIMPIA ----
cat("5. ACTUALIZANDO BASE_FINAL\n")
cat("─────────────────────────────────────────────────────────────\n")

base_final <- base_final_limpia

cat("✓ base_final actualizada y sin duplicados\n\n")

# 6. VERIFICACIÓN FINAL COMPLETA ----
cat("6. RESUMEN FINAL\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("Total personas:", format(nrow(base_final), big.mark = ","), "\n")
cat("Hogares únicos:", format(n_distinct(base_final$llavehog), big.mark = ","), "\n")
cat("Viviendas únicas:", format(n_distinct(base_final$DIRECTORIO), big.mark = ","), "\n")
cat("Variables:", ncol(base_final), "\n")
cat("Duplicados:", 0, "\n\n")

# Verificar variables clave
vars_criticas <- c("DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA", "ORDEN",
                   "P6040", "P6020", "llavehog", "CLASE", "FEX_C")

cat("Variables críticas presentes:\n")
for(var in vars_criticas) {
  if(var %in% names(base_final)) {
    cat("  ✓", var, "\n")
  } else {
    cat("  ✗", var, "FALTA\n")
  }
}

cat("\n╔════════════════════════════════════════════════════════════╗\n")
cat("║   ✓ BASE_FINAL LIMPIA Y LISTA PARA CALCULAR EL IPM        ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")



























################################################################################
# VERIFICACIÓN RÁPIDA POST-LIMPIEZA
################################################################################

library(tidyverse)

cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║          VERIFICACIÓN RÁPIDA DE BASE_FINAL                 ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# 1. CONTEO BÁSICO ----
cat("📊 ESTADÍSTICAS BÁSICAS:\n")
cat("─────────────────────────────────────────────────────────────\n")
cat("Total personas:", format(nrow(base_final), big.mark = ","), "\n")
cat("Total hogares:", format(n_distinct(base_final$llavehog), big.mark = ","), "\n")
cat("Total viviendas:", format(n_distinct(base_final$DIRECTORIO), big.mark = ","), "\n")
cat("Total variables:", ncol(base_final), "\n\n")

# 2. VERIFICAR DUPLICADOS ----
cat("🔍 VERIFICACIÓN DE DUPLICADOS:\n")
cat("─────────────────────────────────────────────────────────────\n")

duplicados <- base_final %>%
  group_by(DIRECTORIO, SECUENCIA_ENCUESTA, ORDEN) %>%
  filter(n() > 1) %>%
  nrow()

if(duplicados == 0) {
  cat("✓✓✓ PERFECTO: No hay duplicados\n\n")
} else {
  cat("⚠️ Hay", duplicados, "registros duplicados\n\n")
}

# 3. VERIFICAR VARIABLES CLAVE ----
cat("📋 VARIABLES NECESARIAS PARA EL IPM:\n")
cat("─────────────────────────────────────────────────────────────\n")

variables_ipm <- c(
  # Identificadores
  "DIRECTORIO", "SECUENCIA_P", "SECUENCIA_ENCUESTA", "ORDEN", "llavehog",
  # Demográficas
  "P6040", "P6020", "FEX_C", "CLASE",
  # Educación
  "P1088", "P1088S1", "P8587", "P8587S1", "P6160",
  # Salud
  "P6090", "P5665", "P8563",
  # Vivienda
  "P4005", "P4015", "P8520S3", "P8520S5", "P5010"
)

todas_presentes <- all(variables_ipm %in% names(base_final))

if(todas_presentes) {
  cat("✓ Todas las variables clave están presentes\n\n")
} else {
  faltantes <- variables_ipm[!variables_ipm %in% names(base_final)]
  cat("⚠️ Faltan variables:", paste(faltantes, collapse = ", "), "\n\n")
}

# 4. VERIFICAR NA EN VARIABLES CRÍTICAS ----
cat("❓ VALORES FALTANTES EN VARIABLES CRÍTICAS:\n")
cat("─────────────────────────────────────────────────────────────\n")

vars_criticas <- c("DIRECTORIO", "SECUENCIA_ENCUESTA", "ORDEN", 
                   "P6040", "llavehog", "FEX_C", "CLASE")

na_count <- base_final %>%
  select(any_of(vars_criticas)) %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "NA_count") %>%
  filter(NA_count > 0)

if(nrow(na_count) == 0) {
  cat("✓ No hay NA en variables críticas\n\n")
} else {
  cat("⚠️ Variables con NA:\n")
  print(na_count)
  cat("\n")
}

# 5. DISTRIBUCIÓN URBANO/RURAL ----
cat("🏘️  DISTRIBUCIÓN URBANO/RURAL:\n")
cat("─────────────────────────────────────────────────────────────\n")

if("CLASE" %in% names(base_final)) {
  tabla_clase <- base_final %>%
    group_by(CLASE) %>%
    summarise(
      personas = n(),
      hogares = n_distinct(llavehog),
      porcentaje = round(n() / nrow(base_final) * 100, 1)
    )
  
  print(tabla_clase)
  cat("(1 = Urbano, 2 = Rural)\n\n")
} else {
  cat("⚠️ Variable CLASE no encontrada\n\n")
}

# 6. DISTRIBUCIÓN DE EDAD ----
cat("👥 DISTRIBUCIÓN POR EDAD:\n")
cat("─────────────────────────────────────────────────────────────\n")

if("P6040" %in% names(base_final)) {
  cat("Edad mínima:", min(base_final$P6040, na.rm = TRUE), "años\n")
  cat("Edad máxima:", max(base_final$P6040, na.rm = TRUE), "años\n")
  cat("Edad promedio:", round(mean(base_final$P6040, na.rm = TRUE), 1), "años\n\n")
  
  grupos <- base_final %>%
    mutate(grupo = case_when(
      P6040 < 15 ~ "Menores de 15",
      P6040 >= 15 & P6040 < 65 ~ "15-64 años",
      P6040 >= 65 ~ "65+ años"
    )) %>%
    count(grupo) %>%
    mutate(porcentaje = round(n / sum(n) * 100, 1))
  
  print(grupos)
  cat("\n")
}

# 7. VERIFICAR HOGARES_0 ----
cat("🏠 VERIFICACIÓN DE HOGARES_0:\n")
cat("─────────────────────────────────────────────────────────────\n")

if(exists("hogares_0")) {
  cat("✓ hogares_0 existe\n")
  cat("  Registros:", format(nrow(hogares_0), big.mark = ","), "\n")
  cat("  Variables:", ncol(hogares_0), "\n\n")
} else {
  cat("⚠️ hogares_0 no existe - necesitas crearla\n\n")
}

# 8. RESUMEN FINAL ----
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║                    RESUMEN FINAL                           ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

problemas <- 0

if(duplicados > 0) {
  cat("❌ Hay duplicados que corregir\n")
  problemas <- problemas + 1
} else {
  cat("✅ Sin duplicados\n")
}

if(!todas_presentes) {
  cat("❌ Faltan variables necesarias\n")
  problemas <- problemas + 1
} else {
  cat("✅ Todas las variables presentes\n")
}

if(nrow(na_count) > 0) {
  cat("⚠️  Hay NA en variables críticas\n")
  problemas <- problemas + 1
} else {
  cat("✅ Sin NA en variables críticas\n")
}

if(!exists("hogares_0")) {
  cat("⚠️  Falta hogares_0\n")
  problemas <- problemas + 1
} else {
  cat("✅ hogares_0 disponible\n")
}

cat("\n")

if(problemas == 0) {
  cat("╔════════════════════════════════════════════════════════════╗\n")
  cat("║  🎉 ¡TODO PERFECTO! LISTO PARA CALCULAR EL IPM 🎉         ║\n")
  cat("╚════════════════════════════════════════════════════════════╝\n\n")
  cat("👉 Siguiente paso: Ejecutar el código del DANE para crear\n")
  cat("   los 15 indicadores del IPM\n\n")
} else {
  cat("⚠️  Hay", problemas, "problema(s) que resolver antes de continuar\n\n")
}


# Exportar base_final limpia
write_csv(base_final, "base_final_limpia.csv")

# Ver dónde se guardó
getwd()











































































