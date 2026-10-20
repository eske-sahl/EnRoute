import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../../../widgets/app_creator_footer.dart';

class ConductorHistoryTab extends StatefulWidget {
  final ConductorModel conductor;

  const ConductorHistoryTab({
    super.key,
    required this.conductor,
  });

  @override
  State<ConductorHistoryTab> createState() => _ConductorHistoryTabState();
}

class _ConductorHistoryTabState extends State<ConductorHistoryTab> {
  final _searchController = TextEditingController();
  String _selectedDateFilter = 'TODAY'; // 'TODAY', 'ALL'
  String _selectedPaymentFilter = 'ALL'; // 'ALL', 'SMART_WALLET', 'CASH', 'UPI', 'SPLIT'
  String _selectedCategoryFilter = 'ALL'; // 'ALL', 'General', 'Student Concession'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IssuedTicketModel> _getFilteredTickets() {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();

    return FleetState.instance.issuedTickets.where((ticket) {
      // Filter by conductor
      if (ticket.conductorId != widget.conductor.id && ticket.conductorName != widget.conductor.name) {
        // If not this conductor, still include if assigned to same bus
        if (ticket.busRegNumber != widget.conductor.assignedBusReg) {
          return false;
        }
      }

      // Date Filter
      if (_selectedDateFilter == 'TODAY') {
        final isToday = ticket.issuedAt.year == now.year &&
            ticket.issuedAt.month == now.month &&
            ticket.issuedAt.day == now.day;
        if (!isToday) return false;
      }

      // Payment Mode Filter
      if (_selectedPaymentFilter != 'ALL' && ticket.paymentMode != _selectedPaymentFilter) {
        return false;
      }

      // Category Filter
      if (_selectedCategoryFilter != 'ALL' && ticket.category != _selectedCategoryFilter) {
        return false;
      }

      // Search Query (Passenger ID, Passenger Name, Stop, Ticket Number)
      if (query.isNotEmpty) {
        final text = '${ticket.passengerId} ${ticket.passengerName} ${ticket.boardingStop} ${ticket.destStop} ${ticket.ticketNumber}'.toLowerCase();
        if (!text.contains(query)) return false;
      }

      return true;
    }).toList();
  }

  void _showTicketDetails(IssuedTicketModel t) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.confirmation_number, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 10),
              const Text('Ticket Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                child: Column(
                  children: [
                    Text(t.ticketNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(DateFormat('dd MMM yyyy, hh:mm a').format(t.issuedAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const Divider(height: 16),
                    _infoRow('Passenger Name', t.passengerName),
                    _infoRow('Passenger ID', t.passengerId),
                    _infoRow('Boarding Stop', t.boardingStop),
                    _infoRow('Destination Stop', t.destStop),
                    _infoRow('Category', t.category),
                    _infoRow('Payment Method', t.paymentMode),
                    if (t.paymentMode == 'CASH') ...[
                      _infoRow('Cash Given', '₹${t.cashGiven.toInt()}'),
                      _infoRow('Change Returned', '₹${t.changeReturned.toInt()}'),
                    ],
                    if (t.paymentMode == 'SPLIT') ...[
                      _infoRow('Split Breakdown', 'Cash: ₹${t.splitCash.toInt()} + UPI: ₹${t.splitUpi.toInt()}'),
                    ],
                    _infoRow('Assigned Bus', '${t.busName} (${t.busRegNumber})'),
                    _infoRow('Conductor', t.conductorName),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('FARE COLLECTED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('₹${t.fare.toStringAsFixed(1)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryGreen)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close Receipt'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tickets = _getFilteredTickets();
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    double totalRevenue = tickets.fold(0.0, (sum, t) => sum + t.fare);
    double walletRevenue = tickets.where((t) => t.paymentMode == 'SMART_WALLET').fold(0.0, (sum, t) => sum + t.fare);
    double cashRevenue = tickets.where((t) => t.paymentMode == 'CASH').fold(0.0, (sum, t) => sum + t.fare);
    double upiRevenue = tickets.where((t) => t.paymentMode == 'UPI').fold(0.0, (sum, t) => sum + t.fare);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -------------------------------------------------------------------
          // 1. REVENUE METRICS SUMMARY CARD
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppTheme.darkCardGradient,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SHIFT AUDIT & REVENUE RECONCILIATION',
                        style: TextStyle(color: Colors.white60, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.bold)),
                    Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                  ],
                ),
                const SizedBox(height: 8),
                Text(currency.format(totalRevenue),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.accentAmber)),
                const SizedBox(height: 14),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metricCol('Tickets', '${tickets.length}', Colors.white),
                    _metricCol('Smart Wallet', currency.format(walletRevenue), AppTheme.accentAmber),
                    _metricCol('Liquid Cash', currency.format(cashRevenue), Colors.greenAccent),
                    _metricCol('UPI QR', currency.format(upiRevenue), Colors.blueAccent),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // 2. SEARCH & FILTER SECTION
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Filter by Stop, Passenger ID, or Ticket #',
                      hintText: 'e.g. Aluva, PASS-1004, KL-SBK...',
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips: Date
                  Row(
                    children: [
                      const Text('Date: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                      ChoiceChip(
                        label: const Text('Today', style: TextStyle(fontSize: 11)),
                        selected: _selectedDateFilter == 'TODAY',
                        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        onSelected: (val) {
                          if (val) setState(() => _selectedDateFilter = 'TODAY');
                        },
                      ),
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: const Text('All History', style: TextStyle(fontSize: 11)),
                        selected: _selectedDateFilter == 'ALL',
                        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        onSelected: (val) {
                          if (val) setState(() => _selectedDateFilter = 'ALL');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Filter Chips: Payment
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text('Payment: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                        _chip('All', _selectedPaymentFilter == 'ALL', () => setState(() => _selectedPaymentFilter = 'ALL')),
                        _chip('Wallet', _selectedPaymentFilter == 'SMART_WALLET', () => setState(() => _selectedPaymentFilter = 'SMART_WALLET')),
                        _chip('Cash', _selectedPaymentFilter == 'CASH', () => setState(() => _selectedPaymentFilter = 'CASH')),
                        _chip('UPI QR', _selectedPaymentFilter == 'UPI', () => setState(() => _selectedPaymentFilter = 'UPI')),
                        _chip('Split', _selectedPaymentFilter == 'SPLIT', () => setState(() => _selectedPaymentFilter = 'SPLIT')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Filter Chips: Category / Fare Tier
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Text('Fare Tier: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                        _chip('All', _selectedCategoryFilter == 'ALL', () => setState(() => _selectedCategoryFilter = 'ALL')),
                        _chip('General', _selectedCategoryFilter == 'General', () => setState(() => _selectedCategoryFilter = 'General')),
                        _chip('Student (₹5)', _selectedCategoryFilter == 'Student Concession', () => setState(() => _selectedCategoryFilter = 'Student Concession')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // -------------------------------------------------------------------
          // 3. LONG TICKETS LIST
          // -------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Issued Tickets Record (${tickets.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Tap card for full receipt', style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),

          if (tickets.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                  SizedBox(height: 10),
                  Text('No tickets found matching the specified filters.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            ...tickets.map((t) {
              Color badgeColor = AppTheme.primaryGreen;
              if (t.paymentMode == 'CASH') badgeColor = Colors.orange;
              if (t.paymentMode == 'UPI') badgeColor = Colors.blue;
              if (t.paymentMode == 'SPLIT') badgeColor = Colors.purple;

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _showTicketDetails(t),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(t.ticketNumber,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace')),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(t.paymentMode,
                                      style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            Text('₹${t.fare.toStringAsFixed(1)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.alt_route, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text('${t.boardingStop} ➔ ${t.destStop}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Passenger: ${t.passengerName} (${t.passengerId})',
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            Text(DateFormat('dd MMM, hh:mm a').format(t.issuedAt),
                                style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
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

  Widget _metricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
      ],
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: isSelected,
        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
