// lib/landing_page.dart
import 'package:flutter/material.dart';
import '../widgets/shared_header.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import '../models/sound_player.dart';
import 'package:just_audio/just_audio.dart';

class MusicPageContent extends StatefulWidget {
  const MusicPageContent({super.key});

  @override
  State<MusicPageContent> createState() => _MusicPageContentState();
}

class _MusicPageContentState extends State<MusicPageContent> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  String? currentlyPlayingSound;
  String currentCategory = 'Broadband Noise'; // Default category
  bool showSoundPlayer = false;

  final Map<String, List<String>> playlists = {
    'Broadband Noise': [
      'White Noise', 'Pink Noise', 'Brown Noise', 'Blue Noise',
      'Violet Noise', 'Gray Noise', 'Black Noise',
    ],
    'Classical': [
      'Clair de Lune', 'Moonlight Sonata', 'Für Elise',
      'Canon in D', 'Air on G String',
    ],
    'Nature Sound': [
      'Rain', 'Ocean Waves', 'Forest', 'Thunderstorm', 'River Stream',
    ],
    'Binaural Beats': [
      'Delta Waves', 'Theta Waves', 'Alpha Waves', 'Beta Waves', 'Gamma Waves',
    ],
    'ASMR': [
      'Tapping', 'Brushing', 'Crinkling', 'Scratching',
    ],
    'Lullaby': [
      'Twinkle Star', 'Brahms Lullaby', 'Rock-a-bye Baby', 'Hush Little Baby',
    ],
  };

  final Map<String, String> categoryAssetPaths = {
    'Broadband Noise': 'broadband',
    'Classical': 'classical',
    'Nature Sound': 'nature',
    'Binaural Beats': 'binaural',
    'ASMR': 'asmr',
    'Lullaby': 'lullaby',
  };

  final List<String> soundOptions = [
    'Broadband\nNoise',
    'Classical',
    'Nature\nSound',
    'Binaural\nBeats',
    'ASMR',
    'Lullaby',
  ];

  double frequencyValue = 300.0;
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to the player state
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });

    // Automatically loop all sounds
    _audioPlayer.setLoopMode(LoopMode.one);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      // Only play if a sound is loaded
      if (_audioPlayer.processingState != ProcessingState.idle) {
        await _audioPlayer.play();
      }
    }
  }

  void _playSound(String soundName, String category) async {
    setState(() {
      currentlyPlayingSound = soundName;
      currentCategory = category;
    });

    await _audioPlayer.stop();

    String? categoryFolder = categoryAssetPaths[category];
    if (categoryFolder == null) {
      print("Error: No asset path for category '$category'");
      return;
    }

    String fileName = soundName.toLowerCase().replaceAll(' ', '_');
    
    try {
      await _audioPlayer.setAsset('assets/$categoryFolder/$fileName.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("Error loading asset '$fileName.mp3': $e");
    }
  }

  void _playNext() {
    final currentPlaylist = playlists[currentCategory] ?? [];
    if (currentPlaylist.isEmpty || currentlyPlayingSound == null) return;

    int currentIndex = currentPlaylist.indexOf(currentlyPlayingSound!);
    int nextIndex = (currentIndex + 1) % currentPlaylist.length; // Wrap around
    
    _playSound(currentPlaylist[nextIndex], currentCategory);
  }

  void _playPrevious() {
    final currentPlaylist = playlists[currentCategory] ?? [];
    if (currentPlaylist.isEmpty || currentlyPlayingSound == null) return;

    int currentIndex = currentPlaylist.indexOf(currentlyPlayingSound!);
    int prevIndex = (currentIndex - 1 + currentPlaylist.length) % currentPlaylist.length; // Wrap around
    
    _playSound(currentPlaylist[prevIndex], currentCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e), 
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: showSoundPlayer
              ? _buildSoundPlayer()
              : _buildMusicOptionsView(),
        ),
      ),
    );
  }

  // This widget now just passes state DOWN
  Widget _buildSoundPlayer() { 
    return SoundPlayerPage(
      key: ValueKey(currentCategory), 
      
      // Pass all the state and controls to the child page
      category: currentCategory,
      isPlaying: isPlaying,
      currentlyPlayingSound: currentlyPlayingSound ?? '',
      
      onBack: () {
        // This just hides the player, it DOES NOT stop the music
        setState(() => showSoundPlayer = false);
      },
      onTogglePlayPause: _togglePlayPause,
      onPlaySound: (soundName) {
        // The child page calls this function to play a new sound
        _playSound(soundName, currentCategory);
      },
      onPlayNext: _playNext,
      onPlayPrevious: _playPrevious,
    );
  }

  // This widget now reflects the *actual* player state
  Widget _buildMusicOptionsView() {
    return Column(
      children: [
        // Using a custom header name, update if needed
        const SharedHeader(title: 'Smart Sleep', subtitle: 'Embedded Sound Therapy'),
        const Divider(color: Colors.white24, height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      // It uses the REAL state variables
                      Text(
                        currentlyPlayingSound != null 
                          ? '$currentlyPlayingSound - $currentCategory'
                          : 'Nothing Playing',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                              onPressed: _playPrevious,
                              icon: const Icon(Icons.skip_previous, size: 32),
                              color: Colors.white),
                          const SizedBox(width: 16),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              // It calls the REAL toggle function
                              onPressed: _togglePlayPause,
                              icon: Icon(
                                // It uses the REAL isPlaying state
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                size: 32,
                              ),
                              color: const Color(0xFF4a148c),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                              onPressed: _playNext,
                              icon: const Icon(Icons.skip_next, size: 32),
                              color: Colors.white),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                const Text('Select Sound', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
                    final categoryString = sound.replaceAll('\n', ' ');
                    
                    // Determine what the full category name is
                    String categoryForThisItem = 'Broadband Noise'; // Default
                    if (categoryString.contains('Classical')) categoryForThisItem = 'Classical';
                    else if (categoryString.contains('Nature')) categoryForThisItem = 'Nature Sound';
                    else if (categoryString.contains('Binaural')) categoryForThisItem = 'Binaural Beats';
                    else if (categoryString.contains('ASMR')) categoryForThisItem = 'ASMR';
                    else if (categoryString.contains('Lullaby')) categoryForThisItem = 'Lullaby';

                    // Check if this category is the one currently playing
                    final isSelected = categoryForThisItem == currentCategory;

                    return InkWell(
                      onTap: () {
                        // When tapped, update the state
                        setState(() {
                          currentCategory = categoryForThisItem;
                          // If no sound is playing from this category,
                          // play the first one.
                          if (currentlyPlayingSound == null || !playlists[currentCategory]!.contains(currentlyPlayingSound)) {
                            final firstSound = playlists[currentCategory]![0];
                            _playSound(firstSound, currentCategory);
                          }
                          
                          // Show the player page
                          showSoundPlayer = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a3e),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected && isPlaying
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
                // ... (Frequency Slider remains unchanged) ...
                const SizedBox(height: 32),
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