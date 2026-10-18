import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class OwnerFleetScreen extends StatefulWidget {
  const OwnerFleetScreen({super.key});

  @override
  State<OwnerFleetScreen> createState() => _OwnerFleetScreenState();
}

class _OwnerFleetScreenState extends State<OwnerFleetScreen> {
  final List<Map<String, dynamic>> _buses = [
    {
      'reg': 'KL 07 CD 4589',
      'name': 'SpeedWings',
      'route': 'Aluva - Perumbavoor (R-14)',
      'status': 'IN_TRANSIT',
      'conductor': 'Suresh Kumar',
      'todayRevenue': '₹5,840',
      'isLive': true,
    },
    {
      'reg': 'KL 07 CE 1204',
      'name': 'GreenCity Express',
      'route': 'Ernakulam - Thoppumpady (R-08)',
      'status': 'IN_TRANSIT',
      'conductor': 'Biju Varghese',
      'todayRevenue': '₹7,220',
      'isLive': true,
    },
    {
      'reg': 'KL 07 BQ 9981',
      'name': 'St. Marys Line',
      'route': 'Vytilla - Kakkanad InfoPark',
      'status': 'SCHEDULED',
      'conductor': 'Rajesh M.',
      'todayRevenue': '₹3,420',
      'isLive': false,
    },
  ];

  void _showAddBusModal() {
    final regCtrl = TextEditingController(text: 'KL 07 DF 6789');
    final nameCtrl = TextEditingController();
    String busType = 'ORDINARY';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Register New Bus into Fleet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: regCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'Registration Number (Kerala Plate)',
                  hintText: 'e.g. KL 07 CD 4589',
                  prefixIcon: const Icon(Icons.pin, color: AppTheme.primaryGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Bus Display Name',
                  hintText: 'e.g. Cochin Royal Express',
                  prefixIcon: const Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Bus Carriage Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                initialValue: busType,
                items: const [
                  DropdownMenuItem(value: 'ORDINARY', child: Text('Ordinary Line Service')),
                  DropdownMenuItem(value: 'LSFP', child: Text('Limited Stop Fast Passenger (LSFP)')),
                  DropdownMenuItem(value: 'FAST_PASSENGER', child: Text('Fast Passenger (FP)')),
                ],
                onChanged: (val) => busType = val!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (regCtrl.text.isNotEmpty && nameCtrl.text.isNotEmpty) {
                    setState(() {
                      _buses.add({
                        'reg': regCtrl.text.toUpperCase(),
                        'name': nameCtrl.text,
                        'route': 'Aluva - Angamaly Direct',
                        'status': 'SCHEDULED',
                        'conductor': 'Unassigned',
                        'todayRevenue': '₹0',
                        'isLive': false,
                      });
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Bus ${regCtrl.text} added to fleet!')),
                    );
                  }
                },
                child: const Text('Add Bus to Fleet'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Owner Fleet Portal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('St. George Motors • Ernakulam Division', style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Bus',
            onPressed: _showAddBusModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Revenue Analytics Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppTheme.darkCardGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                children: [
                  const Text('TODAY\'S TOTAL FLEET COLLECTION',
                      style: TextStyle(color: Colors.white60, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                    '₹16,480.00',
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.accentAmber),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _metricCol('Buses Active', '${_buses.length}', Colors.greenAccent),
                      _metricCol('Tickets Sold', '534', Colors.white),
                      _metricCol('Digital Wallet', '₹11,240', AppTheme.accentAmber),
                      _metricCol('Cash In Hand', '₹5,240', Colors.white70),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Registered Fleet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  onPressed: _showAddBusModal,
                  icon: const Icon(Icons.add, size: 16, color: AppTheme.primaryGreen),
                  label: const Text('Add Bus', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._buses.map((bus) => _buildBusItem(bus)),
          ],
        ),
      ),
    );
  }

  Widget _metricCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  Widget _buildBusItem(Map<String, dynamic> bus) {
    final isLive = bus['isLive'] as bool;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLive ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.directions_bus, color: isLive ? AppTheme.primaryGreen : Colors.grey),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bus['name']} (${bus['reg']})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(bus['route'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bus['status'],
                    style: TextStyle(
                      color: isLive ? Colors.green.shade800 : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Conductor: ${bus['conductor']}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                Text(
                  'Collection: ${bus['todayRevenue']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
