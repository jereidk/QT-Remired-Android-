# QT: Rewired — Port a Psych Engine v0.7.3

Mod original construido para el motor oficial moderno de FNF (`FunkinCrew/Funkin'`,
namespace `funkin.*`: `Module`/`SongEvent`/`ScriptedClass`, charts v2.0, atlas
Adobe Animate). Este engine (Psych Engine v0.7.3) es arquitectónicamente distinto,
así que nada del código/datos original se pudo copiar tal cual — todo lo de abajo
fue reconstruido usando las convenciones reales de mods de Psych (ver
`source/backend/Song.hx`, `source/objects/Character.hx`, `source/backend/StageData.hx`,
`source/backend/Mods.hx`).

## Estado actual: MVP de "Blissful" jugable

Lo que SÍ funciona (carpeta de mod, sin tocar `source/`):
- `characters/{qt,bf-qt,gf-qt}.json` — personajes reconstruidos al schema
  `CharacterFile` de Psych, usando los atlas Adobe Animate reales del mod
  (`images/characters/QT_assets/qt`, `images/characters/gf-qt`) vía el soporte
  nativo `flxanimate` de Psych.
- `stages/qtStage.json` + `stages/qtStage.hx` (HScript) — anchors de personajes,
  zoom y fondos del stage (tv/wall/fg/overlay), sin la cutscene de intro.
- `data/blissful/{blissful,blissful-easy,blissful-hard}.json` — chart convertido
  del formato plano `{t,d,l,p}` del mod original al formato de secciones de Psych
  (notas 0-3/4-7 se mapean 1:1 al mismo mecanismo mustHitSection de Psych).
- `songs/blissful/{Inst,Voices-bf-qt,Voices-qt}.ogg` — audio con voces separadas
  por personaje (usa el `vocals_file` de Psych).
- `weeks/QT.json` — aparece en Freeplay y Story Mode.

## Limitaciones conocidas / trabajo pendiente

1. **BF-QT usa el sprite vanilla de Boyfriend.** El atlas "characters/BF/bf-qt"
   que trae el mod solo contiene animaciones EXTRA (pre dance, caramelldansen,
   dodge, saw hit) — las animaciones base de canto/idle de BF-QT en el mod
   original reusan el atlas del BF del motor moderno oficial, que no viene
   incluido en este mod y no tenemos. Por eso BF-QT se ve como el BF clásico.
2. **Sin cutscene de intro.** El sistema de timeline con tweens/cámara del mod
   original (`QtTransformSongOutro`, bus, etc.) no está portado.
3. **84 eventos de cámara sin portar** (`FocusCamera`/`ZoomCamera`/`SetCameraBop`
   con easing custom) — `data/blissful/events.json` está vacío. Psych sigue la
   cámara automáticamente al cantante activo por defecto.
4. **Solo "Blissful" (variante base).** Faltan: Blissful-erect, Blissful-pico,
   Blissful-2021, Obliterated (+erect/legacy) — y con Obliterated viene la
   mecánica de esquivar sierras (dodge mechanic), que requiere lógica HScript
   nueva (evento de chart custom + sprite de sierra + input de esquive).
5. **Sin note kinds custom** (ej. `caramella` para BF durante Blissful Erect).
6. **Portrait de Story Menu genérico** (`weekCharacters` cae al personaje BF
   por defecto — no hay arte de menú específico de QT convertido todavía).

## Assets de origen

- `data-src/`, `images-src/` — JSON/imágenes crudas del mod original (formato
  del motor moderno), mantenidos como referencia para conversiones futuras.
  No son leídos por el engine.
- Los sprites/audio reales usados sí están copiados en `images/`, `songs/`,
  `sounds/` en las rutas que Psych espera.

## Próximos pasos sugeridos (en orden)

1. Portar los eventos de cámara de Blissful a "Focus Character"/"Add Camera Zoom"
   nativos de Psych (o custom-event HScript si se quiere el easing exacto).
2. Portar Obliterated + mecánica de esquivar sierras como evento de chart custom
   (`stages/qtStage.hx` → `eventPushed`/`onEvent`) + note kind hardcodeado.
3. Variantes erect/pico/2021 de cada canción.
4. Cutscene de intro.
