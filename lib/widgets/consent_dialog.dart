import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dialog for user consent to data collection
class ConsentDialog extends StatelessWidget {
  const ConsentDialog({super.key});

  /// Show consent dialog and return user's decision
  static Future<bool> show(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasConsented = prefs.getBool('data_collection_consent') ?? false;

    // If already consented, return true
    if (hasConsented) {
      return true;
    }

    // Show dialog
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must make a choice
      builder: (BuildContext context) => const ConsentDialog(),
    );

    // Save consent
    if (result == true) {
      await prefs.setBool('data_collection_consent', true);
      await prefs.setBool('auto_sync_enabled', true);
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.privacy_tip, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          const Text('Data Collection Notice'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To improve the accuracy of our cataract detection model, we would like to collect anonymous data from your scans.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'What we collect:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Eye images you scan'),
            _buildBulletPoint('Prediction results and confidence scores'),
            _buildBulletPoint('Analysis timestamps'),
            const SizedBox(height: 16),
            const Text(
              'What we DON\'T collect:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Your name or personal information'),
            _buildBulletPoint('Device identifiers or location'),
            _buildBulletPoint('Any other app data'),
            const SizedBox(height: 16),
            const Text(
              'How it works:',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint('Scans work offline - no internet required'),
            _buildBulletPoint('Data is stored locally on your device'),
            _buildBulletPoint('When internet is available, data syncs automatically in the background'),
            _buildBulletPoint('Local data is deleted after successful upload'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'By accepting, you help us train better AI models to detect cataracts more accurately for everyone.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This app requires your consent to function. You cannot proceed without accepting.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Show additional warning before declining
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Cannot Use App'),
                content: const Text(
                  'This app requires data collection consent to function. Without accepting, you cannot use the cataract detection features.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Exit App'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Decline'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Accept & Continue'),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
