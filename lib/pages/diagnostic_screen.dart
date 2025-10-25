  import 'package:flutter/material.dart'; 
  import '../widgets/shared_header.dart';

  class DiagnosticScreenContent extends StatelessWidget {
    const DiagnosticScreenContent({super.key});

    static const Color _cardColor = Color(0xFF232b47); 
    static const Color _primaryGreen = Color(0xFF4CAF50); 
    static const Color _progressAccent = Color(0xFF6A3DA0); 
    static const Color _scaffoldBackground = Color(0xFF1a1a2e);

    // Running Diagnostic Progress Box
    Widget _buildRunningDiagnosticBox() {
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Running Full Diagnostic',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Progress Bar
            LinearProgressIndicator(
              value: 1.0, // Set to 100% complete
              backgroundColor: _progressAccent.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(_progressAccent),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Diagnostic Complete',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '100 %',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Individual Test Result Card (e.g., Bluetooth, Audio)
    Widget _buildTestCard({required String title}) {
      
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Passed',
                  style: TextStyle(
                    color: _primaryGreen,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            // Checkmark icon
            const Icon(
              Icons.check_circle_outline, 
              color: _primaryGreen, 
              size: 24,
            ),
          ],
        ),
      );
    }

    // Status Banner and Button Section
    Widget _buildStatusAndButton() {
      const successColor = _cardColor; 
      const buttonColor = _primaryGreen; 

      return Column(
        children: [
          // Status Banner
          Container(
            margin: const EdgeInsets.only(top: 15, left: 20, right: 20, bottom: 25),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: successColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.check_box, color: Colors.white, size: 24),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All test passed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Your device is functioning properly. All tests completed successfully.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Run Diagnostic Again Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              onPressed: () {
                // Handle button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'RUN DIAGNOSTIC AGAIN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _scaffoldBackground, 
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10.0), 
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  
                  const Expanded(
                    child: SharedHeader(
                      title: 'System Diagnostic',
                      subtitle: 'Hardware & Software Tests',
                    ),
                  ),
                ],
              ),
            ),
              
            const Divider(
              color: Colors.white24, 
              height: 1, 
              thickness: 1, 
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20), 
                  child: Column(
                    children: <Widget>[
                      _buildRunningDiagnosticBox(),
                      
                      // Individual Tests
                      _buildTestCard(title: 'Bluetooth Connectivity'),
                      _buildTestCard(title: 'Audio Output Test'),
                      _buildTestCard(title: 'Battery'),
                      _buildTestCard(title: 'Sensors'),
                      
                      _buildStatusAndButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }