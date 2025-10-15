# Guide de la licence Syncfusion - FlexiPDF

## 📋 Qu'est-ce que la Community License ?

La **Community License** de Syncfusion offre un **accès gratuit** à tous les produits Syncfusion, y compris les composants Flutter PDF.

### ✅ Qui est éligible ?

Vous êtes éligible si vous remplissez **TOUS** ces critères :

- 🏢 **Revenu annuel** : Moins de 1 million USD
- 👥 **Développeurs** : 5 ou moins
- 👨‍💼 **Employés totaux** : 10 ou moins
- 💰 **Capital externe** : Jamais reçu plus de 3 millions USD de capital (private equity, venture capital, etc.)

### ✅ Avantages

- ✅ Accès à **tous les produits** Syncfusion
- ✅ Support et mises à jour inclus
- ✅ Utilisation pour **applications commerciales** autorisée
- ✅ Licence valide **tant que vous êtes éligible**
- ✅ Pas de limite de temps si vous restez éligible

## 🚀 Comment obtenir la licence gratuite

### Étape 1 : Créer un compte Syncfusion

1. Allez sur : https://www.syncfusion.com/products/communitylicense
2. Cliquez sur **"CLAIM FREE LICENSE"**
3. Connectez-vous avec votre compte LinkedIn ou Xing (requis pour vérification)

### Étape 2 : Remplir le formulaire

1. Remplissez le formulaire avec vos informations :
   - Nom complet
   - Email professionnel
   - Nom de l'entreprise (ou "Individual" si indépendant)
   - Nombre de développeurs
   - Revenu annuel
   
2. Acceptez les termes et conditions

3. Soumettez le formulaire

### Étape 3 : Recevoir la licence

1. Vous recevrez un **email de confirmation**
2. La licence sera activée sur votre compte Syncfusion
3. Vous pouvez télécharger les produits depuis votre compte

## 🔧 Configuration dans FlexiPDF

### ⚠️ Important : Pas de clé de licence requise pour Flutter !

**Bonne nouvelle** : Pour les projets Flutter, **vous n'avez PAS besoin d'enregistrer une clé de licence** dans votre code !

Selon la documentation officielle Syncfusion :
> "The Flutter controls from Syncfusion can be used without registering the license keys."

### Pourquoi ?

Les packages Flutter de Syncfusion sont **open source** et ne nécessitent pas de clé de licence pour fonctionner. La licence Community est simplement pour :
- ✅ Respecter les termes d'utilisation
- ✅ Accéder au support technique
- ✅ Recevoir les mises à jour
- ✅ Utiliser légalement dans vos projets

## 📦 Utilisation dans le projet

### 1. Ajouter la dépendance

Dans `pubspec.yaml` (déjà fait) :

```yaml
dependencies:
  syncfusion_flutter_pdf: ^27.2.5
```

### 2. Utiliser directement

Aucune configuration supplémentaire nécessaire ! Utilisez simplement :

```dart
import 'package:syncfusion_flutter_pdf/pdf.dart';

// Utilisation directe
final pdfDoc = PdfDocument();
// ...
```

### 3. Pas de clé à ajouter

❌ **Ne faites PAS ceci** (pas nécessaire pour Flutter) :
```dart
// Ceci est pour d'autres plateformes, PAS Flutter
SyncfusionLicense.registerLicense('YOUR_LICENSE_KEY');
```

## 📝 Conformité légale

### Pour être en conformité :

1. ✅ **Demandez la Community License** sur le site Syncfusion
2. ✅ **Vérifiez votre éligibilité** annuellement
3. ✅ **Mettez à jour vers une licence payante** si vous dépassez les critères
4. ✅ **Mentionnez Syncfusion** dans vos crédits (optionnel mais apprécié)

### Exemple de crédit (optionnel)

Dans votre app ou README :

```
FlexiPDF utilise Syncfusion Flutter PDF
https://www.syncfusion.com/flutter-widgets
```

## 🔄 Quand passer à une licence payante ?

Vous devez passer à une licence payante si :

- 💰 Revenu annuel > 1 million USD
- 👥 Plus de 5 développeurs
- 👨‍💼 Plus de 10 employés
- 💵 Levée de fonds > 3 millions USD

### Prix des licences payantes

Consultez : https://www.syncfusion.com/sales/products/flutter

## ❓ FAQ

### Q : Puis-je utiliser Syncfusion sans licence ?
**R :** Techniquement oui pour Flutter (le code fonctionne), mais légalement non. Demandez la Community License gratuite pour être en conformité.

### Q : La licence Community est-elle vraiment gratuite ?
**R :** Oui, 100% gratuite si vous êtes éligible. Pas de carte de crédit requise.

### Q : Puis-je vendre mon application avec la Community License ?
**R :** Oui ! Vous pouvez créer et vendre des applications commerciales.

### Q : Que se passe-t-il si je dépasse les critères ?
**R :** Vous devez passer à une licence payante. Syncfusion vous contactera pour renouveler.

### Q : Puis-je utiliser la licence pour des projets open source ?
**R :** Oui, mais vous devez d'abord contacter Syncfusion pour enregistrer votre projet open source.

### Q : Combien de temps la licence est-elle valide ?
**R :** Tant que vous restez éligible selon les critères. Pas de limite de temps.

### Q : Dois-je renouveler chaque année ?
**R :** Syncfusion vérifie périodiquement l'éligibilité. Vous devez confirmer que vous êtes toujours éligible.

## 🔗 Liens utiles

- **Demander la licence** : https://www.syncfusion.com/products/communitylicense
- **Documentation Flutter PDF** : https://help.syncfusion.com/flutter/pdf/overview
- **Forum de support** : https://www.syncfusion.com/forums
- **Exemples de code** : https://github.com/syncfusion/flutter-examples

## 📞 Support

Si vous avez des questions sur la licence :
- **Email** : licensing@syncfusion.com
- **Forum** : https://www.syncfusion.com/forums
- **Contact** : https://www.syncfusion.com/products/community-contact-us

## ✅ Résumé pour FlexiPDF

Pour votre projet FlexiPDF :

1. ✅ **Demandez la Community License** (gratuite)
2. ✅ **Aucune configuration de clé** nécessaire dans le code
3. ✅ **Utilisez directement** les packages Syncfusion
4. ✅ **Restez en conformité** en vérifiant votre éligibilité

**C'est tout ! Vous êtes prêt à développer.** 🚀

---

**Dernière mise à jour** : Janvier 2025  
**Version Syncfusion** : 27.2.5
