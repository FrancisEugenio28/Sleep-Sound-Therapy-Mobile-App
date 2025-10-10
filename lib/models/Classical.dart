import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/shared_header.dart';

class ClassicalPage extends StatefulWidget {
  final String soundName;
  final String category;
  final VoidCallback onBack;

  const ClassicalPage({
    super.key,
    required this.soundName,
    required this.category,
    required this.onBack,
  });

  @override
  State<ClassicalPage> createState() => _ClassicalPageState();
}

class _ClassicalPageState extends State<ClassicalPage> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  String? currentlyPlayingSound;
  String selectedCategory = 'Classical';

  // Sample playlist for each noise type
  final Map<String, List<String>> playlists = {
    'Broadband Noise': [
      'White Noise',
      'Pink Noise', 
      'Brown Noise',
      'Blue Noise',
      'Violet Noise',
      'Gray Noise',
      'Black Noise',
    ],
    'Classical': [
      'Clair de Lune',
      'Moonlight Sonata',
      'Für Elise',
      'Canon in D',
      'Air on G String',
    ],
    'Nature Sound': [
      'Rain',
      'Ocean Waves',
      'Forest',
      'Thunderstorm',
      'River Stream',
    ],
    'Binaural Beats': [
      'Delta Waves',
      'Theta Waves',
      'Alpha Waves',
      'Beta Waves',
      'Gamma Waves',
    ],
    'ASMR': [
      'Whispers',
      'Tapping',
      'Brushing',
      'Crinkling',
      'Scratching',
    ],
    'Lullaby': [
      'Twinkle Star',
      'Brahms Lullaby',
      'Rock-a-bye Baby',
      'Hush Little Baby',
    ],
  };

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    currentlyPlayingSound = widget.soundName;
    
    // Add back button functionality
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      );
    });
    
    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });
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
      await _audioPlayer.play();
    }
  }

  void _playSound(String soundName) async {
    setState(() {
      currentlyPlayingSound = soundName;
    });
    
    String fileName = soundName.toLowerCase().replaceAll(' ', '_');
    await _audioPlayer.setAsset('assets/classical/$fileName.mp3');
    await _audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    final currentPlaylist = playlists[widget.category] ?? ['Unknown'];
    
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            // Header only
            const SharedHeader(
              title: 'Smart Sleep',
              subtitle: 'Embedded Sound Therapy',
            ),

            const Divider(color: Colors.white24, height: 1),

            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
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
                            Text(
                              '${widget.soundName} - ${widget.category}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 22),
                            // Player Controls
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
                                    onPressed: _togglePlayPause,
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

                      // Playlist Title
                      Text(
                        widget.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Playlist Items
                      ...currentPlaylist.map((item) {
                        final isCurrentlyPlaying = currentlyPlayingSound == item;
                        
                        return GestureDetector(
                          onTap: () => _playSound(item),  // 👈 ITO ANG MAGPAPA-PLAY!
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentlyPlaying 
                                  ? const Color(0xFF4a148c)  // Purple pag tumutugtog
                                  : const Color(0xFF2a2a3e),  // Dark gray pag hindi
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCurrentlyPlaying ? Icons.volume_up : Icons.play_circle_outline,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: isCurrentlyPlaying ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
