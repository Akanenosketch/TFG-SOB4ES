#set text(lang:"es")

// Portada     

#image("./media/Portada.pdf", page: 1, width: 100%, height: 100%)

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

#show heading.where(level: 5): set text(
  size: 12pt
)

  //Contador de paginas <- 0
#counter(page).update(0)

//Espacio entre párrafos
#v(60pt)
        

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

#set rect(
  inset: 8pt,
  fill: rgb("#d6e3da"),
  width: 100%,
)

#show figure.where(kind: table): set block(breakable: true)

// Ajustes para las formulas matemáticas
#show math.equation: set text(
      font: "New Computer Modern Math",
      size: 10pt
)

#set math.equation(numbering: none)

  //Alinear texto
#set align(top+left)
// Fin ajustes

#pagebreak()

#include "chapters/dedicatoria.typ"  


// Índice general #############################################################

// Resaltado (negrita) en el índice de los puntos de la memoria donde se
// realiza discusión de resultados, para que sean fáciles de localizar.
#let discusion-labels = (
  <conclusiones-EDA>,
  <prueba-1>,
  <prueba-2>,
  <prueba-3>,
  <prueba-4>,
  <discusion-general>,
)
#show outline.entry: it => {
  let el = it.element
  if el != none and el.func() == heading and el.location() != none {
    let matches = discusion-labels.any(lbl => {
      let q = query(selector(heading).and(selector(lbl)))
      q.any(h => h.location() == el.location())
    })
    if matches { strong(it) } else { it }
  } else { it }
}

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

#outline(title: [Índice de figuras],
        target: figure.where(kind: image))
#show heading.where(level: 1): set text(
  size: 0pt
) 

#heading(outlined: false, bookmarked: true)[Índice de figuras]
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

#pagebreak()
        
//Contador de paginas <- 0
#include "appendices/glosario.typ"

#pagebreak()

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

#set heading(numbering: "1.1.1.")

#counter(page).update(1)

// fin de ajustes, inicio del documento (Introducción)

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

En los siguientes apartados se introducirán elementos que serán de utilidad para tener un mayor entendimiento sobre las diferentes partes de este TFG.


#include "appendices/append1.typ"

#pagebreak()

#include "appendices/append2.typ"

#pagebreak()

#include "appendices/append3.typ"

#pagebreak()

#include "appendices/append4.typ"

#pagebreak()

#include "appendices/append5.typ"

#pagebreak()

#include "appendices/append6.typ"

#pagebreak()

#include "appendices/append7.typ"

/* Para la bibliografía.yml usar esta plantilla
  Nombre:
    type: 
    title: 
    author:
    orgazanization:
    language: 
    url: { value: , date: }
*/