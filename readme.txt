Contenido:
La carpeta contiene 2 subcarpetas: 1.Scripts & DoFiles ; 2. Datos-20231216T185808Z-001.

1.Scripts & DoFiles: Contiene 2 scripts de R, 1 Dofile de Stata y 1 Archivo Log 
	1.1:Scripts de R
	1.1.1: Punto1.1_test_proCol.R : Carga bases de datos en txt, las unifica, 		elimina duplicados y la exporta en xlsx, correspondiente  para 			análizar el tejido empresarial colombiano. En la parte 2, carga 		base  en .dta, filtra basado en reglas para seleccionar empresas y 		exporta base de empresas seleccinadas en xlsx
	1.1.2: Punto2_test_ProCol.R : Carga bases de datos, estima y calibra un 	       modelo ARIMA para proyectar el comportamiendo de las exportaciones 	       no minero energéticas para cierre de 2023 y 2024.

	1.2: DoFile de Stata:
	1.2.1: punto1.2_test_proCol.do: Carga base de datos en excel, genera 	    	       variables para estimación de modelos supervisados de machine 		       learning (Probit & Logit) y realiza pruebas para validarlo.
	1.3: Archivo log de Stata:
	1.3.1: punto1.2_test_proCol.txt: Impresión de la pantalla que es generada 	       por el archivo "punto1.2_test_proCol.do"



2.Datos-20231216T185808Z-001:
2.1 RUES.txt: listado de empresas del RUES en .txt enviada para prueba
2.2 Exportaciones.txt: Listado de empresas exportadoras en .txt enviada para prueba.
2.3 Directorio_DANE.txt: Listado de empresas del directorio del DANE enviada para prueba. 
2.4 SuperSociedades.txt: Listado de empresas de SuperSociedades enviada para prueba.
2.5 Diccionario.xlsx: Diccionario de variables de RUES.txt, Exportaciones.txt, Directorio_DANE.txt y Supersociedades.txt enviada para prueba.
2.6 expo_nme.xlsx: Exportaciones no minero enegerticas enviada para prueba.
2.7 MASTER CIIU por sectores.xlsx: Base de datos CIIU Rev.4.
2.8 Master.xlsx: Union de RUES.txt, Exportaciones.txt, Directorio_DANE.txt y SuperSociedades.txt, sin duplicados.
2.9 Master_Probit_Logit.dta: Base "Master.xlsx" con variables creadas para correr modelos y valores predicho de modelo logit y probit (Resutlado de "punto1.2_test_proCol.do").
2.10 Empresas_Seleccionadas.xlsx: Entregable de empresas seleccionadas.




