# Guide de démarrage - FlexiPDF

## Prérequis

- Flutter SDK 3.9.2+
- Dart SDK 3.9.2+
- Android Studio / VS Code
- Git

## Installation

### 1. Cloner le projet

```bash
git clone <repository-url>
cd flexipdf
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Vérifier l'installation

```bash
flutter doctor
```

## Structure du projet

```
lib/
├── core/                   # Code partagé
│   ├── constants/         # Constantes (AppConstants, AppStrings)
│   ├── errors/            # Gestion des erreurs
│   ├── extensions/        # Extensions Dart
│   ├── theme/             # Thème de l'application
│   └── utils/             # Utilitaires (Logger, Result)
│
├── domain/                 # Logique métier
│   ├── entities/          # Entités (PdfDocument, PdfPage, etc.)
│   ├── repositories/      # Interfaces des repositories
│   └── usecases/          # Cas d'utilisation
│
├── data/                   # Implémentation
│   ├── datasources/       # Sources de données
│   ├── models/            # Modèles de données
│   └── repositories/      # Implémentation des repositories
│
└── presentation/           # Interface utilisateur
    ├── screens/           # Écrans
    ├── widgets/           # Widgets réutilisables
    └── bloc/              # State management
```

## Lancer l'application

### Android

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

### Mode debug

```bash
flutter run --debug
```

### Mode release

```bash
flutter run --release
```

## Développement

### Ajouter une nouvelle fonctionnalité

1. **Créer l'entité** dans `domain/entities/`
2. **Créer le use case** dans `domain/usecases/`
3. **Implémenter le repository** dans `data/repositories/`
4. **Créer l'UI** dans `presentation/screens/`
5. **Ajouter le state management** avec BLoC

### Exemple : Ajouter une fonctionnalité de rotation

```dart
// 1. Entité (déjà existante)
class PdfPage {
  final int rotation;
  // ...
}

// 2. Use Case
class RotatePagesUseCase implements UseCase<PdfDocument, RotatePagesParams> {
  final PdfRepository repository;
  
  @override
  Future<Result<PdfDocument>> call(RotatePagesParams params) async {
    return await repository.rotatePages(
      filePath: params.filePath,
      outputPath: params.outputPath,
      pageRotations: params.pageRotations,
    );
  }
}

// 3. Repository (déjà implémenté)
// Voir pdf_repository.dart

// 4. UI
class RotateScreen extends StatelessWidget {
  // Implementation
}
```

## Bonnes pratiques

### 1. Gestion des erreurs

Toujours utiliser le type `Result<T>` :

```dart
final result = await loadDocument(path);
result.fold(
  onSuccess: (document) {
    // Traiter le succès
  },
  onFailure: (failure) {
    // Gérer l'erreur
  },
);
```

### 2. Extensions

Utiliser les extensions pour éviter la duplication :

```dart
// Utiliser context.showSnackBar au lieu de ScaffoldMessenger
context.showSnackBar('Message');

// Utiliser context.navigateTo au lieu de Navigator.push
context.navigateTo(NextScreen());
```

### 3. Constantes

Centraliser les constantes dans `AppConstants` et `AppStrings` :

```dart
// ❌ Éviter
const padding = 16.0;

// ✅ Préférer
AppConstants.defaultPadding
```

### 4. Logging

Utiliser le Logger pour le débogage :

```dart
final _logger = Logger('MyClass');

_logger.info('Information message');
_logger.error('Error occurred', error, stackTrace);
```

## Tests

### Lancer tous les tests

```bash
flutter test
```

### Lancer un test spécifique

```bash
flutter test test/widget_test.dart
```

### Coverage

```bash
flutter test --coverage
```

## Build

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Dépendances principales

### PDF
- **syncfusion_flutter_pdf** : Manipulation PDF complète
- **pdf** : Création de PDF
- **pdfx** : Visualisation PDF

### State Management
- **flutter_bloc** : BLoC pattern
- **equatable** : Comparaison de valeurs

### Storage
- **path_provider** : Accès aux répertoires
- **sqflite** : Base de données SQL
- **hive** : Stockage clé-valeur

### Security
- **encrypt** : Chiffrement AES
- **flutter_secure_storage** : Stockage sécurisé

## Prochaines étapes

1. **Installer les dépendances** : `flutter pub get`
2. **Lancer l'app** : `flutter run`
3. **Lire la documentation** : Voir `ARCHITECTURE.md`
4. **Implémenter les fonctionnalités** : Commencer par le MVP

## Ressources

- [Documentation Flutter](https://flutter.dev/docs)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Syncfusion PDF](https://help.syncfusion.com/flutter/pdf/overview)

## Support

Pour toute question, ouvrir une issue sur GitHub.
