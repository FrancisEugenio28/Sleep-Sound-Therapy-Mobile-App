import 'package:flutter/material.dart';
import 'SleepData.dart';

class SleepTherapyApp extends StatelessWidget {
  const SleepTherapyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Sleep',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF1a1a2e),
        scaffoldBackgroundColor: const Color(0xFF1a1a2e),
        fontFamily: 'Sans-serif',
      ),
      home: const SoundTherapyScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SoundTherapyScreen extends StatefulWidget {
  const SoundTherapyScreen({Key? key}) : super(key: key);

  @override
  State<SoundTherapyScreen> createState() => _SoundTherapyScreenState();
}

class _SoundTherapyScreenState extends State<SoundTherapyScreen> {
  String selectedSound = 'Classical';
  bool isPlaying = false;
  double frequencyValue = 300.0;
  int selectedTab = 0;

  final List<String> soundOptions = [
    'Broadband\nNoise',
    'Classical',
    'Nature\nSound',
    'Binaural\nBeats',
    'ASMR',
    'Lullaby',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Smart Sleep',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
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
                        '08/18/2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        'Wednesday',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24, height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Now Playing Card
                    Container(
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
                      child: Column(
                        children: [
                          const Text(
                            'Now Playing',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Claude Debussy - Clair de Lune',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.shuffle, size: 28),
                                color: Colors.white,
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.skip_previous, size: 32),
                                color: Colors.white,
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isPlaying = !isPlaying;
                                    });
                                  },
                                  icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 32,
                                  ),
                                  color: const Color(0xFF4a148c),
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.skip_next, size: 32),
                                color: Colors.white,
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.repeat, size: 28),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Select Sound Section
                    const Text(
                      'Select Sound',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sound Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.8,
                      ),
                      itemCount: soundOptions.length,
                      itemBuilder: (context, index) {
                        final sound = soundOptions[index];
                        final isSelected = sound.replaceAll('\n', ' ') == selectedSound.replaceAll('\n', ' ');
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedSound = sound;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2a2a3e),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF6a1b9a) 
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                sound,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Frequency Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Frequency',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '300 Hz',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6a1b9a),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Frequency Slider
                    Row(
                      children: [
                        const Icon(
                          Icons.graphic_eq,
                          color: Colors.white70,
                          size: 24,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFF6a1b9a),
                              inactiveTrackColor: Colors.white24,
                              thumbColor: const Color(0xFF6a1b9a),
                              overlayColor: const Color(0xFF6a1b9a).withOpacity(0.3),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: frequencyValue,
                              min: 60,
                              max: 500,
                              onChanged: (value) {
                                setState(() {
                                  frequencyValue = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            '60 Hz',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                          Text(
                            '500 Hz',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.white24, width: 1),
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: const Color(0xFF1a1a2e),
                selectedItemColor: const Color(0xFF6a1b9a),
                unselectedItemColor: Colors.white54,
                currentIndex: selectedTab,
                onTap: (index) {
                  if (index == 1) {
                    // Navigate to Sleep Data screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SleepDataScreen(),
                      ),
                    );
                  } else {
                    setState(() {
                      selectedTab = index;
                    });
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
            ),
          ],
        ),
      ),
    );
  }
}