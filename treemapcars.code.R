library(devtools)
#El paquete d3treeR no est� dentro del CRAN de R, por eso se instala as�:
install_github("timelyportfolio/d3treeR")
library(dplyr)
library(d3treeR)
library(treemap)
library(RColorBrewer)
library(stringr)

#Leemos los datos:
#Es un dataset que nos dice cu�les fueron los autos m�s vendidos en Colombia durante el 2018
#Sus variables son: Modelo carro - Tipo de carrocer�a - Numero de ventas:
datos=read.csv(file="salescars.csv",sep=";")

#Eliminamos algunos N/A�s que trae el dataset
datos=select(.data = datos,Car,Sales,Type)
datos=datos[1:100,]

#Creamos el primer �rbol
treemap(datos,
        index=c("Type","Car"),
        vSize = "Sales",
        vColor = "Sales",
        type="index"
)

#Este c�digo es para variar el color dependiendo del nivel de ventas de cada auto
#Todo este bloque no es obligatorio!!! Solo para crear un mejor orden
#############################################################################################
datos2 <- datos %>% arrange(Type, Sales)  %>% 
  group_by(Type) %>%
  mutate(bin = cut(Sales, 
                   breaks = c(-Inf, quantile(Sales, probs = seq(0.25, 0.75, 0.25)), Inf), 
                   labels = c(1, 2, 3, 4)))

datos2$newbin <- with(datos2, interaction(Type, bin))

datos2$newbin <- factor(datos2$newbin, as.character(unique(datos2$newbin)))

datos2 %>% group_by(Type, bin) %>% select(newbin)

#Se crea la paleta de colores:
counts <- datos2 %>% group_by(Type) %>% 
  summarise(n = n_distinct(bin)) %>% 
  pull(n)

palette <- sapply(1:n_distinct(datos2$Type), 
                  function(i) brewer.pal(counts[i], 
                                         c("Purples","Blues","Reds",
                                           "Greens","Greys")[i])) %>% 
  unlist()
#############################################################################################


#Se vuelve a graficar todo el �rbol de nuevo, con los cambios creados en los colores:
tree=treemap(datos2,
  index=c("Type", "Car"),
  vSize="Sales",
  vColor="newbin",
  type="categorical",
  position.legend	="none",
  palette = palette
)

#Esta funci�n, es la que hace el �rbol se vuelva interactivo (Hace la magia)
d3tree(tree, rootname = "Type")

