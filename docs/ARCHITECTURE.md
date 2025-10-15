# FlexiPDF - Architecture Documentation

## Vue d'ensemble

FlexiPDF est une application mobile Flutter qui implémente toutes les fonctionnalités d'iLovePDF de manière 100% locale, sans jamais envoyer de fichiers sur Internet.

## Architecture

L'application suit les principes de **Clean Architecture** avec une séparation claire des responsabilités :

```
lib/
├── core/                   # Code partagé et utilitaires
│   ├── constants/         # Constantes de l'application
│   ├── errors/            # Gestion des erreurs (Failures, Exceptions)
│   ├── extensions/        # Extensions Dart
│   ├── theme/             # Configuration du thème
│   └── utils/             # Utilitaires (Logger, Result)
│
├── domain/                 # Logique métier pure
│   ├── entities/          # Entités métier
│   ├── repositories/      # Interfaces des repositories
│   └── usecases/          # Cas d'utilisation
│
├── data/                   # Implémentation des sources de données
│   ├── datasources/       # Sources de données (local, remote)
│   ├── models/            # Modèles de données
│   └── repositories/      # Implémentation des repositories
│
└── presentation/           # Interface utilisateur
    ├── screens/           # Écrans de l'application
    ├── widgets/           # Widgets réutilisables
    └── bloc/              # State management (BLoC)
```

## Principes de conception

### 1. Clean Architecture
- **Séparation des couches** : Domain, Data, Presentation
- **Inversion de dépendances** : Les couches externes dépendent des couches internes
- **Indépendance du framework** : La logique métier est indépendante de Flutter

### 2. SOLID Principles
- **Single Responsibility** : Chaque classe a une seule responsabilité
- **Open/Closed** : Ouvert à l'extension, fermé à la modification
- **Liskov Substitution** : Les sous-types doivent être substituables
- **Interface Segregation** : Interfaces spécifiques plutôt que générales
- **Dependency Inversion** : Dépendre d'abstractions, pas d'implémentations

### 3. DRY (Don't Repeat Yourself)
- Utilisation d'extensions pour éviter la duplication
- Widgets réutilisables
- Utilitaires partagés

## Gestion des erreurs

### Result Type
Utilisation d'un type `Result<T>` pour gérer les succès et les échecs :

```dart
Result<PdfDocument> result = await loadDocument(path);
result.fold(
  onSuccess: (document) => print('Success: ${document.name}'),
  onFailure: (failure) => print('Error: ${failure.message}'),
);
```

### Failures vs Exceptions
- **Exceptions** : Erreurs techniques dans la couche data
- **Failures** : Erreurs métier dans la couche domain

## State Management

Utilisation de **BLoC (Business Logic Component)** :
- Séparation claire entre UI et logique
- Testabilité
- Réactivité avec Streams

## Dépendances principales

### PDF Processing
- `syncfusion_flutter_pdf` : Manipulation PDF complète
- `pdf` : Création de PDF
- `pdfx` : Visualisation PDF

### Image Processing
- `image` : Traitement d'images
- `camera` : Capture photo
- `image_picker` : Sélection d'images

### OCR
- `google_mlkit_text_recognition` : Reconnaissance de texte locale

### Storage
- `path_provider` : Accès aux répertoires
- `sqflite` : Base de données locale
- `hive` : Stockage clé-valeur

### Security
- `encrypt` : Chiffrement AES
- `flutter_secure_storage` : Stockage sécurisé

## Fonctionnalités MVP

1. **Fusionner PDF** - Combiner plusieurs fichiers
2. **Diviser PDF** - Séparer en plusieurs fichiers
3. **Compresser PDF** - Réduire la taille
4. **Visualiser PDF** - Affichage avec zoom
5. **Scanner** - Photo → PDF avec détection de bordures
6. **OCR** - Reconnaissance de texte
7. **Protection** - Chiffrement par mot de passe

## Sécurité et confidentialité

- ✅ 100% local - Aucune donnée envoyée sur Internet
- ✅ Chiffrement AES-256 pour le coffre-fort
- ✅ Stockage sécurisé des clés
- ✅ Permissions minimales
- ✅ Sandboxing iOS/Android

## Tests

- **Tests unitaires** : Logique métier et use cases
- **Tests d'intégration** : Repositories et data sources
- **Tests widgets** : Interface utilisateur

## Évolutivité

L'architecture permet d'ajouter facilement :
- Nouvelles fonctionnalités PDF
- Nouveaux formats de conversion
- Nouvelles langues OCR
- Nouveaux thèmes
- Nouvelles plateformes (Web, Desktop)
