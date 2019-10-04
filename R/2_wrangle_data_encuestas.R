library(tidyverse)
library(lubridate)

resultados_crudo <- read_csv("../Typeform/responses.csv") 

categorias_salida <- c("Salir (cine, música, teatro, museos)", 
                       "Deporte / actividad física", 
                       "Lectura (libros y comics)")

categorias_cultura <- c("Música en vivo", 
                        "Cine", 
                        "Danza / Teatro", 
                        "Museo / Galería")

categorias_lugares <- c("Al aire libre", 
                        "Me da igual!", 
                        "El centro", 
                        "Un shopping center")

#funcion para encontrar categoria faltante en un conjunto de respuestas
faltante <- function(categorias = NULL, ...) {
    presentes <- pmap(list(...), c)
    unlist(map(presentes, ~paste(categorias[!(categorias %in% .x)])))
}



# fix de una mala configuracion en el Typeform (ya corregida) que causo errores en dos encuestas
resultados_crudo[resultados_crudo[[1]] == "9044f5b2e66f315288609e3d25284e71",5] <- "Lectura (libros y comics)"
resultados_crudo[resultados_crudo[[1]] == "84a3d9353fc3479dfe54779573837c1a",5] <- "Lectura (libros y comics)"


# Retenemos sólo las respuestas válidas

inicio_fecha_uno_de_encuestas <- ymd_hm("2019-05-12 15:51", tz = "America/Argentina/Buenos_Aires")

resultados_crudo <- resultados_crudo %>% 
    filter(with_tz(ymd_hms(`Submit Date (UTC)`), tzone = "America/Argentina/Buenos_Aires") > inicio_fecha_uno_de_encuestas, 
           !(`¿Tu edad?` %in% c("13 o menos", "19 o más")))

# fix error misterioso de typeform que guarda surveys con todos los campos vacios
resultados_crudo <- resultados_crudo %>% 
    filter(!is.na(`¡Genial! De estas actividades, cuál es la que más te atrae para pasar tu tiempo libre?`))


# Limpieza general
resultados <- resultados_crudo %>% 
    unite(razones_falta_interes, `No me gusta / No me divierte`:`No tengo quien me acompañe_3`) %>% 
    transmute(fecha = with_tz(ymd_hms(`Submit Date (UTC)`), tzone = "America/Argentina/Buenos_Aires"),
              opcion_salidas_1 = `¡Genial! De estas actividades, cuál es la que más te atrae para pasar tu tiempo libre?`,
              opcion_salidas_2 = coalesce(`Bien, {{answer_120847400}} es tu actividad favorita. De las que quedan, ¿cuál preferís?`,
                                          `Bien, {{answer_120847400}} es tu actividad favorita. De las que quedan, ¿cuál preferís?_1`,
                                          `Bien, {{answer_120847400}} es tu actividad favorita. De las que quedan, ¿cuál preferís?_2`),
              opcion_salidas_3 = faltante(categorias_salida, opcion_salidas_1, opcion_salidas_2),
              opcion_cultural_1 = `Vamos muy bien. Y de éstas opciones para ir a ver, ¿cuál es la que más te atrae?`,
              opcion_cultural_2 = paste0(`¿Y la siguiente en tu preferencia?`, 
                                         `¿Y la siguiente en tu preferencia?_1`,
                                         `¿Y la siguiente en tu preferencia?_2`,
                                         `¿Y la siguiente en tu preferencia?_3`),
              opcion_cultural_2 = str_remove_all(opcion_cultural_2, "NA"),
              opcion_cultural_3 = paste0(`De las dos que quedan, ¿cuál es la que más te gusta?`, 
                                         `De las dos que quedan, ¿cuál es la que más te gusta?_1`, 
                                         `De las dos que quedan, ¿cuál es la que más te gusta?_2`, 
                                         `De las dos que quedan, ¿cuál es la que más te gusta?_3`, 
                                         `De las dos que quedan, ¿cuál es la que más te gusta?_4`, 
                                         `De las dos que quedan, ¿cuál es la que más te gusta?_5`),
              opcion_cultural_3 = str_remove_all(opcion_cultural_3, "NA"),
              opcion_cultural_4 = faltante(categorias_cultura, opcion_cultural_1, opcion_cultural_2, opcion_cultural_3),
              no_me_gusta_o_no_me_divierte = str_detect(razones_falta_interes, "No me gusta / No me divierte"),
              es_caro = str_detect(razones_falta_interes, "Es caro"),
              no_conozco_bien_no_se_donde_se_hace = str_detect(razones_falta_interes, "No la conozco bien / no se donde se hace"),
              me_queda_lejos = str_detect(razones_falta_interes, "Me queda lejos"),
              no_tengo_quien_me_acompanie = str_detect(razones_falta_interes, "No tengo quien me acompañe"),
              preferencia_lectura = `¿Para leer, que te gusta más?`,
              preferencia_ambito_musica = `¿Dónde te gustaría más escuchar música?`,
              preferencia_lugar_salidas = `Para salir a consumir cultura (comprar libros, ir al cine, escuchar música, o lo que sea)... que ambiente te atrae más?`,
              edad = `¿Tu edad?`,
              genero = `¿Como te identificás?`,
              barrio = `¿En qué barrio vivís?`,
              escuela_en_CABA = `¿Vas a una escuela pública en la Ciudad de Buenos Aires? (¿cuál?)`,
              tiene_pase_cultural = `¿Sacaste tu Pase Cultural?`)



# A guardar
write_csv(resultados, "../Typeform/respuestas_limpias.csv")
