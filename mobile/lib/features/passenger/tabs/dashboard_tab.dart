import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../../../widgets/app_creator_footer.dart';

class DashboardTab extends StatelessWidget {
  final PassengerModel passenger;
  final Function(double) onTopUp;

  const DashboardTab({
    super.key,
    required this.passenger,
    required this.onTopUp,
  });

  void _showTopUpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Money to Demo Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Select an amount to recharge your travel balance:', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [50.0, 100.0, 200.0, 500.0].map((amt) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      onTopUp(amt);
                      Navigator.pop(context);
                    },
                    child: Text('₹${amt.toInt()}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  void _showQrFullscreen(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Passenger Identity Pass', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${passenger.name} • ${passenger.concessionCategory}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 20),
                QrImageView(
                  data: passenger.id,
                  version: QrVersions.auto,
                  size: 220.0,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primaryGreen),
                ),
                const SizedBox(height: 16),
                Text('ID: ${passenger.id}', style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTicketDetails(BuildContext context, IssuedTicketModel ticket) {
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.confirmation_num, color: AppTheme.primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Digital Bus Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(ticket.ticketNumber, style: const TextStyle(fontFamily: 'monospace', color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: const Text('PAID & VALID', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Bus & Route
              _ticketRow('Bus Vehicle', '${ticket.busName} (${ticket.busRegNumber})'),
              _ticketRow('Boarding Stop', ticket.boardingStop),
              _ticketRow('Destination Stop', ticket.destinationStop),
              _ticketRow('Issued At', fmt.format(ticket.timestamp)),
              _ticketRow('Passenger ID', ticket.passengerId),
              _ticketRow('Concession Category', ticket.isStudentConcession ? 'Student Concession (₹5 Concession)' : 'General Fare'),
              _ticketRow('Payment Mode', ticket.paymentModeLabel),
              if (ticket.cashTendered != null && ticket.cashTendered! > 0)
                _ticketRow('Cash Handed', '₹${ticket.cashTendered!.toStringAsFixed(1)} (Change: ₹${(ticket.cashChangeGiven ?? 0).toStringAsFixed(1)})'),
              if (ticket.isSplitPayment)
                _ticketRow('Split Breakdown', 'Cash: ₹${ticket.splitCashAmount?.toStringAsFixed(1)} + UPI: ₹${ticket.splitUpiAmount?.toStringAsFixed(1)}'),
              _ticketRow('Conductor Crew', ticket.conductorName),

              const Divider(height: 24),

              // Total Fare Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Fare Paid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '₹${ticket.fare.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ticketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    // Fetch ONLY tickets issued for this specific passenger
    final issuedTickets = FleetState.instance.getTicketsForPassenger(passenger.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Wallet Balance Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppTheme.busGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('DIGITAL TRANSIT WALLET',
                        style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentAmber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currency.format(passenger.walletBalance),
                  style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showTopUpSheet(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Money'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showTopUpSheet(context),
                      icon: const Icon(Icons.bolt, size: 18),
                      label: const Text('Quick Recharge'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Personal Scanner / QR Code Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personal Digital Pass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Conductor scans this to issue tickets', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen, color: AppTheme.primaryGreen),
                        tooltip: 'Enlarge QR',
                        onPressed: () => _showQrFullscreen(context),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  GestureDetector(
                    onTap: () => _showQrFullscreen(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: passenger.id,
                        version: QrVersions.auto,
                        size: 150.0,
                        eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(passenger.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Colors.black54)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Ticket History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Ticket History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${issuedTickets.length} journeys', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),

          if (issuedTickets.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Padding(
                padding: EdgeInsets.all(28.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.confirmation_num_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('No tickets issued yet.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else
            ...issuedTickets.map((ticket) {
              final dateStr = DateFormat('dd MMM, hh:mm a').format(ticket.timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  onTap: () => _showTicketDetails(context, ticket),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.confirmation_num, color: AppTheme.primaryGreen),
                  ),
                  title: Text(
                    '${ticket.boardingStop} ➔ ${ticket.destinationStop}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text(
                    '${ticket.busRegNumber} (${ticket.busName}) • $dateStr',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${ticket.fare.toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          ticket.paymentMode,
                          style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 10),
          const AppCreatorFooter(),
        ],
      ),
    );
  }
}

