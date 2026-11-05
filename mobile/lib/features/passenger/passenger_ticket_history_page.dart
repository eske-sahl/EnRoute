import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/fleet_state.dart';
import '../../widgets/app_creator_footer.dart';

class PassengerTicketHistoryPage extends StatefulWidget {
  final PassengerModel passenger;
  final VoidCallback onBack;

  const PassengerTicketHistoryPage({
    super.key,
    required this.passenger,
    required this.onBack,
  });

  @override
  State<PassengerTicketHistoryPage> createState() => _PassengerTicketHistoryPageState();
}

class _PassengerTicketHistoryPageState extends State<PassengerTicketHistoryPage> {
  final _searchController = TextEditingController();
  String _selectedPaymentFilter = 'ALL'; // 'ALL', 'SMART_WALLET', 'CASH', 'UPI', 'SPLIT'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTicketDetails(BuildContext context, IssuedTicketModel ticket) {
    final fmt = DateFormat('dd MMM yyyy, hh:mm a');
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
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
                          Text('Digital Bus Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                          Text(ticket.ticketNumber, style: TextStyle(fontFamily: 'monospace', color: isDark ? Colors.white60 : Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.primaryGreen.withValues(alpha: 0.15) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppTheme.primaryGreen.withValues(alpha: 0.3) : Colors.green.shade300),
                    ),
                    child: Text(
                      'PAID & VALID',
                      style: TextStyle(color: isDark ? Colors.green.shade300 : Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Bus & Route Details
              _detailRow('Bus Vehicle', '${ticket.busName} (${ticket.busRegNumber})', isDark),
              _detailRow('Boarding Stop', ticket.boardingStop, isDark),
              _detailRow('Destination Stop', ticket.destinationStop, isDark),
              _detailRow('Journey Date & Time', fmt.format(ticket.timestamp), isDark),
              _detailRow('Passenger Name & ID', '${widget.passenger.name} (${ticket.passengerId})', isDark),
              _detailRow('Fare Category', ticket.isStudentConcession ? 'Student Concession (₹5 Concession)' : 'General Fare', isDark),
              _detailRow('Payment Mode', ticket.paymentModeLabel, isDark),
              if (ticket.cashTendered != null && ticket.cashTendered! > 0)
                _detailRow('Cash Handed / Change', '₹${ticket.cashTendered!.toStringAsFixed(1)} (Change: ₹${(ticket.cashChangeGiven ?? 0).toStringAsFixed(1)})', isDark),
              if (ticket.isSplitPayment)
                _detailRow('Split Breakdown', 'Cash: ₹${ticket.splitCashAmount?.toStringAsFixed(1)} + UPI: ₹${ticket.splitUpiAmount?.toStringAsFixed(1)}', isDark),
              _detailRow('Assigned Conductor', ticket.conductorName, isDark),

              const Divider(height: 24),

              // Total Fare Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primaryGreen.withValues(alpha: 0.12) : AppTheme.primaryGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Fare Paid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
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
                child: const Text('Close Receipt', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 13)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allTickets = FleetState.instance.getTicketsForPassenger(widget.passenger.id);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    // Filter tickets by search and payment mode
    final query = _searchController.text.trim().toLowerCase();
    final filteredTickets = allTickets.where((t) {
      if (_selectedPaymentFilter != 'ALL') {
        if (_selectedPaymentFilter == 'SPLIT' && !t.isSplitPayment) return false;
        if (_selectedPaymentFilter == 'SMART_WALLET' && t.paymentMode != 'SMART_WALLET' && t.paymentMode != 'WALLET') return false;
        if (_selectedPaymentFilter == 'CASH' && (t.paymentMode != 'CASH' || t.isSplitPayment)) return false;
        if (_selectedPaymentFilter == 'UPI' && (t.paymentMode != 'UPI' || t.isSplitPayment)) return false;
      }

      if (query.isNotEmpty) {
        final match = '${t.busName} ${t.busRegNumber} ${t.boardingStop} ${t.destinationStop} ${t.ticketNumber} ${t.conductorName}'.toLowerCase();
        if (!match.contains(query)) return false;
      }

      return true;
    }).toList();

    final totalSpent = allTickets.fold(0.0, (sum, t) => sum + t.fare);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Dashboard',
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Travel Ticket History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${allTickets.length} Total Journeys • ${widget.passenger.name}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.darkCardGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL EXPENDITURE', style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(currency.format(totalSpent), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${allTickets.length} Total Trips Recorded', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.auto_graph, color: AppTheme.primaryGreen, size: 28),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search journey by stop, bus, ticket no...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                isDense: true,
              ),
            ),

            const SizedBox(height: 12),

            // Payment Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All Modes', 'ALL'),
                  _chip('Smart Wallet', 'SMART_WALLET'),
                  _chip('Cash', 'CASH'),
                  _chip('UPI QR', 'UPI'),
                  _chip('Split Payment', 'SPLIT'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Ticket List
            if (filteredTickets.isEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: isDark ? Colors.white38 : Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          query.isNotEmpty ? 'No journeys match "$query"' : 'No ticket records found',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tickets issued by bus conductors appear here automatically.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...filteredTickets.map((ticket) {
                final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(ticket.timestamp);

                Color badgeColor = AppTheme.primaryGreen;
                if (ticket.paymentMode == 'CASH') badgeColor = Colors.orange;
                if (ticket.paymentMode == 'UPI') badgeColor = Colors.blue;
                if (ticket.isSplitPayment) badgeColor = Colors.purple;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showTicketDetails(context, ticket),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    ticket.ticketNumber,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      ticket.isSplitPayment ? 'SPLIT' : ticket.paymentMode,
                                      style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${ticket.fare.toStringAsFixed(1)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 17),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.alt_route, size: 14, color: AppTheme.primaryGreen),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${ticket.boardingStop} ➔ ${ticket.destinationStop}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${ticket.busName} (${ticket.busRegNumber})',
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: TextStyle(fontSize: 10.5, color: isDark ? Colors.white60 : Colors.grey),
                              ),
                            ],
                          ),
                          const Divider(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Conductor: ${ticket.conductorName}',
                                style: TextStyle(fontSize: 10.5, color: isDark ? Colors.white54 : Colors.grey),
                              ),
                              const Row(
                                children: [
                                  Text(
                                    'View Details',
                                    style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11.5),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(Icons.chevron_right, size: 14, color: AppTheme.primaryGreen),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

            const SizedBox(height: 14),
            const AppCreatorFooter(),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String key) {
    final isSelected = _selectedPaymentFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        onSelected: (_) => setState(() => _selectedPaymentFilter = key),
      ),
    );
  }
}
