import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';

class OwnerConductorTab extends StatefulWidget {
  const OwnerConductorTab({super.key});

  @override
  State<OwnerConductorTab> createState() => _OwnerConductorTabState();
}

class _OwnerConductorTabState extends State<OwnerConductorTab> {
  void _showAddConductorModal() {
    final nameCtrl = TextEditingController(text: 'Anil Varghese');
    final loginIdCtrl = TextEditingController(text: 'anil.conductor');
    final passCtrl = TextEditingController(text: 'pass123');
    final phoneCtrl = TextEditingController(text: '+91 98470 55009');
    final badgeCtrl = TextEditingController(text: 'KL-MVD-6621');
    String assignedBus = FleetState.instance.buses.first.busName;

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
                    const Text('Provision Conductor Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Text(
                  'Conductors cannot self-register. You create their credentials here. They will sign into the app using this Login ID and Password.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Conductor Full Name',
                    prefixIcon: const Icon(Icons.person, color: AppTheme.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: loginIdCtrl,
                        decoration: InputDecoration(
                          labelText: 'Login ID / Username',
                          prefixIcon: const Icon(Icons.badge, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: passCtrl,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Phone Number',
                    prefixIcon: const Icon(Icons.phone, color: AppTheme.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: badgeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Conductor License / MVD Badge',
                    prefixIcon: const Icon(Icons.verified, color: AppTheme.primaryGreen),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Assign to Bus',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  initialValue: assignedBus,
                  items: FleetState.instance.buses.map((b) => DropdownMenuItem(value: b.busName, child: Text('${b.busName} (${b.regNumber})'))).toList(),
                  onChanged: (val) => assignedBus = val!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final newCond = ConductorModel(
                      id: 'COND-${DateTime.now().millisecondsSinceEpoch}',
                      loginId: loginIdCtrl.text,
                      password: passCtrl.text,
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      badgeNumber: badgeCtrl.text,
                      assignedBusReg: FleetState.instance.buses.firstWhere((b) => b.busName == assignedBus).regNumber,
                      assignedBusName: assignedBus,
                      todayCollection: 0.0,
                    );

                    setState(() {
                      FleetState.instance.addConductor(newCond);
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Conductor ${newCond.name} onboarded! Login ID: ${newCond.loginId}')),
                    );
                  },
                  child: const Text('Create & Authorize Conductor Account'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConductorDetailsModal(ConductorModel cond) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                child: const Icon(Icons.badge, color: AppTheme.primaryGreen),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cond.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Badge: ${cond.badgeNumber}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _credRow('Assigned Bus', '${cond.assignedBusName} (${cond.assignedBusReg})'),
              _credRow('Phone Number', cond.phone),
              _credRow('Conductor Login ID', cond.loginId),
              _credRow('Password', '•••••••• (${cond.password})'),
              _credRow('Today\'s Collections', '₹${cond.todayCollection.toStringAsFixed(1)}'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Authorized to scan passenger QR codes and issue spot tickets for this bus.',
                  style: TextStyle(fontSize: 11, color: Colors.green),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _credRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
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
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Conductor Crew Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${fleet.conductors.length} active conductors', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _showAddConductorModal,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add Conductor', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Conductor Buttons List
            ...fleet.conductors.map((conductor) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _showConductorDetailsModal(conductor),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                          child: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryGreen, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(conductor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text('Bus: ${conductor.assignedBusName} (${conductor.assignedBusReg})',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('ID: ${conductor.loginId} • Badge: ${conductor.badgeNumber}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${conductor.todayCollection.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 16),
                            ),
                            const Text('Shift Total', style: TextStyle(color: Colors.grey, fontSize: 10)),
                            const SizedBox(height: 4),
                            const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
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
