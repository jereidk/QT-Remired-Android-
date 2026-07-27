# QT: Rewired — Port a Psych Engine v0.7.3

Mod original construido para el motor oficial moderno de FNF (`FunkinCrew/Funkin'`,
namespace `funkin.*`: `Module`/`SongEvent`/`ScriptedClass`, charts v2.0, atlas
Adobe Animate). Este engine (Psych Engine v0.7.3) es arquitectónicamente distinto,
así que nada del código/datos original se pudo copiar tal cual — todo lo de abajo
fue reconstruido usando las convenciones reales de mods de Psych (ver
`source/backend/Song.hx`, `source/objects/Character.hx`, `source/backend/StageData.hx`,
`source/backend/Mods.hx`), verificadas también contra el código fuente real de
`FunkinCrew/Funkin'` (clonado aparte) para confirmar semánticas de eventos/charts.

## Estado actual: las 7 canciones/variantes del mod, jugables

Lo que SÍ funciona (carpeta de mod, sin tocar `source/`):
- `characters/{qt,bf-qt,gf-qt,kb,bf-qt-erect,pico-qt,qt-legacy}.json` —
  personajes reconstruidos al schema `CharacterFile` de Psych. La mayoría usan
  los atlas Adobe Animate reales del mod vía el soporte nativo `flxanimate` de
  Psych; `qt-legacy` es un sparrow atlas clásico (`2021/qt.png`+`.xml`) igual
  de simple que un personaje base de Psych. Ver limitación 1 sobre qué
  personajes usan sprite vanilla en vez del atlas real del mod por falta de
  ese atlas base en el paquete del mod.
- `stages/{qtStage,qtStageKiller,qtStageCityErect,qtStageObliteratedErect,
  qtStagePico,qtStage2021}.json`+`.hx` (HScript) — anchors de personajes,
  zoom y fondos de cada stage. `qtStage` y `qtStageCityErect` sí tienen
  cutscene de fin de canción (ver más abajo); el resto todavía no.
- `data/{blissful,obliterated,blissful-erect,obliterated-erect,
  obliterated-legacy,blissful-pico,blissful-2021}/*.json` — charts convertidos
  del formato plano `{t,d,l,p,k}` del mod original al formato de secciones de
  Psych. Obliterated (base/erect/legacy) tienen **BPM variable**: se
  reconstruyó el mapeo tiempo↔beat a partir de los `timeChanges` del mod
  (redondeando cada quiebre de tempo al múltiplo de 4 beats más cercano, ya
  que Psych solo admite cambios de BPM en límites de sección).
- **Note kind `caramella`** (`custom_notetypes/caramella.txt`, una sola línea
  `animSuffix: '-caramella'`) — portado 100% data-driven, sin tocar código
  fuente, aprovechando que Psych ya trae el mecanismo de sufijo de animación
  ("Alt Animation") de fábrica. Las 73+77 notas `caramella` de Blissful-erect
  se convirtieron correctamente, igual que las notas `noanim`/`altAnim` de
  Blissful-erect/-pico (→ note kinds nativos "No Animation"/"Alt Animation").
- **Mecánica de esquivar sierras, generalizada a single/double/triple**
  (`stages/qtStageKiller.hx` y `stages/qtStageObliteratedErect.hx`): el
  evento de chart custom `sawKB` (con `value1` = cantidad de sierras) dispara
  una secuencia de N golpes espaciados 1 beat, cada uno con su propia ventana
  de esquive independiente, usando los atlas reales `saw_mechanic/warning`
  (símbolos `alert 1/2`/`attack` para single, `doubleAlert 1/2`/
  `doubleAttack 1/2` para double/triple) y `saw_mechanic/saw_assets`.
  Esquivar = tecla **Accept** en la ventana de 1 beat antes de cada golpe;
  cura 0.2 de vida por golpe esquivado, quita 1.0 (mitad de la barra) por
  golpe fallado. Verificado contra los eventos `sawKB` reales de
  Obliterated-erect/legacy (claves `num_sawblades` y `quantity`, ambas
  soportadas en el conversor).
- `songs/<cancion>/*.ogg` (7 carpetas) — audio con voces separadas por
  personaje (usa `vocals_file` de Psych; los archivos de voz con sufijo de
  variante en el mod original se renombran sin sufijo dentro de la carpeta de
  cada canción para poder reusar el mismo personaje en varias variantes).
- `weeks/QT.json` — las 7 canciones/variantes aparecen en Freeplay y Story
  Mode.
- **Eventos de cámara `FocusCamera`/`ZoomCamera` con tween real** (no el
  salto instantáneo del evento nativo "Camera Follow Pos"/"Add Camera Zoom"
  de Psych). Cada uno de los 6 stages implementa `focusCamera()`/
  `zoomCamera()` en HScript: replican exactamente la matemática de
  `PlayState.moveCamera()` (posición de personaje + `cameraPosition` propio +
  `camera_boyfriend`/`camera_opponent`/`camera_girlfriend` del stage) y
  tweenan `camFollow`/`FlxG.camera.zoom` con el mismo nombre de función de
  easing que trae el chart original (`Reflect.field(FlxEase, name)`),
  verificado contra `funkin.play.event.FocusCameraSongEvent`/
  `ZoomCameraSongEvent` reales. `game.isCameraOnForcedPos = true` evita que
  el auto-seguimiento de Psych pise el tween cada sección. Se portaron **~1027
  eventos de cámara** en total entre las 7 canciones (25-118 FocusCamera y
  36-169 ZoomCamera por canción, ver `data/*/events.json`).
- **`SetCameraBop`** (oscilación de zoom por beat) en los 6 stages: un tween
  de ida y vuelta cada N beats (parámetros `intensity,rate,offset` del chart
  original), usando `getVar('curBeat')` para saber en qué beat va la canción.
- **`changeStage`** (Obliterated/Obliterated-legacy): recolorea `tvLights`/
  `lightOverlay` entre Normal/Killer/Blue/Red — confirmado que eso es
  literalmente todo lo que hace el evento original (no cambia de escenario).
- **Keybind de esquive configurable + modos instakill/disabled**
  (`data/settings.json`, un archivo de opciones de mod estándar de Psych):
  el menú de "Mod Settings" del juego ahora tiene "Dodge Key" (rebindeable,
  teclado y gamepad) y "Sawblade Mode" (Damage/Instakill/Disabled). Leído en
  tiempo real desde las stages vía el `getModSetting()`/`keyboardJustPressed()`
  ya presets de Psych, sin tocar código fuente.
- **Prop "cars" de `qtStagePico`** con `FlxAnimate` real (`addByFrameLabel`
  sobre el timeline principal del atlas, ya que este atlas en particular no
  tiene diccionario de símbolos, solo etiquetas de frame en el timeline raíz).
- **Animación dedicada de "caramelldansen" para QT** en Blissful-erect: nuevo
  personaje `qt-erect` (atlas `QT_assets/qt-erect`, símbolo
  `qt caramelldansen full`) intercambiado mediante el evento nativo
  `Change Character` de Psych durante la ventana exacta de la sección
  (confirmado que QT no canta ninguna nota durante esos ~24s, así que el
  intercambio de personaje es seguro) y devuelto a `qt` al terminar.
- **Cutscene de intro simplificada** en Blissful (base): al terminar la
  canción por primera vez, se intercepta `onEndSong`/`Function_Stop` (mismo
  mecanismo que usaba el mod original con `hasPlayedOutro`) para mostrar un
  fundido a negro + spotlight + el sonido `qtsfx` antes de continuar
  normalmente vía `game.endSong()`. Ver limitación 3 sobre el alcance
  reducido frente al original.
- **Cutscene final de Blissful-erect, portada casi completa** (a diferencia
  de la de Blissful base, esta SÍ es fiel — `blissful-erect.hxc` tiene su
  propia `onSongEnd` totalmente distinta, con coreografía de cámara real).
  En `qtStageCityErect.hx`: intercepción de `onEndSong`/`Function_Stop` con
  guarda `hasPlayedOutro`, fade del HUD, la voz `qt_erect_ending` + música de
  fondo `outroSong-erect` a volumen 0.2, 12 pasos de cámara con
  `game.camFollow`/`FlxG.camera.zoom` tweenados (posiciones y curvas de easing
  exactas del original) vía `FlxTimer`, el intercambio de personaje `dad`
  a `qt-erect` (reusando el mismo mecanismo del note kind `caramella`) para
  reproducir su pose `erectEnding`, la pose `shoulderSwish` de BF, el sonido
  `bf_erect_shoulder_swish`, y un fundido a negro final antes de llamar de
  nuevo a `game.endSong()`. Tanto `erectEnding` (atlas `qt-erect`) como
  `shoulderSwish` (atlas `bf-qt-erect`) son animaciones por **etiqueta de
  frame** en el timeline raíz (no símbolos de diccionario), registradas en
  runtime con `addByFrameLabel` — mismo mecanismo que el prop `cars`. Se
  omiten los subtítulos (`showoff.srt`, Psych no tiene sistema nativo de
  subtítulos) y el prompt de "presiona para saltar" (ver limitación 8).
- **Corregido un bug latente de BOM UTF-8** en varios `spritemap1.json` (QT,
  sierra, GF-QT, BF-QT, BF-QT-erect) que venían con marca de orden de bytes
  del exportador de Adobe Animate — potencialmente rompía el parseo JSON de
  Haxe en runtime. Verificado y limpiado en todo el mod.

## Limitaciones conocidas / trabajo pendiente

1. **Dos personajes usan sprite vanilla en vez del atlas real del mod**,
   porque ese atlas específico es del juego base del motor moderno y no viene
   incluido en el paquete del mod (solo trae animaciones EXTRA sobre esa
   base):
   - **BF-QT (variante base)** → sprite vanilla de Boyfriend (`bf.json`).
     `bf-qt-erect` sí tiene atlas propio completo.
   - **Pico-QT** → sprite vanilla de Pico (`pico-player.json`, ya incluido en
     Psych). El atlas del mod (`characters/PICO/all`) solo trae animaciones
     de cutscene (burp, cough, numanuma), no las de canto base.
   - **Nene-QT** → **sustituida por GF-QT** (no hay sprite vanilla de Nene en
     Psych, que se basa en el juego clásico pre-Nene; el atlas del mod
     `NENE/love` tampoco trae idle/dance base, solo animaciones de cutscene).
     `qt-legacy` (2021) sí es una excepción: es un sparrow atlas *propio y
     completo* del mod (`2021/qt.png`), no vanilla.
2. **Note kind `caramella` sin diferencia visual confirmada en BF.** Se
   registró `singLEFT-caramella`/etc. apuntando a los MISMOS símbolos que
   `singLEFT`/etc. normales en `bf-qt-erect.json` (no se encontró un símbolo
   de atlas visualmente distinto para el estado "caramelldansen" de BF
   específicamente). El note kind funciona (aplica el sufijo, no rompe nada),
   pero cosméticamente puede no notarse el cambio en BF. **QT sí tiene su
   animación dedicada** ahora (ver "Notas de implementación" abajo).
3. **Cutscene de intro simplificada.** El original (`QtTransformSongOutro.hxc`)
   animaba una transformación completa de QT con un sprite de bus y
   coreografía de cámara. La versión portada (`qtStage.hx`, solo en Blissful
   base) es un placeholder honesto: fade a negro + spotlight + el sonido
   original `qtsfx` + espera + fade de vuelta, usando `onEndSong`/
   `Function_Stop` para interceptar el fin de canción una sola vez (igual que
   el `hasPlayedOutro` original) y `game.endSong()` para continuar
   normalmente después. Sin sprite de QT transformándose ni bus.
4. **`changeStage` solo recolorea, no cambia de escenario real.** Se portó
   correctamente para Obliterated/Obliterated-legacy (`tvLights`/
   `lightOverlay` cambian entre Normal/Killer/Blue/Red, que es literalmente
   todo lo que hacía el evento original — no mueve ni cambia ningún otro
   prop). `blackIn`/`cutsceneVideo`/`fadeStart` siguen sin portar.
5. **Difficulties no estándar remapeadas a easy/normal/hard.** El mod
   original usa nombres de dificultad propios por variante (`erect`/
   `nightmare` en vez de las 3 estándar); para mantener consistencia con el
   resto del week (`"difficulties": "easy,normal,hard"`), se mapeó
   `erect→(easy y el archivo sin sufijo)` y `nightmare→hard`. Cosmético: el
   selector de dificultad dirá "Easy/Normal/Hard" en vez de "Erect/Nightmare".
6. **Portrait de Story Menu genérico** (`weekCharacters` cae al personaje BF
   por defecto — no hay arte de menú específico de QT/KB/Pico convertido).
7. **`SetCameraBop` es una aproximación, no una réplica exacta.** El original
   decae el multiplicador de zoom continuamente cada frame
   (`cameraBopMultiplier` con `Math.pow(decayRate, dt)`); la versión portada
   usa un tween de ida y vuelta de duración fija por golpe. Visualmente muy
   similar, pero no es la misma curva de decaimiento.
8. **Cutscene final de Blissful-erect sin subtítulos ni skip.** Se portó toda
   la coreografía de cámara/sonido/animación (ver "Estado actual"), pero se
   omitió el archivo de subtítulos `subtitles/english/cutsceneErect/showoff.srt`
   (Psych no tiene un sistema de subtítulos nativo) y el mecanismo de
   "mantén presionado para saltar" (`skipCutscene()` del original) — la
   cutscene siempre se reproduce completa, ~14s. Solo se copió el audio en
   inglés (el original también trae una variante en español para
   `qt_erect_ending`, no incluida).
9. **Blissful-pico y Blissful-2021 no tienen cutscene final propia portada
   aún.** Blissful-pico sí tiene una en el original (referencia a un sonido
   `picoWave`, sin investigar en detalle); Blissful-2021 y Obliterated (base)
   confirmado que NO tienen ninguna cutscene de fin de canción en el script
   original (`hasPlayedOutro`/`onSongEnd` no aparecen en sus `.hx`/`.hxc`).

## Assets de origen

- `data-src/`, `images-src/` — JSON/imágenes crudas del mod original (formato
  del motor moderno), mantenidos como referencia para conversiones futuras.
  No son leídos por el engine.
- Los sprites/audio reales usados sí están copiados en `images/`, `songs/`,
  `sounds/` en las rutas que Psych espera.

## Próximos pasos sugeridos (en orden)

1. Investigar y portar la cutscene final de Blissful-pico (referencia a un
   sonido `picoWave` encontrada, no investigada en detalle todavía).
2. Cutscene de intro completa de Blissful base (sprite de QT transformándose
   + bus), en vez de la versión simplificada (fade + spotlight + sfx) que hay
   ahora — Blissful-erect ya tiene su cutscene final casi fiel (ver "Estado
   actual" y limitación 8).
3. Portrait de Story Menu específico para QT/KB/Pico (en vez de caer al
   genérico de BF).
4. `blackIn`/`cutsceneVideo`/`fadeStart` (eventos de Obliterated/legacy aún
   sin portar, relacionados con la cutscene completa del punto 2).
5. Curva de decaimiento exacta para `SetCameraBop` (actualmente es un tween
   de ida y vuelta de duración fija, no la exponencial continua del original).
6. Subtítulos y mecanismo de skip para la cutscene final de Blissful-erect
   (ver limitación 8) — requeriría un sistema de subtítulos propio en HScript
   ya que Psych no trae uno nativo.

## Notas de implementación por variante

Todas las 7 canciones/variantes del mod original están portadas. Resumen de
metadata real (`player`/`opponent`/`girlfriend`, instrumental, stage,
dificultades, BPM) y cómo quedó cada una:

| Canción-variante | `player`/`opponent`/`girlfriend` (real → portado) | `stage` | BPM |
|---|---|---|---|
| Blissful (base) | bf-qt→**BF vanilla** / qt / gf-qt | qtStage | 138 |
| Blissful-erect | bf-qt-erect (atlas propio) / qt / gf**→gf vanilla** | qtStageCityErect | 152 |
| Blissful-pico | pico-qt→**Pico vanilla** / qt / nene-qt→**gf-qt** | qtStagePico | 138 |
| Blissful-2021 | bf-qt→**BF vanilla** / qt-legacy (atlas propio) / gf-qt | qtStage2021 | 138 |
| Obliterated (base) | bf-qt→**BF vanilla** / kb (atlas propio) / gf-qt | qtStageKiller | 245 (variable) |
| Obliterated-erect | bf-qt→**BF vanilla** / kb / gf-qt (solo cambian voces) | qtStageObliteratedErect | 152→160 (variable) |
| Obliterated-legacy | bf-qt→**BF vanilla** / kb / gf-qt (solo cambian voces) | qtStageKiller (mismo) | 245 (variable) |

Anchors de personaje + `cameraZoom` de cada stage (de `data-src/stages/*.json`,
mismo schema `StageFile` de Psych):
- `qtStage`/`qtStageKiller`: bf [1040,913] cam[-175,-113] · dad [380,920]
  cam[290,-50] · gf [727,795] cam[25,165] · zoom 0.8.
- `qtStageCityErect`/`qtStageObliteratedErect`: bf [1330,1285]
  cam[-290,-150] · dad [305,1289] o [364,1282] · gf [820,1164] cam[12,30] ·
  zoom 0.585.
- `qtStagePico`: bf [1025,848] cam[-226,-110] · dad [-29,864] cam[330,-100] ·
  gf [495,786.5] cam[35,17] · zoom 0.69.
- `qtStage2021`: bf [989.5,885] cam[-100,-100] · dad [335,885] cam[150,-100] ·
  gf [751.5,787] cam[0,0] · zoom 0.92125.

### Note kind `caramella`

En el chart de Blissful-erect (`data-src/songs/blissful/blissful-chart-erect.json`)
cada nota tiene un campo `"k"` (kind) igual a `null`, `"noanim"` o
`"caramella"` — 73/77 notas (erect/nightmare) etiquetadas `caramella` entre
t≈189.9s y t≈213.6s. Funcionalmente idéntico al mecanismo de "Alt Animation"
que Psych ya trae de fábrica (`Note.hx` → `animSuffix = '-alt'`). No requiere
tocar código fuente — basta un archivo de note-type data-driven:

```
// mods/qt-rewired/custom_notetypes/caramella.txt
animSuffix: '-caramella'
```

(aplicado automáticamente por `backend/NoteTypesConfig.hx` cuando
`note.noteType == 'caramella'`.) Blissful-pico usa el kind `"altAnim"` (una
sola nota), que mapea directo al note kind nativo "Alt Animation" de Psych
sin necesitar ningún archivo extra.

Para que la animación exista se usa el atlas `characters/BF/bf-qt-erect` en
`bf-qt-erect.json` (a diferencia de `bf-qt`, que solo tiene animaciones
extra, `bf-qt-erect` es un atlas autosuficiente con idle/sing/miss reales +
las variantes `-caramella` registradas apuntando a los mismos símbolos, ver
limitación 2 sobre por qué no hay diferencia visual confirmada).

### Sierra doble/triple

La variante base de Obliterated solo usa `num_sawblades: 1` (10 eventos,
todos `1`). Obliterated-erect usa 1 y 2 (27 eventos, clave `num_sawblades`).
Obliterated-legacy también usa solo `1` pero con la clave `quantity` en vez
de `num_sawblades` — el conversor de eventos soporta ambas claves
(`v.get('num_sawblades', v.get('quantity', 1))`).

`stages/qtStageKiller.hx` (compartido por Obliterated base y legacy) y
`stages/qtStageObliteratedErect.hx` implementan `startSawSequence(numSaws)`
generalizada: N golpes secuenciales espaciados 1 beat, cada uno con su propia
ventana de esquive independiente, alternando entre los símbolos
`export real/alert 1/2`+`attack` (single) y `doubleAlert 1/2`+
`doubleAttack 1/2` (double/triple, reutilizando los mismos símbolos para el
3er golpe ya que el atlas no trae símbolos "triple" separados — así lo hacía
también el `.hxc` original).
