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
  zoom y fondos de cada stage. `qtStage` y `qtStageCityErect` tienen cutscene
  de INICIO **y** de FIN de canción; `qtStagePico` solo tiene la de INICIO
  (antes del countdown); `qtStageKiller` tiene una apertura simple (fundido
  desde negro, sin coreografía) más la cinemática de mitad de canción
  (`fadeStart`/`cutsceneVideo`/`cutsceneVideoOut`); `qtStageObliteratedErect`
  tiene su propia apertura (fundido de 12.5s) **y** cinemática de mitad de
  canción completa — dos videos, fundidos de cámara/HUD, cambio de layout y
  color grading en toda la canción (ver limitación 12 para el detalle
  técnico y las partes que NO se pudieron portar); `qtStage2021` no tiene
  ninguna (confirmado, ver limitación 9).
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
  Mode. **`images/storymenu/QT.png`** (la cápsula estática que Psych muestra
  en la lista de semanas del Story Menu, `MenuItem.hx`) faltaba por completo
  hasta esta revisión — probablemente un bug real, no solo cosmético
  (`Paths.image()` devuelve `null` en vez de tirar excepción cuando no
  encuentra el archivo, pero `MenuItem` no chequea null antes de usar el
  gráfico). Se resolvió copiando el asset `storymenu/titles/weekqt.png` del
  paquete original (422×94, misma proporción que las cápsulas vanilla) a esa
  ruta — el archivo ya estaba disponible, antes se había concluido
  erróneamente que "no tenía a dónde ir" (ver limitación 6).
- **`scripts/gameOverQuotes.hx`** (script global, no atado a ningún stage
  particular — se carga para las 7 canciones vía el mismo mecanismo de
  `scripts/` que usa Psych para cualquier mod, `Mods.directoriesWithFile(...,
  'scripts/')` en `PlayState.hx`). Ported desde `GameOverSubtitles.hxc`: al
  morir, el boyfriend actual (`bf-qt` o `pico-qt`, los únicos dos que usa
  este mod) dice una línea de voz al azar (`sounds/qtgameover/english/...`,
  7 líneas para bf-qt y 6 para pico-qt) con su subtítulo correspondiente,
  usando el hook nativo `onGameOverStart` de Psych (`callOnScripts` desde
  `substates/GameOverSubstate.hx`, confirmado leyendo el código fuente real
  de Psych) y `GameOverSubstate.instance.add()` para mostrar el texto sobre
  la pantalla de Game Over. Solo se portaron las líneas en inglés (mismo
  criterio ya aplicado a los subtítulos de Blissful-erect — limitación 8);
  el modelo/animaciones de muerte del personaje se dejaron como el `bf-dead`
  vanilla de Psych en vez de un death-pose propio de QT (ese arte no forma
  parte de lo ya copiado a este mod). La duración en pantalla de cada línea
  es la duración fija de sus `.srt` (en `data-src/subtitles/`, solo
  referencia) en vez de trackear la posición real de reproducción, mismo
  criterio que `showSubtitle()` en los stages.
- **Popup "DODGED!"** al esquivar una sierra con éxito (`qtStageKiller.hx`/
  `qtStageObliteratedErect.hx`'s `tryDodge()`), ported desde
  `SawbladeAndDodgeModule.hxc`'s `playState.popUpScore("dodged")`. Implementado
  como un sprite standalone (`images/ui/popup/funkin/dodged.png`) en vez de
  enganchar el pipeline real de popups de juicio de Psych (`PlayState.
  popUpScore`), que está atado a combo/precisión de notas reales — usarlo
  para un evento que no es una nota real arriesgaba romper esas cuentas sin
  necesidad. Posicionado/animado igual que los popups nativos de Psych
  (`placement = FlxG.width * 0.35`, `screenCenter()` + offset, ver
  `PlayState.hx:popUpScore`): sube y se desvanece en 0.6s.
- **Música de Game Over distinta al morir por un instakill de sierra**
  (Obliterated/Obliterated-legacy/Obliterated-erect, `applySawHit()` en
  `qtStageKiller.hx`/`qtStageObliteratedErect.hx`), ported desde
  `SawbladeAndDodgeModule.hxc`'s `executeInstantKill()`
  (`GameOverSubState.musicSuffix = '-sawblade'`). Psych no tiene el concepto
  de "sufijo de música" del original, pero SÍ expone
  `GameOverSubstate.loopSoundName`/`endSoundName` como `public static`
  directamente asignables — y `GameOverSubstate.resetVariables()` (que los
  resetearía al default de la canción) solo corre una vez en
  `PlayState.create()`, mucho antes de que esto pueda dispararse, así que
  asignarlos justo antes de matar al jugador (mismo momento exacto que el
  original) queda pegado para ese intento. Los archivos de audio
  (`gameOver-sawblade.ogg`/`gameOverEnd-sawblade.ogg`) ya estaban en el
  paquete original sin portar — copiados a `music/`. Los campos
  `blueBallSuffix`/`mustNotExit`/`blueballed` del original (que además
  bloquean la salida normal de la pantalla de Game Over y piden mantener
  presionado para confirmar) NO se portaron — no existen en el
  `GameOverSubstate` de Psych en absoluto (confirmado leyendo el código
  fuente real), y bloquear la tecla BACK específicamente no se puede desde
  HScript porque `GameOverSubstate.update()` nunca revisa el valor que
  devuelve `callOnScripts('onUpdate', ...)` (ver limitación 15 para el
  detalle completo, incluida la corrección sobre qué es realmente un límite
  de Psych y qué era solo un asset faltante). En su lugar, `onGameOverStart`
  (que SÍ es un hook real, confirmado — ya lo usa `scripts/
  gameOverQuotes.hx`) dispara un shake de cámara y un tinte rojo con blend
  `MULTIPLY` que se desvanece sobre `GameOverSubstate.instance`, como
  sustituto del jumpscare del original con el mismo espíritu dramático, sin
  inventar assets que no existen en el paquete.
- **Gesto de "final feliz" cerca del clímax de Blissful/Blissful-erect/
  Blissful-pico, vía el evento nativo `PlayAnimation` del chart original**
  (`onEvent`/`playCharAnim` en `qtStage.hx`/`qtStageCityErect.hx`/
  `qtStagePico.hx`, evento sintético `PlayAnim` inyectado en `events.json` a
  los timestamps exactos del chart original). Encontrado al revisar los
  scripts de personaje (`characters/qt.hxc`/`bf-qt.hxc`/`gf-qt.hxc`) que
  faltaban por cruzar contra el port: dad(QT) hace `preDance`→`cheer`,
  gf(GF-QT) `preDance`→`cheer`, bf(BF-QT) el clásico `hey`. Lo interesante:
  **`preDance`/`cheer` de QT y `preDance` de GF-QT ya estaban en los atlas
  que este mod YA había copiado** (`export/qt pre dance`/`export/qt hey` en
  `QT_assets/qt`, `export/gf pre dance` en `gf-qt`) — solo hacía falta
  registrarlos en los `characters/*.json` (agregado a `qt.json`/`gf-qt.json`)
  y disparar el evento; cero riesgo, mismo patrón `animType: "symbol"` ya
  usado en el resto de cada uno de esos archivos. Lo mismo para
  `preDance-erect` de dad durante la ventana de caramelldansen de
  Blissful-erect (símbolo `qt transition`, agregado a `qt-erect.json`) — el
  `cheer` final de esa misma ventana (t≈213.2s, todavía dentro del swap a
  qt-erect) queda sin efecto porque el atlas `qt-erect` no tiene un símbolo
  equivalente (Flixel/FlxAnimate ignoran un nombre de animación no
  registrado en vez de tirar excepción, así que no rompe nada, solo no se ve
  nada ese ~1s antes de volver a `qt` normal). **NO portado**: el `preDance`
  de bf(BF-QT) — vive en un atlas Animate separado
  (`characters/BF/bf-qt`, ya copiado en este mod para otro fin) que
  `bf-qt.json` no puede referenciar porque está armado sobre el atlas
  Sparrow vanilla de Psych (ver limitación 1) — se podría portar como
  overlay standalone (mismo patrón de `picoOverlay`/`tsundereOverlay`) pero
  se descartó por el riesgo/complejidad extra para una pose transicional
  breve. En Blissful-pico tampoco se portaron los propios de esa canción
  para boyfriend (`cough`/`burp-long`/`preDance`/`hey` de pico-qt, que ya
  usa sprite vanilla de Pico sin ninguna de esas poses — limitación 1) ni
  para girlfriend (`huh`/`combo50`, sin símbolo equivalente en el atlas de
  `gf-qt`).
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
- **`SetCameraBop`** (oscilación de zoom por beat) en los 6 stages, con la
  curva de decaimiento exponencial real de FunkinCrew
  (`cameraBopMultiplier = lerp(1, cameraBopMultiplier, 0.95^(elapsed*60))`
  cada frame, leída directo de `PlayState.hx`/`SetCameraBopSongEvent.hx`) Y
  un "zoom base" (`camZoomState.zoom`) separado del multiplicador de bop,
  igual que el original — ver limitación 7 para el detalle del refactor.
- **`changeStage`** (Obliterated/Obliterated-legacy): recolorea `tvLights`/
  `lightOverlay` entre Normal/Killer/Blue/Red — confirmado que eso es
  literalmente todo lo que hace el evento original (no cambia de escenario).
- **`blackIn`** (Obliterated/Obliterated-legacy, último evento de ambos
  charts): `blackScreen.alpha = 1` instantáneo en `qtStageKiller.hx` — igual
  de simple en el original.
- **`fadeStart`/`cutsceneVideo`/`cutsceneVideoOut`** (Obliterated/
  Obliterated-legacy): el video real (`videos/cutscene.mp4`) reproducido
  SUPERPUESTO sobre el gameplay en vivo, portado usando `hxCodec` directo
  desde HScript — ver limitación 4 para el detalle técnico y el riesgo
  aceptado.
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
- **Cutscene final de Blissful (base), portada casi completa** (reemplaza la
  versión simplificada de antes). Portada de `blissful.hxc`'s `onSongEnd()` +
  `QtTransformSongOutro.hxc` — resultó ser mucho más simple de lo que
  parecía por el nombre: no hay sprite de bus, es solo dad (QT) reemplazado
  por un `FlxAnimate` standalone que reproduce el símbolo `qt transform` del
  atlas propio del mod (`QT_assets/qtCutscene`, atlas Adobe Animate con
  diccionario de símbolos real esta vez — `addBySymbol` directo, no hace
  falta `addByFrameLabel`), insertado en la lista de renderizado justo debajo
  de las capas de fundido (`game.insert`) para que aparezca donde estaba QT.
  En `qtStage.hx`: mismo patrón `onEndSong`/`Function_Stop`/guarda
  `hasPlayedOutro`, fundido del HUD, zoom de cámara a 0.68 (valor absoluto
  literal del original, no un multiplicador del zoom del stage), el sonido
  `qtsfx`, tween de cámara al punto de foco de dad, las mismas capas de
  fundido (`lightOverlay`/`blackScreen`/`spotLight`/`redScreen`) que ya
  existían en el stage, un `camera.shake` + fundido a blanco, y finalmente
  `game.endSong()`. Subtítulos y skip-key omitidos (igual que en las otras
  cutscenes) — ver limitación 3.
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
- **Cutscene de INTRO de Blissful-erect (recién descubierta y portada)** —
  `blissful-erect.hxc` también tiene su propio `onCountdownStart`, separado
  de la de fin de canción, que se me había pasado por completo en una
  revisión anterior. Portada en el mismo `qtStageCityErect.hx` vía
  `onStartCountdown`/`Function_Stop` (guarda `hasPlayedIntroCutscene`): fade
  desde negro, música `introSong-erect` a volumen 0.2, 8 pasos de cámara,
  las voces `qt_erect_intro_1`/`qt_erect_intro_2` + `bf_erect_yeah`, las
  poses `erectIntro1`/`erectIntro2` de dad (de nuevo vía intercambio a
  `qt-erect`, **revertido a `qt` al terminar** para no romper el gameplay
  real que sigue) y `superHey` de BF (todas etiquetas de frame,
  `addByFrameLabel`). Además, mientras investigaba esto encontré y porté dos
  detalles más del script que no tenían nada que ver con la cutscene en sí:
  - **`pinkFlash`**: un overlay rosa de pantalla completa que se dispara una
    vez en la cutscene de intro y 3 veces más durante el gameplay normal
    (`gameplayFlashTimes`, comparado contra `Conductor.songPosition` en
    `onUpdate`, igual que el original).
  - **Atenuado del strumline del oponente** durante la ventana de
    caramelldansen (beats 221→348 y 478→544, alpha 0.3↔1) — Psych representa
    el strumline como un grupo de notas individuales (`opponentStrums`), no
    un solo objeto como el original, así que se tweenea cada miembro.

  No se portó `danceQT`/`QTErectDanceSprite` (un sprite overlay separado que
  el original usa para el efecto visual de caramelldansen) porque este mod
  ya resuelve esa sección con el intercambio de personaje a `qt-erect`, un
  enfoque distinto pero funcional — ver "Note kind `caramella`" más abajo.
- **Cutscene de intro de Blissful-pico**, portada desde `blissful-pico.hxc`'s
  `onCountdownStart()` — a diferencia de las otras dos (que interceptan el
  FIN de canción), esta corre ANTES del countdown real, interceptado vía
  `onStartCountdown`/`Function_Stop` (mismo patrón, hook distinto — Psych
  también soporta cancelar el countdown así). En `qtStagePico.hx`: fade
  desde negro, música `introSong-pico` a volumen 0.1, coreografía de cámara
  (mismas fórmulas de foco que usa `PlayState.moveCamera` nativo de Psych
  para dad/boyfriend, replicadas para calcular los puntos de foco exactos del
  original), la pose `still`→`intro` de dad (etiquetas de frame en el atlas
  `qt` ya existente, sin intercambio de personaje esta vez), el sonido
  `hi_cutie`, y el sonido `picoWave`. La pose `introbl` de BF se muestra con
  un `FlxAnimate` standalone cargado del atlas propio del mod
  (`characters/PICO/all`, que sí trae esta pose, a diferencia del atlas base
  de canto que falta — ver limitación 1) posicionado en el ancla de BF más el
  offset original — ver limitación 10 sobre la precisión de este overlay. Al
  terminar, llama de nuevo a `game.startCountdown()` (guard
  `hasPlayedIntroCutscene`, mismo patrón que `hasPlayedOutro`).
- **Cutscene de intro de Blissful (base), recién descubierta y portada** —
  `blissful.hxc` TAMBIÉN tiene su propio `onCountdownStart` (además del
  `onSongEnd` ya portado), básicamente la misma plantilla que la de
  Blissful-pico (mismo patrón `still`→`intro` de dad, mismo `hi_cutie`) pero
  sin la pose de BF. Portada en `qtStage.hx` vía `onStartCountdown`: fade
  desde negro, música `introSong-default`, coreografía de cámara, pose de
  dad, sonido `hi_cutie`.
- **Apertura de Obliterated (base/legacy) con fundido desde negro** —
  `obliterated.hxc`'s `onCountdownStart`/`onSongStart`/`onSongRetry`.
  Portada en `qtStageKiller.hx`: pantalla negra al empezar, snap de cámara,
  fundido a 0 en 5s cuando arranca el audio real, `game.skipCountdown` para
  saltar directo a la canción (ver limitación 11 sobre la pose de BF
  omitida).
- **Portrait de QT en el Story Menu** (`images/menucharacters/qt.json`,
  atlas Sparrow real del mod `images/storymenu/props/QT.xml`+`.png`, con
  animaciones `qt_idle`/`qt_hey` — ver limitación 6 sobre el `scale`
  estimado sin verificación visual).
- **Transformación de dad a mitad de Blissful-2021** (`qt-legacy` →
  `qt-kb-legacy`, un tercer personaje "QT + KillerByte (Legacy)"). A
  diferencia de las otras transformaciones del mod, esta es un atlas Sparrow
  clásico genuino y autosuficiente (`2021/qt-kb.png`+`.xml`, igual de simple
  que `qt-legacy` — nada de `addByFrameLabel`/intercambio de atlas Animate
  necesario). En el original (`blissful-2021.hx`) el intercambio está
  hardcodeado a `onBeatHit(beat==287)`, no es un evento del chart; portado
  como un evento nativo `Change Character` inyectado directamente en
  `events.json` en el tiempo equivalente (287 beats × 60000/138 BPM ms —
  esta canción tiene tempo constante, sin cambios de BPM). Es un intercambio
  de un solo sentido (no vuelve a `qt-legacy`), igual que el original.
- **HUD "Kade Engine 2021" de Blissful-2021** (`qtStage2021.hx`), ported
  desde `blissful-2021.hx`: reemplaza el `scoreTxt` nativo de Psych
  (oculto, no destruido) por un texto propio con
  `NPS: N | Score: X | Combo Breaks: Y | Accuracy: Z% | (ranking) rango.`,
  usando tallies propios de sick/good/bad/shit/missed (Psych no tiene un
  equivalente a `Highscore.tallies` en vivo, solo persistencia de high
  score entre sesiones) alimentados desde `goodNoteHit(note)`/
  `noteMiss(note)` — `note.rating` y `note.strumTime` confirmados
  disponibles ahí vía lectura directa de `PlayState.popUpScore`. Incluye el
  popup de diferencia en ms por nota (coloreado según el juicio) y el
  watermark `<nombre de canción> <dificultad> - KE 1.4.2`. Ver limitación
  13 sobre qué partes del original no se portaron (toggles avanzados,
  ranking con colores, y el simulador de lag a propósito).
- **Subtítulos de las 4 cutscenes** (Blissful base/pico intro, Blissful
  erect intro/final) — los 5 archivos `.srt` del original (`hi-cutie` ×2,
  `alright-cutie`, `well-see`, `showoff`) solo tenían 1-2 líneas cortas cada
  uno, así que en vez de parsear `.srt` en runtime se hardcodearon como
  pares texto+duración (ya convertidos a tiempo relativo a cada cutscene) en
  una función `showSubtitle()` compartida por archivo de stage. Activados/
  desactivados con la opción de mod "Show Subtitles" (`data/settings.json`,
  `qtSubtitles`, activada por defecto) ya que Psych no tiene una preferencia
  nativa de subtítulos como el `Preferences.subtitles` del original. Solo en
  inglés — los subtítulos en español del original no se incluyeron (ver
  limitación 8).
- **Prompt de skip para las 4 cutscenes** ("Hold [ACCEPT] to skip", dos
  pasos igual que el original) — ver limitación 14 para el detalle y el
  único caso borde conocido (fundidos de cámara activos durante el skip).
- **Corregido un bug latente de BOM UTF-8** en varios `spritemap1.json` (QT,
  sierra, GF-QT, BF-QT, BF-QT-erect, PICO/all) y en dos atlas Sparrow más
  (`storymenu/props/QT.xml`, `2021/qt-kb.xml`) que venían con marca de
  orden de bytes del exportador de Adobe Animate — potencialmente rompía el
  parseo JSON/XML de Haxe en runtime. Verificado y limpiado en todo el mod.

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
3. **Cutscenes de Blissful (base), ahora con prompt de skip.** A diferencia
   de lo que se pensaba antes (un supuesto sprite de "bus"), el original
   (`blissful.hxc` + `QtTransformSongOutro.hxc`) resultó ser más simple: solo
   QT reemplazada por el sprite `qt transform` + coreografía de cámara +
   fundidos de color en la cutscene final (que nunca tuvo subtítulos en el
   original). La de intro sí los tiene (`hi-cutie.srt`). Ambas ya están
   completas, incluido el prompt "Hold [ACCEPT] to skip" (ver "Estado
   actual" y limitación 14 sobre el único caso borde que queda).
4. **`changeStage` solo recolorea, no cambia de escenario real.** Se portó
   correctamente para Obliterated/Obliterated-legacy (`tvLights`/
   `lightOverlay` cambian entre Normal/Killer/Blue/Red, que es literalmente
   todo lo que hacía el evento original — no mueve ni cambia ningún otro
   prop). `blackIn` también está portado (`qtStageKiller.hx`, es el último
   evento de ambos charts — un simple `blackScreen.alpha = 1` instantáneo, ni
   siquiera tenía tween en el original).
   **`cutsceneVideo`/`cutsceneVideoOut`/`fadeStart` SÍ se portaron**, usando
   `hxcodec.flixel.FlxVideo` importado directo en `qtStageKiller.hx`
   (`import hxcodec.flixel.FlxVideo;`, igual que ya se hacía con
   `openfl.display.BlendMode` — HScript soporta `import` nativo de cualquier
   clase compilada, no hace falta que Psych la registre explícitamente).
   Se clonó el código fuente real de `hxCodec` (pineado a `"main"` en
   `hmm.json`, `haxelib.json` reporta versión `3.0.2`) para confirmar la API
   exacta antes de escribir esto: `FlxVideo extends Video extends Bitmap` (un
   `Bitmap` de OpenFL puro, no un `FlxSprite` — se auto-agrega al stage vía
   `FlxG.addChildBelowMouse(this)` en el constructor, así que queda por
   encima de ambas cámaras del juego sin necesitar `game.add()`), con
   `play(location, loop)`/`pause()`/`stop()`/`onEndReached` tal cual se
   usan acá. `Paths.video('cutscene')` resuelve a
   `mods/qt-rewired/videos/cutscene.mp4` (copiado del paquete original).
   `fadeStart` atenúa el HUD (`fadeHud`) y funde `blackScreenVideo` a negro
   detrás del video; `cutsceneVideo` reproduce el clip y atenúa
   `game.playerStrums` (a 0.67, notas visibles pero discretas, gameplay
   sigue activo — igual que el original); `cutsceneVideoOut` restaura todo.
   **Riesgo aceptado explícitamente**: al ser un `import` de nivel superior
   en un archivo compartido por 2 de las 7 canciones (`qtStageKiller.hx`,
   usado por Obliterated base y legacy), si `hxCodec` no resolviera en el
   build real (versión distinta, plataforma sin soporte, semántica de
   `import` de HScript distinta a la del compilador principal) rompería el
   script entero, no solo el video — no se pudo compilar/ejecutar el juego
   en este entorno para verificarlo en la práctica. El usuario decidió
   dejarlo así de todas formas, dado que el repo apunta a Android/mobile y
   `Project.xml` define `VIDEOS_ALLOWED` para builds mobile/desktop. **Lo
   que NO se portó**: la suspensión del ghost-tap-miss durante el video
   (`isOnVideo` en el original) — Psych llama `noteMissPress` DESPUÉS de
   aplicar la penalización del miss, así que no hay forma de cancelarla
   desde el stage script.
5. **Difficulties no estándar remapeadas a easy/normal/hard.** El mod
   original usa nombres de dificultad propios por variante (`erect`/
   `nightmare` en vez de las 3 estándar); para mantener consistencia con el
   resto del week (`"difficulties": "easy,normal,hard"`), se mapeó
   `erect→(easy y el archivo sin sufijo)` y `nightmare→hard`. Cosmético: el
   selector de dificultad dirá "Easy/Normal/Hard" en vez de "Erect/Nightmare".
6. **Portrait de Story Menu solo para QT, y sin verificación visual.** El
   paquete del mod trae un atlas Sparrow real para esto
   (`images/storymenu/props/QT.xml`+`.png`, con `qt_idle`/`qt_hey` — el
   único personaje de la semana que lo tiene), portado a
   `images/menucharacters/qt.json` (`weekCharacters: ["qt","bf","gf"]`, slots
   BF/GF usan los personajes de menú vanilla de Psych ya que no hay arte
   propio para ellos en el mod). El `scale: 0.65` es una estimación por
   proporción de tamaño de frame contra `Menu_BF` — no se pudo verificar
   visualmente en este entorno (no hay forma de compilar/ejecutar el juego
   acá), así que puede necesitar ajuste. **Corrección de una revisión
   posterior**: se había concluido antes que `images/storymenu/titles/
   weekqt.png` "no tenía a dónde ir" porque Psych no tiene un slot de imagen
   para el título de semana - error. Leyendo `source/objects/MenuItem.hx` y
   `source/states/StoryMenuState.hx` se confirmó que la CÁPSULA de la lista
   de semanas (lo que se ve ANTES de entrar a la semana, distinto del
   `MenuCharacter` de abajo) es `loadGraphic(Paths.image('storymenu/' +
   weekName))` — una imagen estática simple, `images/storymenu/QT.png` en
   este mod (`weekName` sale del nombre de archivo `weeks/QT.json`) — y este
   archivo **nunca se había copiado**. `Paths.image()` devuelve `null` si no
   encuentra el archivo (con un trace de advertencia, no explota ahí mismo),
   pero `MenuItem` no chequea null antes de usar el gráfico — es decir que
   el Story Menu probablemente rompía o mostraba basura cada vez que este
   mod estaba activo, no solo al entrar a esta semana puntual sino
   potencialmente al abrir el Story Menu en general (el bucle que arma
   `grpWeekText` itera TODAS las semanas cargadas). Se resolvió copiando
   exactamente ese `weekqt.png` (422×94, proporción parecida a las cápsulas
   vanilla como `week3.png` de 358×89) a `images/storymenu/QT.png` — el
   asset ya estaba ahí, solo hacía falta ponerlo en la ruta que Psych
   realmente lee.
7. **`SetCameraBop` ya replica el modelo del original al completo** (zoom
   "base" separado del multiplicador de bop, igual que
   `zoomPlusBop = currentCameraZoom * cameraBopMultiplier` en
   `PlayState.hx`). Se separó `camZoomState.zoom` (lo que fijan
   `zoomCamera()`/`tweenCamZoomAbs()`/cada cutscene) de
   `cameraBopMultiplier`, combinándolos recién cada frame en
   `applyCameraZoom()` — ya no hace falta pausar el bop mientras un
   `ZoomCamera` tiene un tween activo, ambos sistemas conviven sin pelear
   por `FlxG.camera.zoom`. Este cambio tocó los ~18 lugares que escribían
   `FlxG.camera.zoom` directamente en las 6 stages (a diferencia de casi
   todo el resto del port, que fue código nuevo aditivo) — el riesgo real
   era la inicialización de `camZoomState.zoom` en `onCreate()` de cada
   stage (copiando `game.defaultCamZoom` antes del primer frame): si eso
   falla, el zoom de cámara se rompe en el gameplay normal de las 7
   canciones, no solo en una cutscene puntual. Se verificó con cuidado que
   las 6 stages lo inicializan correctamente y que no queda ningún escrito
   directo a `FlxG.camera.zoom` fuera de `applyCameraZoom()`.
8. **Las dos cutscenes de Blissful-erect (intro y final), ahora con
   skip.** Se portó toda la coreografía de cámara/sonido/animación/
   subtítulos de ambas, más el prompt "Hold [ACCEPT] to skip" (ver "Estado
   actual" y limitación 14). Solo se copió el audio en inglés (el original
   también trae variantes en español para varias de estas líneas, no
   incluidas — los subtítulos en español tampoco). Además, la pose
   `erectIntro1` de dad no se congela en el frame 0 como en el original (que
   la pausa 0.9s antes de reproducirla completa) — acá simplemente se
   reproduce dos veces seguidas, un detalle cosmético menor (no se pudo
   verificar si pausar un `FlxAnimate` a mitad de reproducción es seguro en
   esta API sin poder compilar/ejecutar el juego).
9. **Blissful-2021 confirmado sin ninguna cutscene** — no aparecen
   `hasPlayedOutro`/`onSongEnd`/`onCountdownStart` en su `.hx`, no falta nada
   por portar ahí. Obliterated (base) sí tenía algo (ver "Estado actual" y
   limitación 11) y Obliterated-erect tiene bastante más (ver limitación 12).
10. **Overlay de la pose `introbl` de BF en la cutscene de Blissful-pico no
    es pixel-perfect.** `pico-qt` usa el sprite vanilla de Pico para el
    gameplay normal (limitación 1), así que esta pose (que sí viene en el
    atlas propio del mod) se muestra con un `FlxAnimate` standalone
    superpuesto, posicionado en `bf.x/bf.y` + el offset original
    `(55, 16.87)` — una aproximación razonable pero no una réplica exacta de
    cómo se vería con el rig Animate real del motor moderno (proporciones/
    pivote pueden diferir levemente; no hay margen real para mejorar esto
    sin poder ver el resultado, ya que ya usa el offset original tal cual).
    **El bop de GF sí se portó**: 18 llamadas a `gf.dance()` cada
    `60/103` segundos (103 BPM, igual que el original) vía
    `scheduleCutsceneTimer`, en vez del `Conductor` secundario del original
    (el `Conductor` principal de Psych todavía no corre durante esta
    cutscene previa a la canción).
11. **Apertura de Obliterated (base/legacy) sin la pose de BF congelada.**
    Se portó el fundido desde negro (~5s), el snap de cámara (zoom 1.2,
    posición 1100,655) y saltar directo a la canción (`game.skipCountdown`,
    en vez del `startSong()` privado del original al que HScript no puede
    llegar) — ver "Estado actual". Se omitió la pose `intro` congelada de BF
    (etiqueta de frame en el atlas propio `characters/BF/bf-qt`, que no se
    usa para el gameplay normal de esta variante — limitación 1) porque
    queda mayormente tapada por la pantalla negra durante los pocos segundos
    que dura, y motivaba otro overlay standalone (como el de la limitación
    10) para un beneficio visual marginal.
12. **Obliterated-erect: apertura + cinemática de mitad de canción, portadas
    (con partes aproximadas/no portadas documentadas abajo).** Ported desde
    `obliterated-erect.hxc`'s `onCountdownStart`/`onSongStart`/`onStepHit`/
    `onUpdate` y `QtStageObliteratedErect.hxc`'s `buildStage`/`addCharacter`:
    - **Apertura**: countdown saltado igual que Obliterated base
      (`game.skipCountdown`), `game.camGame.fade(BLACK, 12.5, true, null,
      true)` al iniciar la canción — el mismo método `.fade()` de
      `FlxCamera` que ya usa `qtStagePico.hx`'s `playIntroCutscene`, así que
      a diferencia del import de `hxCodec`, esta llamada ya tenía precedente
      funcionando en este mismo código antes de este cambio.
    - **Dos videos superpuestos** (`obliteratedErectMid.mp4` en t≈149.7s-
      153.8s, `obliteratedErectEdit.mp4` en t≈153.8s hasta que termina), vía
      `hxCodec`/`FlxVideo` — misma técnica y mismo riesgo de import aceptado
      que `cutsceneVideo` de Obliterated base (limitación 4).
    - **4 fundidos de cámara** (`camFade2/3/4`, ida y vuelta a negro) vía
      `game.camGame.fade()` en los timestamps exactos del original
      (t≈147.9s/178.5s/189.6s) — inyectados como eventos sintéticos en
      `events.json` (el original los dispara por tiempo hardcodeado en el
      script, no por eventos reales del chart).
    - **Fundidos de HUD** (`hudFadeOut1/In/Out2`) y **cambio de layout**
      (`layoutChange`: centra el strumline del jugador, oculta el del
      oponente para el resto de la canción) — mismos timestamps del
      original, misma técnica de `fadeHud`/grupo `.visible` ya usada en
      `qtStageKiller.hx`.
    - **Pose final "tsundere" de dad**: el `.hxc` original la dispara desde
      el `onEndReached` del segundo video, pero el chart original **también**
      trae un evento nativo `PlayAnimation` (target: dad, anim: tsundere) en
      t≈179.05s — casi el mismo momento, pero un timestamp fijo del chart en
      vez de depender de que `hxCodec` reporte el fin del video exactamente
      cuando se esperaba. Se usó ese timestamp del chart como disparador
      principal (más confiable), dejando el `onEndReached` de `FlxVideo`
      como respaldo (la función que muestra la pose es idempotente, llamarla
      dos veces no cambia nada). Como los personajes de Psych no pueden
      cambiar de animación a mitad de canción hacia un atlas completamente
      distinto, se implementó como un `FlxAnimate` standalone superpuesto
      sobre dad (mismo patrón que `qtStagePico.hx`'s `picoOverlay`), cargado
      del atlas real del paquete (`characters/kb_export/kb-erect-end`,
      símbolo `exportanim`). Queda puesta para el resto de la canción, igual
      que en el original.
    - **Color grading de toda la canción** sobre bf/dad/gf: el original usa
      un shader propio (`AdjustColorShader`, hue/saturación/contraste/brillo)
      que Psych no tiene, pero Psych SÍ trae su propio shader de
      hue/saturación/brillo (`shaders.ColorSwap`, `source/shaders/
      ColorSwap.hx`) — una clase real y compilada en el motor, así que
      importarla no tiene el riesgo de "podría no resolver en el build real"
      que sí tiene `hxCodec`. Lo que se pierde: `ColorSwap` no tiene control
      de contraste (el `contrast: 10` del original se descarta), y no hay
      ningún equivalente al `DropShadowShader` (brillo de contorno) que el
      original aplica sobre dad/gf — Psych no trae ningún shader de ese
      tipo. La conversión de unidades entre el original (hue en grados
      -180..180, saturación/brillo en porcentaje -100..100, convención
      típica de un ajuste HSB estilo Photoshop) y `ColorSwap` (hue/
      saturación sumados directo al 0..1 normalizado, brillo como
      multiplicador `×(1+valor)`) es una suposición razonable pero no
      verificada visualmente en este entorno — puede necesitar ajuste.
    - **NO portado**: la pose congelada "intro-erect" de dad (frame 0
      sostenido desde el inicio de la canción hasta el step 34, luego
      resume) — pausar/resumir un `FlxAnimate` a mitad de reproducción vía
      HScript no está verificado en este entorno (misma razón ya aplicada al
      `erectIntro1` de Blissful-erect — limitación 8), y la pose queda casi
      totalmente tapada por el fundido de 12.5s de todas formas, así que dad
      simplemente juega sus animaciones normales esos primeros segundos. La
      pose "tired" de boyfriend (evento nativo `PlayAnimation` del chart en
      t≈178.3s) tampoco se portó — el atlas de `bf-qt` no tiene esa
      animación. La suspensión del ghost-tap-miss durante los videos
      (`inGhost` en el original) tampoco — mismo límite ya documentado en
      la limitación 4 (`noteMissPress` de Psych corre después de aplicar la
      penalización).
13. **HUD estilo "Kade Engine 2021" de Blissful-2021, portado sin los
    toggles avanzados ni el ranking con colores.** Después de leer el código
    fuente real de Psych (`PlayState.popUpScore`/`goodNoteHit`) confirmé que
    `note.rating` ya usa exactamente los mismos nombres que el original
    (`'sick'/'good'/'bad'/'shit'`, de `backend/Rating.hx`) y que
    `note.strumTime` está disponible — o sea que SÍ se pudo portar con APIs
    verificadas, no solo asumidas. Ver "Estado actual" para el detalle. Lo
    que no se portó: el objeto `settings` de toggles (`baseGameRank`,
    `baseGameAccuracy`, `lerpEverything`, `judgementCounter`,
    `holdSplashes`, `noteSplashes`, `disableKeWatermark`) — todos estaban
    apagados por defecto excepto el watermark (que sí se portó), así que se
    hardcodeó directamente esa configuración por defecto en vez de construir
    el sistema de toggles completo. Tampoco el ranking con colores vía
    `FlxTextFormatMarkerPair`/`applyMarkup` (solo se usaba en el modo
    `baseGameRank`, apagado por defecto, así que nunca se ejecutaba en la
    configuración real del mod). **A propósito NO se portó**
    `handleFakeLag()`, una función que quema CPU al azar para simular lag de
    forma intencional como chiste/nostalgia del motor viejo — replicarla
    solo gastaría batería/rendimiento sin ningún beneficio para quien juega.
14. **Prompt de skip para las 4 cutscenes, con un caso borde conocido.**
    Portado en `qtStage.hx`/`qtStagePico.hx`/`qtStageCityErect.hx`: primera
    tecla ([ACCEPT]) muestra "Hold [ACCEPT] to skip" con fade-in de 0.5s,
    segunda tecla salta directo al estado post-cutscene. Cada `FlxTimer` de
    cada cutscene se crea vía un `scheduleCutsceneTimer()` compartido (en vez
    de `new FlxTimer()` directo) para poder cancelarlos todos de una — esto
    significó tocar los ~43 timers que ya estaban escritos y funcionando en
    las 4 cutscenes, a diferencia de casi todo el resto del port que fue
    código nuevo aditivo. Caso borde conocido: si el skip cae justo mientras
    un `FlxG.camera.fade()` está activo (pantalla fundiéndose a negro/
    blanco), ese fundido no se cancela — no hay forma verificada de cancelar
    un fade de `FlxCamera` desde HScript sin poder compilar/probar en este
    entorno. Es una ventana angosta ya que los fundidos ocurren sobre todo
    cerca del final de cada cutscene, cuando ya queda poca razón para
    saltar.
15. **Sistemas del original fuera del alcance de este port, por requerir
    tocar `source/` (no solo la carpeta de mod) o no tener ningún
    equivalente en Psych.** Encontrados al revisar sistemáticamente qué
    quedaba del paquete original sin ni siquiera documentar:
    - **Note skins propios por variante** (`data/notestyles/funkin-qt-2021`/
      `funkin-qt-dodge`) — revisados un poco más a fondo en una segunda
      pasada: **ninguno de los dos trae arte propio**, ambos apuntan a
      `"assetPath": "shared:notes"`/`"shared:noteStrumline"` (las notas
      VANILLA de Funkin', no un reskin de QT) — la única diferencia real es
      `"scale": 0.7` en vez del tamaño default. En Psych el skin de notas es
      una preferencia GLOBAL del jugador (`ClientPrefs.data.noteSkin`,
      confirmado en `source/objects/Note.hx`/`StrumNote.hx`), y aunque
      HScript SÍ puede leer/escribir ese campo directamente (es un `public
      static` real, sin necesidad de tocar `source/`), mutar una preferencia
      global del jugador solo para escalar las notas 0.7x en estas
      variantes — y tener que restaurarla sin fallos en TODOS los caminos de
      salida (fin normal, retry, game over, pausa→salir al menú) — es un
      riesgo real para un beneficio casi nulo, dado que no hay ningún arte
      que se esté perdiendo. Se descartó por esa relación costo/beneficio,
      no por imposibilidad técnica.
    - **Sticker packs** (`data/stickerpacks/*.json`) — sistema de
      "coleccionables" exclusivo del motor moderno, Psych 0.7.3 no tiene
      nada parecido.
    - **Álbum roll y iconos pixel-art propios de Freeplay**
      (`data/ui/freeplay/albums/*.json`, `images/freeplay/icons/*pixel*`) —
      Freeplay en Psych ya muestra los healthicons ya portados de cada
      personaje (`source/states/FreeplayState.hx` usa el mismo `HealthIcon`
      que el gameplay), así que Freeplay ya funciona correctamente — esto es
      una variante más chica/distinta del ícono, cosmético, no una feature
      faltante.
    - **Clases de sprite/UI del menú** (`RetrySprite`/`BusSprite`/
      `QtPlushMenuButton`) — un botón de "Retry" con estilo Pico, un prop de
      bus y un easter egg del menú principal. Ninguna se usa desde un
      stage/canción — viven en pantallas de menú compartidas
      (`FreeplayState`/menú principal), que están en `source/`, no en la
      carpeta de mod. (`SpeakerSprite` NO es de menú pese a estar en la
      misma carpeta de scripts — ver el ítem de abajo, es un prop de
      gameplay).
    - **Prop "altavoz" (boombox) que pulsa junto a GF-QT al bailar**
      (`scripts/sprite/SpeakerSprite.hxc`, atlas
      `characters/gf-qt/speakers`, símbolo "bump") — encontrado leyendo
      `gf-qt.hxc`: el original lo cose DENTRO del propio rig de GF vía
      `getFramesWithKeyword("placeholder")`/`FlxSpriteElement` (se adjunta a
      un punto que se mueve con cada frame de su animación), algo que Psych
      no tiene forma de replicar — la alternativa sería un `FlxAnimate`
      standalone con un offset fijo aproximado (mismo enfoque que
      `picoOverlay`/`tsundereOverlay`), reproduciendo `bump` cada vez que GF
      baila. El atlas SÍ está disponible en el paquete original y no se
      copió a este mod — quedó pendiente por relación costo/beneficio
      (un prop decorativo, con un offset que en el mejor caso sería una
      aproximación, no exacto).
    - **Mecánica de "fakeout death" + confirmación sostenida en Game Over
      al morir por sierra** (`bf-qt.hxc`: `doFakeoutDeath()`, y el bloqueo de
      salida normal + "mantené para confirmar" atado a
      `GameOverSubState.blueBallSuffix`/`mustNotExit`/`blueballed`) —
      **corrección de una revisión posterior**: acá arriba se había dicho
      que esto era "un límite arquitectónico, `GameOverSubstate` no tiene
      ningún hook" — impreciso. `GameOverSubstate.update()` SÍ llama
      `callOnScripts('onUpdate', [elapsed])`/`onGameOverStart` cada frame
      (confirmado leyendo el código fuente real), así que un stage script
      SÍ puede leer/escribir `GameOverSubstate.instance` y su `boyfriend`
      en vivo — de hecho `scripts/gameOverQuotes.hx` ya depende de eso. Lo
      que realmente bloquea cada mitad de esto es distinto:
      - La pose/sonido del jumpscare (`fakeoutDeath`/`fakeout_death`): **no
        es un límite de Psych, es que el asset no existe en absoluto** en
        el paquete de este mod (ni el símbolo del atlas `bfFakeOut` ni el
        sonido están en ningún lado de lo extraído) — son assets del juego
        base del motor moderno, no algo que QT: Rewired haya empaquetado.
      - Bloquear la tecla BACK para forzar "mantené para confirmar": esto
        SÍ es un límite real de Psych, verificado en el código —
        `GameOverSubstate.update()` llama a `callOnScripts('onUpdate', ...)`
        pero nunca revisa el valor que devuelve (a diferencia de otros
        hooks de este mismo motor como `onKeyPressPre`, que sí chequean
        `Function_Stop`), así que no hay forma de cancelar el manejo nativo
        de BACK que corre inmediatamente después, en el mismo frame.
      - **Lo que SÍ se portó en su lugar** (ver "Estado actual"): al morir
        por un instakill de sierra, además de la música distinta, ahora
        también hay un shake de cámara y un tinte rojo que se desvanece
        sobre la pantalla de Game Over — mismo espíritu dramático del
        original, construido solo con técnicas ya probadas en este mod
        (`FlxG.camera.shake`, un `FlxSprite` con blend `MULTIPLY` agregado a
        `GameOverSubstate.instance`), sin inventar contenido nuevo.
    - **Desbloqueo progresivo de canciones dentro de Story Mode**
      (`scripts/weeks/QTWeek.hxc`'s `getSongDisplayNames()`: solo muestra
      "Blissful" hasta que se completa, recién ahí aparece "Obliterated" —
      el original en Story Mode solo tenía esas 2 canciones base, todas las
      demás variantes eran Freeplay-only). El `WeekData` de Psych no tiene
      ningún campo para ocultar canciones individuales de un mismo `weeks/
      *.json` según el progreso guardado, ni para que Story Mode y Freeplay
      muestren listas de canciones distintas dentro de la misma semana (el
      campo `hideFreeplay`/`hideStoryMode` es por SEMANA entera, no por
      canción) — implementarlo bien requeriría tocar `StoryMenuState.hx`.
      Este mod expone las 7 variantes por igual en Story Mode y Freeplay
      desde el principio, sin ese desbloqueo progresivo.
    - **Cápsula animada de Story Menu** (`data/levels/QTWeek.json`'s
      `props` — QT/BF/GF con animaciones idle/confirm en la lista de
      semanas) — distinta del `MenuCharacter` que ya se portó (limitación 6,
      el que aparece DESPUÉS de entrar a la semana). Psych arma esa lista
      con un gráfico ESTÁTICO por semana (`MenuItem.hx`:
      `loadGraphic(Paths.image('storymenu/' + weekName))`), no con props
      animados por personaje; portar la versión animada del original
      requeriría tocar `StoryMenuState.hx`/`MenuItem.hx`. Lo que SÍ se
      arregló de esto (ver limitación 6): a la cápsula ESTÁTICA
      (`images/storymenu/QT.png`) directamente le faltaba el archivo — un
      bug real, no solo una limitación de fidelidad.
    - **`MissesExceptionsModule.hxc`** (suprime el ghost-tap-miss mientras
      BF juega ciertas animaciones) — revisado de nuevo, con más cuidado:
      SÍ existe un hook anterior a la penalización, `onKeyPressPre`
      (`PlayState.hx:2663`, devolver `Function_Stop` cancela toda la función
      `keyPressed` antes de que se calcule si la tecla acierta una nota o no
      — confirmado leyendo el código fuente real). El problema es que ese
      hook se dispara ANTES de que el motor determine si hay una nota real
      para acertar con esa tecla, así que cancelar ahí a ciegas también
      bloquearía notas legítimas durante esa ventana, no solo el ghost-tap.
      Para hacerlo bien habría que reimplementar en HScript el mismo filtro
      de "¿hay una nota acertable para esta tecla ahora?" que usa
      `keyPressed()` internamente (`strumsBlocked`/`canBeHit`/`mustPress`/
      `tooLate`/`wasGoodHit`/`blockHit`) — o, alternativa, dejar que la
      penalización se aplique y tratar de revertirla a mano en
      `noteMissPress` (restaurar vida/combo/score) sin poder verificar en
      este entorno si esa compensación queda perfectamente prolija o deja
      las estadísticas de precisión de la canción en un estado sutilmente
      raro. Ambos caminos son técnicamente alcanzables desde la carpeta de
      mod (no tocan `source/`), pero el riesgo de romper el tracking de
      combo/precisión por una función de bajo impacto (evitar un miss
      durante ~2s de un video ya con las notas atenuadas) no compensa el
      beneficio — se dejó sin portar por esa razón, no por imposibilidad.
    - Lo que SÍ se rescató de esta revisión y ya está portado (ver "Estado
      actual"): las citas de voz + subtítulo al morir
      (`scripts/gameOverQuotes.hx`, desde `GameOverSubtitles.hxc`) y el
      popup "DODGED!" al esquivar (desde
      `SawbladeAndDodgeModule.hxc`).

## Assets de origen

- `data-src/`, `images-src/` — JSON/imágenes crudas del mod original (formato
  del motor moderno), mantenidos como referencia para conversiones futuras.
  No son leídos por el engine.
- Los sprites/audio reales usados sí están copiados en `images/`, `songs/`,
  `sounds/` en las rutas que Psych espera.

## Próximos pasos sugeridos (en orden)

Todas las cutscenes/aperturas/cinemáticas que tienen contenido real en el
original (Blissful base ×2, Blissful erect ×2, Blissful pico, Obliterated
base/legacy, Obliterated-erect) ya están portadas. Lo que queda:

1. Verificar/ajustar visualmente el `scale`/`position` del portrait de QT en
   el Story Menu (limitación 6 — estimado por proporción, sin poder
   compilar/ejecutar el juego en este entorno). KB y Pico no tienen arte de
   story menu en el paquete original, así que no hay nada que portar para
   ellos ahí.
2. Cancelar `FlxG.camera.fade()` activos al hacer skip (limitación 14) —
   requeriría confirmar si `FlxCamera` expone algún método tipo `stopFX()`
   en la versión de Flixel de este proyecto.
3. Overlay de la pose `introbl` de Blissful-pico más preciso (limitación 10)
   — el bop de GF ya está portado. Sin verificación visual posible en este
   entorno, no queda mucho margen concreto de mejora más allá de lo ya
   hecho.
4. `cutsceneVideo`/`cutsceneVideoOut`/`fadeStart` de Obliterated — **ya
   portado** (ver "Estado actual" y limitación 4), usando `hxCodec`/
   `FlxVideo` directo desde HScript con el riesgo de import aceptado
   explícitamente por decisión del usuario.
5. Apertura + cinemática de mitad de canción de Obliterated-erect — **ya
   portada** (ver "Estado actual" y limitación 12): dos videos, 4 fundidos
   de cámara, fundidos de HUD, cambio de layout, pose final de dad y color
   grading en toda la canción. Quedan sin portar, documentados en la misma
   limitación: la pose congelada `intro-erect`, la pose `tired` de BF, el
   contraste y el brillo de contorno (`DropShadowShader`) del color grading,
   y la suspensión del ghost-tap-miss durante los videos.
6. La pose congelada `intro` de BF en la apertura de Obliterated base/legacy
   (limitación 11) y la pose `intro-erect` de KB en Obliterated-erect (atlas
   separado `kb_export/kb_erect_intro`, `animType: "symbol"`) — ambas
   omitidas por bajo beneficio visual frente al riesgo de otro overlay
   standalone sin verificación visual posible.
7. Toggles avanzados del HUD 2021 (`baseGameRank`/`baseGameAccuracy`/
   `lerpEverything`/`judgementCounter`/`holdSplashes`/`noteSplashes`/
   `disableKeWatermark`) y el ranking con colores vía `applyMarkup` —
   omitidos porque todos estaban apagados por defecto en el original (ver
   limitación 13), no cambiarían el comportamiento actual.

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
