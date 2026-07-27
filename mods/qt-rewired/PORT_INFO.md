# QT: Rewired — Port a Psych Engine v0.7.3

Mod original construido para el motor oficial moderno de FNF (`FunkinCrew/Funkin'`,
namespace `funkin.*`: `Module`/`SongEvent`/`ScriptedClass`, charts v2.0, atlas
Adobe Animate). Este engine (Psych Engine v0.7.3) es arquitectónicamente distinto,
así que nada del código/datos original se pudo copiar tal cual — todo lo de abajo
fue reconstruido usando las convenciones reales de mods de Psych (ver
`source/backend/Song.hx`, `source/objects/Character.hx`, `source/backend/StageData.hx`,
`source/backend/Mods.hx`), verificadas también contra el código fuente real de
`FunkinCrew/Funkin'` (clonado aparte) para confirmar semánticas de eventos/charts.

## Estado actual: "Blissful" y "Obliterated" jugables

Lo que SÍ funciona (carpeta de mod, sin tocar `source/`):
- `characters/{qt,bf-qt,gf-qt,kb}.json` — personajes reconstruidos al schema
  `CharacterFile` de Psych, usando los atlas Adobe Animate reales del mod vía
  el soporte nativo `flxanimate` de Psych.
- `stages/qtStage.json`+`.hx` y `stages/qtStageKiller.json`+`.hx` (HScript) —
  anchors de personajes, zoom y fondos del stage, sin la cutscene de intro.
- `data/blissful/*.json` — chart convertido del formato plano `{t,d,l,p}` del
  mod original al formato de secciones de Psych (notas 0-3/4-7 se mapean 1:1
  al mismo mecanismo mustHitSection de Psych).
- `data/obliterated/*.json` — igual, pero con **BPM variable**: se reconstruyó
  el mapeo tiempo↔beat a partir de los `timeChanges` del mod (redondeando cada
  quiebre de tempo al múltiplo de 4 beats más cercano, ya que Psych solo admite
  cambios de BPM en límites de sección) para poder ubicar cada nota en la
  sección correcta pese a los ~20 cambios de tempo de la sección "Killer".
- **Mecánica de esquivar sierras** (`stages/qtStageKiller.hx`): el evento de
  chart custom `sawKB` dispara una secuencia de 2 beats (alerta → sierra
  gira → ataque), usando los atlas reales `saw_mechanic/warning` y
  `saw_mechanic/saw_assets`. Esquivar = tecla **Accept** (Enter/Space según
  bindeo) en la ventana de 1 beat antes del ataque; cura 0.2 de vida si se
  esquiva a tiempo, quita 1.0 de vida (mitad de la barra) si no.
- `songs/{blissful,obliterated}/*.ogg` — audio con voces separadas por
  personaje (usa `vocals_file` de Psych).
- `weeks/QT.json` — ambas canciones aparecen en Freeplay y Story Mode.

## Limitaciones conocidas / trabajo pendiente

1. **BF-QT usa el sprite vanilla de Boyfriend.** El atlas "characters/BF/bf-qt"
   que trae el mod solo contiene animaciones EXTRA (pre dance, caramelldansen,
   dodge, saw hit) — las animaciones base de canto/idle de BF-QT en el mod
   original reusan el atlas del BF del motor moderno oficial, que no viene
   incluido en este mod y no tenemos. Por eso BF-QT se ve como el BF clásico
   (sí tiene animación `dodge` propia, tomada del `bf.json` vanilla de Psych).
2. **Sin cutscene de intro** en ninguna de las dos canciones (timeline con
   tweens/cámara del mod original — `QtTransformSongOutro`, bus, etc.).
3. **Eventos de cámara sin portar** (`FocusCamera`/`ZoomCamera`/`SetCameraBop`
   con easing custom, ~84 en Blissful) — Psych sigue la cámara automáticamente
   al cantante activo por defecto. En Obliterated sí se portaron los eventos
   `ScrollSpeed` (→ "Change Scroll Speed" nativo de Psych, sin el tween/easing
   del original, aplicado instantáneo) y los 10 `sawKB`.
4. **`changeStage` sin portar** (Obliterated cambia de escenario 5 veces
   durante la canción en el original; aquí el fondo de `qtStageKiller` se
   queda fijo). `blackIn`/`cutsceneVideo`/`fadeStart` tampoco están portados.
5. **Solo la variante base de cada canción.** Faltan: Blissful-erect,
   Blissful-pico, Blissful-2021, Obliterated-erect, Obliterated-legacy — estas
   traen su propio note kind custom (`caramella`), personajes/atlas
   adicionales, y en el caso de Obliterated-erect probablemente doble/triple
   sierra (la mecánica ya soporta un solo saw a la vez; single/double/triple
   del `.hxc` original no se portó, solo single porque es lo único que usa la
   variante base).
6. **Solo el hit de sierra en `mode: instant damage`.** El modo "instakill"
   / "disabled" configurable por el jugador (guardado en `Save`) del mod
   original no está portado — siempre resta la mitad de vida.
7. **Portrait de Story Menu genérico** (`weekCharacters` cae al personaje BF
   por defecto — no hay arte de menú específico de QT/KB convertido todavía).
8. **Tecla de esquive fija** (Accept/Enter), no configurable como en el mod
   original (que guardaba un keybind custom en las opciones).

## Assets de origen

- `data-src/`, `images-src/` — JSON/imágenes crudas del mod original (formato
  del motor moderno), mantenidos como referencia para conversiones futuras.
  No son leídos por el engine.
- Los sprites/audio reales usados sí están copiados en `images/`, `songs/`,
  `sounds/` en las rutas que Psych espera.

## Próximos pasos sugeridos (en orden)

1. Portar los eventos de cámara de Blissful a "Focus Character"/"Add Camera
   Zoom" nativos de Psych (o custom-event HScript si se quiere el easing
   exacto).
2. Variantes erect/pico/2021/legacy de cada canción, incluyendo el note kind
   `caramella` y el soporte double/triple sawblade.
3. `changeStage` (recolorear props vía `eventCalled` en vez de cambiar de
   escenario real) y cutscene de intro.
4. Keybind configurable para esquivar + modos instakill/disabled desde
   opciones del mod.

## Investigación: variantes erect/pico/legacy, `caramella`, sierra doble/triple

Detalle de lo que hace falta para el punto 2 de arriba, investigado contra
`data-src/` (metadata/charts crudos del mod original) y contra
`FunkinCrew/Funkin'` (clonado aparte para confirmar semánticas).

### Variantes por canción (metadata real)

| Canción-variante | `player`/`opponent`/`girlfriend` | `instrumental` | `stage` | dificultades | BPM |
|---|---|---|---|---|---|
| Blissful (base) | bf-qt / qt / gf-qt | — | qtStage | easy,normal,hard | 138 |
| Blissful-erect | bf-qt / qt / **gf** (vanilla, no gf-qt) | `erect` | **qtStageCityErect** | erect,nightmare | 152 |
| Blissful-pico | **pico-qt** / qt / **nene-qt** | `pico` | qtStagePico | easy,normal,hard | 138 |
| Blissful-2021 | bf-qt / **qt-legacy** / gf-qt | — | qtStage2021 | easy,normal,hard | 138 |
| Obliterated (base) | bf-qt / kb / gf-qt | — | qtStageKiller | easy,normal,hard | 245 (variable) |
| Obliterated-erect | bf-qt / kb / gf-qt (voces `bf-erect`/`kb-erect`) | `erect` | **qtStageObliteratedErect** | erect,nightmare | 152→160 (variable) |
| Obliterated-legacy | bf-qt / kb / gf-qt | `legacy` | qtStageKiller (mismo stage) | easy,normal,hard | 245 (variable) |

Cada variante es efectivamente **una canción nueva** para Psych (chart +
personajes + stage propios), no un simple flag — así que portarlas es repetir
el mismo trabajo hecho para Blissful/Obliterated base, una por una. La única
que reutiliza el stage ya portado es Obliterated-legacy (mismo `qtStageKiller`).

Anchors de personaje + `cameraZoom` de los stages nuevos (de
`data-src/stages/*.json`, mismo schema `StageFile` ya usado):
- `qtStagePico`: bf [1025,848] cam[-226,-110] · dad [-29,864] cam[330,-100] ·
  gf [495,786.5] cam[35,17] · zoom 0.69 · 23 props.
- `qtStageCityErect`: dad [305,1289] cam[235,-88] · bf [1330,1285]
  cam[-290,-150] · gf [820,1164] cam[12,30] · zoom 0.585 · 16 props.
- `qtStageObliteratedErect`: igual que CityErect pero dad en [364,1282]
  cam[255,-78] · zoom 0.585 · 16 props.
- `qtStage2021`: bf [989.5,885] cam[-100,-100] · dad [335,885] cam[150,-100] ·
  gf [751.5,787] cam[0,0] · zoom 0.92125 · solo 3 props (escenario simple).

### Note kind `caramella`

No es un flag separado del engine: en el chart de Blissful-erect
(`data-src/songs/blissful/blissful-chart-erect.json`) cada nota tiene un
campo `"k"` (kind) igual a `null`, `"noanim"` o `"caramella"` — **73 notas**
etiquetadas `caramella` entre t=189.9s y t=213.6s (la sección
"caramelldansen" de la canción).

En el motor original (`scripts/notekinds/caramella.hxc`) esto era una clase
`NoteKind` que solo asigna un sufijo de animación — funcionalmente idéntico
al mecanismo de "Alt Animation" que Psych YA trae de fábrica
(`Note.hx` → `animSuffix = '-alt'`). Confirmado que **no requiere tocar
código fuente**: `animSuffix` es un `public var` en `Note.hx`, así que basta
un archivo de note-type data-driven:

```
// mods/qt-rewired/custom_notetypes/caramella.txt
animSuffix: '-caramella'
```

(aplicado automáticamente por `backend/NoteTypesConfig.hx` cuando
`note.noteType == 'caramella'`, sin editar `Note.hx`/`PlayState.hx`.)

Para que la animación exista hay que usar el atlas
`characters/BF/bf-qt-erect` (ya copiado a `images/`, sin usar todavía) en un
character JSON específico de la variante erect (`bf-qt-erect.json`, NO el
`bf-qt.json` actual que apunta al sprite vanilla de BF). Ese atlas SÍ trae
animaciones base completas y las variantes `-caramella`:
`export/BF idle dance` (idle), `export/left alt`/`export/right alt`
(singLEFT/singRIGHT), `alt export/down alt`/`alt export/up alt`
(singDOWN/singUP) — osea que a diferencia de `bf-qt` (solo animaciones
extra), `bf-qt-erect` es un atlas autosuficiente para toda la variante erect.

### Sierra doble/triple

La variante base de Obliterated solo usa `num_sawblades: 1` (confirmado:
las 10 entradas `sawKB` del chart base son todas `1`). La variante
**Obliterated-erect** sí usa 1 y 2 (28 eventos `sawKB`, mezcla de `1`/`2`,
sin `3` en este chart en particular). El schema real del evento
(`scripts/events/SawbladeEvent.hxc`) define 3 secuencias:

- **Single** (ya portada): alert(beat 0) → attack(beat 1) → attack-1(beat 2).
- **Double**: alert(beat 0) → attack "attack-2-1"(beat 1, 1er golpe) →
  attack "attack-2-1" otra vez(beat 2, 2do golpe) → attack-2-2(beat 3) — es
  decir, **dos ventanas de esquive separadas**, una por cada golpe, cada una
  necesita su propio input de esquive independiente.
- **Triple**: mismo patrón pero 3 golpes espaciados por beat, usando frames
  `attack-2-1`/`attack-2-2` repetidos.

Portar esto a `qtStageKiller.hx` implica generalizar `startSawSequence()`
(ya escrita para single) a un loop de N golpes en vez de la secuencia fija
de 2 timers actual, y usar los símbolos `export real/doubleAlert 1/2` y
`export real/doubleAttack 1/2` ya presentes en el atlas
`saw_mechanic/warning` (confirmado en el JSON, no copiados/usados todavía)
en lugar de `export real/alert 1/2`+`export real/attack`.
