import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../../../widgets/app_creator_footer.dart';

class OwnerConductorTab extends StatefulWidget {
  final OwnerModel owner;
  const OwnerConductorTab({super.key, required this.owner});

  @override
  State<OwnerConductorTab> createState() => _OwnerConductorTabState();
}

class _OwnerConductorTabState extends State<OwnerConductorTab> {
  void _showAddConductorModal() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final userIdCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();
    
    // Default assigned bus for this owner
    final ownerBuses = FleetState.instance.getBusesForOwner(widget.owner.id);
    String assignedBusReg = ownerBuses.isNotEmpty 
        ? ownerBuses.first.regNumber 
        : 'Unassigned';

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_add_alt_1, color: AppTheme.primaryGreen),
                              SizedBox(width: 8),
                              Text('Add Conductor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(modalCtx)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Conductor access is provisioned by the Bus Owner. Logging in with this User ID & Owner-assigned Password grants entry to Conductor Portal. (If logging in with a personal phone/password, the app opens the Passenger Portal).',
                                style: TextStyle(fontSize: 11, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 1. Name
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Conductor Full Name *',
                          prefixIcon: const Icon(Icons.person, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // 2. Email
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address *',
                          prefixIcon: const Icon(Icons.email, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // 3. User ID & Password (App Login Credentials)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.key, color: Colors.brown, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'CONDUCTOR APP LOGIN CREDENTIALS',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.brown),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: userIdCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'User ID (Login ID) *',
                                      hintText: 'e.g. anil.conductor',
                                      prefixIcon: const Icon(Icons.badge, color: AppTheme.primaryGreen, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'User ID is required' : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextFormField(
                                    controller: passwordCtrl,
                                    decoration: InputDecoration(
                                      labelText: 'Password *',
                                      hintText: 'e.g. password123',
                                      prefixIcon: const Icon(Icons.lock, color: AppTheme.primaryGreen, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Password is required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 4. Phone
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number *',
                          prefixIcon: const Icon(Icons.phone, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone number is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // 5. License Number (MVD Conductor Badge)
                      TextFormField(
                        controller: licenseCtrl,
                        decoration: InputDecoration(
                          labelText: 'License / MVD Badge Number *',
                          hintText: 'e.g. KL-MVD-COND-6621',
                          prefixIcon: const Icon(Icons.verified, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'License number is required' : null,
                      ),
                      const SizedBox(height: 12),

                      // 6. Assigned Bus [Bus Name and Bus Number]
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Assigned Bus [Bus Name and Bus Num] *',
                          prefixIcon: const Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        initialValue: assignedBusReg,
                        items: [
                          const DropdownMenuItem(value: 'Unassigned', child: Text('Unassigned (Assign Later)')),
                          ...ownerBuses.map((b) {
                            return DropdownMenuItem(
                              value: b.regNumber,
                              child: Text('${b.busName} [${b.regNumber}]', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            );
                          }),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => assignedBusReg = val);
                          }
                        },
                      ),

                      const SizedBox(height: 22),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          final assignedBusObj = ownerBuses.where((b) => b.regNumber == assignedBusReg).firstOrNull;

                          final newCond = ConductorModel(
                            id: 'COND-${DateTime.now().millisecondsSinceEpoch}',
                            ownerId: widget.owner.id,
                            name: nameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            userId: userIdCtrl.text.trim(),
                            password: passwordCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            licenseNumber: licenseCtrl.text.trim(),
                            assignedBusReg: assignedBusObj?.regNumber ?? 'Unassigned',
                            assignedBusName: assignedBusObj?.busName ?? 'Unassigned',
                            todayCollection: 0.0,
                          );

                          // Also update bus's conductor field if assigned
                          if (assignedBusObj != null) {
                            assignedBusObj.conductorName = newCond.name;
                          }

                          setState(() {
                            FleetState.instance.addConductor(newCond);
                          });

                          Navigator.pop(modalCtx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Conductor ${newCond.name} added! Assigned to ${newCond.assignedBusName} (${newCond.assignedBusReg}). Login ID: ${newCond.userId}'),
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save & Authorize Conductor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
                  Text('Badge: ${cond.licenseNumber}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _credRow('Assigned Bus', '${cond.assignedBusName} [${cond.assignedBusReg}]'),
              _credRow('Email', cond.email),
              _credRow('Phone Number', cond.phone),
              _credRow('License Number', cond.licenseNumber),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('OWNER ASSIGNED APP LOGIN CREDENTIALS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.brown)),
                    const SizedBox(height: 4),
                    _credRow('User ID', cond.userId),
                    _credRow('Password', cond.password),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _credRow('Today\'s Collections', '₹${cond.todayCollection.toStringAsFixed(1)}'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Logging into the app with this User ID and Owner-given password opens the Conductor Portal for the assigned bus.',
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
    final ownerConductors = fleet.getConductorsForOwner(widget.owner.id);

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
                    Text('${ownerConductors.length} active conductors', style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
                  label: const Text('Add Conductor', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Conductor accounts are created by the Bus Owner. Conductors log into the app using their owner-assigned User ID & Password.',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (ownerConductors.isEmpty)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Icon(Icons.badge_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 14),
                      Text(
                        'No Conductors Added for ${widget.owner.companyName}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Provision app login credentials for your crew by tapping "Add Conductor" above. Your conductors will use these credentials to issue smart tickets and sync collections to your dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...ownerConductors.map((conductor) {
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
                              Text('Assigned: ${conductor.assignedBusName} [${conductor.assignedBusReg}]',
                                  style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text('User ID: ${conductor.userId} • License: ${conductor.licenseNumber}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
            const SizedBox(height: 10),
            const AppCreatorFooter(),
          ],
        ),
      ),
    );
  }
}
