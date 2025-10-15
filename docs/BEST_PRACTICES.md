# Bonnes Pratiques - FlexiPDF

Ce document décrit les bonnes pratiques suivies dans le développement de FlexiPDF.

## 🏗️ Architecture

### Clean Architecture
- **Séparation en couches** : Domain, Data, Presentation
- **Indépendance** : Le domaine ne dépend d'aucune couche externe
- **Testabilité** : Chaque couche peut être testée indépendamment

### Dependency Injection
- Utilisation de `get_it` pour l'injection de dépendances
- Enregistrement centralisé dans `injection.dart`
- Factory pattern pour les BLoCs (nouvelle instance à chaque fois)
- Singleton pour les repositories et services

## 📁 Gestion des Fichiers

### Stockage Public
```dart
// ✅ BON : Utiliser StorageRepository pour accéder aux dossiers
final storageRepository = getIt<StorageRepository>();
final downloadResult = await storageRepository.getDownloadDirectory();

// ❌ MAUVAIS : Chemins hardcodés
final path = '/storage/emulated/0/Download/file.pdf';
```

### Création de Répertoires
```dart
// ✅ BON : Créer le répertoire avant d'écrire
final outputDir = Directory(outputDirectory);
if (!await outputDir.exists()) {
  await outputDir.create(recursive: true);
}

// ❌ MAUVAIS : Supposer que le répertoire existe
await File(outputPath).writeAsBytes(bytes);
```

## 🔐 Permissions

### Demande de Permissions
```dart
// ✅ BON : Vérifier et demander avant l'action
final hasPermission = await PermissionHelper.requestStoragePermission();
if (!hasPermission) {
  context.showErrorSnackBar('Permission required');
  return;
}

// ❌ MAUVAIS : Supposer que la permission est accordée
final result = await FilePicker.platform.pickFiles();
```

### Permissions Android 13+
- Utiliser `photos`, `videos`, `audio` au lieu de `storage`
- Gérer les permissions de manière granulaire
- Fallback pour les anciennes versions d'Android

## 🎨 Interface Utilisateur

### Feedback Utilisateur
```dart
// ✅ BON : Afficher le chemin complet du fichier
context.showSnackBar(
  'PDF created successfully\nSaved in: $filePath',
);

// ❌ MAUVAIS : Message générique
context.showSnackBar('PDF created');
```

### États de Chargement
```dart
// ✅ BON : Utiliser LoadingOverlay avec progression
if (state is PdfLoading)
  LoadingOverlay(
    message: state.message ?? 'Processing...',
    progress: state.progress,
  ),

// ❌ MAUVAIS : Bloquer toute l'interface
if (_isLoading) CircularProgressIndicator(),
```

### Gestion des Erreurs
```dart
// ✅ BON : Messages d'erreur descriptifs
context.showErrorSnackBar(
  'Failed to access downloads: ${failure.message}',
);

// ❌ MAUVAIS : Messages génériques
context.showErrorSnackBar('Error');
```

## 🔄 Gestion d'État (BLoC)

### Events
```dart
// ✅ BON : Events immutables avec Equatable
class MergePdfs extends PdfEvent {
  final List<String> filePaths;
  final String outputPath;

  const MergePdfs({
    required this.filePaths,
    required this.outputPath,
  });

  @override
  List<Object?> get props => [filePaths, outputPath];
}
```

### States
```dart
// ✅ BON : States typés et descriptifs
sealed class PdfState extends Equatable {
  const PdfState();
}

class PdfLoading extends PdfState {
  final String? message;
  final double? progress;
  
  const PdfLoading({this.message, this.progress});
}
```

## 📦 Traitement PDF

### Utilisation de Syncfusion
```dart
// ✅ BON : Utiliser createTemplate() pour copier les pages
final sourcePage = sourceDoc.pages[i];
final page = mergedDoc.pages.add();
final template = sourcePage.createTemplate();
page.graphics.drawPdfTemplate(template, Offset.zero);

// ❌ MAUVAIS : Utiliser importPageRange (n'existe pas en Flutter)
mergedDoc.importPageRange(sourceDoc, 0, count);
```

### Compression
```dart
// ✅ BON : Options de compression configurables
final options = CompressionOptions(
  level: CompressionLevel.medium,
  optimizeImages: true,
  imageQuality: 75,
  removeMetadata: false,
);

// ❌ MAUVAIS : Compression hardcodée
// Pas de contrôle utilisateur
```

## 🖼️ Scanner de Documents

### Capture d'Images
```dart
// ✅ BON : Demander la permission appropriée selon la source
if (source == ImageSource.camera) {
  hasPermission = await PermissionHelper.requestCameraPermission();
} else {
  hasPermission = await PermissionHelper.requestPhotosPermission();
}

// ❌ MAUVAIS : Demander toutes les permissions
await Permission.camera.request();
await Permission.photos.request();
```

### Crop d'Images
```dart
// ✅ BON : Permettre le crop après capture
final croppedFile = await ImageCropper().cropImage(
  sourcePath: image.path,
  uiSettings: [
    AndroidUiSettings(
      toolbarTitle: 'Crop Document',
      aspectRatioPresets: [...],
    ),
  ],
);

// ❌ MAUVAIS : Utiliser l'image brute
_scannedImages.add(image.path);
```

## 📖 Visualisation PDF

### Utilisation de pdfx
```dart
// ✅ BON : Contrôleur avec gestion d'erreurs
_pdfController = PdfController(
  document: PdfDocument.openFile(widget.filePath),
);

try {
  final document = await PdfDocument.openFile(widget.filePath);
  setState(() {
    _totalPages = document.pagesCount;
    _isLoading = false;
  });
} catch (e) {
  setState(() {
    _errorMessage = 'Failed to load PDF: $e';
  });
}

// ❌ MAUVAIS : Pas de gestion d'erreurs
PdfView(controller: _pdfController);
```

### Navigation
```dart
// ✅ BON : Contrôles de navigation intuitifs
- Boutons Précédent/Suivant
- Indicateur de page cliquable
- Raccourcis première/dernière page
- Dialogue "Go to page"

// ❌ MAUVAIS : Seulement le scroll
```

## 🧪 Tests

### Tests Unitaires
```dart
// ✅ BON : Tester la logique métier
test('should merge PDFs successfully', () async {
  // Arrange
  final params = MergePdfsParams(...);
  
  // Act
  final result = await useCase(params);
  
  // Assert
  expect(result.isSuccess, true);
});
```

### Tests d'Intégration
```dart
// ✅ BON : Tester les flux complets
testWidgets('should display merged PDF path', (tester) async {
  // Arrange
  await tester.pumpWidget(MyApp());
  
  // Act
  await tester.tap(find.text('Merge'));
  await tester.pump();
  
  // Assert
  expect(find.text('Saved in:'), findsOneWidget);
});
```

## 📝 Documentation

### Code
```dart
// ✅ BON : Documentation claire et concise
/// Merges multiple PDF files into a single document
/// 
/// [filePaths] List of PDF file paths to merge
/// [outputPath] Path where the merged PDF will be saved
/// [pageRanges] Optional page ranges to include
Future<Result<PdfDocument>> mergePdfs({...});

// ❌ MAUVAIS : Pas de documentation
Future<Result<PdfDocument>> mergePdfs({...});
```

### README
- Instructions d'installation claires
- Exemples d'utilisation
- Liste des fonctionnalités
- Captures d'écran

## 🔒 Sécurité

### Validation des Entrées
```dart
// ✅ BON : Valider avant traitement
if (_selectedFiles.length < 2) {
  context.showErrorSnackBar('Please select at least 2 PDF files');
  return;
}

// ❌ MAUVAIS : Supposer que les données sont valides
context.read<PdfBloc>().add(MergePdfs(...));
```

### Gestion des Fichiers Temporaires
```dart
// ✅ BON : Nettoyer les fichiers temporaires
await storageRepository.cleanTempFiles();

// ❌ MAUVAIS : Laisser les fichiers s'accumuler
```

## ⚡ Performance

### Chargement Asynchrone
```dart
// ✅ BON : Opérations lourdes en arrière-plan
Future<void> _compressPdf() async {
  setState(() => _isProcessing = true);
  
  try {
    await heavyOperation();
  } finally {
    setState(() => _isProcessing = false);
  }
}

// ❌ MAUVAIS : Bloquer le thread UI
void _compressPdf() {
  heavyOperation(); // Bloque l'UI
}
```

### Optimisation Mémoire
```dart
// ✅ BON : Dispose des ressources
@override
void dispose() {
  _pdfController.dispose();
  _textController.dispose();
  super.dispose();
}

// ❌ MAUVAIS : Fuites mémoire
// Pas de dispose()
```

## 🌍 Internationalisation

### Constantes de Texte
```dart
// ✅ BON : Utiliser AppStrings
title: const Text(AppStrings.merge),

// ❌ MAUVAIS : Texte hardcodé
title: const Text('Merge PDFs'),
```

### Support Multi-langue
- Préparer pour i18n
- Utiliser des clés de traduction
- Éviter les textes hardcodés

## 📊 Logging

### Utilisation du Logger
```dart
// ✅ BON : Logger les opérations importantes
_logger.info('Merging ${filePaths.length} PDFs');
_logger.error('Error merging PDFs', e, stackTrace);

// ❌ MAUVAIS : print()
print('Merging PDFs');
```

---

**Dernière mise à jour** : Janvier 2025  
**Version** : 1.0.0
