// lib/sound_player.dart
import 'package:flutter/material.dart';
import '../widgets/shared_header.dart'; 

class SoundPlayerPage extends StatefulWidget {
  final String category;
  final bool isPlaying;
  final String currentlyPlayingSound;
  final VoidCallback onBack;
  final VoidCallback onTogglePlayPause;
  final Function(String soundName) onPlaySound;
  final VoidCallback onPlayNext;
  final VoidCallback onPlayPrevious;

  const SoundPlayerPage({
    super.key,
    required this.category,
    required this.isPlaying,
    required this.currentlyPlayingSound,
    required this.onBack,
    required this.onTogglePlayPause,
    required this.onPlaySound,
    required this.onPlayNext,
    required this.onPlayPrevious,
  });

  @override
  State<SoundPlayerPage> createState() => _SoundPlayerPageState();
}

class _SoundPlayerPageState extends State<SoundPlayerPage> {
  // --- All player logic is GONE ---
  // No AudioPlayer, no isPlaying, no currentlyPlayingSound
  // No initState, no dispose, no _playSound, no _togglePlayPause

  // This page still needs the list of sounds to display it
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
  

  @override
  Widget build(BuildContext context) {
    // We get the playlist from our local map
    final currentPlaylist = playlists[widget.category] ?? ['Unknown'];
    
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: Column(
          children: [
            const SharedHeader(
              title: 'Smart Sleep',
              subtitle: 'Embedded Sound Therapy',
            ),
            const Divider(color: Colors.white24, height: 1),

            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                // It just calls the onBack function from the parent
                onPressed: widget.onBack,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        // ... (decoration is the same) ...
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
                            const Text(
                              'Now Playing',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // It uses the STATE from the parent
                            Text(
                              '${widget.currentlyPlayingSound} - ${widget.category}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  // It calls the FUNCTION from the parent
                                  onPressed: widget.onPlayPrevious,
                                  icon: const Icon(Icons.skip_previous, size: 32),
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    // It calls the FUNCTION from the parent
                                    onPressed: widget.onTogglePlayPause,
                                    icon: Icon(
                                      // It uses the STATE from the parent
                                      widget.isPlaying ? Icons.pause : Icons.play_arrow,
                                      size: 32,
                                    ),
                                    color: const Color(0xFF4a148c),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  // It calls the FUNCTION from the parent
                                  onPressed: widget.onPlayNext,
                                  icon: const Icon(Icons.skip_next, size: 32),
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        widget.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...currentPlaylist.map((item) {
                        // It highlights based on STATE from the parent
                        final isCurrentlyPlaying = widget.currentlyPlayingSound == item;
                        
                        return GestureDetector(
                          // It calls the FUNCTION from the parent
                          onTap: () => widget.onPlaySound(item),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrentlyPlaying 
                                  ? const Color(0xFF4a148c)
                                  : const Color(0xFF2a2a3e),
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