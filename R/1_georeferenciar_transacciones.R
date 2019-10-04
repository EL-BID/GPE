library(tidyverse)

transacciones <- read_csv("../entregables/bases/transacciones.csv") %>% 
    mutate(Comercio = str_remove(Comercio, "491 - COMPRA     "))

georeferenciar <- transacciones %>% 
    select(Comercio) %>% 
    unique() %>% 
    arrange(Comercio)

library(ggmap)
library(purrr)


#Georeferenciamos usando Google Maps API, se requiere API key
key = readLines("../../../../code/Urban Analytics/g_api_key")
register_google(key)
coords <- map_df(paste(transacciones$Comercio, "CABA, Argentina"), geocode, output = "more")

# REQUIERE VERIFICACION "MANUAL", PARA CONTROL DE CALIDAD
bind_cols(georeferenciar, coords) %>% 
    write_csv("../entregables/direcciones_transacciones_raw.csv")
# TRAS LIMPIAR LA TABLA...

coords_transacciones <- read_csv("../entregables/direcciones_transacciones.csv") %>% 
    filter(local_unico == TRUE) %>% 
    select(Comercio, lon, lat)

transacciones <- transacciones %>% 
    left_join(coords_transacciones)

write_csv(transacciones, "../entregables/bases/transacciones_georeferenciadas.csv")



#####################################################################
#####################################################################
# Actualizando la data cuando se actualiza la base de transacciones #
#####################################################################
#####################################################################


transacciones <- read_csv("../entregables/bases/transacciones.csv") %>% 
    mutate(Comercio = str_remove(Comercio, "491 - COMPRA     "))

transacciones_ya_referenciadas <- read_csv("../entregables/direcciones_transacciones.csv")

georeferenciar <- transacciones %>% 
    filter(!(Comercio %in% transacciones_ya_referenciadas$Comercio)) %>% 
    select(Comercio) %>% 
    unique() %>% 
    arrange(Comercio)


#Georeferenciamos usando Google Maps API, se requiere API key
key = readLines("../../../../code/Urban Analytics/g_api_key")
register_google(key)
coords <- map_df(paste(georeferenciar$Comercio, "CABA, Argentina"), geocode, output = "more", key = key)


# REQUIERE VERIFICACION "MANUAL", PARA CONTROL DE CALIDAD
transacciones_ya_referenciadas %>% 
    bind_rows(bind_cols(georeferenciar, coords)) %>% 
    write_csv("../entregables/direcciones_transacciones_raw.csv")
# TRAS LIMPIAR LA TABLA...

coords_transacciones <- read_csv("../entregables/direcciones_transacciones.csv") %>% 
    filter(local_unico == TRUE) %>% 
    select(Comercio, lon, lat)

transacciones <- transacciones %>% 
    left_join(coords_transacciones)

write_csv(transacciones, "../entregables/bases/transacciones_georeferenciadas.csv")


### Actualizar tabla de rubros

tabla_rubros <- read_csv("../entregables/cruce_comercios_categoria.csv")

comercios_nuevos <- transacciones %>% 
    select(Comercio) %>% 
    unique() %>% 
    filter(!(Comercio %in% unique(tabla_rubros$Comercio)))
    
tabla_rubros %>% 
    bind_rows(comercios_nuevos) %>% 
    write_csv("../entregables/cruce_comercios_categoria.csv")
