# TODO - FlexiPDF

## Phase 1 : MVP (Minimum Viable Product)

### ✅ Complété
- [x] Architecture de base (Clean Architecture)
- [x] Structure des dossiers
- [x] Entités du domaine
- [x] Repositories (interfaces)
- [x] Use cases de base
- [x] Thème et constantes
- [x] Extensions utilitaires
- [x] Gestion des erreurs (Result, Failures, Exceptions)
- [x] UI de base (HomeScreen)
- [x] Documentation (README, ARCHITECTURE, GETTING_STARTED)

### 🔄 En cours
- [ ] Implémentation du PdfLocalDataSource avec Syncfusion
- [ ] Implémentation du StorageRepository
- [ ] State management avec BLoC

### 📋 À faire - Fonctionnalités MVP

#### Core PDF Operations
- [ ] **Merge PDFs**
  - [ ] Sélection de fichiers multiples
  - [ ] Prévisualisation des pages
  - [ ] Options de fusion (ordre, pages spécifiques)
  - [ ] Barre de progression
  
- [ ] **Split PDF**
  - [ ] Sélection du fichier
  - [ ] Options de division (par page, par plage, par taille)
  - [ ] Prévisualisation
  - [ ] Export multiple
  
- [ ] **Compress PDF**
  - [ ] Niveaux de compression (low, medium, high)
  - [ ] Options avancées (images, métadonnées)
  - [ ] Comparaison avant/après
  
- [ ] **Rotate Pages**
  - [ ] Rotation par page
  - [ ] Rotation de toutes les pages
  - [ ] Prévisualisation en temps réel

#### Visualisation
- [ ] **PDF Viewer**
  - [ ] Affichage des pages
  - [ ] Zoom et pan
  - [ ] Miniatures
  - [ ] Navigation entre pages
  - [ ] Recherche de texte

#### Scanner & OCR
- [ ] **Scanner**
  - [ ] Capture photo
  - [ ] Détection de bordures
  - [ ] Correction de perspective
  - [ ] Enhancement (contraste, luminosité)
  - [ ] Conversion en PDF
  
- [ ] **OCR**
  - [ ] Intégration Google ML Kit
  - [ ] Sélection de langue (FR, EN)
  - [ ] Export texte
  - [ ] PDF searchable

#### Sécurité
- [ ] **Protect PDF**
  - [ ] Chiffrement par mot de passe
  - [ ] Options de permissions
  
- [ ] **Unlock PDF**
  - [ ] Déchiffrement
  - [ ] Validation du mot de passe

#### Gestion des fichiers
- [ ] **File Manager**
  - [ ] Liste des fichiers récents
  - [ ] Import depuis stockage
  - [ ] Export vers stockage
  - [ ] Partage
  - [ ] Suppression

## Phase 2 : Fonctionnalités avancées

### Conversion
- [ ] Image to PDF
- [ ] PDF to Image
- [ ] Office to PDF (avec SDK commercial)
- [ ] PDF to Office (avec SDK commercial)

### Édition avancée
- [ ] Watermark (texte et image)
- [ ] Annotations
- [ ] Formulaires
- [ ] Signature numérique (PAdES)
- [ ] Extraction d'images
- [ ] Métadonnées

### Organisation
- [ ] Drag & drop pour réorganiser
- [ ] Extract pages
- [ ] Delete pages
- [ ] Bookmarks

### Autres
- [ ] Comparaison de PDFs
- [ ] Historique des opérations
- [ ] Undo/Redo
- [ ] Coffre-fort chiffré

## Phase 3 : Optimisations & Polish

### Performance
- [ ] Traitement en background (Isolates)
- [ ] Streaming pour gros fichiers
- [ ] Cache des miniatures
- [ ] Optimisation mémoire

### UX/UI
- [ ] Animations fluides
- [ ] Tutoriels intégrés
- [ ] Mode sombre/clair
- [ ] Localisation (FR, EN, ES, DE)
- [ ] Accessibilité

### Tests
- [ ] Tests unitaires (Use cases)
- [ ] Tests d'intégration (Repositories)
- [ ] Tests widgets (UI)
- [ ] Tests E2E

### DevOps
- [ ] CI/CD (GitHub Actions)
- [ ] Code coverage
- [ ] Analyse statique
- [ ] Release automatique

## Phase 4 : Fonctionnalités premium

- [ ] Conversion Office complète
- [ ] Signature numérique avancée
- [ ] Batch processing
- [ ] Templates PDF
- [ ] Cloud sync (optionnel, opt-in)
- [ ] Backup automatique

## Bugs connus

- Aucun pour le moment

## Notes techniques

### Dépendances à évaluer
- [ ] Évaluer MuPDF vs Syncfusion pour performance
- [ ] Tester Tesseract OCR vs Google ML Kit
- [ ] Comparer Hive vs Sqflite pour stockage

### Décisions architecturales
- [x] Clean Architecture adoptée
- [x] BLoC pour state management
- [x] Result type pour gestion des erreurs
- [ ] Dependency injection avec get_it
- [ ] Navigation avec go_router (à décider)

### Optimisations futures
- [ ] Lazy loading des pages PDF
- [ ] Compression des miniatures
- [ ] Cache intelligent
- [ ] Background processing avec WorkManager

## Priorités

1. **P0 (Critique)** : Fonctionnalités MVP
2. **P1 (Haute)** : Visualisation et Scanner
3. **P2 (Moyenne)** : Fonctionnalités avancées
4. **P3 (Basse)** : Optimisations et polish

## Timeline estimé

- **Semaine 1-2** : Implémentation PDF de base (merge, split, compress)
- **Semaine 3** : Visualisation et navigation
- **Semaine 4** : Scanner et OCR
- **Semaine 5** : Sécurité et gestion fichiers
- **Semaine 6** : Tests et optimisations
- **Semaine 7-8** : Fonctionnalités avancées
- **Semaine 9-10** : Polish et release

---

**Dernière mise à jour** : 2025-01-XX
