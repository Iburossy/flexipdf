# Prochaines étapes - FlexiPDF

## ✅ Ce qui a été fait

### Architecture de base
- ✅ Structure Clean Architecture complète
- ✅ Séparation en couches (Domain, Data, Presentation)
- ✅ Entités du domaine (PdfDocument, PdfPage, PdfOperation, etc.)
- ✅ Repositories (interfaces)
- ✅ Use cases (Merge, Split, Compress, Load)
- ✅ Gestion des erreurs avec Result type
- ✅ Extensions utilitaires
- ✅ Thème moderne (clair/sombre)

### Configuration
- ✅ Dépendances configurées dans pubspec.yaml
- ✅ Structure de dossiers organisée
- ✅ Constantes et strings centralisés
- ✅ Logger pour le débogage

### Interface utilisateur
- ✅ Écran d'accueil avec grille de fonctionnalités
- ✅ Widget FeatureCard réutilisable
- ✅ Thème Material 3 moderne

### Documentation
- ✅ README complet
- ✅ Guide d'architecture (ARCHITECTURE.md)
- ✅ Guide de démarrage (GETTING_STARTED.md)
- ✅ Liste TODO (TODO.md)

## 🔄 Prochaines étapes immédiates

### 1. Installer les dépendances

```bash
flutter pub get
```

**Note** : Certaines dépendances peuvent nécessiter des configurations natives (Android/iOS).

### 2. Implémenter le PdfLocalDataSource

Créer `lib/data/datasources/pdf_local_datasource_impl.dart` :

```dart
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfLocalDataSourceImpl implements PdfLocalDataSource {
  @override
  Future<PdfDocument> loadDocument(String filePath) async {
    // Implémenter avec Syncfusion
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final pdfDoc = PdfDocument(inputBytes: bytes);
    
    // Convertir en notre entité PdfDocument
    return _mapToPdfDocument(pdfDoc, filePath);
  }
  
  // Implémenter les autres méthodes...
}
```

### 3. Implémenter le StorageRepository

Créer `lib/data/repositories/storage_repository_impl.dart` :

```dart
import 'package:path_provider/path_provider.dart';

class StorageRepositoryImpl implements StorageRepository {
  @override
  Future<Result<String>> getDocumentsDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return Success(dir.path);
    } catch (e) {
      return ResultFailure(StorageFailure(message: e.toString()));
    }
  }
  
  // Implémenter les autres méthodes...
}
```

### 4. Configurer l'injection de dépendances

Créer `lib/core/di/injection.dart` :

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<PdfRepository>(
    () => PdfRepositoryImpl(
      localDataSource: getIt(),
    ),
  );
  
  // Data sources
  getIt.registerLazySingleton<PdfLocalDataSource>(
    () => PdfLocalDataSourceImpl(),
  );
  
  // Use cases
  getIt.registerLazySingleton(() => MergePdfsUseCase(getIt()));
  getIt.registerLazySingleton(() => SplitPdfUseCase(getIt()));
  // ...
}
```

### 5. Créer les BLoCs pour le state management

Exemple pour Merge :

```dart
// lib/presentation/bloc/merge/merge_bloc.dart
class MergeBloc extends Bloc<MergeEvent, MergeState> {
  final MergePdfsUseCase mergePdfsUseCase;
  
  MergeBloc({required this.mergePdfsUseCase}) : super(MergeInitial()) {
    on<MergePdfsRequested>(_onMergePdfsRequested);
  }
  
  Future<void> _onMergePdfsRequested(
    MergePdfsRequested event,
    Emitter<MergeState> emit,
  ) async {
    emit(MergeLoading());
    
    final result = await mergePdfsUseCase(event.params);
    
    result.fold(
      onSuccess: (document) => emit(MergeSuccess(document)),
      onFailure: (failure) => emit(MergeError(failure.message)),
    );
  }
}
```

### 6. Créer les écrans de fonctionnalités

Exemple pour Merge :

```dart
// lib/presentation/screens/merge/merge_screen.dart
class MergeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<MergeBloc>(),
      child: MergeScreenBody(),
    );
  }
}
```

### 7. Configurer les permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to import images</string>
```

## 📋 Ordre de développement recommandé

### Phase 1 : Infrastructure (1-2 jours)
1. ✅ Architecture de base (FAIT)
2. Installer dépendances : `flutter pub get`
3. Implémenter PdfLocalDataSource
4. Implémenter StorageRepository
5. Configurer DI (Dependency Injection)

### Phase 2 : Fonctionnalités de base (3-5 jours)
1. **Visualisation PDF**
   - Écran de visualisation
   - Zoom et navigation
   - Miniatures

2. **Merge PDFs**
   - Sélection de fichiers
   - Prévisualisation
   - Fusion et sauvegarde

3. **Split PDF**
   - Sélection du fichier
   - Options de division
   - Export

4. **Compress PDF**
   - Options de compression
   - Comparaison taille

### Phase 3 : Scanner & OCR (2-3 jours)
1. Scanner avec caméra
2. Détection de bordures
3. OCR avec ML Kit
4. Export en PDF

### Phase 4 : Sécurité (1-2 jours)
1. Protection par mot de passe
2. Déchiffrement
3. Coffre-fort chiffré

### Phase 5 : Polish & Tests (2-3 jours)
1. Tests unitaires
2. Tests d'intégration
3. Optimisations performance
4. UX improvements

## 🛠️ Commandes utiles

### Développement
```bash
# Lancer l'app
flutter run

# Hot reload
r (dans le terminal)

# Hot restart
R (dans le terminal)

# Analyser le code
flutter analyze

# Formater le code
flutter format lib/
```

### Tests
```bash
# Tous les tests
flutter test

# Avec coverage
flutter test --coverage

# Test spécifique
flutter test test/domain/usecases/merge_pdfs_usecase_test.dart
```

### Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📚 Ressources importantes

### Documentation
- [Syncfusion PDF](https://help.syncfusion.com/flutter/pdf/overview)
- [Google ML Kit](https://developers.google.com/ml-kit/vision/text-recognition)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

### Exemples de code
- Voir `docs/GETTING_STARTED.md` pour des exemples
- Voir `docs/ARCHITECTURE.md` pour l'architecture
- Voir `docs/TODO.md` pour la roadmap complète

## ⚠️ Points d'attention

1. **Syncfusion License** : Syncfusion nécessite une licence (gratuite pour usage personnel)
2. **Permissions** : Configurer les permissions Android/iOS avant de tester
3. **Taille de l'app** : Les bibliothèques PDF peuvent augmenter la taille
4. **Performance** : Tester avec de gros fichiers (>50MB)
5. **Mémoire** : Implémenter le streaming pour éviter les OutOfMemory

## 🎯 Objectif immédiat

**Commencer par implémenter la visualisation PDF et la fusion de PDFs** - ce sont les fonctionnalités les plus critiques et elles serviront de base pour les autres.

## 💡 Conseils

- Commencer petit : implémenter une fonctionnalité à la fois
- Tester régulièrement sur device réel
- Utiliser le Logger pour déboguer
- Suivre les bonnes pratiques (voir GETTING_STARTED.md)
- Commit régulièrement avec des messages clairs

---

**Bon développement ! 🚀**
