# Scanned PDFs (no text layer)

Playbook for image-only PDFs (book scans). The standard pipeline extracts nothing
from these; everything below was learned the hard way converting a 340-page
scanned book (Kierkegaard, Trotta 2007).

## 1. Detect

```bash
pdftotext -f 1 -l 5 input.pdf - | wc -c   # ~0 bytes → scanned, no text layer
```

If scanned, do NOT run the normal converter on it. Follow this playbook.

## 2. OCR with tesseract — never LLM-vision as primary source

**LLM visual OCR of whole books hallucinates**: repeated-loop text, invented
sentences, silently dropped lines. It looks plausible and diffs terribly.
Use it ONLY to arbitrate specific discrepancies (read one page image, check one
word), never to produce the corpus.

```bash
# Render at 300 dpi (150 is too low for tesseract)
pdftoppm -gray -r 300 -png input.pdf pages/p

# Book scans are usually two-page spreads: split into halves
w=$(magick identify -format %w p-001.png)
magick p-001.png -crop $((w/2))x+0+0 +repage p-001-L.png   # and the right half

# Trim spine/edge junk (vertical stripe of stray chars in output = binding shadow)
magick half.png -gravity West -chop 80x0 -shave 0x50 clean.png

tesseract clean.png out -l spa --psm 6      # language of the book, PSM 6
```

Post-process the text: join end-of-line hyphenations, drop running heads
(all-caps title lines), page numbers, and marginal edition numbers (standalone
1–3 digit tokens). Check for empty outputs (`find -size -200c`) — tesseract
occasionally returns 0 bytes on a valid page; rerun that page without the crop.

## 3. Mandatory verification pass

Extract the EPUB text and align it against the OCR word-by-word:

```python
import difflib
sm = difflib.SequenceMatcher(a=ocr_norm_words, b=epub_norm_words, autojunk=False)
sm.ratio()   # body text should be > 0.99; scanned-source EPUBs often land ~0.97
```

Normalize before comparing: lowercase, unify quotes/dashes, strip punctuation,
drop pure-digit tokens (page/margin numbers).

**High-confidence typo detection** (finds the EPUB's own OCR errors): for each
small `replace` opcode, flag it when the PDF-side word is frequent in the EPUB
itself (≥10×) and the EPUB-side word is rare (≤2×). Classic confusions:
`yez/vez`, `bijo/hijo`, `gue/que`, `renga/tenga`, `accidenral/accidental`.
Apply fixes with word-boundary regex, never bare `str.replace` (substring hits
inside longer words); disambiguate multiple hits by expected position in the
chapter.

## 4. Footnotes → EPUB 3 popup notes

Superscript note markers survive OCR only as junk glued to the previous word
(`imposible**,`, `fe*%`, stray `”`) — in tesseract output AND in the EPUB body.
Tesseract cannot split them out even at 600 dpi, so:

1. Extract the notes sections (usually end-of-chapter "NOTAS" pages) from the
   OCR; parse `^\d+\. ` entries; validate the count is contiguous 1..N per
   chapter (OCR misreads digits — trust order, not the printed number).
2. Locate markers in the body by combining three sources: junk-residue tokens
   in the OCR text, junk-residue tokens in the EPUB body itself (these carry
   exact positions), and targeted visual reads of page images for the gaps.
3. Assign numbers 1..N by document order; the sequence-continuity constraint is
   the integrity check. A single false positive shifts every later note — favor
   precision over recall, and visually verify low-confidence positions.
4. Emit EPUB 3 popup markup (Kindle shows these as popups; OPF must be
   `version="3.0"`):

```html
<sup><a epub:type="noteref" href="#ch1-n28" id="ch1-r28">28</a></sup>
...
<aside epub:type="footnote" id="ch1-n28"><p>28. Note text.</p></aside>
```

## 5. Section inventory

Diff the PDF's section inventory (half-titles, epigraphs, per-chapter notes,
glossary, concordance tables, name indexes) against the EPUB spine and report
omissions to the user. Scanned-book conversions silently drop exactly these.

## 6. Notes-section parsing (validate or it WILL be wrong)

Parsing `^\d+\. ` naively produced silent merges and splits on the reference
book — every one of these actually happened:

- Continuation lines that look like new notes: `vol. 1, pp. 234-236.` and
  `2, p. 59).` were taken as notes 1 and 2.
- OCR-corrupted numbers: `t50`→150, `15h`→151, `$0`→80, `39`→59 (printed 59).

Parser rules that survived:

- Monotonic repair: accept a line as note *k* only if it starts with a
  number-ish token AND (|k − expected| ≤ 2, OR it differs from `expected` in
  exactly one digit) AND the rest does not start lowercase or with `pp.`/`p.`.
  Map `O Q→0, $→8, l t I h→1, S→5` before comparing. Otherwise it is a
  continuation of the current note.
- **Always validate with ≥15 checkpoints** (note number → distinctive fragment:
  a Bible cite, a proper name) spread across the chapter, and check the total
  against the last printed note number, before using the list for anything.
- Marker numbering in the body comes from ORDER + semantic match against each
  note's content. Visually-read superscript digits (yours or a subagent's) are
  weak hints only: tiny digits misread (3↔5, 7↔2) and margin numbers of
  critical editions get mistaken for markers.

## 7. Tables and indexes: embed as page images

OCR destroys concordance tables and name indexes (column soup). Do not drop
them and do not OCR them — embed the page halves as images in their own
sections, added to manifest + spine + nav:

```bash
magick half.png -shave 60x80 -resize 1100x -colorspace Gray -strip PNG8:conc-01.png
```

One `<img>` per page in a plain XHTML section. Faithful, readable, ~120 KB/page.

## 8. Misc traps

- **Page arithmetic** (spread → book page, e.g. `L = 2n-4`): half-titles and
  blank pages shift it. Verify the mapping against the printed folios of 2–3
  spreads before relying on it.
- **Before declaring a section "omitted" from the EPUB**, grep the EPUB for
  its distinctive content. A misaligned diff makes present text look missing
  (the reference book's notes were "missing" until a targeted grep found them).
- **Marker residues in the body** (`fe*%`, `ella7?`, `»?`, stray `”`): clean
  them contextually when inserting noterefs — keep `?` only if the sentence
  segment has an opening `¿`; convert `”` to `»` only if there is an unclosed
  `«` nearby, else drop; drop glued digits when they are a prefix of the note
  number; collapse `!!` to `!`.
- Typo fixes: word-boundary regex, never bare `str.replace` — a 2-char typo
  like `ci` matches thousands of substrings. Disambiguate multiple hits by
  expected position within the chapter.

## 9. Intermediate files and subagents

- The session scratchpad can be garbage-collected MID-RUN. Write subagent
  outputs to a persistent dir (`~/.cache/...`) immediately; sync early, sync often.
- Never ask a subagent to "rewrite from memory" a long transcription it made
  earlier — it will hallucinate a plausible fake. Re-derive from the source.
- Give vision subagents narrow, verifiable tasks with a fixed output format
  (e.g. "list superscript markers as `page | number | preceding words`"), never
  mass transcription. Validate their output against an independent source: they
  routinely misread margin numbers as note markers and invent sequences.

## 10. Catálogo adicional (sesión vol. 1, 2026-09-26)

- **`csv.reader` sobre TSV de tesseract**: usar SIEMPRE `quoting=csv.QUOTE_NONE`.
  Con el quoting por defecto, una comilla doble en el texto traga filas enteras
  del TSV: páginas con 5× palabras, párrafos gigantes y basura numérica
  ("52 -1 5 1 1 1") incrustada. Síntoma: `parsed words >> tsv words`.
- **Margen izquierdo por moda**: en páginas inclinadas la moda de inicios de
  línea cae en la sangría y el filtro come la primera palabra de CADA línea
  (pérdida silenciosa del 5-8%). Usar percentil 15 de los inicios y umbral
  laxo (BL−60). Verificar con un pasaje conocido (buscar 20 palabras seguidas
  de una página leída visualmente).
- **Detector de notas de autor**: una línea que "empieza con *" puede ser un
  superíndice mal leído; el corte amputa media página. Detectar candidatos,
  verificarlos visualmente y usar LISTA BLANCA de páginas antes de cortar.
- **Doble numeración (ediciones críticas, p. ej. Trotta/SKS)**: el número del
  margen superior/lateral es la paginación de la edición crítica, el folio
  real va al pie. No usar el número superior para la aritmética de páginas.
- **Superíndices**: no sobreviven como palabras en tesseract ni en Vision (ni
  a 600 dpi); quedan como residuos pegados (`palabra'`, `palabra*`, `palabra12`).
  Pipeline que funcionó: candidatos por residuos en AMBOS flujos crudos +
  anclas semánticas (citas «...» del texto de la nota buscadas difusas en el
  cuerpo, nombres propios únicos con filtro de página plausible) + DP
  monotónico con prior de posición (2 pasadas autoconsistentes) + pins
  verificados visualmente. Excluir `; : ! ?` de la clase de residuos (ruido) y
  el flujo del cuerpo debe estar LIBRE de las secciones de notas antes de
  anclar (si no, las anclas se clavan en la propia nota).
- **Fidelidad medible**: contra un solo motor el techo es ~94% (errores del
  motor incluidos). La métrica honesta es el CONSENSO: donde tess+Vision
  coinciden (bloques ≥3 palabras), medir cuánto coincide el texto final.
  Pasada de reparación por consenso (adoptar la lectura acordada en
  replace/insert acotados) sube de ~98% a ~99,6%.
- **Vision como respaldo por página**: puntuar cada mitad por solapamiento de
  bolsas de palabras tess↔Vision; con <0,6 usar Vision (re-OCR con
  boundingBox para recuperar sangrías). El lexscore no sirve (la basura corta
  parece léxica).
- **Deshifenado del flujo de referencia**: Vision conserva guiones de fin de
  línea; sin deshifenarlo, la métrica y el arbitraje se degradan varios puntos.
