import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';

class ConductorJourneyTab extends StatefulWidget {
  final ConductorModel conductor;

  const ConductorJourneyTab({
    super.key,
    required this.conductor,
  });

  @override
  State<ConductorJourneyTab> createState() => _ConductorJourneyTabState();
}

class _ConductorJourneyTabState extends State<ConductorJourneyTab> {
  late BusModel _bus;

  @override
  void initState() {
    super.initState();
    _initBus();
  }

  void _initBus() {
    final found = FleetState.instance.getBusByReg(widget.conductor.assignedBusReg);
    _bus = found ?? FleetState.instance.buses.first;
    _bus.sortStops();
  }

  void _advanceStage() {
    setState(() {
      FleetState.instance.advanceBusStage(_bus.regNumber);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bus stage advanced to: ${_bus.currentStop}. Updated on passenger & owner live tracking.'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddStopModal() {
    final stopNameCtrl = TextEditingController(text: '');
    final timeCtrl = TextEditingController(text: '10:30 AM');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.add_location_alt, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text('Add Stop to Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: stopNameCtrl,
                decoration: InputDecoration(
                  labelText: 'Stop Name',
                  hintText: 'e.g. Asokapuram Junction',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                decoration: InputDecoration(
                  labelText: 'Scheduled Departure Time',
                  hintText: 'e.g. 10:30 AM',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
              onPressed: () {
                if (stopNameCtrl.text.trim().isEmpty) return;

                setState(() {
                  _bus.stops.add(BusStopSchedule(
                    stopName: stopNameCtrl.text.trim(),
                    time: timeCtrl.text.trim(),
                  ));
                  _bus.sortStops();
                });

                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${stopNameCtrl.text.trim()}" to ${_bus.busName} schedule. Sorted chronologically.'),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Add Stop'),
            ),
          ],
        );
      },
    );
  }

  void _showManageScheduleModal() {
    List<Map<String, String>> editList = _bus.stops.map((s) => {'stop': s.stopName, 'time': s.time}).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_calendar, color: AppTheme.primaryGreen),
                            SizedBox(width: 8),
                            Text('Edit Bus Journey Timetable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheetCtx)),
                      ],
                    ),
                    const Text('Conductors can edit or calibrate stops and timings to match actual ground operations.',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 14),

                    ...editList.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final item = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: item['stop'],
                                decoration: InputDecoration(
                                  labelText: 'Stop #${idx + 1}',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onChanged: (v) => editList[idx]['stop'] = v,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: item['time'],
                                decoration: InputDecoration(
                                  labelText: 'Departure',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onChanged: (v) => editList[idx]['time'] = v,
                              ),
                            ),
                            if (editList.length > 2)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () {
                                  setModalState(() {
                                    editList.removeAt(idx);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        setModalState(() {
                          editList.add({'stop': 'New Stop', 'time': '11:00 AM'});
                        });
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Another Intermediate Stop'),
                    ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        final updatedStops = editList.map((s) {
                          return BusStopSchedule(stopName: s['stop'] ?? 'Stop', time: s['time'] ?? '10:00 AM');
                        }).toList();

                        setState(() {
                          _bus.stops = updatedStops;
                          _bus.sortStops();
                        });

                        Navigator.pop(sheetCtx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Timetable for ${_bus.busName} updated and synchronized with passengers & owner!'),
                            backgroundColor: AppTheme.primaryGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Save & Synchronize Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stops = _bus.stops;
    final currentStage = _bus.currentStageIndex.clamp(0, stops.isNotEmpty ? stops.length - 1 : 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -------------------------------------------------------------------
          // 1. LIVE CONDUCTOR DEVICE GPS TELEMETRY CARD
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF131A22), Color(0xFF1F2937)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('CONDUCTOR DEVICE GPS: ACTIVE',
                            style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(6)),
                      child: const Text('ACCURATE TO 3m', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.my_location, color: AppTheme.accentAmber, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DETECTED CONDUCTOR POSITION', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.1)),
                          const SizedBox(height: 2),
                          Text(_bus.conductorLocationString,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'GPS: ${_bus.currentLatitude.toStringAsFixed(4)}° N, ${_bus.currentLongitude.toStringAsFixed(4)}° E',
                            style: const TextStyle(color: AppTheme.accentAmber, fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white12),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _advanceStage,
                        icon: const Icon(Icons.navigation, size: 18),
                        label: const Text('Advance to Next Stage / Stop', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // 2. COMPLETE BUS SCHEDULE TIMELINE HEADER
          // -------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bus Journey Timetable', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${stops.length} scheduled stops • Chronological ascending order',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: AppTheme.primaryGreen),
                    tooltip: 'Add Stop',
                    onPressed: _showAddStopModal,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
                    tooltip: 'Edit Schedule',
                    onPressed: _showManageScheduleModal,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // 3. COMPLETE TIMELINE LIST VIEW
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: stops.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final stop = entry.value;
                  final isPassed = idx < currentStage;
                  final isCurrent = idx == currentStage;
                  final isUpcoming = idx > currentStage;
                  final isLast = idx == stops.length - 1;

                  Color dotColor = Colors.grey.shade300;
                  if (isPassed) dotColor = AppTheme.primaryGreen;
                  if (isCurrent) dotColor = AppTheme.accentAmber;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: isCurrent ? Colors.black87 : Colors.transparent, width: 2),
                              boxShadow: isCurrent ? [BoxShadow(color: AppTheme.accentAmber.withValues(alpha: 0.6), blurRadius: 8)] : null,
                            ),
                            child: isPassed
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : (isCurrent ? const Icon(Icons.location_on, size: 12, color: Colors.black87) : null),
                          ),
                          if (!isLast)
                            Container(
                              width: 3,
                              height: 44,
                              color: isPassed ? AppTheme.primaryGreen : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 22.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stop.stopName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                      color: isCurrent ? AppTheme.primaryGreen : Colors.black87,
                                    ),
                                  ),
                                  if (isCurrent)
                                    const Text('BUS IS AT THIS STAGE (LIVE GPS)',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  if (isPassed)
                                    const Text('Stage Passed', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  if (isUpcoming)
                                    const Text('Upcoming Stage', style: TextStyle(fontSize: 10, color: Colors.black54)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPassed ? Colors.grey.shade100 : AppTheme.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  stop.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isPassed ? Colors.grey : AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
