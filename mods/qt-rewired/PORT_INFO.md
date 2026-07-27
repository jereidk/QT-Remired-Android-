# QT: Rewired - Port a Psych Engine v0.7.3

## Información Original
- **Mod Original:** QT: Rewired
- **Autor:** JoaDash
- **Engine Original:** FNF v0.6.2+
- **Formato Original:** Scripts Haxe compilados

## Port Info
- **Engine Destino:** Psych Engine v0.7.3
- **Formato de Scripts:** Lua
- **Estado:** En progreso

## Contenido del Mod
- **Canciones:** 4 (Blissful, Blissful-2021, Obliterated, y variantes)
- **Personajes:** Qt (novia), BF-Qt, Pico
- **Escenarios:** QtStage, QtStagePico, QtStageCityErect, QtStageKiller, QtStageObliteratedErect
- **Videos:** Cinemáticas
- **Sonidos Custom:** Sonidos de gameplay especiales
- **Mecánicas Custom:** 
  - Dodge mechanics (evitar sierras)
  - Note kinds personalizadas
  - Subtítulos en game over
  - Opciones de categoría personalizadas

## Estructura de Directorios
```
mods/qt-rewired/
├── scripts/           # Scripts Lua (a convertir/adaptar)
├── data-src/          # Datos de origen (metadata canciones, etc)
├── data/              # Datos procesados para Psych
├── images-src/        # Imágenes originales
├── images/            # Imágenes para Psych
├── music/             # Archivos de música
├── sounds/            # Sonidos custom
├── videos/            # Cinemáticas
└── mod.json           # Metadata del mod
```

## Tareas Pendientes
- [ ] Convertir scripts Haxe a Lua
- [ ] Adaptarformato metadata canciones
- [ ] Procesar y optimizar imágenes
- [ ] Configurar personajes
- [ ] Configurar escenarios
- [ ] Implementar mecánicas custom
- [ ] Testear en juego
