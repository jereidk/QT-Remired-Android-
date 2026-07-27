# QT: Rewired — Port a Psych Engine v0.7.3

Mod original construido para el motor oficial moderno de FNF (`FunkinCrew/Funkin'`,
namespace `funkin.*`: `Module`/`SongEvent`/`ScriptedClass`, charts v2.0, atlas
Adobe Animate). Este engine (Psych Engine v0.7.3) es arquitectónicamente distinto,
así que nada del código/datos original se pudo copiar tal cual — todo lo de abajo
fue reconstruido usando las convenciones reales de mods de Psych (ver
`source/backend/Song.hx`, `source/objects/Character.hx`, `source/backend/StageData.hx`,
`source/backend/Mods.hx`), verificadas también contra el código fuente real de
`FunkinCrew/Funkin'` (clonado aparte) para confirmar semánticas de eventos/charts.

## Estado actual: 4 canciones jugables (Blissful/Obliterated, base + erect)

Lo que SÍ funciona (carpeta de mod, sin tocar `source/`):
- `characters/{qt,bf-qt,gf-qt,kb,bf-qt-erect}.json` — personajes reconstruidos
  al schema `CharacterFile` de Psych, usando los atlas Adobe Animate reales
  del mod vía el soporte nativo `flxanimate` de Psych. Blissful-erect reusa
  `gf.json`/`qt.json` vanilla y solo necesitó un personaje nuevo (`bf-qt-erect`,
  ver limitación 1). Obliterated-erect no necesitó ningún personaje nuevo —
  reusa `bf-qt`/`kb`/`gf-qt` tal cual, solo cambian los archivos de voz.
- `stages/{qtStage,qtStageKiller,qtStageCityErect,qtStageObliteratedErect}
  .json`+`.hx` (HScript) — anchors de personajes, zoom y fondos de cada stage,
  sin cutscene de intro.
- `data/{blissful,obliterated,blissful-erect,obliterated-erect}/*.json` —
  charts convertidos del formato plano `{t,d,l,p,k}` del mod original al
  formato de secciones de Psych. Obliterated (base y erect) tienen **BPM
  variable**: se reconstruyó el mapeo tiempo↔beat a partir de los
  `timeChanges` del mod (redondeando cada quiebre de tempo al múltiplo de 4
  beats más cercano, ya que Psych solo admite cambios de BPM en límites de
  sección).
- **Note kind `caramella`** (`custom_notetypes/caramella.txt`, una sola línea
  `animSuffix: '-caramella'`) — portado 100% data-driven, sin tocar código
  fuente, aprovechando que Psych ya trae el mecanismo de sufijo de animación
  ("Alt Animation") de fábrica. Las 73+77 notas `caramella` de Blissful-erect
  (dificultades erect/nightmare) se convirtieron correctamente, igual que las
  2+2 notas `noanim` (→ "No Animation", note kind nativo de Psych).
- **Mecánica de esquivar sierras, generalizada a single/double/triple**
  (`stages/qtStageKiller.hx` y `stages/qtStageObliteratedErect.hx`): el
  evento de chart custom `sawKB` (con `value1` = cantidad de sierras) dispara
  una secuencia de N golpes espaciados 1 beat, cada uno con su propia ventana
  de esquive independiente, usando los atlas reales `saw_mechanic/warning`
  (símbolos `alert 1/2`/`attack` para single, `doubleAlert 1/2`/
  `doubleAttack 1/2` para double/triple) y `saw_mechanic/saw_assets`.
  Esquivar = tecla **Accept** en la ventana de 1 beat antes de cada golpe;
  cura 0.2 de vida por golpe esquivado, quita 1.0 (mitad de la barra) por
  golpe fallado. Verificado contra los 27 eventos `sawKB` reales de
  Obliterated-erect (mezcla de 1 y 2 sierras).
- `songs/{blissful,obliterated,blissful-erect,obliterated-erect}/*.ogg` —
  audio con voces separadas por personaje (usa `vocals_file` de Psych; los
  archivos de voz "-erect" se renombran sin sufijo dentro de la carpeta de
  cada canción para poder reusar el mismo personaje en varias variantes).
- `weeks/QT.json` — las 4 canciones aparecen en Freeplay y Story Mode.

## Limitaciones conocidas / trabajo pendiente

1. **BF-QT (variante base) usa el sprite vanilla de Boyfriend.** El atlas
   "characters/BF/bf-qt" que trae el mod solo contiene animaciones EXTRA
   (pre dance, dodge, saw hit) — las animaciones base de canto/idle de BF-QT
   en el mod original reusan el atlas del BF del motor moderno oficial, que
   no viene incluido en este mod. Por eso BF-QT (base) se ve como el BF
   clásico. **La variante erect SÍ tiene atlas propio completo**
   (`bf-qt-erect`, con idle/sing/miss reales), usado en `bf-qt-erect.json`.
2. **Note kind `caramella` sin diferencia visual confirmada.** Se registró
   `singLEFT-caramella`/etc. apuntando a los MISMOS símbolos que
   `singLEFT`/etc. normales en `bf-qt-erect.json` (no se encontró un símbolo
   de atlas visualmente distinto y claramente rotulado para el estado
   "caramelldansen" de BF specificamente, a diferencia de QT que sí tiene
   `qt caramelldansen full` en su propio atlas `qt-erect`, sin portar — ver
   punto 3). El note kind funciona (aplica el sufijo, no rompe nada), pero
   cosméticamente puede no notarse el cambio en BF.
3. **QT no cambia a su animación de "caramelldansen" dedicada.**
   Blissful-erect reusa el `qt.json` normal (mismo atlas `QT_assets/qt`) para
   simplicidad — el atlas `QT_assets/qt-erect` (con `qt caramelldansen full`,
   `erectIntro1/2`, `erectEnding`) está identificado pero no portado.
4. **Sin cutscene de intro** en ninguna canción (timeline con tweens/cámara
   del mod original — `QtTransformSongOutro`, bus, etc.).
5. **Eventos de cámara sin portar** (`FocusCamera`/`ZoomCamera`/
   `SetCameraBop` con easing custom — ~84 en Blissful, ~291 en
   Blissful-erect, ~190 en Obliterated-erect) — Psych sigue la cámara
   automáticamente al cantante activo por defecto. Sí se portaron
   `ScrollSpeed` (→ "Change Scroll Speed" nativo, instantáneo) y `sawKB` en
   ambas variantes de Obliterated.
6. **`changeStage` sin portar** (Obliterated cambia de escenario durante la
   canción en el original; aquí el fondo se queda fijo por variante).
   `blackIn`/`cutsceneVideo`/`fadeStart` tampoco están portados.
7. **Faltan Blissful-pico, Blissful-2021, Obliterated-legacy.** Investigación
   de metadata/personajes/stage ya hecha (ver tabla más abajo), pendiente de
   implementar con el mismo patrón usado para erect.
8. **Difficulties "erect"/"nightmare" remapeadas a easy/normal/hard.** El mod
   original usa nombres de dificultad propios por variante en vez de las 3
   estándar; para mantener consistencia con el resto del week (que usa
   `"difficulties": "easy,normal,hard"`), se mapeó `erect→(easy y el archivo
   sin sufijo)` y `nightmare→hard`. Cosmético: el selector de dificultad
   dirá "Easy/Normal/Hard" en vez de "Erect/Nightmare".
9. **Solo el hit de sierra en modo daño instantáneo.** El modo "instakill" /
   "disabled" configurable por el jugador (guardado en `Save`) del mod
   original no está portado — siempre resta la mitad de vida por golpe.
10. **Portrait de Story Menu genérico** (`weekCharacters` cae al personaje BF
    por defecto — no hay arte de menú específico de QT/KB convertido).
11. **Tecla de esquive fija** (Accept/Enter), no configurable como en el mod
    original (que guardaba un keybind custom en las opciones).

## Assets de origen

- `data-src/`, `images-src/` — JSON/imágenes crudas del mod original (formato
  del motor moderno), mantenidos como referencia para conversiones futuras.
  No son leídos por el engine.
- Los sprites/audio reales usados sí están copiados en `images/`, `songs/`,
  `sounds/` en las rutas que Psych espera.

## Próximos pasos sugeridos (en orden)

1. Blissful-pico y Blissful-2021 (personajes nuevos: pico-qt/nene-qt/qt-legacy
   — ver tabla abajo), y Obliterated-legacy (reusa `qtStageKiller`, mismo
   patrón que Obliterated-erect: solo cambian los archivos de voz).
2. Portar los eventos de cámara a "Focus Character"/"Add Camera Zoom" nativos
   de Psych (o custom-event HScript si se quiere el easing exacto) — pendiente
   en las 4 canciones ya portadas.
3. Animación dedicada de "caramelldansen" para QT (atlas `qt-erect`, símbolo
   `qt caramelldansen full`) en vez de reusar el atlas base durante
   Blissful-erect.
4. `changeStage` (recolorear props vía `eventCalled` en vez de cambiar de
   escenario real) y cutscene de intro.
5. Keybind configurable para esquivar + modos instakill/disabled desde
   opciones del mod.

## Investigación: variantes erect/pico/legacy, `caramella`, sierra doble/triple

Blissful-erect y Obliterated-erect ya están implementados (ver arriba);
`caramella` y la sierra doble/triple también. Queda pendiente Blissful-pico,
Blissful-2021 y Obliterated-legacy. Detalle investigado contra `data-src/`
(metadata/charts crudos del mod original) y contra `FunkinCrew/Funkin'`
(clonado aparte para confirmar semánticas).

### Variantes por canción (metadata real)

| Canción-variante | `player`/`opponent`/`girlfriend` | `instrumental` | `stage` | dificultades | BPM | Estado |
|---|---|---|---|---|---|---|
| Blissful (base) | bf-qt / qt / gf-qt | — | qtStage | easy,normal,hard | 138 | ✅ portado |
| Blissful-erect | bf-qt-erect / qt / **gf** (vanilla) | `erect` | qtStageCityErect | erect,nightmare | 152 | ✅ portado |
| Blissful-pico | **pico-qt** / qt / **nene-qt** | `pico` | qtStagePico | easy,normal,hard | 138 | ⬜ pendiente |
| Blissful-2021 | bf-qt / **qt-legacy** / gf-qt | — | qtStage2021 | easy,normal,hard | 138 | ⬜ pendiente |
| Obliterated (base) | bf-qt / kb / gf-qt | — | qtStageKiller | easy,normal,hard | 245 (variable) | ✅ portado |
| Obliterated-erect | bf-qt / kb / gf-qt (voces `bf-erect`/`kb-erect`) | `erect` | qtStageObliteratedErect | erect,nightmare | 152→160 (variable) | ✅ portado |
| Obliterated-legacy | bf-qt / kb / gf-qt | `legacy` | qtStageKiller (mismo stage) | easy,normal,hard | 245 (variable) | ⬜ pendiente |

Obliterated-legacy es el más simple de los 3 pendientes: mismo stage, mismos
personajes, solo requiere convertir su chart (`obliterated-metadata-legacy.json`
+ `obliterated-chart-legacy.json`, ya en `data-src/`) y copiar
`Inst-legacy.ogg`/`Voices-bf-qt-legacy.ogg`/`Voices-kb-legacy.ogg` — mismo
patrón exacto que Obliterated-erect. Pico y 2021 requieren personajes nuevos
(pico-qt, nene-qt, qt-legacy) que aún no se investigaron en detalle
(animaciones/atlas disponibles).

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
