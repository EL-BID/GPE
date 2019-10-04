library(tidyverse)
library(readxl)
source("geocoder.R")


read_excel_allsheets <- function(filename, skip = 0) {
    read_sheet <- function(X){
        sheet <- readxl::read_xlsx(filename, sheet = X , skip = skip)
        sheet <- sheet[!grepl('^X_', names(sheet))]
    } 
    sheets <- readxl::excel_sheets(filename)
    x <- lapply(sheets, read_sheet)
    names(x) <- sheets
    x
}

# para georeferenciar direcciones luego

normalizar_dir <- function(direccion) {
        direccion %>%
            str_to_upper() %>%
            str_remove(",") %>%
            str_remove("\\(.*\\)") %>%
            str_remove(" -.*") %>%
            str_remove(" –.*") %>%
            str_remove(" Nº") %>%
            str_remove_all("S/N°?") %>% 
            str_remove("^PEAT. ") %>%
            str_remove("(?<!HUMBERTO )1RO.*") %>%
            str_remove("2DO.*") %>%
            str_remove("3RO.*") %>%
            str_remove("4TO.*") %>%
            str_remove("5TO.*") %>%
            str_remove("6TO.*") %>%
            str_remove("7MO.*") %>%
            str_remove("8VO.*") %>%
            str_remove("9NO.*") %>%
            str_remove(" OF( |\\.).*") %>%
            str_remove(" P( |\\.).*") %>%
            str_remove("(?<!HUMBERTO) [:digit:]+º.*") %>%
            str_remove(" PISO.*") %>%
            str_remove(" P\\.*B.*") %>%
            str_remove(" DPTO.*") %>%
            str_remove(" DTO.*") %>%
            str_remove("(?<=[:digit:]{1,5}) +[:digit:]{1,5}.*") %>%
            str_remove(" P\\.[:digit:].*") %>%
            str_remove(" LOCAL .*") %>%
            str_remove("(/ *[:digit:]{1,5}).*") %>%
            str_remove(" /?ESQ( |\\.).*") %>%
            str_squish() %>%
            paste0(", CABA")
    }



#######
#######
####### TRANSACCIONES
####### 
####### 

files_transacciones <- list.files('../CABA/Transacciones', 
                                  pattern = "Beneficiarios Pase Cultural", 
                                  full.names = T)

transacciones <- map_df(files_transacciones, 
                        read_xlsx) %>% 
    mutate(Nro_Doc = as.numeric(Nro_Doc)) %>% 
    select(Tipo_Doc:Fecha) 

write_csv(transacciones, "../entregables/bases/transacciones.csv")

#######
#######
####### COMERCIOS
####### 
####### 

# all_sheets <- read_excel_allsheets("../CABA/Listado comercios PASE - BID UTDT.xlsx", skip = 1)
# 
# comercios <- all_sheets[1:8] %>% 
#     map_df(mutate_all, .funs = c(as.character)) %>% 
#     mutate(Rubro = ifelse(is.na(Rubro), 
#                           `Rubro/Categoría`, 
#                           Rubro),
#            `Denominación Sucursal` = ifelse(is.na(`Denominación Sucursal`), 
#                                             `Denominacion Sucursal`,
#                                             `Denominación Sucursal`)) %>% 
#     select(-`Rubro/Categoría`, -`Denominacion Sucursal`)
# 
# 
# ### TEST ###
direcciones <- c("RIOBAMBA 460 3RO A",
                 "AGUIRRE 229 PB 2",
                 "Peat. CUBA 3622",
                 "AV ACOYTE 25, 4to E",
                 "AV. CORRIENTES 1283 / 1285",
                 "JD PERON 3654/56",
                 "RIVADAVIA 1495 / 1497 / 1499, CABA",
                 "HUMBErto 1º 340",
                 "SALTA 1272, 1º C of 45",
                 "SALTA 1272, 14 C",
                 "SALTA 1272, PB C",
                 "SALTA 1272, 2do J",
                 "SALTA 1272, 2do. J",
                 "Sarlanga 5463 OF. 4",
                 "Sarlanga 5463 OF B",
                 "CALIFORNIA 2082 P 3 OF 315",
                 "Av.Santa Fe Nº 1544 local 34",
                 "ESTADOS UNIDOS 700 esq Chacabu",
                 "SALVIGNY 1510 /ESQ CENTENERA",
                 "FLORIDA 1065  11 G",
                 "M. T. DE ALVEAR 1840. -SUBSUELO",
                 "(HOSPITAL ELIZALDE) Montes de Oca 40",
                 "PERITO MORENO Y VARELA ARTURO JAURETCHES/N°",
                 "BARRIO FERROVIARIO MZA 12 C 36 S/N CASA ABIERTAS/N°")

normalizar_dir(direcciones)
# 
# ### FIN TEST ###
# 
# geocodes <- normalizar_dir(comercios$Dirección) %>% map_df(USIG_geocode)
# 
# write_csv(geocodes, "lat_lon_negocios.csv")
# 
# coords <- read_csv("lat_lon_negocios.csv") %>% 
#     distinct()
# 
# comercios %>% 
#     mutate(address = normalizar_dir(comercios$Dirección)) %>% 
#     left_join(coords) %>% 
#     select(-address) %>% 
#     write_csv("../entregables/bases/comercios_georeferenciados.csv")


comercios <- read_csv("../entregables/bases/comercios_georeferenciados.csv")

#######
#######
####### ESCUELAS
####### 
####### 


# escuelas <- read_xlsx("../CABA/Listado de Escuelas PASE - BID UTDT.xlsx", sheet = 2) %>%
#     mutate(`NOMBRE DE LA ESCUELA` = str_squish(str_to_upper(`NOMBRE DE LA ESCUELA`)),
#            CUE = as.numeric(CUE))
# 
# escuelas <- escuelas %>%
#     # esta mal el CUE de la Escuela de Danza Jorge Donn
#     mutate(CUE = ifelse(`NOMBRE DE LA ESCUELA` == 'ESCUELA SUPERIOR DE EDUCACIÓN ARTÍSTICA EN DANZA Nº 2 "JORGE DONN"',
#                         203029,
#                         CUE))
# 
# # Agregamos coordenadas usando el dataset georeferenciado de establecimientos educativos
# # disponible en el portal de datos del GCBA -
# # https://data.buenosaires.gob.ar/api/files/establecimientos-educativos.csv/download/csv
# # 
# 
# # Hay establecimientos con múltiples sedes, es decir que un mismo CUE aparece en varios sitios con coordenadas distintas.
# # En esos casos nos quedamos solo con el primero
# 
# datos_escuelas_caba <- read_csv("../CABA/establecimientos-educativos_porta_open_data.csv") %>%
#     select(lng = long, lat, CUE = cue) %>% 
#     group_by(CUE) %>% 
#     slice(1)
# 
# 
# escuelas <- escuelas %>% left_join(datos_escuelas_caba)
# 
# # Tomamos las direcciones sin coordenadas, que en general son de
# # establecimientos nacionales que no figuran en la base georeferenciada del GCBA
# 
# referenciar <- escuelas %>%
#     filter(is.na(lat)) %>%
#     pull(DIRECCIÓN) %>%
#     normalizar_dir() %>%
#     unique() %>%
#     map_df(USIG_geocode) %>%
#     mutate(address = str_remove(address, ", CABA")) %>%
#     na.omit() %>%
#     # Retiramos las direcciones en "VILLA #" que no se georeferencian bien
#     filter(!str_detect(address, "VILLA [[digit]]*")) %>%
#     rename("DIRECCIÓN" = address)
# 
# # completamos con datos georeferenciados en el paso anterior
# # renombramos lat y long para que se preserven tras el join
# 
# referenciar <- referenciar %>%
#     rename(lat2 = lat,
#            lng2 = lng)
# 
# 
# escuelas <- escuelas %>%
#     left_join(referenciar) %>%
#     mutate(lat = ifelse(is.na(lat), as.double(lat2), lat),
#            lng = ifelse(is.na(lng), as.double(lng2), lng)) %>%
#     select(-lat2, -lng2)
# 
# 
# 
# write_csv(escuelas, "../entregables/bases/escuelas_georeferenciadas.csv")



escuelas <- read_csv("../entregables/bases/escuelas_georeferenciadas.csv")

#######
#######
####### ALUMNOS
####### 
####### 

# alumnos <- readxl::read_xlsx("../CABA/BASE RIB.xlsx") %>%
#     select(numero, num__docum, sexo, tipo__domicilio, dom__caba__calle, dom__villa__calle,
#            nom__asentamiento, dom__fuera__calle, localidad, nombre__institucion) %>%
#     mutate(dom__caba__calle = str_replace(dom__caba__calle, "��", "Ñ"),
#            nombre__institucion = str_squish(str_to_upper(nombre__institucion))) %>%
#     distinct()
# 
#georeferenciamos dirección de alumnos
encontrar_direccion <- function(dom__caba__calle, dom__villa__calle,
                                dom__fuera__calle, localidad) {
    case_when(
        !is.na(dom__caba__calle) ~dom__caba__calle,
        !is.na(dom__villa__calle) ~dom__villa__calle,
        !is.na(dom__fuera__calle) ~paste0(dom__fuera__calle, ", ", localidad)
    )
}
# 
# 
# alumnos <- alumnos %>% 
#     # identificar cual es el domicilio, habiendo varios campos posibles
#     mutate(domicilio = encontrar_direccion(dom__caba__calle, dom__villa__calle, 
#                                            dom__fuera__calle, localidad),
#            domicilio_asentamiento_precario = tipo__domicilio == "Barrio Social y Villas",
#            domicilio_fuera_CABA = !is.na(localidad))  %>% 
#     #limpieza de direcciones
#     mutate(domicilio = str_to_upper(domicilio)) %>% 
#     mutate(domicilio = ifelse(domicilio %in% c("SIN DATO", "SIN DATO 0", "0", ".", "SIN NOMBRE OFICIAL 0"),
#                               NA, 
#                               domicilio))
# 
# 
# 
# referenciar <- alumnos %>% 
#     filter(str_length(domicilio) > 4) %>% 
#     pull(domicilio)
# 
# direcciones_alumnos <- map_df(referenciar, USIG_geocode) 
# 
# direcciones_alumnos <- direcciones_alumnos %>% 
#     rename(domicilio = address)
# # 
# alumnos <- alumnos %>%
#     left_join(direcciones_alumnos) %>%
#     rename(lat_domicilio = lat,
#            lng_domicilio = lng)
# 
# reordenamos un poco el dataframe
# alumnos <- alumnos %>%
#     select(1:9, 11:16, 10)
# 
# 
# ## Ahora identificamos sus escuelas
# # Normalizamos nombres de escuela usando una tabla confeccionada a mano
# 
# corregir <- read_csv("nombres_escuelas_corregir.csv") %>% 
#     mutate(nombre__institucion = str_squish(str_to_upper(nombre__institucion)))
# 
# alumnos <- alumnos %>% 
#     left_join(corregir) %>% 
#     mutate(nombre__institucion = ifelse(is.na(correcto), nombre__institucion, correcto)) %>%
#     select(-correcto) %>% 
#     mutate(nombre__institucion = str_to_upper(nombre__institucion)) %>% 
#     left_join(escuelas, by = c("nombre__institucion" = "NOMBRE DE LA ESCUELA")) %>% 
#     rename(CUE_institucion = CUE, 
#            direccion_institucion = DIRECCIÓN,
#            nivel_educativo_institucion = `NIVEL EDUCATIVO`,
#            lng_institucion = lng,
#            lat_institucion = lat)
# 
# write_csv(alumnos, "../entregables/bases/alumnos_georeferenciados.csv")





##################################
### PLANILLAS ADICIONALES      ###
##################################


alumnos <- read_csv("../entregables/bases/alumnos_georeferenciados.csv")

# Cargamos la siguiente tanda de inscriptos, entregda por el GCBA en mayo 2019
mas_alumnos <- readxl::read_xlsx("../CABA/Beneficiarios/Entrega III/CRUDO LOTE 29-7-19.xlsx") %>%
    select(numero, num__docum, sexo, tipo__domicilio, dom__caba__calle, dom__villa__calle,
           nom__asentamiento, dom__fuera__calle, localidad, nombre__institucion) %>%
    mutate(dom__caba__calle = str_replace(dom__caba__calle, "��", "Ñ"),
           nombre__institucion = str_squish(str_to_upper(nombre__institucion))) %>%
    distinct() 

# retenemos sólo los beneficiarios que no aparezcan en la base de alumnos que ya procesamos

mas_alumnos <- mas_alumnos %>% anti_join(alumnos, by = "num__docum")

mas_alumnos <- mas_alumnos %>%
    # identificar cual es el domicilio, habiendo varios campos posibles
    mutate(domicilio = encontrar_direccion(dom__caba__calle, dom__villa__calle,
                                           dom__fuera__calle, localidad),
           domicilio_asentamiento_precario = tipo__domicilio == "Barrio Social y Villas",
           domicilio_fuera_CABA = !is.na(localidad))  %>%
    #limpieza de direcciones
    mutate(domicilio = str_to_upper(domicilio)) %>%
    mutate(domicilio = ifelse(domicilio %in% c("SIN DATO", "SIN DATO 0", "0", ".", 
                                               "SIN NOMBRE OFICIAL 0", "DE MAYO AV. 575"),
                              NA,
                              domicilio))

referenciar <- mas_alumnos %>%
    filter(str_length(domicilio) > 4) %>%
    pull(domicilio)

direcciones_alumnos <- map(referenciar, USIG_geocode)

direcciones_alumnos <- reduce(direcciones_alumnos, rbind)

direcciones_alumnos <- direcciones_alumnos %>%
    select(-address_normalised) %>% 
    rename(domicilio = address)

mas_alumnos <- mas_alumnos %>%
    left_join(direcciones_alumnos) %>%
    rename(lat_domicilio = lat,
           lng_domicilio = lng)


## Ahora identificamos sus escuelas
# Normalizamos nombres de escuela usando una tabla confeccionada a mano

corregir <- read_csv("nombres_escuelas_corregir.csv") %>%
    mutate(nombre__institucion = str_squish(str_to_upper(nombre__institucion)))

mas_alumnos <- mas_alumnos %>%
    left_join(corregir) %>%
    mutate(nombre__institucion = ifelse(is.na(correcto), nombre__institucion, correcto)) %>%
    select(-correcto) %>%
    mutate(nombre__institucion = str_to_upper(nombre__institucion)) %>%
    left_join(escuelas, by = c("nombre__institucion" = "NOMBRE DE LA ESCUELA")) %>%
    rename(CUE_institucion = CUE,
           direccion_institucion = DIRECCIÓN,
           nivel_educativo_institucion = `NIVEL EDUCATIVO`,
           lng_institucion = lng,
           lat_institucion = lat) %>%
           distinct()

alumnos <- rbind(alumnos, mas_alumnos) 


### DONDE FALLO EL NORMALIZADOR DE CALLES, INTENTAR GEOREFERENCIAR CON EL NOMBRE DEL ASENTAMIENTO

## Coordenadas de asentamientos precarios
asentamientos <- read_csv("georef_asentamientos_precarios.csv")

alumnos <- alumnos %>% 
    left_join(asentamientos) %>% 
    mutate(lat_domicilio = ifelse(is.na(lat_domicilio), lat_asentamiento, lat_domicilio),
           lng_domicilio = ifelse(is.na(lng_domicilio), lng_asentamiento, lng_domicilio)) %>% 
    select(-lat_asentamiento, -lng_asentamiento)

write_csv(alumnos, "../entregables/bases/alumnos_georeferenciados.csv")

### FUNCIONA!!!

alumnos <- read_csv("../entregables/bases/alumnos_georeferenciados.csv")


cruce <- transacciones %>% 
    left_join(alumnos, by = c("Nro_Doc" ="num__docum")) 

sum(is.na(cruce$lat_domicilio)) / nrow(cruce)

cruce %>% 
    filter(is.na(lat_domicilio)) %>% 
    View()


## mas transacciones

transacciones_previas <- read.csv("../entregables/bases/transacciones.csv",
                                  stringsAsFactors = FALSE)

files_transacciones <- list.files('../CABA/Transacciones/Tanda III/', 
                                  pattern = "Beneficiarios", 
                                  full.names = T)

transacciones <- map_df(files_transacciones, 
                        read_xlsx) %>% 
    mutate(Nro_Doc = as.numeric(Nro_Doc))

if (!("Tipo_Doc" %in% names(transacciones))) {
    transacciones <- mutate(transacciones, Tipo_Doc = NA)
}
    

transacciones %>%
    select(Tipo_Doc, Nro_Doc, Apellido_y_Nombre, Cod_GrupoAfin, 
             Desc_GrupoAfin, Comercio, Importe, Fecha) %>% 
    rbind(transacciones_previas) %>% 
    arrange(Fecha, Nro_Doc) %>% 
    mutate(Fecha = substr(Fecha, 1, 10)) %>% 
    write_csv("../entregables/bases/transacciones.csv")

