import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For Date Formatting
import '../widgets/shared_header.dart';
import '../bluetooth_controller.dart';
import '../models/sleep_session.dart'; // Import the Database Model

class SleepDataPageContent extends StatefulWidget {
  const SleepDataPageContent({super.key});

  @override
  State<SleepDataPageContent> createState() => _SleepDataPageContentState();
}

class _SleepDataPageContentState extends State<SleepDataPageContent> {
  // Controller
  final BluetoothController _btController = BluetoothController();
  StreamSubscription? _streamSubscription;

  // Real-Time State Variables
  String _systemTime = "--:--:--";
  String _motionStatus = "Waiting...";
  String _sleepTimer = "-- min";
  String _micLevel = "0";
  
  // Colors for dynamic status
  Color _motionColor = Colors.white70;

  // --- DATABASE FUTURES (History Data) ---
  late Future<List<SleepSession>> _sessionsFuture;
  //late Future<Map<String, dynamic>> _averagesFuture;

  @override
  void initState() {
    super.initState();
    _listenToBluetooth();
    _refreshDatabaseData(); // Load history on startup
  }

  // Reloads data from SQLite
  void _refreshDatabaseData() {
    setState(() {
      _sessionsFuture = DatabaseHelper.instance.getAllSessions();
      //_averagesFuture = DatabaseHelper.instance.getAverages();
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  void _listenToBluetooth() {
    _streamSubscription = _btController.dataStream.listen((message) {
      if (!mounted) return;

      if (message.startsWith("DATA:")) {
        try {
          String cleanData = message.substring(5).trim();
          List<String> parts = cleanData.split('|');

          if (parts.length >= 4) {
            String rawTime = parts[0].trim();
            String rawMotion = parts[1].trim();
            int secondsLeft = int.tryParse(parts[2].trim()) ?? 0;
            String rawMic = parts[3].trim();

            setState(() {
              _systemTime = rawTime;
              
              if (rawMotion == "YES") {
                _motionStatus = "DETECTED";
                _motionColor = Colors.redAccent;
              } else {
                _motionStatus = "None";
                _motionColor = const Color(0xFF4CAF50); // Green
              }

              int mins = secondsLeft ~/ 60;
              int secs = secondsLeft % 60;
              _sleepTimer = "${mins}m ${secs.toString().padLeft(2, '0')}s";

              _micLevel = rawMic;
            });
          }
        } catch (e) {
          print("Parse Error: $e");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      // --- DEV TOOL: Button to generate fake data for testing ---
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await DatabaseHelper.instance.generateDummyData();
          _refreshDatabaseData(); // Refresh UI
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Generated 7 Days of Sleep Data")),
          );
        },
        label: const Text("Gen Data"),
        icon: const Icon(Icons.developer_mode),
        backgroundColor: Colors.white10,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SharedHeader(
              title: 'Sleep Data',
              subtitle: 'Real-Time Monitoring',
            ),
            const Divider(color: Colors.white24, height: 1),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Real-Time Monitor (Live)
                    _buildRealTimeMonitor(),
                    
                    const SizedBox(height: 24),
                    const Text("HISTORICAL AVERAGES", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // 2. Static Stats (Now Dynamic from DB)
                    HistoricalFlipCard(sessionsFuture: _sessionsFuture), // Flip Card with Graph
                    
                    const SizedBox(height: 24),
                    
                    // 3. Weekly Overview (Now Dynamic from DB)
                    _buildRecentActivityList(),
                    
                    // Add extra space for the FloatingButton
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildRealTimeMonitor() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF232b47),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LIVE SENSOR FEED',
                style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              Icon(Icons.sensors, color: Color(0xFF6a1b9a), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLiveItem("Device Clock", _systemTime, Icons.access_time),
              _buildLiveItem("Sleep Timer", _sleepTimer, Icons.timer),
            ],
          ),
          const Divider(color: Colors.white10, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Motion Sensor", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    _motionStatus,
                    style: TextStyle(color: _motionColor, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              _buildLiveItem("Mic Noise Level", _micLevel, Icons.graphic_eq),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white54, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // UPDATED: Now fetches List from SQLite
  Widget _buildRecentActivityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        
        FutureBuilder<List<SleepSession>>(
          future: _sessionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                child: const Text("No sleep data recorded yet.", style: TextStyle(color: Colors.white54)),
              );
            }

            final sessions = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true, // Vital for nesting in SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final dateStr = DateFormat('MMM dd').format(session.startTime);
                final durStr = "${(session.durationMinutes / 60).toStringAsFixed(1)} hrs";
                
                // Determine Emoji/Trend based on Quality
                bool isGood = session.qualityScore > 75;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2a2a3e),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Text(dateStr, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 10),
                          Text(isGood ? "😴" : "😐", style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(durStr, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                              Text(
                                "Eff: ${session.sleepEfficiency}% | Lat: ${session.sleepLatency}m", 
                                style: const TextStyle(fontSize: 10, color: Colors.white38)
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        isGood ? Icons.trending_up : Icons.trending_flat,
                        color: isGood ? const Color(0xFF7FFF00) : Colors.orange,
                        size: 24,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class HistoricalFlipCard extends StatefulWidget {
  final Future<List<SleepSession>> sessionsFuture; // Now accepts DB data

  const HistoricalFlipCard({Key? key, required this.sessionsFuture}) : super(key: key);

  @override
  _HistoricalFlipCardState createState() => _HistoricalFlipCardState();
}

class _HistoricalFlipCardState extends State<HistoricalFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  // Dropdown state
  String _selectedMetric = 'Quality';
  final List<String> _metrics = ['Quality', 'Duration', 'Efficiency', 'Latency'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isFront ? _toggleCard : null, // Only tap front to flip. Back has its own close button.
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle < (pi / 2)
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateX(pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232b47), // Matched to your app's card color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.bar_chart, color: Color(0xFF6a1b9a), size: 50),
          SizedBox(height: 15),
          Text(
            "Historical Trends",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            "Tap to view your 7-day sleep charts",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a3e),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // Header Row with Dropdown and Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: _selectedMetric,
                dropdownColor: const Color(0xFF232b47),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                underline: Container(), // Hides the default underline
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6a1b9a)),
                items: _metrics.map((String metric) {
                  return DropdownMenuItem<String>(
                    value: metric,
                    child: Text(metric),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedMetric = newValue!;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: _toggleCard, // Flip back to front
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 10),

          // The Dynamic Graph
          Expanded(
            child: FutureBuilder<List<SleepSession>>(
              future: widget.sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6a1b9a)));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No data generated yet.", style: TextStyle(color: Colors.white54)));
                }

                // Get last 7 sessions and sort them chronologically (oldest to newest for graph)
                List<SleepSession> sessions = snapshot.data!.take(7).toList();
                sessions.sort((a, b) => a.startTime.compareTo(b.startTime));

                // 1. Determine the maximum value for accurate bar scaling
                double maxScaleValue = 100.0; // Default max for Quality & Efficiency (%)
                if (_selectedMetric == 'Duration') {
                  maxScaleValue = sessions.map((s) => s.durationMinutes.toDouble()).reduce(max);
                  if (maxScaleValue < 1) maxScaleValue = 1; // Prevent division by zero
                } else if (_selectedMetric == 'Latency') {
                  maxScaleValue = sessions.map((s) => s.sleepLatency.toDouble()).reduce(max);
                  if (maxScaleValue < 1) maxScaleValue = 1;
                }

                // 2. Draw the bars
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: sessions.map((session) {
                    // Extract the specific value based on the dropdown
                    double rawValue = 0;
                    String displayLabel = "";

                    if (_selectedMetric == 'Quality') {
                      rawValue = session.qualityScore.toDouble();
                      displayLabel = "${rawValue.toInt()}%";
                    } else if (_selectedMetric == 'Efficiency') {
                      rawValue = session.sleepEfficiency.toDouble();
                      displayLabel = "${rawValue.toInt()}%";
                    } else if (_selectedMetric == 'Duration') {
                      rawValue = session.durationMinutes.toDouble();
                      displayLabel = "${(rawValue / 60).toStringAsFixed(1)}h";
                    } else if (_selectedMetric == 'Latency') {
                      rawValue = session.sleepLatency.toDouble();
                      displayLabel = "${rawValue.toInt()}m";
                    }

                    // Calculate bar height relative to the max value
                    double heightPercentage = rawValue / maxScaleValue;
                    if (heightPercentage > 1.0) heightPercentage = 1.0;

                    // Get Day string (e.g., "Mon")
                    String dayStr = DateFormat('E').format(session.startTime);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(displayLabel, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                        const SizedBox(height: 4),
                        // The animated bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 20,
                          height: 120 * heightPercentage, 
                          decoration: BoxDecoration(
                            color: const Color(0xFF6a1b9a), // Theme purple
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(dayStr, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}