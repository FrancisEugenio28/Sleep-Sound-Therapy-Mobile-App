import 'package:flutter/material.dart';
import '../widgets/shared_header.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import '../models/Broadband.dart';

class MusicPageContent extends StatefulWidget {
  const MusicPageContent({super.key});

  @override
  State<MusicPageContent> createState() => _MusicPageContentState();
}

class _MusicPageContentState extends State<MusicPageContent> {
  String selectedSound = 'Classical';
  bool isPlaying = false;
  double frequencyValue = 300.0;
  bool showSoundPlayer = false; // NEW: to toggle view

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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: showSoundPlayer
              ? BroadbandPage(
                  key: const ValueKey('player'),
                  soundName: selectedSound.replaceAll('\n', ' '), 
                  artist: "Sleep Therapy",
                  category: "Relaxation",
                  onBack: () {
                    setState(() => showSoundPlayer = false);
                  },
                )
              : _buildMusicOptionsView(),
        ),
      ),
    );
  }

  Widget _buildMusicOptionsView() {
    return Column(
      children: [
        const SharedHeader(),
        const Divider(color: Colors.white24, height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎵 Now Playing Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4a148c), Color(0xFF6a1b9a)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Now Playing',
                          style: TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 8),
                      const Text('Claude Debussy - Clair de Lune',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.shuffle, size: 28),
                              color: Colors.white),
                          const SizedBox(width: 16),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.skip_previous, size: 32),
                              color: Colors.white),
                          const SizedBox(width: 16),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                setState(() => isPlaying = !isPlaying);
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
                              color: Colors.white),
                          const SizedBox(width: 16),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.repeat, size: 28),
                              color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 🎧 Select Sound
                const Text(
                  'Select Sound',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // 🟪 Sound Grid
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
                    final isSelected = sound.replaceAll('\n', ' ') ==
                        selectedSound.replaceAll('\n', ' ');

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedSound = sound;
                          if (sound.contains('Broadband')) {
                            // when user clicks Broadband Noise
                            showSoundPlayer = true;
                          }
                          if (sound.contains('Classical')) {
                            // when user clicks Classical
                            showSoundPlayer = true;
                          }
                          if (sound.contains('Nature')) {
                            // when user clicks Nature
                            showSoundPlayer = true;
                          }
                          if (sound.contains('Binaural')) {
                            // when user clicks Binaural
                            showSoundPlayer = true;
                          }
                          if (sound.contains('ASMR')) {
                            // when user clicks ASMR
                            showSoundPlayer = true;
                          }
                          if (sound.contains('Lullaby')) {
                            // when user clicks Lullaby
                            showSoundPlayer = true;
                          }
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

                // 🔊 Frequency Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Frequency',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Text('${frequencyValue.toStringAsFixed(0)} Hz',
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6a1b9a),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const RiveAnimatedIcon(
                      riveIcon: RiveIcon.sound,
                      width: 36,
                      height: 36,
                      color: Colors.white70,
                      loopAnimation: true,
                    ),
                    Expanded(
                      child: SfSlider(
                        min: 50.0,
                        max: 500.0,
                        value: frequencyValue,
                        interval: 50,
                        stepSize: 50,
                        showTicks: true,
                        showLabels: true,
                        enableTooltip: true,
                        activeColor: const Color(0xFF6a1b9a),
                        inactiveColor: Colors.white24,
                        onChanged: (dynamic value) {
                          setState(() {
                            frequencyValue = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
