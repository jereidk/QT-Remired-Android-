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
