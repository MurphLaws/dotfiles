# SlalomSymbols

Fuente de símbolos con un único glyph: el logo "s" de Slalom, en el codepoint
PUA **U+F8000**. Se usa como fuente de *fallback* en ghostty para renderizar ese
codepoint sin re-parchear JetBrainsMono, y se referencia como icono del grupo
`<leader>os` (Slalom) en which-key.

En terminal el glyph es monocromo (una sola tinta): se ve la silueta de la "s"
con el color del texto/highlight, no el cuadro azul con la s blanca.

## Archivos

- `slalom-logo-source.png` — logo original (fuente del trazado).
- `slalom-s.svg` — silueta vectorial (trazada con potrace).
- `build-slalom-font.py` — script de FontForge que genera la fuente.
- `SlalomSymbols.ttf` — fuente generada (instalar en `~/Library/Fonts/`).

## Regenerar

Requiere `fontforge`, `potrace` e `imagemagick` (`brew install ...`).

```sh
# 1. (opcional) re-trazar el SVG desde el PNG
magick slalom-logo-source.png -alpha off -colorspace Gray -threshold 55% \
  -negate -bordercolor white -border 12 -alpha off slalom-s.pbm
potrace slalom-s.pbm -s -o slalom-s.svg
rm slalom-s.pbm

# 2. generar la fuente
fontforge -script build-slalom-font.py

# 3. instalar
cp SlalomSymbols.ttf ~/Library/Fonts/
```

Tras instalar, recarga ghostty (la config ya la lista como `font-family` de
fallback) y nvim (`:Lazy reload which-key.nvim`).
