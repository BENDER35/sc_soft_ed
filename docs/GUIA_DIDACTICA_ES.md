# Guía didáctica (español)

Esta guía acompaña a `sc_soft_ed`. No prescribe un currículo oficial: ofrece una **secuencia de uso** de las herramientas instaladas para que alumnado de 6 a 16 años (y adultos principiantes) aprenda con ellas.

## 1. Principios pedagógicos

| Principio | Qué significa en el aula | Cómo lo aplica este catálogo |
|---|---|---|
| Constructivismo | El alumno construye significado al explorar, no solo recibiendo datos | GeoGebra, Step y PhET permiten probar hipótesis y ver el resultado |
| Construccionismo (Papert) | Aprender programando es aprender pensar | Scratch y Thonny: crear artefactos, no solo resolver ejercicios |
| Andamiaje (Vygotsky) | Ayuda gradual que se retira al crecer la competencia | GCompris tiene niveles; KTouch y Anki ajustan dificultad |
| Repetición espaciada | Repasar en intervalos crecientes fija la memoria | Anki programa las tarjetas por rendimiento |
| Gamificación | Retos, feedback inmediato y progreso sostienen la motivación | GCompris, Tux Math, KAnagram, KHangMan |
| Taxonomía de Bloom | Ordenar objetivos: recordar → comprender → aplicar → analizar → evaluar → crear | Cada sesión termina en «crear algo», no solo en responder |

## 2. Estructura de una sesión (45 minutos)

1. **Motivación (5 min).** Pregunta disparadora: «¿Por qué el agua sube por el tubo?».
2. **Demostración guiada (8 min).** El docente abre la herramienta y resuelve un caso sencillo en proyección.
3. **Exploración en parejas (15 min).** Dos alumnos por equipo, una máquina; uno opera y el otro registra hipótesis. Rotar al medio tiempo.
4. **Reto de creación (12 min).** Producir un artefacto: una construcción, un dibujo vectorial, una tarjeta Anki, un programa de 10 bloques.
5. **Cierre y metacognición (5 min).** «¿Qué cambió de tu idea inicial?» Se escribe en Xournal++ o Freeplane.

## 3. Secuencia por franja de edad

- **6–8 años:** GCompris (ratón, teclado, conteo, secuencias), Tux Paint, Tux Typing. Objetivo: alfabetización digital y automatsmo lector básico.
- **9–11 años:** Tux Math, GeoGebra (geometricamente), KAnagram, KHangMan, KWordQuiz, KStars. Objetivo: operaciones, vocabulario y observación científica.
- **12–14 años:** Scratch, Thonny, Step, KAlgebra, Kig, KGeography, Audacity. Objetivo: lógica, modelado y expresión.
- **15–16 años y adultos:** LibreOffice, Anki, Kiwix, Inkscape, Krita, GIMP, MuseScore, Scribus, Freeplane. Objetivo: producción autónoma y estudio independiente.

## 4. Plan de 4 semanas (ejemplo transversal)

| Semana | Asignatura | Herramienta | Producto final |
|---|---|---|---|
| 1 | Matemáticas | GeoGebra + KAlgebra | Construcción interactiva de una parábola y su tabla |
| 2 | Lengua | KWordQuiz + Anki | Baraja de 20 vocablos con ejemplo y audio |
| 3 | Ciencias | Step + KStars | Modelo de plano inclinado y registro lunar de una semana |
| 4 | Tecnología | Scratch o Thonny | Juego pequeño con puntuación y reinicio |

> Nota: ajusta la lista de productos al idioma y al nivel del curso.

## 5. Evaluación

- **Formativa:** observación durante la exploración; el docente anota hipótesis incorrectas y las usa al cierre.
- **Sumativa:** rúbrica de 4 niveles (inicial, en proceso, logrado, avanzado) sobre: uso correcto de la herramienta, explicación del concepto, registro de evidencias y creatividad.
- **Autoevaluación:** usa la ficha «Hoy aprendí… / Me costó… / Mañana probaré…».
- No evalúes la velocidad: valora el razonamiento y la capacidad de explicar el proceso.

## 6. Accesibilidad y buenas prácticas

- Activar subtítulos y controles de Contraste del sistema antes de la sesión.
- KTouch y Tux Typing pueden usarse con teclado grande o layouts alternativos.
- Agrupar en parejas heterogéneas; rotar el rol de «operador» y «registrador».
- Kiwix permite trabajar **sin Internet**: descarga el paquete de Wikipedia en el idioma del curso.
- No pedir cuentas personales: ninguna herramienta del catálogo las requiere para uso básico.
- Guardar producciones en una carpeta compartida por curso, no en el perfil del alumno.

## 7. Solución de problemas de instalación

| Síntoma | Acción |
|---|---|
| `sudo: command not found` | Ejecuta `./install.sh --list-stores` y usa `--stores` con una tienda de usuario (flatpak, brew, nix). |
| Un paquete no existe en la distro | Es normal: el catálogo tiene nombres alternativos por tienda. Prueba `--all-stores` o `--group all`. |
| Flatpak pide Flathub | El script añade el remoto automáticamente; verifica con `flatpak remote-list`. |
| winget no encuentra un id | El script buscará por nombre; también puedes usar `-Stores choco,scoop`. |
| macOS sin Homebrew | Instala Homebrew desde https://brew.sh o usa `--stores macports,nix`. |

## 8. Recursos citados

- Wikipedia, *Educational software*: https://en.wikipedia.org/wiki/Educational_software
- Wikipedia, *GCompris*: https://en.wikipedia.org/wiki/GCompris
- Karolčík et al. (2015), marco CEELTES: https://doi.org/10.15388/infedu.2015.14
- PhET Interactive Simulations: https://phet.colorado.edu/
- Scratch: https://scratch.mit.edu/

---

[Volver al README](../README.md) · [History and curriculum (EN)](HISTORY_AND_CURRICULUM_EN.md) · [Mirror](MIRROR.md)
