import 'package:flutter/material.dart';
import '../widgets/shared_header.dart';

// This is now just the content widget, no Scaffold or BottomNavigationBar
class MusicPageContent extends StatefulWidget {
  const MusicPageContent({Key? key}) : super(key: key);

  @override
  State<MusicPageContent> createState() => _MusicPageContentState();
}

class _MusicPageContentState extends State<MusicPageContent> {
  String selectedSound = 'Classical';
  bool isPlaying = false;
  double frequencyValue = 300.0;

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
            const SharedHeader(),

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

          ],
        ),
      ),
    );
  }
}