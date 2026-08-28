== Notebooks de preparación de datos (Anexo III) <preparacion-de-datos>

=== Notebook de ingesta de datos en ficheros <ficheros-locales>

#let file = "../media/anexos/data-prep.pdf"
#let total_pages = 16 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Notebook de ingesta de datos de fuentes remotas <ficheros-remotos>

#let file = "../media/anexos/data-prep-online.pdf"
#let total_pages = 8 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}

=== Notebook de integración de fuentes <mixin-de-datos>

#let file = "../media/anexos/data-prep-combination.pdf"
#let total_pages = 4 
#set page(number-align: right)
#for p in range(1, total_pages + 1) {
  page(
    margin: (top: 2.5cm, left: 2.5cm, right: 2.5cm, bottom: 2.5cm),
    background: image(file, page: p, width: 90%, height: 90%, fit: "cover"),
    footer: auto 
  )[]
}