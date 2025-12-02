library(dplyr)
library(tidyr)

# ============================================================
# 0. CARGAR BASE IPM A NIVEL PERSONA
# ============================================================
file.choose()
# Usa tu ruta:
IPM_personas <- read.csv("IPM_personas_final.csv")

# ============================================================
# 1. VARIABLES DEL HOGAR (DEMOGRÁFICAS)
# ============================================================

hogar_demo <- IPM_personas %>%
  group_by(llavehog) %>%
  summarise(
    TAMANO_HOGAR   = n(),
    EDAD_PROMEDIO  = mean(P6040, na.rm = TRUE),
    EDU_PROMEDIO   = mean(P8587S1, na.rm = TRUE),
    PROP_MUJERES   = mean(P6020 == 2, na.rm = TRUE)
  )

# ============================================================
# 2. PRIVACIONES DEL IPM (TOMAR MÁXIMO POR HOGAR)
# ============================================================

privaciones <- IPM_personas %>%
  group_by(llavehog) %>%
  summarise(
    LOGRO_2         = max(LOGRO_2, na.rm = TRUE),
    ALFA_2          = max(ALFA_2, na.rm = TRUE),
    ASISTE_2        = max(ASISTE_2, na.rm = TRUE),
    REZAGO_2        = max(REZAGO_2, na.rm = TRUE),
    A_INTEGRAL_2    = max(A_INTEGRAL_2, na.rm = TRUE),
    
    TRABAJOINF_2    = max(TRABAJOINF_2, na.rm = TRUE),
    DES_DURA_2      = max(DES_DURA_2, na.rm = TRUE),
    EFORMAL_2       = max(EFORMAL_2, na.rm = TRUE),
    
    SEGURO_SALUD_2  = max(SEGURO_SALUD_2, na.rm = TRUE),
    SALUD_NEC_2     = max(SALUD_NEC_2, na.rm = TRUE),
    
    ACUEDUCTO       = max(ACUEDUCTO, na.rm = TRUE),
    ALCANTARILLADO  = max(ALCANTARILLADO, na.rm = TRUE),
    PISOS           = max(PISOS, na.rm = TRUE),
    PAREDES         = max(PAREDES, na.rm = TRUE),
    HACINAMIENTO    = max(HACINAMIENTO, na.rm = TRUE)
  ) %>%
  mutate(
    TOT_PRIVACIONES = LOGRO_2 + ALFA_2 + ASISTE_2 + REZAGO_2 + A_INTEGRAL_2 +
      TRABAJOINF_2 + DES_DURA_2 + EFORMAL_2 +
      SEGURO_SALUD_2 + SALUD_NEC_2 +
      ACUEDUCTO + ALCANTARILLADO + PISOS +
      PAREDES + HACINAMIENTO
  )

# ============================================================
# 3. IPM Y POBRE DEL HOGAR
# ============================================================

hogar_ipm <- IPM_personas %>%
  group_by(llavehog) %>%
  summarise(
    IPM   = max(IPM, na.rm = TRUE),
    POBRE = max(POBRE, na.rm = TRUE)
  )

# ============================================================
# 4. VARIABLES TERRITORIALES Y PESOS
# ============================================================

hogar_zona <- IPM_personas %>%
  group_by(llavehog) %>%
  summarise(
    CLASE        = first(CLASE),
    DEPARTAMENTO = first(DEPARTAMENTO),
    FEX_C        = first(FEX_C)
  ) %>%
  mutate(
    ZONA = case_when(
      CLASE == 1 ~ "Cabecera",
      CLASE == 2 ~ "Centro poblado",
      CLASE == 3 ~ "Rural disperso",
      TRUE ~ NA_character_
    )
  )

# ============================================================
# 5. CONSTRUIR BASE FINAL hogares_ML
# ============================================================

hogares_ML <- hogar_zona %>%
  left_join(hogar_demo,    by = "llavehog") %>%
  left_join(privaciones,   by = "llavehog") %>%
  left_join(hogar_ipm,     by = "llavehog")

# ============================================================
# 6. EXPORTAR A CSV
# ============================================================

write.csv(hogares_ML, "hogares_ML_FINAL.csv", row.names = FALSE)

cat("✔ hogares_ML_FINAL.csv generado correctamente.\n")
