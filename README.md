<div align="center">

# 📚 **Repositorio de Bases de Datos – ECV 2024 & IPM Colombia**

<img src="https://raw.githubusercontent.com/github/explore/main/topics/r/r.png" width="90">

<br>

### **Procesamiento de Microdatos • Ingeniería de Datos • Estadística Social**

<br>

![Status](https://img.shields.io/badge/Estado-Activo-success?style=flat-square)
![License](https://img.shields.io/badge/Licencia-DANE%20Microdatos-blue?style=flat-square)
![Made with R](https://img.shields.io/badge/Hecho%20en-R-276DC3?style=flat&logo=r&logoColor=white)
![GitHub Repo](https://img.shields.io/badge/GitHub-jmeza--data-black?style=flat&logo=github)

</div>

---

## 📑 **Tabla de Contenidos**
- [Acerca del Proyecto](#acerca-del-proyecto)
- [Estructura del Repositorio](#estructura-del-repositorio)
- [Componentes del Proceso](#componentes-del-proceso)
- [Requisitos del Entorno](#requisitos-del-entorno)
- [Cómo Reproducir los Resultados](#cómo-reproducir-los-resultados)
- [Figuras Incluidas](#figuras-incluidas)
- [Licencia y Uso de Datos](#licencia-y-uso-de-datos)
- [Autor](#autor)

---

## 🧩 **Acerca del Proyecto**

Este repositorio contiene la infraestructura completa utilizada para:

- Construcción de bases derivadas de la **Encuesta de Calidad de Vida (ECV 2024)**
- Cálculo del **Índice de Pobreza Multidimensional (IPM)** para Colombia
- Preparación de datasets para Machine Learning
- Producción de figuras descriptivas y mapas

Proyecto académico asociado al trabajo:

### **“Medición multidimensional de la pobreza en Colombia y análisis complementario mediante técnicas de Machine Learning”**

---

## 📁 **Estructura del Repositorio**

```text
Repositorio_Bases_De_Datos/
│
├── 01_Scripts/
│     ├── Limpieza_de_datos.R
│     ├── Construcción_Base_ECV_Personas.R
│     └── Contrucción_base_IPM_Nivel_hogar.R
│
├── 02_Datos_Procesados/
│     ├── hogares_ML.csv
│     └── base_final.csv
│
├── 03_Figuras/
│     ├── Mapas e indicadores en PNG
│
└── README.md
⚙️ Componentes del Proceso
🔹 1. Limpieza y estandarización
Integración de módulos

Normalización de columnas

Depuración de valores faltantes

🔹 2. Construcción de la base a nivel persona
Variables derivadas

Identificación de privaciones AF

🔹 3. Construcción de la base a nivel hogar
Agregación por DIRECTORIO – SECUENCIA P

Cálculo de privaciones del hogar

Determinación del estado de pobreza

🔹 4. Preparación para Machine Learning
Base final hogares_ML.csv

Variables socioeconómicas, educativas y demográficas

🔹 5. Figuras descriptivas
Mapas

Gráficos comparativos

Pirámides poblacionales

🧠 Requisitos del Entorno (R)
Versión recomendada: R ≥ 4.2

Paquetes requeridos:

r
Copiar código
library(tidyverse)
library(readr)
library(dplyr)
library(stringr)
🔁 Cómo Reproducir los Resultados
1️⃣ Descargar microdatos
https://microdatos.dane.gov.co/

2️⃣ Guardar los módulos originales:
Hogares

Personas

Viviendas (opcional)

3️⃣ Ejecutar los scripts en orden:
text
Copiar código
01 - Limpieza_de_datos.R
02 - Construcción_Base_ECV_Personas.R
03 - Contrucción_base_IPM_Nivel_hogar.R
4️⃣ Salidas generadas automáticamente:
base_final.csv

hogares_ML.csv

🖼️ Figuras Incluidas
Mapas IPM

Acceso a servicios públicos

Condiciones del hogar

Condiciones de hacinamiento

Empleo

Educación

Pirámide poblacional

📜 Licencia y Uso de Datos
Los scripts y figuras son de uso libre.

Los microdatos originales del DANE NO se incluyen por restricciones legales.

Este repositorio respeta la política de protección de microdatos del DANE.

👤 Autor
Jhoan Sebastián Meza García
Estudiante de Economía – Universidad Nacional de Colombia
Investigación en pobreza multidimensional, estadística aplicada y ML

🔗 GitHub: https://github.com/jmeza-data

Si este repositorio te fue útil, ¡considera dejar una estrella ⭐!
