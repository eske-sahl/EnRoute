import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_theme.dart';

class UpiPaymentDialog extends StatelessWidget {
  static const String defaultPlatformVpa = 'enroute.kerala@upi';
  static const String defaultPlatformPayee = 'EnRoute Kerala';

  // Fallback constants
  static const String defaultVpa = defaultPlatformVpa;
  static const String defaultPayeeName = defaultPlatformPayee;

  // For backwards compatibility with static access
  static String get upiId => defaultPlatformVpa;
  static String get payeeName => defaultPlatformPayee;

  final double amount;
  final String vpa;
  final String payee;
  final String title;
  final String subtitle;
  final String transactionNote;
  final String confirmButtonText;
  final VoidCallback onPaymentConfirmed;

  const UpiPaymentDialog({
    super.key,
    required this.amount,
    this.vpa = defaultVpa,
    this.payee = defaultPayeeName,
    required this.title,
    required this.subtitle,
    required this.transactionNote,
    required this.confirmButtonText,
    required this.onPaymentConfirmed,
  });

  /// Constructs the standard NPCI UPI payment deep link string
  static String buildUpiUri({
    required double amount,
    required String note,
    String? vpa,
    String? name,
  }) {
    final effectiveVpa = (vpa != null && vpa.trim().isNotEmpty) ? vpa.trim() : defaultVpa;
    final effectiveName = (name != null && name.trim().isNotEmpty) ? name.trim() : defaultPayeeName;
    final encodedName = Uri.encodeComponent(effectiveName);
    final encodedNote = Uri.encodeComponent(note);
    final formattedAmt = amount.toStringAsFixed(2);
    return 'upi://pay?pa=$effectiveVpa&pn=$encodedName&am=$formattedAmt&cu=INR&tn=$encodedNote';
  }

  /// Convenience static helper to display the modal dialog
  static Future<void> show({
    required BuildContext context,
    required double amount,
    String? vpa,
    String? payeeName,
    String title = 'UPI Dynamic Payment',
    String subtitle = 'Scan to pay with any UPI App',
    required String transactionNote,
    String confirmButtonText = 'Confirm Payment Received',
    required VoidCallback onPaymentConfirmed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => UpiPaymentDialog(
        amount: amount,
        vpa: (vpa != null && vpa.trim().isNotEmpty) ? vpa.trim() : defaultVpa,
        payee: (payeeName != null && payeeName.trim().isNotEmpty) ? payeeName.trim() : defaultPayeeName,
        title: title,
        subtitle: subtitle,
        transactionNote: transactionNote,
        confirmButtonText: confirmButtonText,
        onPaymentConfirmed: onPaymentConfirmed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveVpa = vpa.trim().isNotEmpty ? vpa.trim() : defaultVpa;
    final effectivePayee = payee.trim().isNotEmpty ? payee.trim() : defaultPayeeName;
    final upiUri = buildUpiUri(amount: amount, note: transactionNote, vpa: effectiveVpa, name: effectivePayee);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2_rounded, color: Colors.blue, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),

            // Amount Highlight Box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount to Pay:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Dynamic UPI QR View
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SizedBox(
                width: 170,
                height: 170,
                child: QrImageView(
                  data: upiUri,
                  version: QrVersions.auto,
                  size: 170,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Payee VPA Details & Copy Pill
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Clipboard.setData(ClipboardData(text: effectiveVpa));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('UPI ID copied: $effectiveVpa'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified, color: Colors.blue, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '$effectivePayee • $effectiveVpa',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.copy, size: 13, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Supported UPI Apps Row
            const Text(
              'Scan with Google Pay, PhonePe, Paytm, BHIM, or Cred',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10.5, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: () {
            Navigator.pop(context);
            onPaymentConfirmed();
          },
          child: Text(confirmButtonText, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
