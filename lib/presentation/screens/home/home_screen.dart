import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../widgets/feature_card.dart';
import '../merge/merge_screen.dart';
import '../split/split_screen.dart';
import '../compress/compress_screen.dart';
import '../scanner/scanner_screen.dart';
import '../protect/protect_screen.dart';

/// Home screen with all PDF features
class HomeScreen extends Scaffold {
  HomeScreen({super.key})
      : super(
          appBar: AppBar(
            title: const Text(AppStrings.homeTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Navigate to settings
                },
              ),
            ],
          ),
          body: const HomeScreenBody(),
        );
}

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            AppStrings.homeSubtitle,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Main Features Grid
          Text(
            'Main Features',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              FeatureCard(
                icon: Icons.merge,
                title: AppStrings.merge,
                color: Colors.blue,
                onTap: () {
                  context.navigateTo(const MergeScreen());
                },
              ),
              FeatureCard(
                icon: Icons.call_split,
                title: AppStrings.split,
                color: Colors.purple,
                onTap: () {
                  context.navigateTo(const SplitScreen());
                },
              ),
              FeatureCard(
                icon: Icons.compress,
                title: AppStrings.compress,
                color: Colors.orange,
                onTap: () {
                  context.navigateTo(const CompressScreen());
                },
              ),
              FeatureCard(
                icon: Icons.transform,
                title: AppStrings.convert,
                color: Colors.green,
                onTap: () {
                  // Navigate to convert
                },
              ),
              FeatureCard(
                icon: Icons.lock,
                title: AppStrings.protect,
                color: Colors.red,
                onTap: () {
                  context.navigateTo(const ProtectScreen());
                },
              ),
              FeatureCard(
                icon: Icons.document_scanner,
                title: AppStrings.scan,
                color: Colors.teal,
                onTap: () {
                  context.navigateTo(const ScannerScreen());
                },
              ),
              FeatureCard(
                icon: Icons.text_fields,
                title: AppStrings.ocr,
                color: Colors.indigo,
                onTap: () {
                  // Navigate to OCR
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Additional Features
          Text(
            'More Tools',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              FeatureCard(
                icon: Icons.edit,
                title: AppStrings.sign,
                color: Colors.red,
                onTap: () {},
              ),
              FeatureCard(
                icon: Icons.lock,
                title: AppStrings.protect,
                color: Colors.amber,
                onTap: () {},
              ),
              FeatureCard(
                icon: Icons.view_carousel,
                title: AppStrings.organize,
                color: Colors.pink,
                onTap: () {},
              ),
              FeatureCard(
                icon: Icons.rotate_right,
                title: AppStrings.rotate,
                color: Colors.cyan,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
