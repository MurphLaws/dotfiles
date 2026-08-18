#!/usr/bin/env fontforge -script
# Genera SlalomSymbols.ttf: una fuente de símbolos con un único glyph, el
# logo "s" de Slalom, en el codepoint PUA U+F8000. Se usa como fuente de
# *fallback* en ghostty para que ese codepoint renderice el logo sin tener
# que re-parchear JetBrainsMono en cada actualización.
#
# Fuente del glyph: slalom-s.svg (trazado con potrace desde el logo oficial).
# Uso: fontforge -script build-slalom-font.py

import fontforge
import psMat
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SVG = os.path.join(HERE, "slalom-s.svg")
OUT = os.path.join(HERE, "SlalomSymbols.ttf")
CODEPOINT = 0xF8000

EM = 1000
ASCENT = 800
DESCENT = 200
ADVANCE = 600            # ancho monospace de JetBrainsMono NFM (por 1000 em)
TARGET_HEIGHT = 640      # alto del glyph sobre la baseline
BASELINE_Y = 40          # separación desde la baseline

font = fontforge.font()
font.encoding = "UnicodeFull"
font.em = EM
font.ascent = ASCENT
font.descent = DESCENT
font.familyname = "SlalomSymbols"
font.fontname = "SlalomSymbols"
font.fullname = "SlalomSymbols"
font.copyright = "Slalom logo glyph for personal terminal use."

g = font.createChar(CODEPOINT, "slalom_s")
g.importOutlines(SVG)

# potrace exporta SVG con coordenadas que FontForge importa ya en la
# orientación correcta (Y hacia arriba). Normalizamos tamaño y posición.
xmin, ymin, xmax, ymax = g.boundingBox()
h = ymax - ymin
w = xmax - xmin
if h > 0:
    scale = float(TARGET_HEIGHT) / h
    g.transform(psMat.scale(scale, scale))

xmin, ymin, xmax, ymax = g.boundingBox()
w = xmax - xmin
# Centrar horizontalmente en el ancho de avance y apoyar en la baseline.
dx = (ADVANCE - w) / 2.0 - xmin
dy = BASELINE_Y - ymin
g.transform(psMat.translate(dx, dy))

g.width = ADVANCE
g.round()

font.generate(OUT)
print("Generado:", OUT)
