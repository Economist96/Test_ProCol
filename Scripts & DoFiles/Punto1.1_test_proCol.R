#### Librerias ----
library(readxl) #Lectura de bases de datos (Excel)
library(tidyr) #Limpieza manipulación y transformación de datos 
library(dplyr) #Manipulación de datos con sintaxis intuitiva
library(writexl) #Guardar excel write_xlsx
library(stringi) #strings
library(stringr) #strings
library(data.table) #Manejo de dataframes
library(openxlsx)
library(RColorBrewer) #Paleta de colores
library(ggplot2) #Graficos
library(wordcloud2) #Nubes de palabras
library(haven) #Leer y escribir bases en dta
####Ruta de bases de datos----
Dir_dane<-"D:/OneDrive/Escritorio/ProColombia/Datos-20231216T185808Z-001/Datos/Directorio_DANE.txt"
Export<-"D:/OneDrive/Escritorio/ProColombia/Datos-20231216T185808Z-001/Datos/Exportaciones.txt"
RUES_r<-"D:/OneDrive/Escritorio/ProColombia/Datos-20231216T185808Z-001/Datos/RUES.txt"
supSos<-"D:/OneDrive/Escritorio/ProColombia/Datos-20231216T185808Z-001/Datos/Supersociedades.txt"
#### Cargue de bases de datos a R----
#Cargue de base de datos en txt
#La función "read.table" me permite leer bases de datos en .txt
#Sus argumentos son:
#read.table(file,                  Archivo de datos TXT indicado como string o ruta completa al archivo
           #header = FALSE,        Si se muestra el encabezado (TRUE) o no (FALSE)
           #sep = "",              Separador de las columnas del archivo
           #dec = ".")             Caracter utilizado para separar decimales de los números en el archivo

emp_dane<-read.table(Dir_dane, header=T,sep="|",dec="," ) #Cargue de base de datos del directorio del DANE
export<-read.table(Export, header=T,sep="|",dec="," )     #Cargue de base de datos de exportaciones
RUES<-read.table(RUES_r, header=T,sep="|",dec="," )       #Cargue de base de datos de listado de RUES
ssoc<-read.table(supSos, header=T,sep="|",dec="," )       #Cargue de base de datos de listado de super sociedades

#### Pegue de bases de datos ----
#Identificar si las bases tienen las mismas variables
identical(colnames(emp_dane), colnames(RUES)) #Las variables de emp_dane y RUES son las mismas
identical(colnames(RUES), colnames(export))  #Las variables de RUES son las mismas de export
identical(colnames(export), colnames(ssoc))  #Las variables de export son las mismas que ssoc
#Dado que las bases tienen las mismas variables se hace un rbind (pegar y una base debajo de la otra)
Master<-rbind(emp_dane,export,RUES,ssoc)
# ya que hay empresas que pueden estar en más de una base, se limpian los duplicados por NIT
Master2<- Master %>% distinct(NIT, .keep_all = T)
#Nos queda como resultado una base de datos de 50.000 observaciones únicas para correr modelo Probit/Logit en STATA
#Generamos una dummie para identificar si 
#### Exportar base de datos ----
r_save<-"D:/OneDrive/Escritorio/ProColombia/Datos-20231216T185808Z-001/Datos/Master.xlsx"
write_xlsx(Master2,r_save)
#### Parte 2 / Selección de empresas  -----
r_probit<-"D:/OneDrive/Escritorio/ProColombia/Datos-20231216T185808Z-001/Datos/Master_Probit_Logit.dta"
final<-read_dta(r_probit)
#Cargue de base de datos CIIU para identificar el sector (División, Grupo y Clase de las empresas)
r_CIIU<-"D:/OneDrive - Universidad Externado de Colombia/Test_ProCol/Datos-20231216T185808Z-001/Datos/MASTER CIIU por sectores.xlsx"
CIIU<-read_excel(r_CIIU, sheet="Master_valores")
#Pegandole la CIIU a la base de exportaciones y a la base final
#En las bases que enviaron hay algunos CIIU a nivel clase que tienen 3 dígitos, poniéndoles 0 al principio para que cruce
#la funcion "ifelse" me permite transformar observaciones. La función nchar me permite identificar el número de caracteres de una variable
#La función "paste" me permite pegar variables o numeros y variables, con un separador.
#La línea 61 le pone un 0 a las observaciones de la variable "CIIU.Rev.4.principal" al principio cuando tiene 3 digitos y cuando no, la deja igual
export$CIIU<-ifelse(nchar(export$CIIU.Rev.4.principal)==3, paste(0,export$CIIU.Rev.4.principal, sep=""),export$CIIU.Rev.4.principal)
export2<-merge(export, CIIU, by.x="CIIU", by.y="CLASE2", all.x=T)
#Lo mismo para base final
final$CIIU<-ifelse(nchar(final$CIIURev4principal)==3, paste(0,final$CIIURev4principal, sep=""),final$CIIURev4principal)
final2<-merge(final,CIIU, by.x="CIIU", by.y="CLASE2", all.x=T)
#Viendo las principales divisiones a las que pertenecen las empresas exportadoras
seccion_more_freq<-data.frame(table(export2$`DESCRIPCIÓN SECCIÓN`))
colnames(seccion_more_freq)<-c("Sección", "Frecuencia")
seccion_more_freq$Freq_rela<-seccion_more_freq$Frecuencia/sum(seccion_more_freq$Frecuencia)
#Viendo los principales grupos a los que pertenecen las empresas exportadoras
grupo_more_freq<-data.frame(table(export2$`DESCRIPCIÓN GRUPO`))
colnames(grupo_more_freq)<-c("Grupo", "Frecuencia")
#Viendo las principales clases a las que pertenecen las empresas exportadoras
clase_more_freq<-data.frame(table(export2$`DESCRIPCIÓN CLASE`))
colnames(clase_more_freq)<-c("Clase","Frecuencia")
#Seleccionando empresas
df2<-final2[,c("NIT","exportadora","plogit","pprobit","Expopromult5años","Expo2022","VarExpo2022","CIIU","DESCRIPCIÓN DIVISIÓN","DESCRIPCIÓN GRUPO","DESCRIPCIÓN CLASE","TamañoempresaRUES")]
#La función subset me permite sacar una base dependiendo el criterio que le establezca subset(BD,criterio)
df3<-subset(df2, exportadora==0)
df4<-subset(df3, plogit>0.5) #Empresas con una probabilidad mayor a 0.5 a exportar
df5<-subset(df3,CIIU=="1011" & (TamañoempresaRUES=="Grande" | TamañoempresaRUES=="Mediana") ) #Empresas del CIIU 1011 medianas o grandes
df6<-rbind(df4,df5)
df6$Type<-"No Exportadora"
df7<-final2[,c("NIT","exportadora","plogit","pprobit","Expopromult5años","Expo2022","VarExpo2022","CIIU","DESCRIPCIÓN DIVISIÓN","DESCRIPCIÓN GRUPO","DESCRIPCIÓN CLASE","TamañoempresaRUES")]
df8<-subset(df7,Expo2022==0 )
df9<-subset(df8, plogit>0.5)
df10<-subset(df8, Expopromult5años>mean(df8$Expopromult5años))
df10$Type<-"Exportadora"
df11<-rbind(df10,df6)
seleccionadas<-df11$NIT
final_2_vice<-final2[final2$NIT %in% seleccionadas, ]
final_2_vice<-merge(final_2_vice, df11[,c("NIT","Type")], by="NIT", all.x=T)
#Exportación de base de datos para seleccionar empresas
r_seleccion<-"D:/OneDrive - Universidad Externado de Colombia/Test_ProCol/Datos-20231216T185808Z-001/Datos/Empresas_seleccionadas.xlsx"

write_xlsx(final_2_vice,r_seleccion)


