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

  void _showEditConductorModal(ConductorModel cond) {
    final nameCtrl = TextEditingController(text: cond.name);
    final emailCtrl = TextEditingController(text: cond.email);
    final phoneCtrl = TextEditingController(text: cond.phone);
    final licenseCtrl = TextEditingController(text: cond.licenseNumber);
    final passwordCtrl = TextEditingController(text: cond.password);

    final ownerBuses = FleetState.instance.getBusesForOwner(widget.owner.id);
    String assignedBusReg = cond.assignedBusReg.isNotEmpty ? cond.assignedBusReg : (ownerBuses.isNotEmpty ? ownerBuses.first.regNumber : '');

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
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.edit_note, color: AppTheme.primaryGreen),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Edit Conductor Details',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(modalCtx)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // User ID (Fixed login username)
                      TextFormField(
                        initialValue: cond.userId,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: 'User ID (Login Username - Fixed)',
                          prefixIcon: const Icon(Icons.badge, color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Name
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

                      // Phone
                      TextFormField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Mobile Phone Number',
                          prefixIcon: const Icon(Icons.phone, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // License
                      TextFormField(
                        controller: licenseCtrl,
                        decoration: InputDecoration(
                          labelText: 'Conductor License / Badge Number',
                          prefixIcon: const Icon(Icons.assignment, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password
                      TextFormField(
                        controller: passwordCtrl,
                        decoration: InputDecoration(
                          labelText: 'App Login Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primaryGreen),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Assigned Bus Dropdown
                      if (ownerBuses.isNotEmpty)
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: ownerBuses.any((b) => b.regNumber == assignedBusReg)
                              ? assignedBusReg
                              : ownerBuses.first.regNumber,
                          decoration: InputDecoration(
                            labelText: 'Assign to Operating Bus',
                            prefixIcon: const Icon(Icons.directions_bus, color: AppTheme.primaryGreen),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          items: ownerBuses.map((b) {
                            return DropdownMenuItem<String>(
                              value: b.regNumber,
                              child: Text(
                                '${b.busName} (${b.regNumber})',
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                assignedBusReg = val;
                              });
                            }
                          },
                        ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;

                          String assignedBusName = cond.assignedBusName;
                          final matchBus = ownerBuses.where((b) => b.regNumber == assignedBusReg);
                          if (matchBus.isNotEmpty) {
                            assignedBusName = matchBus.first.busName;
                          }

                          cond.name = nameCtrl.text.trim();
                          cond.email = emailCtrl.text.trim();
                          cond.phone = phoneCtrl.text.trim();
                          cond.licenseNumber = licenseCtrl.text.trim();
                          if (passwordCtrl.text.trim().isNotEmpty) {
                            cond.password = passwordCtrl.text.trim();
                          }
                          cond.assignedBusReg = assignedBusReg;
                          cond.assignedBusName = assignedBusName;

                          FleetState.instance.updateConductor(cond);
                          setState(() {});
                          Navigator.pop(modalCtx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Conductor ${cond.name} updated successfully!'),
                              backgroundColor: AppTheme.primaryGreen,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: const Text('Save Conductor Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;

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
                  Text(cond.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black87)),
                  Text('Badge: ${cond.licenseNumber}', style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _credRow('Assigned Bus', '${cond.assignedBusName} [${cond.assignedBusReg}]', isDark),
              _credRow('Email', cond.email, isDark),
              _credRow('Phone Number', cond.phone, isDark),
              _credRow('License Number', cond.licenseNumber, isDark),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2B2416) : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? Colors.amber.shade700.withValues(alpha: 0.5) : Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('OWNER ASSIGNED APP LOGIN CREDENTIALS',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isDark ? Colors.amber.shade300 : Colors.brown.shade800)),
                    const SizedBox(height: 4),
                    _credRow('User ID', cond.userId, isDark, true),
                    _credRow('Password', cond.password, isDark, true),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _credRow('Today\'s Collections', '₹${cond.todayCollection.toStringAsFixed(1)}', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.primaryGreen.withValues(alpha: 0.12) : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppTheme.primaryGreen.withValues(alpha: 0.3) : Colors.green.shade200),
                ),
                child: Text(
                  'Logging into the app with this User ID and Owner-given password opens the Conductor Portal for the assigned bus.',
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.green.shade300 : Colors.green.shade800),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 16),
              label: const Text('Delete Conductor', style: TextStyle(color: Colors.red)),
              onPressed: () => _confirmDeleteConductor(cond, dialogCtx),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Details'),
              onPressed: () {
                Navigator.pop(dialogCtx);
                _showEditConductorModal(cond);
              },
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteConductor(ConductorModel cond, BuildContext parentCtx) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Conductor?'),
            ],
          ),
          content: Text(
            'Are you sure you want to remove conductor "${cond.name}" (${cond.userId})? '
            'This conductor will no longer be able to log in, and their assigned bus (${cond.assignedBusReg}) will be set to Unassigned.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(parentCtx);
                FleetState.instance.deleteConductor(cond.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Conductor ${cond.name} deleted successfully.'),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _credRow(String label, String value, [bool isDark = false, bool isHighlight = false]) {
    Color valColor;
    if (isHighlight) {
      valColor = isDark ? Colors.amber.shade200 : Colors.brown.shade900;
    } else {
      valColor = isDark ? Colors.white : Colors.black87;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: valColor)),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Conductor Crew Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${ownerConductors.length} active conductors', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
                              Text(
                                'Assigned: ${conductor.assignedBusName} [${conductor.assignedBusReg}]',
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => _showEditConductorModal(conductor),
                                  borderRadius: BorderRadius.circular(6),
                                  child: const Padding(
                                    padding: EdgeInsets.all(3),
                                    child: Icon(Icons.edit, size: 14, color: AppTheme.primaryGreen),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
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
            const SizedBox(height: 10),
            const AppCreatorFooter(),
          ],
        ),
      ),
    );
  }
}
