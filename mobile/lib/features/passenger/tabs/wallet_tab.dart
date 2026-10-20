import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../../../widgets/app_creator_footer.dart';

class WalletTab extends StatefulWidget {
  final PassengerModel passenger;
  final Function(double) onTopUp;

  const WalletTab({
    super.key,
    required this.passenger,
    required this.onTopUp,
  });

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  String _selectedFilter = 'ALL'; // 'ALL', 'RECHARGE', 'WALLET', 'UPI', 'CASH'

  void _showAddMoneyModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Money to Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Select a demo recharge amount:', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                      widget.onTopUp(amt);
                      Navigator.pop(context);
                    },
                    child: Text('₹${amt.toInt()}'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFmt = DateFormat('dd MMM, hh:mm a');

    // Query strictly this passenger's ledger from FleetState
    final passengerTransactions = FleetState.instance.getTransactionsForPassenger(widget.passenger.id);

    // Filter transactions
    final filtered = passengerTransactions.where((tx) {
      if (_selectedFilter == 'ALL') return true;
      return tx.type == _selectedFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wallet Balance Header
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
                const Text(
                  'AVAILABLE WALLET BALANCE',
                  style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  currency.format(widget.passenger.walletBalance),
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
                      onPressed: _showAddMoneyModal,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Top Up Balance'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Transaction Category Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('All History', 'ALL'),
                _filterChip('Recharges', 'RECHARGE'),
                _filterChip('Wallet Tickets', 'WALLET'),
                _filterChip('UPI Paid', 'UPI'),
                _filterChip('Cash Paid', 'CASH'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transactions List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transaction & Travel Ledger', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('${filtered.length} entries', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),

          if (filtered.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'No Ledger Entries Found',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedFilter == 'ALL'
                          ? 'This account has no transaction history yet. Recharge your wallet above or travel on EnRoute to view ledger entries.'
                          : 'No $_selectedFilter transactions found for this account.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filtered.map((tx) {
              final isCredit = tx.amount > 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCredit
                              ? Colors.green.withValues(alpha: 0.1)
                              : (tx.type == 'UPI' ? Colors.blue.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.account_balance_wallet
                              : (tx.type == 'UPI' ? Icons.qr_code : Icons.directions_bus),
                          color: isCredit
                              ? Colors.green
                              : (tx.type == 'UPI' ? Colors.blue : AppTheme.primaryGreen),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text('${tx.busOrSource} • ${dateFmt.format(tx.timestamp)}',
                                style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'METHOD: ${tx.type}',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isCredit ? '+' : ''}₹${tx.amount.abs().toStringAsFixed(1)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isCredit ? Colors.green : Colors.black87,
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

  Widget _filterChip(String label, String key) {
    final isSelected = _selectedFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryGreen : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        onSelected: (val) => setState(() => _selectedFilter = key),
      ),
    );
  }
}
