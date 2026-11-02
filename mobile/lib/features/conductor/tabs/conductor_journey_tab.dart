import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../../../widgets/app_creator_footer.dart';

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

  void _showEditSingleFareDialog({
    required BuildContext parentCtx,
    required String from,
    required String to,
    required double currentFare,
    required StateSetter modalSetState,
    TextEditingController? fareInputCtrl,
  }) {
    final editCtrl = TextEditingController(text: currentFare.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (context, dlgSetState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_note, color: AppTheme.primaryGreen, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Edit Stop Fare', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '$from ➔ $to',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: editCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Standard Fare (₹)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    children: [-5.0, -1.0, 1.0, 5.0].map((delta) {
                      return ActionChip(
                        label: Text('${delta > 0 ? '+' : ''}₹${delta.toInt()}'),
                        onPressed: () {
                          final cur = double.tryParse(editCtrl.text) ?? currentFare;
                          final next = (cur + delta).clamp(1.0, 500.0);
                          dlgSetState(() {
                            editCtrl.text = next.toStringAsFixed(1);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final newFare = double.tryParse(editCtrl.text.trim()) ?? currentFare;
                    _bus.setCustomFare(from, to, newFare);
                    FleetState.instance.setBusStopFare(_bus.regNumber, from, to, newFare);
                    if (fareInputCtrl != null) {
                      fareInputCtrl.text = newFare.toStringAsFixed(1);
                    }
                    modalSetState(() {});
                    setState(() {});
                    Navigator.pop(dlgCtx);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('Updated fare for $from ➔ $to to ₹${newFare.toStringAsFixed(1)}!'),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFareChartModal() {
    final routeStops = _bus.allRouteStops;
    if (routeStops.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least 2 stops are required to configure a fare chart.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String selectedFrom = routeStops.first;
    String selectedTo = routeStops.length > 1 ? routeStops[1] : routeStops.last;

    final fromSearchCtrl = TextEditingController(text: selectedFrom);
    final toSearchCtrl = TextEditingController(text: selectedTo);
    final fareInputCtrl = TextEditingController(
      text: _bus.getFareFor(selectedFrom, selectedTo).toStringAsFixed(1),
    );

    bool showFromSuggestions = false;
    bool showToSuggestions = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final textPrimary = Theme.of(context).colorScheme.onSurface;
            final textSecondary = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65);

            // Group unique pairs for display
            final uniquePairs = <String, Map<String, dynamic>>{};
            _bus.customFareChart.forEach((key, val) {
              final parts = key.split('->');
              if (parts.length == 2) {
                final fromName = routeStops.firstWhere(
                  (s) => s.toLowerCase() == parts[0],
                  orElse: () => parts[0],
                );
                final toName = routeStops.firstWhere(
                  (s) => s.toLowerCase() == parts[1],
                  orElse: () => parts[1],
                );
                final normKey = fromName.compareTo(toName) < 0
                    ? '$fromName ➔ $toName'
                    : '$toName ➔ $fromName';
                uniquePairs[normKey] = {
                  'from': fromName,
                  'to': toName,
                  'fare': val,
                };
              }
            });

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
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.currency_rupee, color: AppTheme.primaryGreen, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stop-to-Stop Fare Chart',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Configure tariffs for ${_bus.busName}',
                                      style: TextStyle(color: textSecondary, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheetCtx)),
                      ],
                    ),
                    const Divider(height: 24),

                    // Section 1: Assign / Edit New Fare (Search Engine with Suggestion Droplists)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.green.shade50.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.search, size: 16, color: AppTheme.primaryGreen),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Search Stops & Assign Fare',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.swap_horiz, color: AppTheme.primaryGreen, size: 20),
                                tooltip: 'Swap Boarding & Destination',
                                onPressed: () {
                                  setModalState(() {
                                    final tmp = fromSearchCtrl.text;
                                    fromSearchCtrl.text = toSearchCtrl.text;
                                    toSearchCtrl.text = tmp;
                                    final tmpS = selectedFrom;
                                    selectedFrom = selectedTo;
                                    selectedTo = tmpS;
                                    if (selectedFrom.isNotEmpty && selectedTo.isNotEmpty) {
                                      fareInputCtrl.text = _bus.getFareFor(selectedFrom, selectedTo).toStringAsFixed(1);
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 1. From Stop Search Box
                          TextField(
                            controller: fromSearchCtrl,
                            decoration: InputDecoration(
                              labelText: 'From Stop (Boarding)',
                              hintText: 'Type stop name or tap arrow...',
                              prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.primaryGreen, size: 18),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (fromSearchCtrl.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      tooltip: 'Clear stop',
                                      onPressed: () {
                                        setModalState(() {
                                          fromSearchCtrl.clear();
                                          selectedFrom = '';
                                          showFromSuggestions = true;
                                        });
                                      },
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      showFromSuggestions ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                      color: AppTheme.primaryGreen,
                                    ),
                                    tooltip: 'Show all route stops',
                                    onPressed: () {
                                      setModalState(() {
                                        showFromSuggestions = !showFromSuggestions;
                                        showToSuggestions = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                selectedFrom = val.trim();
                                showFromSuggestions = true;
                                showToSuggestions = false;
                                if (selectedFrom.isNotEmpty && selectedTo.isNotEmpty) {
                                  fareInputCtrl.text = _bus.getFareFor(selectedFrom, selectedTo).toStringAsFixed(1);
                                }
                              });
                            },
                            onTap: () {
                              setModalState(() {
                                showFromSuggestions = true;
                                showToSuggestions = false;
                              });
                            },
                          ),

                          // From Suggestions Droplist
                          if (showFromSuggestions) ...[
                            const SizedBox(height: 4),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 160),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
                                ],
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                children: routeStops
                                    .where((s) => s.toLowerCase().contains(fromSearchCtrl.text.trim().toLowerCase()))
                                    .map((s) {
                                  final sIdx = routeStops.indexOf(s) + 1;
                                  return ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    leading: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('#$sIdx', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                                    ),
                                    title: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    trailing: const Icon(Icons.north_west, size: 12, color: Colors.grey),
                                    onTap: () {
                                      setModalState(() {
                                        fromSearchCtrl.text = s;
                                        selectedFrom = s;
                                        showFromSuggestions = false;
                                        if (selectedTo.isNotEmpty) {
                                          fareInputCtrl.text = _bus.getFareFor(selectedFrom, selectedTo).toStringAsFixed(1);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),

                          // 2. To Stop Search Box
                          TextField(
                            controller: toSearchCtrl,
                            decoration: InputDecoration(
                              labelText: 'To Stop (Destination)',
                              hintText: 'Type destination or tap arrow...',
                              prefixIcon: const Icon(Icons.flag, color: Colors.redAccent, size: 18),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (toSearchCtrl.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      tooltip: 'Clear stop',
                                      onPressed: () {
                                        setModalState(() {
                                          toSearchCtrl.clear();
                                          selectedTo = '';
                                          showToSuggestions = true;
                                        });
                                      },
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      showToSuggestions ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                      color: Colors.redAccent,
                                    ),
                                    tooltip: 'Show all route stops',
                                    onPressed: () {
                                      setModalState(() {
                                        showToSuggestions = !showToSuggestions;
                                        showFromSuggestions = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onChanged: (val) {
                              setModalState(() {
                                selectedTo = val.trim();
                                showToSuggestions = true;
                                showFromSuggestions = false;
                                if (selectedFrom.isNotEmpty && selectedTo.isNotEmpty) {
                                  fareInputCtrl.text = _bus.getFareFor(selectedFrom, selectedTo).toStringAsFixed(1);
                                }
                              });
                            },
                            onTap: () {
                              setModalState(() {
                                showToSuggestions = true;
                                showFromSuggestions = false;
                              });
                            },
                          ),

                          // To Suggestions Droplist
                          if (showToSuggestions) ...[
                            const SizedBox(height: 4),
                            Container(
                              constraints: const BoxConstraints(maxHeight: 160),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
                                ],
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                children: routeStops
                                    .where((s) => s.toLowerCase().contains(toSearchCtrl.text.trim().toLowerCase()))
                                    .map((s) {
                                  final sIdx = routeStops.indexOf(s) + 1;
                                  return ListTile(
                                    dense: true,
                                    visualDensity: VisualDensity.compact,
                                    leading: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('#$sIdx', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                    ),
                                    title: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    trailing: const Icon(Icons.north_west, size: 12, color: Colors.grey),
                                    onTap: () {
                                      setModalState(() {
                                        toSearchCtrl.text = s;
                                        selectedTo = s;
                                        showToSuggestions = false;
                                        if (selectedFrom.isNotEmpty) {
                                          fareInputCtrl.text = _bus.getFareFor(selectedFrom, selectedTo).toStringAsFixed(1);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // 3. Fare Amount & Quick Chips
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: fareInputCtrl,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Standard Fare (₹)',
                                    prefixText: '₹ ',
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Wrap(
                                spacing: 4,
                                children: [10.0, 15.0, 20.0, 25.0].map((f) {
                                  return ActionChip(
                                    padding: EdgeInsets.zero,
                                    label: Text('₹${f.toInt()}', style: const TextStyle(fontSize: 10)),
                                    onPressed: () {
                                      setModalState(() {
                                        fareInputCtrl.text = f.toStringAsFixed(1);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.save, size: 16),
                            label: const Text('Save Fare to Route Chart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            onPressed: () {
                              final fromClean = fromSearchCtrl.text.trim();
                              final toClean = toSearchCtrl.text.trim();
                              if (fromClean.isEmpty || toClean.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select or search both From and To stops!')),
                                );
                                return;
                              }
                              if (fromClean.toLowerCase() == toClean.toLowerCase()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('From and To stops cannot be the same!')),
                                );
                                return;
                              }
                              final f = double.tryParse(fareInputCtrl.text.trim()) ?? 10.0;
                              FleetState.instance.setBusStopFare(_bus.regNumber, fromClean, toClean, f);
                              setModalState(() {});
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Assigned ₹${f.toStringAsFixed(1)} for $fromClean ➔ $toClean. Synced to ticketing dashboard.'),
                                  backgroundColor: AppTheme.primaryGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 2: Active Assigned Fares
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Current Stop Fares (${uniquePairs.length})',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('Reset Stage Formula', style: TextStyle(fontSize: 11)),
                          onPressed: () {
                            setModalState(() {
                              _bus.initDefaultFareChart(force: true);
                            });
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fare chart reset to standard Kerala Stage formula.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (uniquePairs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('No custom fares assigned yet. Kerala stage formulas are active.',
                              style: TextStyle(color: textSecondary, fontSize: 12)),
                        ),
                      )
                    else
                      ...uniquePairs.entries.map((entry) {
                        final pairTitle = entry.key;
                        final data = entry.value;
                        final from = data['from'] as String;
                        final to = data['to'] as String;
                        final fare = data['fare'] as double;

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setModalState(() {
                              fromSearchCtrl.text = from;
                              selectedFrom = from;
                              toSearchCtrl.text = to;
                              selectedTo = to;
                              fareInputCtrl.text = fare.toStringAsFixed(1);
                              showFromSuggestions = false;
                              showToSuggestions = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Loaded $from ➔ $to (₹${fare.toStringAsFixed(1)}) into search editor above.'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(pairTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textPrimary)),
                                      const SizedBox(height: 2),
                                      Text('Tap to edit above • Auto-applies at ticketing', style: TextStyle(fontSize: 10, color: textSecondary)),
                                    ],
                                  ),
                                ),
                                // Inline -1 Button
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.amber),
                                  tooltip: 'Decrease by ₹1',
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  onPressed: () {
                                    final newFare = (fare - 1.0).clamp(1.0, 500.0);
                                    _bus.setCustomFare(from, to, newFare);
                                    FleetState.instance.setBusStopFare(_bus.regNumber, from, to, newFare);
                                    if (selectedFrom == from && selectedTo == to) {
                                      fareInputCtrl.text = newFare.toStringAsFixed(1);
                                    }
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('₹${fare.toStringAsFixed(1)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen)),
                                ),
                                // Inline +1 Button
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.primaryGreen),
                                  tooltip: 'Increase by ₹1',
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  onPressed: () {
                                    final newFare = (fare + 1.0).clamp(1.0, 500.0);
                                    _bus.setCustomFare(from, to, newFare);
                                    FleetState.instance.setBusStopFare(_bus.regNumber, from, to, newFare);
                                    if (selectedFrom == from && selectedTo == to) {
                                      fareInputCtrl.text = newFare.toStringAsFixed(1);
                                    }
                                    setModalState(() {});
                                    setState(() {});
                                  },
                                ),
                                const SizedBox(width: 2),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
                                  tooltip: 'Edit exact fare',
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  onPressed: () {
                                    _showEditSingleFareDialog(
                                      parentCtx: sheetCtx,
                                      from: from,
                                      to: to,
                                      currentFare: fare,
                                      modalSetState: setModalState,
                                      fareInputCtrl: fareInputCtrl,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                  tooltip: 'Reset this stop pair to stage formula',
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                  onPressed: () {
                                    _bus.removeCustomFare(from, to);
                                    FleetState.instance.removeBusStopFare(_bus.regNumber, from, to);
                                    setModalState(() {});
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Removed custom tariff for $pairTitle. Reverted to stage formula.'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
                        foregroundColor: textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(sheetCtx),
                      child: const Text('Close Fare Chart', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Expanded(
                      child: Row(
                        children: [
                          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'CONDUCTOR GPS: ACTIVE',
                              style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
          // 2. ROUTE STOP-TO-STOP FARE CHART & TARIFF CARD
          // -------------------------------------------------------------------
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.currency_rupee, color: AppTheme.primaryGreen, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Stop-to-Stop Fare Chart',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_bus.customFareChart.length ~/ 2} active stop tariffs • Auto-calculates',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _showFareChartModal,
                        icon: const Icon(Icons.tune, size: 14),
                        label: const Text('Edit Chart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Assign exact fares between stops on this bus route. The ticketing dashboard calculates fares from this chart and allows live on-the-fly override.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick Fare Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: _bus.customFareChart.entries.take(4).map((e) {
                      final pair = e.key.split('->');
                      if (pair.length != 2) return const SizedBox.shrink();
                      return Chip(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade100,
                        avatar: const Icon(Icons.currency_rupee, size: 12, color: AppTheme.primaryGreen),
                        label: Text('${pair[0]} ➔ ${pair[1]}: ₹${e.value.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // 3. COMPLETE BUS SCHEDULE TIMELINE HEADER
          // -------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bus Journey Timetable', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      '${stops.length} scheduled stops • Chronological ascending order',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
          // 4. COMPLETE TIMELINE LIST VIEW
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
                              border: Border.all(
                                color: isCurrent
                                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)
                                    : Colors.transparent,
                                width: 2,
                              ),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stop.stopName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                        color: isCurrent ? AppTheme.primaryGreen : Theme.of(context).colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isCurrent)
                                      const Text(
                                        'BUS IS AT THIS STAGE (LIVE GPS)',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (isPassed)
                                      const Text('Stage Passed', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    if (isUpcoming)
                                      Text('Upcoming Stage', style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPassed
                                      ? (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : Colors.grey.shade100)
                                      : AppTheme.primaryGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  stop.time,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isPassed
                                        ? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey)
                                        : AppTheme.primaryGreen,
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
          const SizedBox(height: 10),
          const AppCreatorFooter(),
        ],
      ),
    );
  }
}
