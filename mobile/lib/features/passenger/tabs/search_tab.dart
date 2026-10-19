import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../bus_location_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> with SingleTickerProviderStateMixin {
  late TabController _innerTabCtrl;

  // -------------------------------------------------------------------------
  // Inner Tab 1: Route Search State
  // -------------------------------------------------------------------------
  final _startSearchController = TextEditingController(text: 'Aluva Stand');
  final _endSearchController = TextEditingController(text: 'Perumbavoor Stand');
  bool _hasSearchedRoute = false;
  List<String> _startSuggestions = [];
  List<String> _endSuggestions = [];
  bool _showStartSuggestions = false;
  bool _showEndSuggestions = false;

  // -------------------------------------------------------------------------
  // Inner Tab 2: Bus Search by Name or Reg Number State
  // -------------------------------------------------------------------------
  final _busSearchController = TextEditingController(text: '');
  BusModel? _selectedBus;

  // Dynamic stops extracted from all buses registered/modified by owner & conductor
  List<String> get _dynamicStops {
    final stopsSet = <String>{};
    for (final b in FleetState.instance.buses) {
      if (b.startPoint.trim().isNotEmpty) stopsSet.add(b.startPoint.trim());
      if (b.destPoint.trim().isNotEmpty) stopsSet.add(b.destPoint.trim());
      for (final s in b.stops) {
        if (s.stopName.trim().isNotEmpty) stopsSet.add(s.stopName.trim());
      }
    }
    // Baseline Kerala stops
    stopsSet.addAll([
      'Aluva Stand',
      'Bank Junction',
      'Pump Junction',
      'Kizhakkambalam',
      'Pattimattom',
      'Perumbavoor Stand',
      'Angamaly Stand',
      'Ernakulam Kaloor',
      'Thoppumpady',
      'Vytilla Hub',
      'Kakkanad InfoPark',
      'Palarivattom Bypass',
    ]);
    final sortedList = stopsSet.toList()..sort();
    return sortedList;
  }

  Color _getCategoryColor(String category) {
    if (category.contains('Red') || category.contains('Limited')) {
      return const Color(0xFFC62828);
    } else if (category.contains('Blue') || category.contains('Ordinary')) {
      return const Color(0xFF1565C0);
    } else {
      return const Color(0xFF2E7D32);
    }
  }

  @override
  void initState() {
    super.initState();
    _innerTabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _innerTabCtrl.dispose();
    _startSearchController.dispose();
    _endSearchController.dispose();
    _busSearchController.dispose();
    super.dispose();
  }

  void _onStartChanged(String text) {
    setState(() {
      if (text.trim().isEmpty) {
        _startSuggestions = [];
        _showStartSuggestions = false;
      } else {
        _startSuggestions = _dynamicStops
            .where((s) => s.toLowerCase().contains(text.trim().toLowerCase()))
            .toList();
        _showStartSuggestions = _startSuggestions.isNotEmpty;
      }
    });
  }

  void _onEndChanged(String text) {
    setState(() {
      if (text.trim().isEmpty) {
        _endSuggestions = [];
        _showEndSuggestions = false;
      } else {
        _endSuggestions = _dynamicStops
            .where((s) => s.toLowerCase().contains(text.trim().toLowerCase()))
            .toList();
        _showEndSuggestions = _endSuggestions.isNotEmpty;
      }
    });
  }

  void _selectStartStop(String stop) {
    setState(() {
      _startSearchController.text = stop;
      _showStartSuggestions = false;
    });
  }

  void _selectEndStop(String stop) {
    setState(() {
      _endSearchController.text = stop;
      _showEndSuggestions = false;
    });
  }

  void _searchRoute() {
    FocusScope.of(context).unfocus();
    setState(() {
      _showStartSuggestions = false;
      _showEndSuggestions = false;
      _hasSearchedRoute = true;
    });
  }

  List<BusModel> _getFilteredRouteBuses() {
    if (!_hasSearchedRoute) return [];

    final startQuery = _startSearchController.text.trim().toLowerCase();
    final endQuery = _endSearchController.text.trim().toLowerCase();

    final matches = FleetState.instance.buses.where((bus) {
      final allStopsText = '${bus.startPoint} ${bus.destPoint} ${bus.routeName} ${bus.stops.map((s) => s.stopName).join(" ")}'.toLowerCase();
      final hasStart = startQuery.isEmpty || allStopsText.contains(startQuery);
      final hasEnd = endQuery.isEmpty || allStopsText.contains(endQuery);
      return hasStart && hasEnd;
    }).toList();

    return matches.isNotEmpty ? matches : FleetState.instance.buses;
  }

  List<BusModel> _getMatchingBusesByNameOrReg() {
    final query = _busSearchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return FleetState.instance.buses;
    }

    final queryClean = query.replaceAll(' ', '');
    return FleetState.instance.buses.where((bus) {
      final nameMatches = bus.busName.toLowerCase().contains(query);
      final regMatches = bus.regNumber.toLowerCase().replaceAll(' ', '').contains(queryClean);
      return nameMatches || regMatches;
    }).toList();
  }

  void _openBusLiveLocation(BusModel bus) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusLocationScreen(
          busRegNumber: bus.regNumber,
          busName: bus.busName,
          routeName: bus.routeName,
          companyName: bus.companyName,
          currentStop: bus.currentStop,
          nextStop: bus.nextStop,
          eta: bus.eta,
          stops: bus.stops,
          category: bus.category,
          driverName: bus.driverName,
          conductorName: bus.conductorName,
        ),
      ),
    );
  }

  Widget _buildDirectContactCard(BusModel bus) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.headset_mic, size: 16, color: AppTheme.primaryGreen),
              SizedBox(width: 6),
              Text('Direct Operator & Crew Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          // Owner Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Owner: ${bus.ownerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('${bus.ownerPhone} • ${bus.ownerEmail}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, size: 18, color: AppTheme.primaryGreen),
                    tooltip: 'Call Owner',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling Bus Owner: ${bus.ownerPhone} (${bus.ownerName})')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.email, size: 18, color: Colors.blueAccent),
                    tooltip: 'Email Owner',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Composing email to: ${bus.ownerEmail}')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 14),
          // Conductor Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Conductor: ${bus.conductorName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text('${bus.conductorPhone} • ${bus.conductorEmail}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.call, size: 18, color: AppTheme.primaryGreen),
                    tooltip: 'Call Conductor',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling Conductor: ${bus.conductorPhone} (${bus.conductorName})')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.email, size: 18, color: Colors.blueAccent),
                    tooltip: 'Email Conductor',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Composing email to: ${bus.conductorEmail}')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRateAndFeedbackDialog(BuildContext context, BusModel bus) {
    double selectedRating = 5.0;
    final commentCtrl = TextEditingController();
    final quickTags = [
      'Punctual & on time ⏱️',
      'Clean & sanitized 🧼',
      'Polite Conductor 🤝',
      'Safe driving 🚌',
      'Student friendly 🎒',
    ];

    showDialog(
      context: context,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            final starLabels = {
              1.0: 'Poor Service (1 Star)',
              2.0: 'Below Average (2 Stars)',
              3.0: 'Average (3 Stars)',
              4.0: 'Good Experience (4 Stars)',
              5.0: 'Excellent & Highly Recommended (5 Stars)',
            };

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Icon(Icons.rate_review, color: AppTheme.accentAmber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rate ${bus.busName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${bus.regNumber} • ${bus.companyName}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    // Star Rating Selector
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starNum = index + 1.0;
                          return IconButton(
                            iconSize: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            icon: Icon(
                              starNum <= selectedRating ? Icons.star : Icons.star_border,
                              color: AppTheme.accentAmber,
                            ),
                            onPressed: () {
                              setDlgState(() {
                                selectedRating = starNum;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    Center(
                      child: Text(
                        starLabels[selectedRating] ?? 'Selected: ${selectedRating.toInt()} Stars',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Tags
                    const Text('Quick Highlights:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: quickTags.map((tag) {
                        return ActionChip(
                          label: Text(tag, style: const TextStyle(fontSize: 10)),
                          backgroundColor: Colors.grey.shade100,
                          onPressed: () {
                            setDlgState(() {
                              if (commentCtrl.text.isEmpty) {
                                commentCtrl.text = tag;
                              } else {
                                commentCtrl.text = '${commentCtrl.text}, $tag';
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // Comments input
                    TextField(
                      controller: commentCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share feedback regarding timings, conductor attitude, driving quality...',
                        hintStyle: const TextStyle(fontSize: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 12, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Ratings notify the Owner & Conductor instantly.',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dlgCtx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final comment = commentCtrl.text.trim().isNotEmpty
                        ? commentCtrl.text.trim()
                        : 'Great service on ${bus.busName}!';
                    FleetState.instance.addReview(
                      busId: bus.id,
                      busRegNumber: bus.regNumber,
                      busName: bus.busName,
                      passengerName: 'Anjali Nair',
                      rating: selectedRating,
                      comment: comment,
                    );
                    Navigator.pop(dlgCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Feedback submitted for ${bus.busName}! Notified to Owner & Conductor.'),
                        backgroundColor: AppTheme.primaryGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('Submit Review'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRateAndFeedbackButton(BusModel bus) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.amber.shade900,
          side: BorderSide(color: Colors.amber.shade400, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: () => _showRateAndFeedbackDialog(context, bus),
        icon: const Icon(Icons.star_rate, color: Colors.amber),
        label: const Text('Rate & Give Feedback for this Bus', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showBusRouteTimelineModal(BusModel bus) {
    // Sort bus stops in ascending order of scheduled time
    final sortedStops = List<BusStopSchedule>.from(bus.stops);
    sortedStops.sort((a, b) => parseTimeToMinutes(a.time).compareTo(parseTimeToMinutes(b.time)));
    final catColor = _getCategoryColor(bus.category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(bus.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                          Text(bus.regNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 13)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: bus.isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: bus.isActive ? Colors.green.shade300 : Colors.red.shade300),
                        ),
                        child: Text(
                          bus.isActive ? 'ACTIVE ON ROUTE' : 'INACTIVE',
                          style: TextStyle(
                            color: bus.isActive ? Colors.green.shade800 : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: catColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(bus.category, style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const Divider(height: 24),
                  const Text('Scheduled Stops & Timeline (Ascending)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Operating from ${bus.startTime} to ${bus.endTime}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 14),

                  // Scheduled timeline nodes in ascending order
                  ...sortedStops.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final stop = entry.value;
                    final isFirst = idx == 0;
                    final isLast = idx == sortedStops.length - 1;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: isFirst || isLast ? AppTheme.primaryGreen : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.primaryGreen, width: 2),
                              ),
                              child: isFirst
                                  ? const Icon(Icons.trip_origin, size: 10, color: Colors.white)
                                  : (isLast ? const Icon(Icons.location_on, size: 10, color: Colors.white) : null),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 38,
                                color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  stop.stopName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: (isFirst || isLast) ? FontWeight.bold : FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    stop.time,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

                  const SizedBox(height: 14),

                  // Conductor & Owner Direct Contact
                  _buildDirectContactCard(bus),

                  const SizedBox(height: 10),

                  // Rate & Give Feedback
                  _buildRateAndFeedbackButton(bus),

                  const SizedBox(height: 10),

                  // Live Location Radar Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      Navigator.pop(modalCtx);
                      _openBusLiveLocation(bus);
                    },
                    icon: const Icon(Icons.radar),
                    label: const Text('Open Live GPS Radar & Timeline', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-Tabs Header
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _innerTabCtrl,
            labelColor: AppTheme.primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryGreen,
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.alt_route, size: 20),
                text: 'Bus Route Search',
              ),
              Tab(
                icon: Icon(Icons.search, size: 20),
                text: 'Bus Search',
              ),
            ],
          ),
        ),

        // Sub-Tabs Content
        Expanded(
          child: TabBarView(
            controller: _innerTabCtrl,
            children: [
              _buildRouteSearchTab(),
              _buildBusSearchTab(),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // INNER TAB 1: BUS ROUTE SEARCH (TYPE-TO-SEARCH STOPS)
  // -------------------------------------------------------------------------
  Widget _buildRouteSearchTab() {
    final filteredBuses = _getFilteredRouteBuses();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Route Input Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Search Running Buses on Route', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Type stop names to see live autocomplete suggestions', 
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 14),

                  // 1. Start Point Type-To-Search Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _startSearchController,
                        onChanged: _onStartChanged,
                        decoration: InputDecoration(
                          labelText: 'Trip Start Point',
                          hintText: 'Type to search stops (e.g. Aluva, Kaloor)',
                          prefixIcon: const Icon(Icons.trip_origin, color: AppTheme.primaryGreen),
                          suffixIcon: _startSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _startSearchController.clear();
                                    _onStartChanged('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      if (_showStartSuggestions)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _startSuggestions.length,
                            itemBuilder: (context, idx) {
                              final suggestion = _startSuggestions[idx];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.place, size: 16, color: AppTheme.primaryGreen),
                                title: Text(suggestion, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                onTap: () => _selectStartStop(suggestion),
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 2. End Point Type-To-Search Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _endSearchController,
                        onChanged: _onEndChanged,
                        decoration: InputDecoration(
                          labelText: 'Trip End Point',
                          hintText: 'Type to search stops (e.g. Perumbavoor, Angamaly)',
                          prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                          suffixIcon: _endSearchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _endSearchController.clear();
                                    _onEndChanged('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      if (_showEndSuggestions)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: _endSuggestions.length,
                            itemBuilder: (context, idx) {
                              final suggestion = _endSuggestions[idx];
                              return ListTile(
                                dense: true,
                                leading: const Icon(Icons.place, size: 16, color: Colors.red),
                                title: Text(suggestion, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                onTap: () => _selectEndStop(suggestion),
                              );
                            },
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Popular Stop Quick-Fill Chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      'Aluva Stand',
                      'Perumbavoor Stand',
                      'Angamaly Stand',
                      'Ernakulam Kaloor',
                      'Kakkanad InfoPark',
                      'Vytilla Hub',
                    ].map((s) {
                      return ActionChip(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        label: Text(s, style: const TextStyle(fontSize: 10)),
                        onPressed: () {
                          if (_startSearchController.text.isEmpty) {
                            _selectStartStop(s);
                          } else {
                            _selectEndStop(s);
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _searchRoute,
                    icon: const Icon(Icons.search),
                    label: const Text('Search Running Buses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bus Search Results
          if (_hasSearchedRoute) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Buses on Route (${filteredBuses.length} running)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Text('Tap bus for timeline schedule', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),

            ...filteredBuses.map((bus) {
              final catColor = _getCategoryColor(bus.category);

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: bus.isActive ? Colors.green.withValues(alpha: 0.3) : Colors.grey.shade300,
                    width: bus.isActive ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _showBusRouteTimelineModal(bus),
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
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: bus.isActive
                                            ? AppTheme.primaryGreen.withValues(alpha: 0.1)
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.directions_bus,
                                        color: bus.isActive ? AppTheme.primaryGreen : Colors.grey.shade600,
                                        size: 24,
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          bus.isActive ? Icons.check_circle : Icons.cancel,
                                          color: bus.isActive ? Colors.green : Colors.red,
                                          size: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(bus.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: bus.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: bus.isActive ? Colors.green.shade300 : Colors.red.shade300,
                                            ),
                                          ),
                                          child: Text(
                                            bus.isActive ? 'ACTIVE' : 'INACTIVE',
                                            style: TextStyle(
                                              color: bus.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(bus.regNumber, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${bus.seatingCapacity} Seats', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                Text('Driver: ${bus.driverName.split(" ").first}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Livery Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: catColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6, decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text(bus.category, style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text('Route: ${bus.routeName}', style: const TextStyle(fontSize: 12, color: Colors.black87)),

                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 15, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('${bus.startTime} ➔ ${bus.endTime}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                              ],
                            ),
                            const Row(
                              children: [
                                Text('View Schedule Timeline', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 11, color: AppTheme.primaryGreen),
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
          ] else ...[
            Container(
              padding: const EdgeInsets.all(28),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.directions_bus, size: 48, color: Colors.black26),
                  SizedBox(height: 10),
                  Text('Type stop names to search running buses on your route', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // INNER TAB 2: BUS SEARCH (BY NAME OR REG NUMBER)
  // Shows list first; full details only shown upon selecting a bus
  // -------------------------------------------------------------------------
  Widget _buildBusSearchTab() {
    final matchingBuses = _getMatchingBusesByNameOrReg();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Input Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Search by Bus Name or Reg. Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('Type bus name (e.g. City Express) or Kerala number plate', 
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _busSearchController,
                          onChanged: (val) {
                            setState(() {
                              _selectedBus = null; // Reset detailed selection when query changes
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Bus Name or Plate Number',
                            hintText: 'e.g. City, SpeedWings, or KL 07 CD 4589',
                            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                            suffixIcon: _busSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _busSearchController.clear();
                                      setState(() {
                                        _selectedBus = null;
                                      });
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _selectedBus = null;
                          });
                        },
                        child: const Text('Find', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Quick query chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: ['SpeedWings', 'GreenCity', 'City Rider', 'KL 07 CD 4589', 'KL 07 CE 1204'].map((q) {
                      return ActionChip(
                        label: Text(q, style: const TextStyle(fontSize: 10)),
                        onPressed: () {
                          _busSearchController.text = q;
                          setState(() {
                            _selectedBus = null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // -------------------------------------------------------------------
          // STATE 1: If passenger has selected a bus -> SHOW ALL DETAILS
          // -------------------------------------------------------------------
          if (_selectedBus != null) ...[
            Builder(builder: (context) {
              final bus = _selectedBus!;
              final catColor = _getCategoryColor(bus.category);

              // Sort timetable in ascending order of time
              final sortedStops = List<BusStopSchedule>.from(bus.stops);
              sortedStops.sort((a, b) => parseTimeToMinutes(a.time).compareTo(parseTimeToMinutes(b.time)));

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with back to list button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => setState(() => _selectedBus = null),
                            icon: const Icon(Icons.arrow_back, size: 16, color: AppTheme.primaryGreen),
                            label: const Text('Back to Matching Buses', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: bus.isActive ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: bus.isActive ? Colors.green.shade300 : Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(bus.isActive ? Icons.sensors : Icons.power_settings_new,
                                    size: 12, color: bus.isActive ? Colors.green.shade700 : Colors.red.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  bus.isActive ? 'ACTIVE ON ROUTE' : 'INACTIVE',
                                  style: TextStyle(
                                    color: bus.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(bus.busName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(bus.regNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen, fontSize: 14)),
                      const SizedBox(height: 8),

                      // Livery Category Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: catColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.palette, color: catColor, size: 14),
                            const SizedBox(width: 6),
                            Text(bus.category, style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                      ),

                      const Divider(height: 24),
                      _detailRow('Owner / Operator', bus.companyName),
                      _detailRow('Corridor Route', '${bus.startPoint} ➔ ${bus.destPoint}'),
                      _detailRow('Route Schedule', bus.routeName),
                      _detailRow('Daily Service Timings', '${bus.startTime} to ${bus.endTime}'),
                      _detailRow('Seating Capacity', '${bus.seatingCapacity} Passenger Seats'),
                      _detailRow('Driver', bus.driverName),
                      _detailRow('Cleaner / Attendant', bus.cleanerName),
                      _detailRow('Assigned Conductor', bus.conductorName),
                      _detailRow('Current Location Stage', bus.currentStop),
                      _detailRow('Next Stop ETA', '${bus.nextStop} (${bus.eta})'),

                      const SizedBox(height: 14),

                      // Stops & Timetable in ascending order
                      const Text('Full Route Timetable (Ascending Order):', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                      const SizedBox(height: 8),
                      if (sortedStops.isEmpty)
                        const Text('No scheduled intermediate stops recorded.', style: TextStyle(color: Colors.grey, fontSize: 12))
                      else
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: sortedStops.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final s = entry.value;
                              final isFirst = idx == 0;
                              final isLast = idx == sortedStops.length - 1;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      isFirst ? Icons.trip_origin : (isLast ? Icons.location_on : Icons.circle),
                                      size: 12,
                                      color: isFirst ? AppTheme.primaryGreen : (isLast ? Colors.red : Colors.grey),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        s.stopName,
                                        style: TextStyle(
                                          fontWeight: (isFirst || isLast) ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        s.time,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 18),

                      // Conductor & Owner Direct Contact
                      _buildDirectContactCard(bus),

                      const SizedBox(height: 12),

                      // Rate & Give Feedback
                      _buildRateAndFeedbackButton(bus),

                      const SizedBox(height: 12),

                      // Live Radar Location Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentAmber,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => _openBusLiveLocation(bus),
                          icon: const Icon(Icons.location_on),
                          label: const Text('View Current Live Radar Location & GPS', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ]

          // -------------------------------------------------------------------
          // STATE 2: INITIAL LIST OF MATCHING BUSES (Only summary shown)
          // -------------------------------------------------------------------
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Matching Buses (${matchingBuses.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const Text('Select a bus to inspect details', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 10),

            if (matchingBuses.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('No buses found matching your search query.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ...matchingBuses.map((bus) {
                final catColor = _getCategoryColor(bus.category);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: bus.isActive ? Colors.green.withValues(alpha: 0.3) : Colors.grey.shade300,
                      width: bus.isActive ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        _selectedBus = bus; // Select bus to reveal all details!
                      });
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
                                      color: bus.isActive ? AppTheme.primaryGreen.withValues(alpha: 0.1) : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.directions_bus,
                                      color: bus.isActive ? AppTheme.primaryGreen : Colors.grey.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(bus.busName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 2),
                                      Text(bus.regNumber, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: bus.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: bus.isActive ? Colors.green.shade300 : Colors.red.shade300),
                                ),
                                child: Text(
                                  bus.isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    color: bus.isActive ? Colors.green.shade800 : Colors.red.shade800,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Livery tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: catColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 6, height: 6, decoration: BoxDecoration(color: catColor, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(bus.category, style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),
                          Text('Route: ${bus.routeName}', style: const TextStyle(fontSize: 12, color: Colors.black87)),

                          const Divider(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Tap to view full timetable & crew details', 
                                style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                              Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primaryGreen),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
