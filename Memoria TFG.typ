#set text(lang:"es")

// Portada     

#image("media/Portada.pdf", page: 1, width: 100%, height: 100%)

// Fin portada

//Ajustes
#set text(lang: "es")
#set par(justify: true)

//Ajuste nombre encabezado

#set math.equation(numbering: "1.")

//Ajuste tamaño encabezados
#show heading.where(level: 1): set text(
  size: 20pt
)

#show heading.where(level: 2): set text(
  size: 18pt
)

#show heading.where(level: 3): set text(
  size: 16pt
)

#show heading.where(level: 4): set text(
  size: 14pt
)

  //Contador de paginas <- 0
#counter(page).update(0)

//Espacio entre párrafos
#v(90pt)
        

// Tipografía normal    
#set text(
          size: 10.5pt,
          font: "Libertinus Serif",
         ) 

  
// Alineamniento párrafo
#set par(
          leading: 1.5mm, // Interlineado
          spacing: 4mm    // Espacio entre párrafgos
        )
    
#set outline(indent: 6mm) // Sangría

#set list(
  spacing: 3mm,   // espacio entre ítems
)

#set enum(
  spacing: 3mm,
)

// Ajustes para las formulas matemáticas
#show math.equation: set text(
      font: "New Computer Modern Math",
      size: 10.5pt
)

  //Alinear texto
#set align(top+left)
// Fin ajustes


#heading(outlined: false, bookmarked: true)[Dedicatoria] <dedicatoria>

#pagebreak()

#heading(outlined: false, bookmarked: true)[Agradecimientos] <agradecimientos>

#pagebreak()

// Índice general #############################################################

#outline(title: [Índice])
#show heading.where(level: 1): set text(
  size: 0pt
)
#heading(outlined: false, bookmarked: true)[Índice]
#show heading.where(level: 1): set text(
  size: 20pt
)
#pagebreak()

//Índice de imagenes ##########################################################

#outline(title: [Índice de imágenes],
        target: figure.where(kind: image))
#show heading.where(level: 1): set text(
  size: 0pt
) 

#heading(outlined: false, bookmarked: true)[Índice de imágenes]
#show heading.where(level: 1): set text(
  size: 20pt
)
#pagebreak()

// Índice de tablas ###########################################################

#outline(title: [Índice de tablas],
target: figure.where(kind: table))
#show heading.where(level: 1): set text(
  size: 0pt
)
#heading(outlined: false, bookmarked: true)[Índice de tablas]
#show heading.where(level: 1): set text(
  size: 20pt
)

// Ajuste de enumeración de los capitulos, para que inicie en introduccion

#set heading(numbering: "1.1.1.")

// fin de ajustes, inicio del documento (Introducción)

  //Ajustes de página
#set page(
        numbering: "1",
        header: [  // Cabezado de página 
                #set text(10pt)
                #set align(center)
                #h(1fr) _Desarrollo y evaluación de modelos de aprendizaje automático para la predicción de
la biodiversidad del suelo_
                ],
        paper: "a4",
        margin: (x: 2.5cm, y: 3cm),
        footer: context [ //pie de página
                   #set align(top+right)
                   #set text(10pt)
                   #counter(page).display("1")
                   ]
        )  
        
//Contador de paginas <- 0
#counter(page).update(1)

#pagebreak()

#include "chapters/chpt1.typ"

#pagebreak()

#include "chapters/chpt2.typ"

#pagebreak()

#include "chapters/chpt3.typ"

#pagebreak()

#include "chapters/chpt4.typ"

#pagebreak()

#include "chapters/chpt5.typ"

#pagebreak()

#include "chapters/chpt6.typ"

#pagebreak()

#include "chapters/chpt7.typ"

#pagebreak()

#include "chapters/chpt8.typ"

#pagebreak()

#include "chapters/chpt9.typ"

#pagebreak()

= Referencias <referencias> 
#bibliography("bibliografía.yml", 
              full: true, 
              style: "institute-of-electrical-and-electronics-engineers", 
              title: none)

#pagebreak()

= Anexos <anexos>

En los siguientes apartados se introducirán elementos que serán de utilidad par tener un mayor entendimiento sobre las diferentes partes de este TFG.

// Anexo 1: Glosario de Términos

#include "appendices/append1.typ"

/* Para la bibliografía.yml usar esta plantilla
  Nombre:
    type: 
    title: 
    author:
    orgazanization:
    language: 
    url: { value: , date: }
*/