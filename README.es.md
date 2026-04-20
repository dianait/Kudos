# 🎉 Kudos

**Español** | [English](README.md)

Una app iOS para guardar y celebrar tus logros personales como notas adhesivas digitales.

🌐 [dianait.blog/kudos](https://dianait.blog/kudos)

## ✨ Características

- **Guardar logros**: Crea notas adhesivas con tus logros y victorias personales
- **Contador visual**: Ve cuántos logros has guardado en tu colección
- **Animaciones de celebración**: Confetti animado al guardar un nuevo logro
- **Carrusel de logros**: Navega por todos tus logros con un gesto de deslizamiento
- **Borrar desde el carrusel**: Elimina logros directamente sin entrar al detalle
- **Fotos**: Adjunta una foto a cualquier logro
- **Multiidioma**: Español e inglés con cambio en tiempo real
- **Privacidad total**: Todos los datos se almacenan localmente, nada sale de tu teléfono
- **Accesibilidad**: Soporte completo de VoiceOver con etiquetas y pistas localizadas

## 📖 Cómo usar

1. **Añadir un logro**: Toca la nota adhesiva en la pantalla principal, escribe tu logro, desliza hacia arriba para guardar
2. **Ver tus logros**: Toca el contador en la parte superior para abrir el carrusel, desliza para navegar
3. **Borrar un logro**: Toca el icono de papelera en la nota activa del carrusel
4. **Cambiar idioma**: Ajustes → selecciona tu idioma preferido

## 🏗️ Arquitectura

Kudos está construida con **Clean Architecture** y **MVVM**, respetando estrictamente la regla de dependencias: el Domain no tiene dependencias externas.

```
kudos/
├── Domain/
│   ├── Models/              # AccomplishmentItem, NewAccomplishment
│   ├── Protocols/           # Contratos de casos de uso y repositorio
│   ├── UseCases/            # AddAccomplishment, AddPhotoAccomplishment (solo lógica de negocio — delegaciones puras eliminadas)
│   └── Utilities/Validators # AccomplishmentValidator, ValidationError
├── Data/
│   ├── Entities/            # AccomplishmentEntity (@Model, SwiftData)
│   └── Repositories/        # AccomplishmentRepository (implementación SwiftData)
├── Presentation/
│   ├── Main/                # MainView + MainViewModel
│   ├── Carousel/            # CarouselView, AccomplishmentDetailView
│   ├── Stickies/            # StickyView y subcomponentes
│   ├── Settings/            # SettingsView
│   ├── AboutMe/             # AboutView
│   ├── Error/               # ErrorView
│   └── Utilities/
│       ├── Constants/       # Dimensions, Space, Timing, Icon, etc.
│       ├── Localization/    # Copies, A11y, LanguageManager
│       └── Confetti/        # Componentes de animación de celebración
├── Dependencies/
│   └── AppFactory.swift     # Inyección de dependencias
└── Services/
    ├── AppSettings.swift
    └── LocalizationManager.swift
```

### Stack técnico

| | |
|---|---|
| Lenguaje | Swift 6 |
| UI | SwiftUI |
| Persistencia | SwiftData |
| iOS mínimo | 17.0 |
| Xcode | 15.0+ |
| Concurrencia | Swift 6, strict concurrency complete |

### Patrones clave

- **Clean Architecture**: Domain → Data → Presentation, regla de dependencias aplicada
- **MVVM**: `MainViewModel` gestiona el estado de presentación
- **DI basada en protocolos**: Casos de uso y repositorio inyectados via protocolos; el ViewModel llama al repositorio directamente para fetch/delete simples (sin caso de uso cuando no hay lógica de negocio)
- **Capa de validación**: `AccomplishmentValidator` en Domain, no en las vistas
- **Localización**: Enums `Copies` y `A11y` con extensión `.localized`, cambio de idioma en tiempo real
- **Concurrencia Swift 6**: todos los tipos con aislamiento explícito (`@MainActor` en ViewModels, casos de uso y repositorio); compresión de imagen ejecutada en background

## 🔒 Privacidad

Todos los datos viven en tu dispositivo. Sin analíticas, sin servidores externos, sin tracking.

## 🧪 Tests

```bash
xcodebuild test -project kudos.xcodeproj -scheme kudosTests -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild test -project kudos.xcodeproj -scheme kudosUITests -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 👤 Autora

Desarrollado con ❤️ por [@Dianait](https://dianait.blog)
