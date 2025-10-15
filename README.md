# flexipdf

All-in-one mobile app to edit, convert, and protect your documents — fast, secure, and 100% offline.

## Getting Started

# FlexiPDF

**All-in-one mobile app to edit, convert, and protect your documents — fast, secure, and 100% offline.**

FlexiPDF is a comprehensive PDF toolkit for Android and iOS that performs all operations locally on your device, ensuring complete privacy and security.

## ✨ Features

### Core PDF Operations
- 📄 **Merge PDFs** - Combine multiple PDF files into one
- ✂️ **Split PDF** - Divide PDF into separate files
- 🗜️ **Compress PDF** - Reduce file size with quality control
- 🔄 **Rotate Pages** - Rotate individual or all pages
- 📑 **Extract Pages** - Extract specific pages to new PDF
- 🗑️ **Delete Pages** - Remove unwanted pages
- 📋 **Organize** - Reorder pages with drag & drop

### Conversion
- 🖼️ **Image to PDF** - Convert JPG, PNG to PDF
- 📸 **PDF to Image** - Export pages as images
- 📝 **Office to PDF** - Convert DOCX, XLSX, PPTX (planned)
- 📄 **PDF to Office** - Convert to Word, Excel (planned)

### Advanced Features
- 🔍 **OCR** - Extract text from scanned documents
- 📷 **Scanner** - Scan documents with edge detection
- ✍️ **Sign** - Add digital signatures
- 🔒 **Protect** - Encrypt with password
- 🔓 **Unlock** - Remove password protection
- 💧 **Watermark** - Add text or image watermarks
- 🔎 **Search** - Find text in PDFs
- 📊 **Metadata** - View and edit document info

## 🏗️ Architecture

FlexiPDF follows **Clean Architecture** principles with clear separation of concerns:

- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources and repositories
- **Presentation Layer**: UI and state management

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed documentation.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Android Studio / Xcode
- Android SDK / iOS SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/flexipdf.git
cd flexipdf
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📦 Dependencies

Key packages used:
- `syncfusion_flutter_pdf` - PDF manipulation
- `pdfx` - PDF viewing
- `google_mlkit_text_recognition` - OCR
- `flutter_bloc` - State management
- `encrypt` - Security & encryption
- `hive` - Local storage

See [pubspec.yaml](pubspec.yaml) for complete list.

## 🔒 Privacy & Security

- ✅ **100% Offline** - No data leaves your device
- ✅ **AES-256 Encryption** - Secure vault for sensitive files
- ✅ **No Tracking** - Zero analytics or telemetry
- ✅ **Minimal Permissions** - Only essential permissions requested

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📱 Platforms

- ✅ Android (API 21+)
- ✅ iOS (13.0+)
- 🔜 Web (planned)
- 🔜 Desktop (planned)

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by iLovePDF
- Built with Flutter
- Uses Syncfusion PDF library

## 📞 Support

For issues and questions, please open an issue on GitHub.

---

Made with ❤️ for privacy-conscious users
