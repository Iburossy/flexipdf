
Cahier des charges — Application mobile 100% locale (équivalent d’iLovePDF, tout le traitement sur l’appareil)

Objectif : fournir sur mobile (Android + iOS) une application capable d’exécuter toutes les opérations disponibles sur iLovePDF — fusion, séparation, conversion, compression, OCR, signature, etc. — sans jamais envoyer les fichiers sur Internet. Tout le traitement se fait localement sur le téléphone de l’utilisateur.

1. Périmètre fonctionnel (liste exhaustive des fonctionnalités à implémenter)

Chaque fonctionnalité doit pouvoir être exécutée entièrement en local.

Opérations de base sur PDF

Fusionner plusieurs PDF (merge) — option: sélectionner pages / ordonner / ajouter pages blanches.

Séparer un PDF (split) — par pages individuelles, plages, taille de fichier, ou signets.

Extraire des pages (extract).

Supprimer des pages.

Réorganiser / permuter des pages.

Rotation de pages (par page ou toutes).

Découper (crop) les pages.

Redimensionner / mettre à l’échelle les pages.

Compresser PDF (plusieurs niveaux : faible/medium/fort) — optimisation image, suppression métadonnées, linearisation.

Réparer / optimiser structure du PDF (corriger objets corrompus).

Protéger par mot de passe / chiffrer (owner/user password) et déverrouiller (unlock).

Ajouter/supprimer watermark (texte/image) sur toutes pages ou plages.

Ajouter numéros de page / en-têtes / pieds de page.

Annotation & édition (ajouter texte, boîtes de texte, surlignage, formes, commentaires).

Conversion PDF ↔ Office :

PDF → Word (.docx)

PDF → Excel (.xlsx)

PDF → PowerPoint (.pptx)

Word/Excel/PPT → PDF

Conversion image ↔ PDF :

JPG/PNG → PDF (une image = 1 page ; options: qualité, orientation, multiple images par page)

PDF → JPG/PNG (exporter pages en images, choix de résolution)

OCR (reconnaissance de texte local) : image/scans → PDF texte (PDF searchable) ; export texte (TXT), DOCX. Support multilingue.

Signature électronique locale : dessiner / image signature / importer certificat (PFX) ; signer numériquement et vérifier signature.

Extraire texte (text layer) / copie du texte du PDF.

Recherche de texte dans PDF (indexation locale facultative).

Conversion vers/depuis formats d’image vectorielle si pertinent (SVG).

Compression/archivage (ZIP) de plusieurs fichiers.

Visualisation PDF (zoom, recherche, miniatures, aperçu pages).

Gestionnaire de fichiers intégré : ouvrir depuis stockage local, importer depuis galerie, partager (export local), ouvrir avec autres apps.

Scanner de documents : prise de photo, détection de bordures, correction perspective, enhancement (contraste), conversion en PDF.

OCR et correction automatique sur scans.

Fonction “Organiser” visuelle : miniatures, glisser-déposer pour réordonner.

Historique local des opérations + annuler/refaire (dans la session et lorsque possible : versioning).

Comparaison / diff de deux PDFs (pages manquantes / différences textuelles basiques).

Prévisualisation des modifications avant enregistrement.

Exporter et partager le résultat (fichier local, Bluetooth, partage Android/iOS).

Import/Export de métadonnées (titre, auteur, mots-clés).

Support des signets (bookmarks) : extraire, créer, modifier.

Extraction d’images intégrées au PDF.

Accessibilité (lecture vocale du texte extrait — option locale).

Localisation (multilingue UI).

Gestion des permissions et stockage sécurisé (sandbox).

2. Exigences fonctionnelles détaillées

Règle de confidentialité : aucun fichier ne sortira de l’appareil sauf action explicite de l’utilisateur (partage).

Modes d’import : stockage local, galerie, scanner (caméra), partage depuis d’autres apps, gestionnaire de fichiers.

Formats supportés en entrée / sortie : PDF, DOCX, XLSX, PPTX, JPG, PNG, TIFF, TXT, ZIP.

Options par opération : par exemple pour fusion → choisir pages, ordre, intercalation, compression post-merge.

OCR : choix de la langue (liste déroulante), seuil de qualité, possibilité d’exporter texte seul ou d’incruster couche texte dans PDF.

Signature : support signature visuelle et signature numérique (PKCS#12) ; afficher métadonnées de signature et vérifier validité (local).

Sécurité des fichiers : chiffrement AES-256 pour “coffre” optionnel où l’utilisateur peut stocker fichiers sensibles (avec PIN/biométrie).

Undo/Redo : pour opérations sur un document ouvert (pile d’actions locales jusqu’à sauvegarde finale).

Préférences utilisateur : dossier de travail par défaut, qualité d’export, OCR par défaut, langue UI.

3. Exigences non-fonctionnelles

100% local — aucune requête réseau par défaut.

Performance : traiter fichiers jusqu’à ~100–200 MB raisonnablement (dépend du device). Implémenter traitement en background (isolate / background thread) et progression/estimation pour l’utilisateur.

Robustesse : reprise après crash, sauvegarde temporaire (draft) des fichiers en cours.

Sécurité : stockage chiffré des éléments sensibles ; respecter sandboxing iOS/Android ; permissions minimales.

Compatibilité : Android (min SDK recommandé selon libs), iOS (version min selon PDFKit/tesseract).

UX : interface simple, actions courtes, prévisualisation, confirmation avant écraser fichier.

Localisation : AU MOINS français et anglais, extensible.

Accessibilité : support lecteurs d’écran, taille de texte dynamique.

Taille : garder l’application légère (éviter d’inclure modèles ML trop volumineux par défaut — proposer téléchargement on-demand pour langues OCR lourdes).

Licences : respecter licences des librairies (éviter AGPL sans conformité ou prévoir alternative commerciale).

4. Architecture technique / Modules

UI (Flutter) — écrans, navigation, interactions.

Core PDF Engine (native / bindings) — module qui exécute opérations lourdes (merge, split, compress, convert). Peut être : librairie Dart pure + wrappers natifs pour opérations avancées.

OCR Engine (local) — wrapper Tesseract ou autre moteur embarqué.

Image Processing Module — détection de bordures, correction perspective, enhancement (lib image).

Storage Layer — accès fichiers, sandbox, coffre chiffré.

Task Manager — exécution asynchrone, file d’attente des jobs, progress bar, cancel.

Preview Renderer — rendre miniatures & pages (PDF renderer natif / pdfium / PDFKit).

Signature & Crypto — gestion clés, PKCS#12 import, vérification signature.

Interop Module — open-with, share, export.

Communication interne : API locale entre Flutter UI et modules natifs (MethodChannel pour Android/iOS). Les opérations lourdes doivent tourner dans des isolates ou threads natifs.

5. Librairies / outils recommandés (options locales)

Choisir selon budget (open-source vs commercial). Je propose d’abord option open-source / gratuite, puis alternatives commerciales (si besoin de fiabilité et performances accrues).

Dart / Flutter (front-end)

pdf (package Dart) — création PDF.

printing — pour exporter/imprimer / preview.

flutter_pdfview / pdfx / native_pdf_view — affichage PDF.

image, image_picker, camera — capture et traitement d’images.

path_provider, permission_handler — accès fichier et permissions.

sqflite/hive — stockage local des métadonnées/historique.

encrypt — chiffrement AES local (pour coffre).

flutter_secure_storage — stocker clefs ou PIN (biométrie).

PDF processing (native / plus puissant)

Android (lib Java/C++) :

Apache PDFBox (Java) — manipulation (merge/split/extract) — open-source but heavy.

MuPDF (C, licence dual, rapide, très complet) — rendering, manipulation, OCR support via wrapper.

PDFium (Chromium) — rendu rapide (nécessite intégration native).

iOS :

PDFKit (Apple) — rendu et manipulation (local).

MuPDF ou Poppler (port) si besoin de parité fonctionnelle.

Conversion Office ↔ PDF

Conversion native complète (DOCX/XLSX/PPTX) localement est la partie la plus complexe. Options :

Utiliser des convertisseurs natifs embarqués (LibreOffice headless n’est pas adapté sur mobile).

Solution viable : intégrer des convertisseurs open-source légers (docx -> PDF via parsing docx and rendering pages via engine) — travail conséquent.

Alternative pragmatique : supporter l’import/export via format Office limité (export PDF depuis images ou HTML) et proposer conversion Office→PDF par ouverture locale avec app capable de le sauvegarder en PDF. Si conversion Office→PDF 100% locale impérative, envisager une SDK commerciale (ex. PDFTron, PSPDFKit, Syncfusion) — ces SDK font conversion Office ↔ PDF localement et proposent licences mobiles.

OCR

Tesseract OCR (via tesseract_ocr wrapper) — fonctionne localement ; multilingue ; possibilité de télécharger packs de langue à la demande.

Alternatives commerciales (pour meilleure qualité / vitesse) : ABBYY SDK (payant), Google ML Kit on-device (mais vérifier modèle offline et taille).

Signature numérique

utiliser bibliothèques cryptographiques (BouncyCastle pour Java, Security frameworks iOS) pour PKCS#7 / CMS signing ; ou intégrer SDKs commerciaux qui gèrent PAdES signatures (PDFTron, PSPDFKit).

6. Sécurité & confidentialité

Par défaut, aucune donnée envoyée sur un serveur externe. Toute demande de sync/cloud est explicitement opt-in et doit être clairement expliquée.

Stockage chiffré pour zone “sensible” (AES-256).

Utiliser biométrie (FaceID / Fingerprint) pour accéder au coffre.

Permissions : demander uniquement celles nécessaires (storage/camera).

Suppression sécurisée optionnelle (écraser fichiers temporaires).

Gestion des logs : ne pas stocker contenu sensible dans logs.

Respect licences : ne pas inclure de composants AGPL sans conformité.

7. UX / UI — exigences

Écran d’accueil : accès rapide à fonctions principales (Fusionner, Diviser, Compresser, Convertir, Scanner, OCR, Signer, Protéger).

Mode « Assistant » (wizard) pour chaque tâche (sélection fichiers → options → traitement → aperçu → enregistrer).

Écran “Organiser” avec miniatures et glisser-déposer.

Dialogue de progression pour chaque tâche (barre + % + estimé + bouton annuler).

Prévisualisation avant sauvegarde.

Feedback clair sur erreurs (fichier trop volumineux, mémoire insuffisante).

Paramètres avancés accessibles mais cachés pour la majorité.

Thème clair/sombre.

8. Stockage & gestion des fichiers

Utiliser répertoires app sandbox + option dossier “Export” accessible via Files/Explorer.

Gérer fichiers temporaires dans dossier chiffré, nettoyer après opération.

Option “Enregistrer une copie” vs “Écraser” (par défaut créer copie).

Index local (sqflite/hive) pour retrouver fichiers récents, opérations, tags.

9. Tests & QA

Tests unitaires des modules (conversion, merge, split).

Tests d’intégration (opérations complexes en chaîne : scan → OCR → merge → sign).

Tests de charge / mémoire (fichiers gros).

Tests sur appareils réels (faible mémoire, CPU bas).

Tests de sécurité (chiffrement, stockage, permissions).

Tests UX (accessibilité, multi-langue).

10. Livrables (à livrer)

Application compilée Android (APK/AAB) et iOS (IPA) prêtes à installer.

Code source complet (repo) + documentation de build.

Documentation technique (architecture, API internes, choix libs, licences).

Manuel utilisateur (FR/EN) couvrant toutes les fonctions.

Jeux de tests / rapport QA.

Guide d’intégration de modules (OCR packs, conversion Office si option SDK).

11. Critères d’acceptation

Chaque fonctionnalité listée en section 1 doit fonctionner entièrement hors-ligne sur un appareil de référence (ex. Android milieu de gamme récent, iOS équivalent).

La fusion/split/compress/convert/ocr/signature doivent produire fichiers valides (ouverts par autres viewer) et respecter options choisies.

Le chiffrement/déchiffrement fonctionne et protège l’accès au fichier.

L’application ne tente pas d’envoyer les fichiers sans autorisation explicite.

Interface réactive ; opérations longues montrent progression et peuvent être annulées.

Tests unitaires et d’intégration couvrant les cas critiques sont fournis.

12. Contraintes & recommandations importantes

Conversion Office ↔ PDF 100% locale est la fonction la plus coûteuse en développement si vous refusez tout SDK commercial. Pour disponibilité complète (Word/Excel/PPT <-> PDF) envisagez un SDK payant (PDFTron, PSPDFKit, Syncfusion) qui exécute ces conversions localement et qui facilitera la conformité et la qualité.

La taille de l’app peut augmenter si l’on embarque des packs OCR multilingues ; proposer téléchargement à la demande.

Certaines fonctionnalités (signature PAdES, vérification certificate chain offline) nécessitent gestion fine des certificats — prévoir support PKI local.

Performance et mémoire : pour gros fichiers il faudra implémenter streaming processing (ne pas charger tout en RAM). Utiliser moteurs natifs optimisés (MuPDF, PDFium).

13. Plan de livrables minimal (MVP) — sans durée, uniquement contenu

MVP (minimum pour version utilisable localement) :

Fusionner / Séparer / Extraire pages / Réorganiser / Rotation.

Visualisation PDF complète (zoom, miniature).

Scanner → image → PDF (edge detection + correction).

JPG/PNG → PDF et PDF → JPG (export image).

Compression de PDF (basique : recompression images).

Protéger par mot de passe / déverrouiller.

OCR (langue principale, ex. français + anglais).

Signature visuelle (dessin) et sauvegarde.

Gestionnaire de fichiers local + partage.

Logs & historique local simple.

Fonctionnalités avancées (post-MVP) : conversion Office↔PDF complète, signature numérique PAdES, comparaison avancée, extraction d’images, édition avancée de PDF, plugins langue OCR additionnelles, coffre chiffré complet.

14. Contraintes légales & licences

Vérifier licences de chaque bibliothèque (AGPL, GPL, BSD, commercial). Certaines libs comme iText ont AGPL/Commercial — l’utilisation impose obligations.

Si confidentialité pour entreprises : fournir clause claire sur non-transmission et option d’audit.

15. Recommandation finale technique (synthèse)

Front-end : Flutter (UI unique iOS/Android).

Rendering & manipulations lourdes : utiliser MuPDF ou PDFium via bindings natifs (performance + contrôle mémoire).

OCR : Tesseract on-device (packs de langues en téléchargement).

Conversion Office : si vous exigez conversions fiables 100% locales, prévoir licence SDK commerciale (PDFTron / PSPDFKit / Syncfusion) — sinon supporter conversions limitées et documenter les limites.

Signature numérique : implémentation via libs cryptographiques natives ; pour PAdES préférer SDK (gain temps et conformité).

Sécurité : chiffrement AES-256 pour coffre + stockage sécurisé des clefs.

16. Annexes — points d’implémentation pratiques

Implémenter traitement par jobs (queue) avec persistence (reprise après fermeture).

Prévoir option “mode économie” pour limiter qualité images quand device faible.

Implémenter tests E2E sur appareils réels (Firebase Test Lab / autres).

Prévoir mécanisme de “Nettoyage” pour effacer données temporaires (clear cache).

Proposer tutoriels intégrés (scan, OCR, signer) pour faciliter adoption.

