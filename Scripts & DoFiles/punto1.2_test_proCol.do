clear 
//Crear archivo log
log using "D:\OneDrive - Universidad Externado de Colombia\Test_ProCol\Scripts & DoFiles\punto1.2_test_proCol.txt"
//Comando para imporat una hoja de excel con el primer renglon como nombre de columna 
import excel "D:\OneDrive\Escritorio\ProColombia\Datos-20231216T185808Z-001\Datos\Master.xlsx", sheet("Sheet1") firstrow

//Identificando las empresas que han exportado para generar variable dependiente
// El comando Tab no devuelve una tabla de frecuencias de la variabale que le pidamos. Adicionalmente, el comando "if" nos permite condicionar las observaciones. != significa diferente y la opción "sort" ordena la tabla de frecuencias de mayor a menor 
tab Tipoult10años if Tipoult10años !="No exportó ult. 10 años", sort 
tab Cadenault10años if Cadenault10años!="No exportó ult. 10 años", sort
tab Sectorult10años if Sectorult10años!="No exportó ult. 10 años", sort
tab Subsectorult10años if Subsectorult10años!="No exportó ult. 10 años", sort
tab Departamentoult10años if Departamentoult10años!="No exportó ult. 10 años", sort

//Todas las tablas de frecuencia nos indica que 3.273 (coincide con la base de empresas exportadoras) empresas han exportado en los últimos 10 años, por lo tanto a esas empresas se les va a generar una dummie =1 si han exportado e igual a 0 si no lo han hecho
gen exportadora=.
replace exportadora=1 if Tipoult10años !="No exportó ult. 10 años"
replace exportadora=0 if exportadora==.
// Dummie igual a 1 si la empresa es grande o mediana 
gen grande_mediana=1 if TamañoempresaRUES=="Grande" | TamañoempresaRUES=="Mediana"
replace grande_mediana=0 if grande_mediana==.
//Dummie sucursal
gen sucursal=.
replace sucursal=1 if Sucursalsociedadextranjera=="Si"
replace sucursal=0 if Sucursalsociedadextranjera=="No"
//Categorica trayectoria
gen trayectoria=.
replace trayectoria=0 if Trayectoriaexpo=="Mineras, chatarra, otros"
replace trayectoria=1 if Trayectoriaexpo=="Futuros"
replace trayectoria=2 if Trayectoriaexpo=="No Constante"
replace trayectoria=3 if Trayectoriaexpo=="Pymex"
replace trayectoria=4 if Trayectoriaexpo=="Top"
//Activos en millones de pesos
gen activos2=Activos/2000000000 // Los activos2 quedan medidos en 200 millones de pesos, para poder tener una mejor interpretación al momento de leer los margins 

// Módelo Probit y Logit 
//El comando global me permite llamar estas variables de manera mas fácil para la estimación de modelos
global ylist exportadora 
global xlist activos2 Antigüedadempresa grande_mediana sucursal trayectoria

// describe: describe el ripo de datos que estamos tratando
describe $ylist $xlist 
// Sum: da estadísticas básicas de las variables
summarize $ylist $xlist

tabulate $ylist 

* Probit model
probit $ylist $xlist

* Logit model
logit $ylist $xlist


* Predicted probabilities
quietly logit $ylist $xlist // quietly corre el modelo sin mostrarlo en el terminal 
predict plogit, pr //Genera una columna en la BD que se llama plogit y tiene los valores predichos que arroja el modelo

quietly probit $ylist $xlist 
predict pprobit, pr 

summarize $ylist plogit pprobit 


* Percent correctly predicted values
quietly logit $ylist $xlist
estat classification //Identifica los "falsos positivos y negativos" del modelo para dar el porcentaje de predicción correcto del modelo 

quietly probit $ylist $xlist
estat classification 

save "D:\OneDrive\Escritorio\ProColombia\Datos-20231216T185808Z-001\Datos\Master_Probit_Logit2.dta", replace

log close

