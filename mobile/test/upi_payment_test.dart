import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/upi_payment_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  group('EnRoute Dynamic UPI Payment QR Suite', () {
    test('1. UPI constants match user account specifications', () {
      expect(UpiPaymentDialog.upiId, 'kvksalu-2@okaxis');
      expect(UpiPaymentDialog.payeeName, 'ESKE_');
    });

    test('2. NPCI deep link URI format is correctly generated', () {
      final uri = UpiPaymentDialog.buildUpiUri(
        amount: 25.50,
        note: 'EnRoute Bus Ticket KL 10 AZ 4589',
      );

      expect(uri, contains('upi://pay?'));
      expect(uri, contains('pa=kvksalu-2@okaxis'));
      expect(uri, contains('pn=ESKE_'));
      expect(uri, contains('am=25.50'));
      expect(uri, contains('cu=INR'));
      expect(uri, contains('tn=EnRoute%20Bus%20Ticket%20KL%2010%20AZ%204589'));
    });

    testWidgets('3. UpiPaymentDialog renders QR code, payee name, VPA, and confirms payment', (WidgetTester tester) async {
      bool paymentConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  UpiPaymentDialog.show(
                    context: context,
                    amount: 50.0,
                    title: 'UPI Dynamic Spot QR',
                    subtitle: 'Payee: ESKE_ (Sana Line)',
                    transactionNote: 'EnRoute Ticket',
                    confirmButtonText: 'Confirm Payment Received',
                    onPaymentConfirmed: () {
                      paymentConfirmed = true;
                    },
                  );
                },
                child: const Text('Open UPI Modal'),
              ),
            ),
          ),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open UPI Modal'));
      await tester.pumpAndSettle();

      // Verify Dialog Content
      expect(find.text('UPI Dynamic Spot QR'), findsOneWidget);
      expect(find.text('Payee: ESKE_ (Sana Line)'), findsOneWidget);
      expect(find.text('₹50.00'), findsOneWidget);
      expect(find.textContaining('ESKE_ • kvksalu-2@okaxis'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('Confirm Payment Received'), findsOneWidget);

      // Tap Confirm Payment
      await tester.tap(find.text('Confirm Payment Received'));
      await tester.pumpAndSettle();

      expect(paymentConfirmed, isTrue);
      expect(find.byType(UpiPaymentDialog), findsNothing);
    });
  });
}
