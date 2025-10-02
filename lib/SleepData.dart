import 'package:flutter/material.dart';

class SleepDataScreen extends StatelessWidget {
  const SleepDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsCard(),
                    const SizedBox(height: 24),
                    _buildWeeklyOverview(),
                    const SizedBox(height: 24),
                    _buildLastNightSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Smart Sleep',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              Text(
                'Embedded Sound Therapy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '06/18/2025',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              Text(
                'Wednesday',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4a148c),
            const Color(0xFF6a1b9a),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: const [
              Text(
                '85%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7FFF00),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Average Sleep Quality',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
          Column(
            children: const [
              Text(
                '6.5 hrs',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7FFF00),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Average Sleep Duration',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    final weekData = [
      {'date': 'June 17', 'emoji': '😴', 'hours': '7 hrs', 'trend': true},
      {'date': 'June 16', 'emoji': '😴', 'hours': '6.5 hrs', 'trend': false},
      {'date': 'June 15', 'emoji': '😴', 'hours': '6.8 hrs', 'trend': true},
      {'date': 'June 14', 'emoji': '😴', 'hours': '7.3 hrs', 'trend': true},
      {'date': 'June 13', 'emoji': '😴', 'hours': '7.5 hrs', 'trend': true},
      {'date': 'June 12', 'emoji': '😴', 'hours': '4.1 hrs', 'trend': false},
      {'date': 'June 11', 'emoji': '😴', 'hours': '6.4 hrs', 'trend': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...weekData.map((data) => _buildWeekItem(
              data['date'] as String,
              data['emoji'] as String,
              data['hours'] as String,
              data['trend'] as bool,
            )),
      ],
    );
  }

  Widget _buildWeekItem(String date, String emoji, String hours, bool trendUp) {
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
              Text(
                date,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                hours,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          Icon(
            trendUp ? Icons.trending_up : Icons.trending_down,
            color: trendUp ? const Color(0xFF7FFF00) : Colors.red,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildLastNightSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Last Night\'s Sleep',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'Sleep graph coming soon',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white38,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white24, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: const Color(0xFF1a1a2e),
        selectedItemColor: const Color(0xFF6a1b9a),
        unselectedItemColor: Colors.white54,
        currentIndex: 1, // Sleep Data is selected
        onTap: (index) {
          if (index == 0) {
            // Go back to Music/Landing page
            Navigator.pop(context);
          } else if (index == 2) {
            // Diagnostics - do nothing for now or show message
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Music',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Sleep Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Diagnostics',
          ),
        ],
      ),
    );
  }
}
