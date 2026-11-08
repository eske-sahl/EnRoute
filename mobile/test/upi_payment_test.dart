import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/fleet_state.dart';
import 'package:mobile/widgets/upi_payment_dialog.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  group('EnRoute Dynamic UPI Payment QR Suite', () {
    test('1. Platform UPI constants match specifications', () {
      expect(UpiPaymentDialog.upiId, 'enroute.kerala@upi');
      expect(UpiPaymentDialog.payeeName, 'EnRoute Kerala');
    });

    test('2. NPCI deep link URI format is correctly generated', () {
      final uri = UpiPaymentDialog.buildUpiUri(
        amount: 25.50,
        note: 'EnRoute Bus Ticket KL 10 AZ 4589',
        vpa: 'kvksalu-2@okaxis',
        name: 'ESKE_',
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
                    vpa: 'kvksalu-2@okaxis',
                    payeeName: 'ESKE_',
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

    test('4. BusModel starts with empty unassigned UPI by default, hasValidUpi is false', () {
      final freshBus = BusModel(
        id: 'TEST-NEW-BUS',
        regNumber: 'KL 10 GG 1234',
        busName: 'Fresh Bus',
        category: 'Limited Stop Bus (Red-Whiteline)',
        routeName: 'Route A',
        stops: [],
      );

      expect(freshBus.upiId, isEmpty);
      expect(freshBus.payeeName, isEmpty);
      expect(freshBus.isUpiEnabled, isFalse);
      expect(freshBus.hasValidUpi, isFalse);
    });

    test('5. BusModel supports owner-assigned UPI details and serialization', () {
      final bus = BusModel(
        id: 'TEST-BUS-1',
        regNumber: 'KL 10 AZ 9999',
        busName: 'Test Express',
        category: 'Ordinary Bus (Blue-Whiteline)',
        routeName: 'Test Route',
        stops: [],
        upiId: 'custom.owner@okhdfcbank',
        payeeName: 'Custom Motors',
        isUpiEnabled: true,
      );

      expect(bus.upiId, 'custom.owner@okhdfcbank');
      expect(bus.payeeName, 'Custom Motors');
      expect(bus.isUpiEnabled, isTrue);
      expect(bus.hasValidUpi, isTrue);

      final json = bus.toJson();
      expect(json['upiId'], 'custom.owner@okhdfcbank');
      expect(json['payeeName'], 'Custom Motors');
      expect(json['isUpiEnabled'], isTrue);

      final revived = BusModel.fromJson(json);
      expect(revived.upiId, 'custom.owner@okhdfcbank');
      expect(revived.payeeName, 'Custom Motors');
      expect(revived.isUpiEnabled, isTrue);
      expect(revived.hasValidUpi, isTrue);
    });

    test('6. FleetState updates bus UPI details configured by owner', () {
      final state = FleetState.instance;
      final bus = state.buses.first;

      // Ensure fresh state starts empty/unassigned
      bus.upiId = '';
      bus.payeeName = '';
      bus.isUpiEnabled = false;
      expect(bus.hasValidUpi, isFalse);

      // Owner assigns UPI details
      state.updateBusUpiDetails(
        regNumber: bus.regNumber,
        upiId: 'sahl.bus@okaxis',
        payeeName: 'Sana Lines',
        isUpiEnabled: true,
      );

      final updated = state.getBusByReg(bus.regNumber);
      expect(updated?.upiId, 'sahl.bus@okaxis');
      expect(updated?.payeeName, 'Sana Lines');
      expect(updated?.isUpiEnabled, isTrue);
      expect(updated?.hasValidUpi, isTrue);
    });

    test('7. Dynamic UPI URI generation reflects customized owner VPA and Payee', () {
      final customUri = UpiPaymentDialog.buildUpiUri(
        amount: 32.0,
        note: 'EnRoute Spot Ticket KL 10 CE 1204',
        vpa: 'arafa.transport@okaxis',
        name: 'Arafa Lines',
      );

      expect(customUri, contains('pa=arafa.transport@okaxis'));
      expect(customUri, contains('pn=Arafa%20Lines'));
      expect(customUri, contains('am=32.00'));
    });
  });
}
