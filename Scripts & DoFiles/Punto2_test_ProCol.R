library(readxl)
library(dplyr)
library(zoo)
library(xts)
library(forecast)
library(doBy)
library(data.table)
library(quantmod)
library(fpp)
library(urca)

r_serie<-"D:/OneDrive - Universidad Externado de Colombia/Test_ProCol/Datos-20231216T185808Z-001/Datos/expo_nme.xlsx"
serie<-read_excel(r_serie)
####Entrenamiento (hasta diciembre de 2022)----
entreno<-subset(serie, Mes<="2022-12-01")
#Para este ejercicio se le aplica logaritmo natural a la serie original para:
#Estabilizar varianza y mejorar estacionariedad
#Definiedo una serie de tiempo
Entreno<- ts(entreno$`Log(Expo_NME)`, frequency = 12, start= c(2006,1), end= c(2022,12))
#Graficando en una matriz 1X1 el gráfico de exportaciones no minero enegéticas
par(mfrow=c(1,1))
plot(Entreno ,main=("Exportaciones no minero energéticas"), col="blue")
#Descomponiendo la serie de tiempo de exportaciones no minero energéticas de entrenamiento
componentes <- decompose(Entreno)
plot(componentes, col="blue")


#PRUEBAS DE RAICES UNITARIAS para determinar estacionariedad

#ADF en el nivel
#Ho: Tiene raíz unitaria->No es estacionaria
l.df <- ur.df(y=Entreno, type='trend',lags=2,  selectlags=c("AIC"))
summary(l.df) #|DF|<VC  -> Acepto Ho ->Tiene Raíz Unitaria = |2.99|<3.99 -> La serie no es estacionaria
#La serie en nivel no es estacionaria, por lo tanto tiene que ser diferenciada

#prueba ADF a diferencia
#Ho: Tiene raíz unitaria->No es estacionaria
L_Entreno<- na.omit(entreno$`Log(D_Expor_NME)`)
df.1 <- ur.df(y=L_Entreno, type='trend',lags=2, selectlags=c("AIC"))
summary(df.1) # |DF|>VC -> Rechazo Ho ->No tiene raíz unitaria -> = |17.21|<3.99 ->La serie es estacionaria
#La serie en primera diferencia es estacionaria
L_Entreno<- ts(L_Entreno, frequency = 12, start= c(2006,1), end= c(2022,12))
par(mfrow=c(1,1))
plot(L_Entreno ,main=("Exportaciones no minero energéticas diferenciada"), col="blue")
par(mfrow=c(1,2))
forecast::Acf(L_Entreno) #Tratando de identificar el proceso MA
forecast::Pacf(L_Entreno) #Trantando de identificar el proceso AR 

#Estimación del modelo 
#ARIMA (4,1,3)
modelo_NME<-arima(Entreno, c(4,1,3),method="ML")
summary(modelo_NME)
#aic = -350.61 ; error^2=0.009492
par( mfrow = (c(1 ,1)))
plot(forecast::forecast(modelo_NME,h=9))
#Valores predichos del modelo
k<-data.frame(forecast::forecast(modelo_NME,h=9))
#Trayendo los valores originales de la serie
k2<-subset(serie, Mes>"2022-12-01")
#Uniendo los valores predichos con los valores verdaderos
k3<-cbind(k,k2)
#Diferencia entre la proyeccion y el valor verdadero
k3$DIFF<-k3$Point.Forecast-k3$`Log(Expo_NME)`
#Valor medio de la diferencia entre la proyección y el valor verdadero
mean(k3$DIFF)
#DIFF=0.07446261
#Guardando el residuo para las pruebas de error
residm<- modelo_NME$residuals
#PRUEBAS DE ERROR
#Homocedasticidad
par( mfrow = (c(1 ,2)))
resid_cuad<- residm^2 
forecast::Acf(resid_cuad, main= "FACS", col="red")
forecast::Pacf(resid_cuad, main= "FACP", col="red")
#Las líneas estan en los intervalos de confianza, por lo tanto, es homocedastico
#NORMALIDAD
#HO: el error es normal
JBtest<- rnorm(modelo_NME$residuals) #pvalue>0.05 -> 0.29>0.05-> entonces se hacepta la ho
jarque.bera.test(JBtest)
#Test de shapiro
#HO: el error se distrubuye normalmente
shapiro.test(na.remove(modelo_NME$residuals))#pvalue>0.05, entonces se hacepta la ho
par(mfrow=c(1,1))
qqnorm(na.remove(modelo_NME$residuals))
qqline(na.remove(modelo_NME$residuals))#no se dan desviaciones sustanciales de la linea teorica, entonces el error tiene distr normal

#ESTACIONAREIDAD
par(mfrow=c(1,1))
plot(na.remove(modelo_NME$residuals)) #La serie tiene un comportamiento poco previsible
#AUTOCORRELACION
par(mfrow=c(1,2))
forecast::Acf(modelo_NME$residuals)
forecast::Pacf(modelo_NME$residuals) #Los rezagos del AR y MA se encuentran en los intervalos de confianza


#Se Estima otro modelo, para elegir cual es el mejor
#### ARIMA (2,1,2) 
par( mfrow = (c(1 ,1)))
modelo_NME2<-arima(Entreno, c(2,1,2),method="ML")
summary(modelo_NME2)
#aic = -342.07 ; error^2=0.0103 ; Tanto con el criterio akaike como el error cuadratico medio es mejor en el ARIMA(4,1,3)
plot(forecast::forecast(modelo_NME2,h=9)) #gráficamente el ARIMA(4,1,3) tiene mejor comportamiento
k4<-data.frame(forecast::forecast(modelo_NME2,h=9))
k5<-subset(serie, Mes>"2022-12-01")

residm2<- modelo_NME2$residuals
#PRUEBAS DE ERROR
#Homocedasticidad
par( mfrow = (c(1 ,2)))
resid_cuad2<- residm^2 
forecast::Acf(resid_cuad2, main= "FACS", col="red")
forecast::Pacf(resid_cuad2, main= "FACP", col="red")#Este modelo tambien es homocedastico
#NORMALIDAD
#HO: el error es normal
JBtest2<- rnorm(modelo_NME2$residuals) #pvalue>0.05, entonces se hacepta la ho
jarque.bera.test(JBtest2) #El error tambien es normal en este modelo
#HO: el error se distrubuye normalmente
shapiro.test(na.remove(modelo_NME2$residuals))#pvalue>0.05, entonces se hacepta la ho
par(mfrow=c(1,1))
qqnorm(na.remove(modelo_NME2$residuals))
qqline(na.remove(modelo_NME2$residuals))#no se dan desviaciones sustanciales de la linea teorica, entonces el error tiene distr normal

#ESTACIONAREIDAD
par(mfrow=c(1,1))
plot(na.remove(modelo_NME2$residuals)) #Muestra comportamientos poco previsibles 
#AUTOCORRELACION
par(mfrow=c(1,2))
forecast::Acf(modelo_NME2$residuals)
forecast::Pacf(modelo_NME2$residuals) #Los rezagos del AR y MA se encuentran en los intervalos de confianza

#Aunque el modelo ARIMA (2,1,2) es válido, el mejor es el ARIMA (4,1,4) ya que tiene mejor criterio akaike y error cuadratico medio

####Estimación del modelo ARIMA(4,1,3) para proyectar serie de proyecciones no minero energéticas  ----
#Estimación del modelo 
#ARIMA (4,1,3)
L_NME<-ts(serie$`Log(Expo_NME)`, frequency = 12, start= c(2006,1), end= c(2023,09))
modelo_NME_F<-arima(L_NME, c(4,1,3),method="ML")
summary(modelo_NME_F)
#aic = -362.99 ; error^2=0.009709
par( mfrow = (c(1 ,1)))
plot(forecast::forecast(modelo_NME_F,h=15))
#Valores predichos del modelo
proyeccion<-data.frame(forecast::forecast(modelo_NME_F,h=15)) #Este dataframe tiene la proyección para nov-dic 2023 y todo el 2024, junto con sus intervalos de confianza. 
proyeccion$true<-exp(proyeccion$Point.Forecast)
mean(proyeccion$true)
#Las exportaciones se mantendrán alrededor de 1.609'513.843

