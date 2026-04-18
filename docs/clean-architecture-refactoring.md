# Refactorización Clean Architecture — Kudos

Documentación del proceso de migración hacia Clean Architecture en la rama `clean-arquitecture`.

---

## ¿Por qué Clean Architecture?

La app Kudos empezó como una app SwiftUI+SwiftData sencilla donde las vistas accedían directamente a `ModelContext` para leer y escribir datos. Al crecer la app, esto generó:

- **Acoplamiento fuerte**: las vistas dependían de SwiftData directamente, haciendo imposible testearlas sin persistencia real.
- **Lógica de negocio dispersa**: la validación, creación y borrado de datos estaba repartida entre Views y ViewModels.
- **Dificultad para probar**: los tests necesitaban un `ModelContainer` real incluso para verificar lógica simple.

Clean Architecture separa el código en capas con dependencias unidireccionales:

```
Presentation → Domain ← Data
```

- **Domain**: define los contratos (protocolos) y reglas de negocio. No importa nada de SwiftUI ni SwiftData.
- **Data**: implementa los contratos usando SwiftData.
- **Presentation**: vistas y ViewModels que orquestan use cases.

---

## Historial de commits

### `31075a0` — Punto de partida (rama `main`)

Estado inicial: vistas con acceso directo a `ModelContext`, sin capas.

---

### `eb4ceea` — Extract Add Accomplishment flow to UseCase + Repository

**Qué se hizo:** Primer use case extraído.

Se crearon:
- `Domain/AccomplishmentRepository.swift` — protocolo `AccomplishmentRepositoryProtocol` con `save()`, `fetch()`, `delete()`
- `Domain/useCases/AddAccomplishmentUseCase.swift` — encapsula la lógica de guardar texto
- `Data/SwiftDataAccomplishmentRepository` — implementación concreta con `ModelContext`

**Por qué:** Separar la operación de guardado de la Vista. El ViewModel ya no sabe que existe SwiftData.

---

### `158f88a` — Complete migration of text save flow to Clean Architecture

**Qué se hizo:** `MainViewModel` conectado con el use case. Se elimina el acceso directo a `ModelContext` del ViewModel.

**Por qué:** El ViewModel ahora solo habla con abstracciones (`AddAccomplishmentUseCaseProtocol`), no con SwiftData.

---

### `58b52b8` — Relocated ValidationError

**Qué se hizo:** `ValidationError` movido a `Domain/`.

**Por qué:** Los errores de validación son parte del dominio. No dependen de SwiftData ni de SwiftUI.

---

### `0bcef7b` — Move Accomplishment model to Data layer

**Qué se hizo:** `Accomplishment.swift` (el `@Model` de SwiftData) movido a `Data/`.

**Por qué:** El modelo de persistencia pertenece a la capa de datos, no al dominio. El dominio usa `NewAccomplishment` (DTO) para crear logros, sin conocer `@Model`.

---

### `b1ac1e9` — Remove SwiftData dependency from MainView

**Qué se hizo:** `MainView` deja de recibir o usar `ModelContext` directamente.

**Por qué:** La View no debería saber de persistencia. Toda esa responsabilidad pasa al ViewModel y los use cases.

---

### `6aee03d` — Extract accomplishment count reading from KudosJarView

**Qué se hizo:** `KudosJarView` obtiene el count desde el ViewModel en lugar de hacer su propia query.

**Por qué:** Las vistas no deben leer datos de persistencia directamente. Un único punto de verdad en el ViewModel.

---

### `9a5d2f9` — Extract accomplishment list reading from StickiesView

**Qué se hizo:** `StickiesView` obtiene la lista de logros desde el ViewModel.

**Por qué:** Misma razón: las vistas reciben datos del ViewModel, no los consultan ellas mismas.

---

### `18bd545` — Derive accomplishment count from loaded accomplishments

**Qué se hizo:** El count de logros se deriva del array `accomplishments` ya cargado, en lugar de hacer una query separada.

**Por qué:** Eliminar estado redundante. Si ya tienes la lista, el count es `lista.count`, no una propiedad independiente que puede desincronizarse.

---

### `8c3b0b1` — Remove derived state from StickiesViewOverview

**Qué se hizo:** `StickiesViewOverview` deja de mantener estado propio derivado del ViewModel.

**Por qué:** El estado derivado duplicado crea bugs sutiles. Si el ViewModel tiene los datos, la Vista los lee directamente.

---

### `02a24fb` — Add delete use case

**Qué se hizo:** Creado `Domain/useCases/DeleteAccomplishmentUseCase.swift`.

**Por qué:** La operación de borrado también debe pasar por el Domain layer. Ahora las tres operaciones CRUD principales (add, get, delete) tienen su use case.

---

### `77fbde9` — Replace legacy Result-based validator with domain throwing validator ← **Último**

**Qué se hizo:**

Existían dos validadores en el proyecto:

| Fichero | Patrón | Problema |
|--------|--------|---------|
| `Utilities/Validation/AccomplishmentValidator.swift` | `Result<String, ValidationError>` | Código verboso, no es del Domain layer |
| `Domain/AccomplishmentValidatorNew.swift` | `throws` | Limpio, correcto, pero con nombre provisional |

`Accomplishment.swift` (capa Data) aún usaba el validator antiguo con este código:

```swift
// Antes (verboso e incorrecto de capa):
let textResult = AccomplishmentValidator.validateText(text)
guard case .success(let validatedText) = textResult else {
    if case .failure(let error) = textResult {
        throw error
    }
    throw ValidationError.emptyText
}
```

Después del commit:

```swift
// Después (limpio):
self.text = try AccomplishmentValidator.validateText(text)
```

**Cambios concretos:**
1. `AccomplishmentValidatorNew.swift` renombrado a `AccomplishmentValidator.swift` (mismo Domain, nombre sin el sufijo provisional)
2. `Accomplishment.swift` simplificado: usa `try` directamente en lugar del pattern matching de Result
3. `AddAccomplishmentUseCase.swift` actualizado: referencia al nuevo nombre
4. `Utilities/Validation/AccomplishmentValidator.swift` eliminado
5. `project.pbxproj` actualizado con el nuevo nombre de fichero

**Por qué importa:** El Domain layer es ahora la única fuente de verdad para validación de texto. No hay dos validadores con distintos patrones causando confusión.

---

## Estado actual de las capas

```
Domain/
├── AccomplishmentRepository.swift      # Protocolo de persistencia
├── AccomplishmentValidator.swift       # Validación de texto (throws)
├── NewAccomplishment.swift             # DTO para crear logros
├── ValidationError.swift               # Errores de dominio
└── useCases/
    ├── AddAccomplishmentUseCase.swift
    ├── GetAccomplishmentsUseCase.swift
    └── DeleteAccomplishmentUseCase.swift

Data/
└── Accomplishment.swift                # @Model SwiftData

Presentation/Views/Main/
├── MainViewModel.swift                 # @Observable, orquesta use cases
└── MainView.swift                      # Sin dependencias de SwiftData
```

---

## Próximos pasos sugeridos

### 1. Mover la foto fuera de `ContentView` (prioridad alta)

Actualmente `ContentView` inserta fotos directamente en el `ModelContext`:

```swift
private func addPhotoItem(photoData: Data, caption: String?) {
    let newItem = try Accomplishment(photoData: photoData, text: caption)
    modelContext.insert(newItem)
}
```

Debería existir un `AddPhotoAccomplishmentUseCase` en el Domain layer.

### 2. Hacer `accomplishmentsCount` computed (prioridad baja)

En `MainViewModel`, `accomplishmentsCount` se actualiza manualmente tras cada carga. Podría ser una propiedad computed:

```swift
var accomplishmentsCount: Int { accomplishments.count }
```

### 3. Eliminar el `print` de debug en `MainViewModel.delete`

```swift
print("Deleting:", accomplishment) // ← eliminar antes de producción
```
