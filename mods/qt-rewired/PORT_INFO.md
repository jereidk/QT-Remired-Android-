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
  desde negro, sin coreografía); `qtStageObliteratedErect` tiene una apertura
  bastante más grande sin portar (ver limitación 12); `qtStage2021` no tiene
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
- **`SetCameraBop`** (oscilación de zoom por beat) en los 6 stages, con la
  curva de decaimiento exponencial real de FunkinCrew
  (`cameraBopMultiplier = lerp(1, cameraBopMultiplier, 0.95^(elapsed*60))`
  cada frame, leída directo de `PlayState.hx`/`SetCameraBopSongEvent.hx`),
  en vez del tween de ida y vuelta de duración fija que había antes. Se
  pausa mientras un evento `ZoomCamera` tiene un tween activo (para no pelear
  por `FlxG.camera.zoom`) — ver limitación 7 sobre esta única diferencia
  restante con el original.
- **`changeStage`** (Obliterated/Obliterated-legacy): recolorea `tvLights`/
  `lightOverlay` entre Normal/Killer/Blue/Red — confirmado que eso es
  literalmente todo lo que hace el evento original (no cambia de escenario).
- **`blackIn`** (Obliterated/Obliterated-legacy, último evento de ambos
  charts): `blackScreen.alpha = 1` instantáneo en `qtStageKiller.hx` — igual
  de simple en el original. Ver limitación 4 sobre por qué
  `cutsceneVideo`/`fadeStart` (los otros dos eventos "de video" del mismo
  chart) no se portaron.
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
3. **Cutscenes de Blissful (base) sin el prompt de skip.** A diferencia de
   lo que se pensaba antes (un supuesto sprite de "bus"), el original
   (`blissful.hxc` + `QtTransformSongOutro.hxc`) resultó ser más simple: solo
   QT reemplazada por el sprite `qt transform` + coreografía de cámara +
   fundidos de color en la cutscene final (que nunca tuvo subtítulos en el
   original). La de intro sí los tiene (`hi-cutie.srt`) y ya está portada
   (ver "Estado actual" y `showSubtitle()` en `qtStage.hx`). Lo único que
   falta en ambas es el prompt de "mantén presionado para saltar".
4. **`changeStage` solo recolorea, no cambia de escenario real.** Se portó
   correctamente para Obliterated/Obliterated-legacy (`tvLights`/
   `lightOverlay` cambian entre Normal/Killer/Blue/Red, que es literalmente
   todo lo que hacía el evento original — no mueve ni cambia ningún otro
   prop). `blackIn` también está portado (`qtStageKiller.hx`, es el último
   evento de ambos charts — un simple `blackScreen.alpha = 1` instantáneo, ni
   siquiera tenía tween en el original). **`cutsceneVideo`/`cutsceneVideoOut`/
   `fadeStart` NO se portaron y quedan como limitación arquitectónica, no
   como pendiente trivial**: el original reproduce un video real
   (`videos/cutscene.mp4`, vía `FunkinVideoSprite`) SUPERPUESTO sobre el
   gameplay en vivo mientras las notas siguen cayendo (con los misses
   deshabilitados durante el video). Psych sí trae soporte de video nativo
   (`hxCodec`, ver `PlayState.startVideo()`), pero está diseñado únicamente
   para tomar la pantalla completa antes o después de una canción — no hay
   forma limpia de superponer un video como sprite dentro del gameplay activo
   sin acceder directamente a las clases de `hxCodec` desde HScript, algo que
   ningún otro script de este mod hace y que no se pudo verificar sin poder
   compilar/ejecutar el juego en este entorno. Implementarlo a medias
   (portar solo el fundido a negro de `fadeStart` sin el video real) dejaría
   la pantalla en negro permanentemente en mitad de la canción, que es peor
   que no portarlo. Ver "Próximos pasos".
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
   acá), así que puede necesitar ajuste. También había un
   `images/storymenu/titles/weekqt.png` en el paquete original, pero Psych
   no tiene un slot de imagen para el título de semana en el story menu (es
   texto plano, `txtWeekTitle`), así que no tiene a dónde ir.
7. **`SetCameraBop` ya usa la curva de decaimiento real** (ver "Estado
   actual"), con una única diferencia deliberada: el original mantiene el
   zoom "base" (el que fijan los tweens de `ZoomCamera`) completamente
   separado del multiplicador de bop, combinándolos recién cada frame
   (`zoomPlusBop = currentCameraZoom * cameraBopMultiplier`). La versión
   portada no tiene ese "zoom base" como variable independiente — ambos
   sistemas escriben directo a `FlxG.camera.zoom` — así que, para no pelear
   por ese valor, el decaimiento del bop se pausa mientras un `ZoomCamera`
   tiene un tween activo y retoma cuando termina. Esto SÍ pasa seguido (los
   charts casi siempre emiten `SetCameraBop` cerca de un `ZoomCamera`, así
   que hay secciones enteras donde ambos están activos a la vez): en esas
   ventanas el bop queda congelado en vez de seguir decayendo en paralelo
   como en el original — visualmente similar (el zoom igual se mueve, solo
   que sin el pulso superpuesto durante esos tramos) pero no idéntico.
   Arreglarlo del todo requeriría separar un "zoom base" propio en las 6
   stages en vez de escribir `FlxG.camera.zoom` directamente desde
   `zoomCamera()`.
8. **Las dos cutscenes de Blissful-erect (intro y final) sin skip.** Se
   portó toda la coreografía de cámara/sonido/animación/subtítulos de ambas
   (ver "Estado actual"), pero se omitió el mecanismo de "mantén presionado
   para saltar" (`skipCutscene()` del original) — ambas cutscenes siempre se
   reproducen completas (~9.8s la de intro, ~14s la final). Solo se copió el
   audio en inglés (el original también trae variantes en español para
   varias de estas líneas, no incluidas — los subtítulos en español
   tampoco). Además,
   la pose `erectIntro1` de dad no se congela en el frame 0 como en el
   original (que la pausa 0.9s antes de reproducirla completa) — acá
   simplemente se reproduce dos veces seguidas, un detalle cosmético menor
   (no se pudo verificar si pausar un `FlxAnimate` a mitad de reproducción es
   seguro en esta API sin poder compilar/ejecutar el juego).
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
    pivote pueden diferir levemente). Tampoco se replicó el bop de GF
    sincronizado a los beats del `introSong-pico` (103 BPM) que tiene el
    original vía un `Conductor` secundario — GF se queda en su pose idle
    normal durante estos ~11s.
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
12. **Obliterated-erect NO tiene su apertura/cinemática de mitad de canción
    portada — es una limitación arquitectónica, no un pendiente simple.** Al
    investigar la apertura encontré que está enredada con un sistema mucho
    más grande: DOS videos incrustados (`obliteratedErectMid.mp4`,
    `obliteratedErectEdit.mp4`, vía `FunkinVideoSprite`, igual que el
    `cutsceneVideo` de Obliterated base — ver limitación 4), shaders de
    color (`AdjustColorShader`/`DropShadowShader` sobre dad), y 4 fundidos
    de cámara con cambio de layout en momentos específicos
    (`camFade2/3/4Triggered`, `fadeOut1/2Triggered`, `layoutTriggered`, en
    t≈147.9s/148.3s/152.2s/152.3s/178.5s/179.2s/189.6s) que llevan al
    personaje a un estado "tsundere" después. Portar solo el fundido a negro
    inicial sin el resto dejaría una apertura sin ningún pago visual —
    mismo criterio que ya se aplicó a `cutsceneVideo`/`fadeStart`.
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

## Assets de origen

- `data-src/`, `images-src/` — JSON/imágenes crudas del mod original (formato
  del motor moderno), mantenidos como referencia para conversiones futuras.
  No son leídos por el engine.
- Los sprites/audio reales usados sí están copiados en `images/`, `songs/`,
  `sounds/` en las rutas que Psych espera.

## Próximos pasos sugeridos (en orden)

Todas las cutscenes/aperturas que tienen contenido real en el original
(Blissful base ×2, Blissful erect ×2, Blissful pico, Obliterated
base/legacy) ya están portadas. Lo que queda:

1. Verificar/ajustar visualmente el `scale`/`position` del portrait de QT en
   el Story Menu (limitación 6 — estimado por proporción, sin poder
   compilar/ejecutar el juego en este entorno). KB y Pico no tienen arte de
   story menu en el paquete original, así que no hay nada que portar para
   ellos ahí.
2. Mecanismo de "mantén presionado para saltar" para las 4 cutscenes
   (limitaciones 3/8) — los subtítulos ya están portados (ver "Estado
   actual").
3. Overlay de la pose `introbl` de Blissful-pico más preciso (limitación 10)
   y/o bop de GF sincronizado a los beats de `introSong-pico`.
4. Separar un "zoom base" propio del bop en las 6 stages para que
   `SetCameraBop` no tenga que pausarse mientras un `ZoomCamera` está activo
   (limitación 7 — hoy ambos escriben directo a `FlxG.camera.zoom`).
5. `cutsceneVideo`/`cutsceneVideoOut`/`fadeStart` de Obliterated (video
   superpuesto en gameplay en vivo) — ver limitación 4 sobre por qué esto es
   una limitación arquitectónica de Psych, no un simple pendiente; requeriría
   experimentar con las clases de `hxCodec` directamente desde HScript (sin
   poder compilar/probar en este entorno) y probablemente solo seria seguro
   de intentar con acceso a un build real del juego para verificar.
6. La apertura/cinemática de mitad de canción de Obliterated-erect (dos
   videos incrustados + shaders de color + 4 fundidos de cámara con cambio
   de layout — ver limitación 12), misma limitación arquitectónica que el
   punto 5. Antes de intentar cualquiera de los dos puntos de video, valdría
   la pena confirmar si las clases de `hxCodec` son siquiera alcanzables
   desde HScript en esta versión de Psych — eso determina si esto es viable
   algún día o es un límite duro del engine.
7. La pose congelada `intro` de BF en la apertura de Obliterated base/legacy
   (limitación 11) y la pose `intro-erect` de KB en Obliterated-erect (atlas
   separado `kb_export/kb_erect_intro`, `animType: "symbol"`) — ambas
   omitidas por bajo beneficio visual frente al riesgo de otro overlay
   standalone sin verificación visual posible.
8. Toggles avanzados del HUD 2021 (`baseGameRank`/`baseGameAccuracy`/
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
