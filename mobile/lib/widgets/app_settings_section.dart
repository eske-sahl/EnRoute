import 'package:flutter/material.dart';
import '../services/app_settings_service.dart';
import '../theme/app_theme.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsService.instance;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final isDark = settings.isDarkMode;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              settings.t('theme') + ' & ' + settings.t('language'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  // 1. Dark / Light Mode Toggle
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.amber.withValues(alpha: 0.15) : Colors.indigo.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        color: isDark ? Colors.amber : Colors.indigo,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      isDark ? 'Dark Mode' : 'Light Mode',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      isDark ? 'Sleek dark theme for night transit' : 'Crisp daylight theme',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    value: isDark,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      settings.toggleTheme();
                    },
                  ),

                  const Divider(height: 1),

                  // 2. Language Switcher (English / Malayalam)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.translate_rounded, color: AppTheme.primaryGreen, size: 22),
                    ),
                    title: Text(
                      settings.t('language'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      settings.languageDisplayName,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        settings.isMalayalam ? 'English' : 'മലയാളം',
                        style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    onTap: () {
                      settings.toggleLanguage();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to ${settings.languageDisplayName}'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.primaryGreen,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // App Help & Community Section
            const Text(
              'Help, Feedback & Community',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  // 3. How to Use This App
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00875A).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: Color(0xFF00875A), size: 22),
                    ),
                    title: Text(
                      settings.t('howToUse'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Guide for Passengers, Conductors & Owners', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => settings.showHowToUseModal(context),
                  ),

                  const Divider(height: 1),

                  // 4. Share App
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.share_rounded, color: Colors.blue, size: 22),
                    ),
                    title: Text(
                      settings.t('shareApp'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Invite others to download EnRoute', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => settings.showShareModal(context),
                  ),

                  const Divider(height: 1),

                  // 5. Rate Us
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.amber, size: 22),
                    ),
                    title: Text(
                      settings.t('rateUs'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Share your experience & rate our service', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => settings.showRateUsModal(context),
                  ),

                  const Divider(height: 1),

                  // 6. Report Issue
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bug_report_rounded, color: Colors.red, size: 22),
                    ),
                    title: Text(
                      settings.t('reportIssue'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Notify developers of bugs or GPS errors', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => settings.showReportIssueModal(context),
                  ),

                  const Divider(height: 1),

                  // 7. Suggest Feature
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.lightbulb_rounded, color: Colors.purple, size: 22),
                    ),
                    title: Text(
                      settings.t('suggestFeature'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Send ideas directly to Sahl & Fathima', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => settings.showSuggestFeatureModal(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
