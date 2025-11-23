import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'; // Add this
import 'package:just_audio/just_audio.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../widgets/shared_header.dart';
import '../models/sound_player.dart';
import '../bluetooth_controller.dart'; // Add this import

class MusicPageContent extends StatefulWidget {
  const MusicPageContent({super.key});

  @override
  State<MusicPageContent> createState() => _MusicPageContentState();
}

class _MusicPageContentState extends State<MusicPageContent> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  String? currentlyPlayingSound;
  String currentCategory = 'Broadband Noise'; 
  bool showSoundPlayer = false;

  // 1. Initialize Bluetooth Controller
  final BluetoothController _btController = BluetoothController();

  // Frequency/Volume Value
  double frequencyValue = 50.0; // Default to 50% volume

  final Map<String, List<String>> playlists = {
    'Broadband Noise': ['White Noise', 'Pink Noise', 'Brown Noise', 'Blue Noise', 'Violet Noise', 'Gray Noise', 'Black Noise'],
    'Classical': ['Clair de Lune', 'Moonlight Sonata', 'Für Elise', 'Canon in D', 'Air on G String'],
    'Nature Sound': ['Rain', 'Ocean Waves', 'Forest', 'Thunderstorm', 'River Stream'],
    'Binaural Beats': ['Delta Waves', 'Theta Waves', 'Alpha Waves', 'Beta Waves', 'Gamma Waves'],
    'ASMR': ['Tapping', 'Brushing', 'Crinkling', 'Scratching'],
    'Lullaby': ['Twinkle Star', 'Brahms Lullaby', 'Rock-a-bye Baby', 'Hush Little Baby'],
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
    'Broadband\nNoise', 'Classical', 'Nature\nSound',
    'Binaural\nBeats', 'ASMR', 'Lullaby',
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state.playing;
        });
      }
    });
    _audioPlayer.setLoopMode(LoopMode.one);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // 2. Connection Dialog Logic
  void _showConnectionDialog() async {
    await _btController.initPermissions();
    // Get list of paired devices
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF232b47),
        title: const Text("Connect to Device", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: devices.isEmpty 
            ? const Center(child: Text("No paired devices found.\nPlease pair in Android Settings first.", style: TextStyle(color: Colors.white70)))
            : ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(devices[index].name ?? "Unknown", style: const TextStyle(color: Colors.white)),
                    subtitle: Text(devices[index].address, style: const TextStyle(color: Colors.white70)),
                    trailing: const Icon(Icons.link, color: Colors.white54),
                    onTap: () async {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Connecting...")),
                      );
                      
                      bool success = await _btController.connect(devices[index]);
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? "Connected to ${devices[index].name}!" : "Connection Failed"),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
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
    if (categoryFolder == null) return;

    String fileName = soundName.toLowerCase().replaceAll(' ', '_');
    try {
      await _audioPlayer.setAsset('assets/$categoryFolder/$fileName.mp3');
      await _audioPlayer.play();
    } catch (e) {
      print("Error loading asset: $e");
    }
  }

  void _playNext() {
    final currentPlaylist = playlists[currentCategory] ?? [];
    if (currentPlaylist.isEmpty || currentlyPlayingSound == null) return;
    int currentIndex = currentPlaylist.indexOf(currentlyPlayingSound!);
    int nextIndex = (currentIndex + 1) % currentPlaylist.length;
    _playSound(currentPlaylist[nextIndex], currentCategory);
  }

  void _playPrevious() {
    final currentPlaylist = playlists[currentCategory] ?? [];
    if (currentPlaylist.isEmpty || currentlyPlayingSound == null) return;
    int currentIndex = currentPlaylist.indexOf(currentlyPlayingSound!);
    int prevIndex = (currentIndex - 1 + currentPlaylist.length) % currentPlaylist.length;
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

  Widget _buildSoundPlayer() { 
    return SoundPlayerPage(
      key: ValueKey(currentCategory), 
      category: currentCategory,
      isPlaying: isPlaying,
      currentlyPlayingSound: currentlyPlayingSound ?? '',
      onBack: () => setState(() => showSoundPlayer = false),
      onTogglePlayPause: _togglePlayPause,
      onPlaySound: (soundName) => _playSound(soundName, currentCategory),
      onPlayNext: _playNext,
      onPlayPrevious: _playPrevious,
    );
  }

  Widget _buildMusicOptionsView() {
    return Column(
      children: [
        // HEADER WITH BLUETOOTH BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              const Expanded(
                child: SharedHeader(title: 'Smart Sleep', subtitle: 'Embedded Sound Therapy'),
              ),
              IconButton(
                icon: const Icon(Icons.bluetooth, color: Colors.white),
                tooltip: "Connect to Device",
                onPressed: _showConnectionDialog, // Opens the list
              ),
              const SizedBox(width: 10),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4a148c), Color(0xFF6a1b9a)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Now Playing', style: TextStyle(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(
                        currentlyPlayingSound != null 
                          ? '$currentlyPlayingSound - $currentCategory'
                          : 'Nothing Playing',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: _playPrevious, icon: const Icon(Icons.skip_previous, size: 32), color: Colors.white),
                          const SizedBox(width: 16),
                          Container(
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: _togglePlayPause,
                              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
                              color: const Color(0xFF4a148c),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(onPressed: _playNext, icon: const Icon(Icons.skip_next, size: 32), color: Colors.white),
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
                    
                    String categoryForThisItem = 'Broadband Noise'; 
                    if (categoryString.contains('Classical')) categoryForThisItem = 'Classical';
                    else if (categoryString.contains('Nature')) categoryForThisItem = 'Nature Sound';
                    else if (categoryString.contains('Binaural')) categoryForThisItem = 'Binaural Beats';
                    else if (categoryString.contains('ASMR')) categoryForThisItem = 'ASMR';
                    else if (categoryString.contains('Lullaby')) categoryForThisItem = 'Lullaby';

                    final isSelected = categoryForThisItem == currentCategory;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          currentCategory = categoryForThisItem;
                          if (currentlyPlayingSound == null || !playlists[currentCategory]!.contains(currentlyPlayingSound)) {
                            final firstSound = playlists[currentCategory]![0];
                            _playSound(firstSound, currentCategory);
                          }
                          showSoundPlayer = true;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2a3e),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected && isPlaying ? const Color(0xFF6a1b9a) : Colors.transparent,
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
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),
                
                // VOLUME CONTROL (Mapped to ESP32)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Device Volume', // Changed label
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${frequencyValue.toInt()}%', 
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6a1b9a), fontWeight: FontWeight.w600)),
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
                        min: 0.0,
                        max: 100.0, // Correct range for ESP32 Volume
                        value: frequencyValue,
                        interval: 20,
                        showTicks: true,
                        showLabels: false,
                        enableTooltip: true,
                        activeColor: const Color(0xFF6a1b9a),
                        inactiveColor: Colors.white24,
                        onChanged: (dynamic value) {
                          setState(() {
                            frequencyValue = value;
                          });
                          // SEND TO ESP32
                          _btController.sendCommand("VOL:${value.toInt()}");
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