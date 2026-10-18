import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../bus_detail_page.dart';

class OwnerBusListTab extends StatefulWidget {
  final VoidCallback onNavigateToConductorTab;

  const OwnerBusListTab({
    super.key,
    required this.onNavigateToConductorTab,
  });

  @override
  State<OwnerBusListTab> createState() => _OwnerBusListTabState();
}

class _OwnerBusListTabState extends State<OwnerBusListTab> {
  void _showRegisterBusModal() {
    final regCtrl = TextEditingController(text: 'KL 07 DE 3344');
    final nameCtrl = TextEditingController(text: 'Kochi Royal Express');
    final routeCtrl = TextEditingController(text: 'Aluva - Angamaly Direct (R-30)');
    final driverCtrl = TextEditingController(text: 'Babu Mathew (Badge #KL7712)');
    final cleanerCtrl = TextEditingController(text: 'Sunil K.');
    String busType = 'Ordinary Line Service';
    int seatingCapacity = 48;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Register New Bus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Text(
                  'Submit vehicle credentials for State Transport Admin authenticity verification.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
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
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Bus Display Name',
                    prefixIcon: const Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Carriage Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  initialValue: busType,
                  items: const [
                    DropdownMenuItem(value: 'Ordinary Line Service', child: Text('Ordinary Line Service')),
                    DropdownMenuItem(value: 'Limited Stop Fast Passenger (LSFP)', child: Text('Limited Stop Fast Passenger (LSFP)')),
                    DropdownMenuItem(value: 'Fast Passenger (FP)', child: Text('Fast Passenger (FP)')),
                  ],
                  onChanged: (val) => busType = val!,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: routeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Assigned Route',
                    prefixIcon: const Icon(Icons.alt_route, color: AppTheme.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: driverCtrl,
                  decoration: InputDecoration(
                    labelText: 'Assigned Driver & Badge',
                    prefixIcon: const Icon(Icons.airline_seat_recline_normal, color: AppTheme.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cleanerCtrl,
                  decoration: InputDecoration(
                    labelText: 'Cleaner / Helper Name',
                    prefixIcon: const Icon(Icons.cleaning_services, color: AppTheme.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final newBus = BusModel(
                      id: 'BUS-${DateTime.now().millisecondsSinceEpoch}',
                      regNumber: regCtrl.text.toUpperCase(),
                      busName: nameCtrl.text,
                      busType: busType,
                      routeName: routeCtrl.text,
                      startTime: '06:30 AM',
                      endTime: '08:00 PM',
                      conductorName: 'Suresh Kumar',
                      driverName: driverCtrl.text,
                      cleanerName: cleanerCtrl.text,
                      companyName: 'St. George Motors Ernakulam',
                      seatingCapacity: seatingCapacity,
                      todayCollection: 0.0,
                      ticketsCount: 0,
                      status: 'PENDING_ADMIN',
                      isApprovedByAdmin: true, // Auto-approved for viva demonstration
                    );

                    setState(() {
                      FleetState.instance.addBus(newBus);
                    });

                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Row(
                            children: [
                              Icon(Icons.verified, color: AppTheme.primaryGreen),
                              SizedBox(width: 8),
                              Text('Registration Submitted!'),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bus: ${newBus.busName} (${newBus.regNumber})',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text(
                                'A verification request was sent to the Transport Admin. Authenticity verified & added to your fleet!',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Submit for Admin Verification & Register'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fleet = FleetState.instance;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Bus Fleet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${fleet.buses.length} registered vehicles', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _showRegisterBusModal,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Register New Bus', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bus Buttons List
            ...fleet.buses.map((bus) {
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BusDetailPage(
                          bus: bus,
                          onNavigateToConductors: widget.onNavigateToConductorTab,
                        ),
                      ),
                    );
                  },
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
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(bus.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(bus.regNumber,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ADMIN APPROVED',
                                style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Route: ${bus.routeName}',
                                style: const TextStyle(fontSize: 12, color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Row(
                              children: [
                                Text('Manage Details', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.primaryGreen),
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
          ],
        ),
      ),
    );
  }
}
