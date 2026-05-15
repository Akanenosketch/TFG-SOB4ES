#set text(lang:"es")
#box(
  stroke: 0pt,
  image(
    "media/image1.png", height: 0.4930555555555556in, width: 2.7083333333333335in,
  ),
)

// Portada     

// TODO COGER IMAGEN DE WORD/LIBREOFFICE
#set align(center)
#strong[E];scola #strong[S];uperior de #strong[E];nxeñaría #strong[I];nformática
\
\
\
\
\
\
\
\
\
\
\
\
\
\
#figure(
  align(
    center,
  )[#table(
      stroke: 0pt,
      columns: (100%), align: (center,center), 
      table.cell(
        align: center,
      )[Memoria do Traballo de Fin de Grao que presenta

        #strong[Dª. Tatiana María Quintas Rodríguez]

        para a obtención do Título de Graduado en Enxeñaría Informática

        #strong[Desarrollo de un sistema de monitorización y automatización de los valores de conductividad en acuarios con Arduino]

      ],
    )],
    outlined: false
)
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
#figure(
  align(
    bottom+center,
  )[#table(
      stroke: 0pt,
      columns: (21.58%, 78.42%), align: (left, auto), table.cell(
        align: left,
      )[#box(
          image(
            "media/image2.png", height: 1.2291666666666667in, width: 1.1944444444444444in,
          ),
        )], [Xullo, 2026

        #strong[Traballo de Fin de Grao Nº];: 

        #strong[Titor/a:] Javier Rodeiro Iglesias

        #strong[Área de coñecemento:] Linguaxes e Sistemas Informáticos

        #strong[Departamento:] Informática

      ],
    )],
    outlined: false
)

// Fin portada
/*
########################################################################################################################################################

########################################################################################################################################################
*/
//Ajustes
#set text(lang: "es")

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

  //Ajustes de página
#set page(
        numbering: "1",
        header: [  // Cabezado de página 
                #set text(10pt)
                #set align(center)
                #h(1fr) _Desarrollo de un sistema de monitorización y automatización de los valores de conductividad en acuarios con Arduino_
                ],
        paper: "a4",
        margin: (x: 2.5cm, y: 3cm),
        footer: context [ //pie de página
                   #set align(top+center)
                   #set text(10pt)
                   #counter(page).display("1")
                   ]
        )  
        

// Tipografía normal    
#set text(
          size: 10pt,
          font: "Libertinus Serif",
         ) 

  
// Alineamniento párrafo
#set par(
          leading: 2.5mm, // Interlineado
          spacing: 5mm    // Espacio entre párrafgos
        )
    
#set outline(indent: 6mm) // Sangría

// Ajustes para las formulas matemáticas
#show math.equation: set text(
      font: "New Computer Modern Math",
      size: 10pt
)

  //Alinear texto
#set align(top+left)
// Fin ajustes


#heading(outlined: false, bookmarked: true)[Dedicatoria] <dedicatoria>

#pagebreak()

#heading(outlined: false, bookmarked: true)[Agradecimientos] <agradecimientos>

#pagebreak()

// Índice general #############################################################


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

#include "chapters/chpt10.typ"

#pagebreak()

#include "chapters/chpt11.typ"

#pagebreak()

#include "chapters/chpt12.typ"

#pagebreak()

#include "chapters/chpt13.typ"

#pagebreak()

#include "chapters/chpt14.typ"

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