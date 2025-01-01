import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zimi/screens/library_screen.dart';
import 'package:zimi/services/share_service.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/song_bloc.dart';
import 'services/lyrics_service.dart';
import 'services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';
import 'services/song_matching_service.dart';
import 'package:provider/provider.dart';
import 'adapters/song_adapter.dart';
import 'adapters/playlist_adapter.dart';
import '../screens/lyrics_screen.dart';
import 'services/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

   await ACRCloud.setUp(
      ACRCloudConfig(
        "5b79a16696a611d361f263bdfd6968d4",
        "6gY72eAQDuvwH1ahnypDUq3sSdj5f7xZlfWmad76",
        "identify-eu-west-1.acrcloud.com"
      )
    );

  // Initialize Hive and register adapters
  await Hive.initFlutter();

  // Register adapters BEFORE initializing DatabaseService
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SongAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PlaylistAdapter());
  }

  // Now initialize database service
  final databaseService = DatabaseService();
  await databaseService.initialize();

  // Initialize other services
  final lyricsService = LyricsService();
  final storageService = StorageService(await SharedPreferences.getInstance());
  final shareService = ShareService();
  final songMatchingService = SongMatchingService(lyricsService, storageService);

  final songBloc = SongBloc(
    lyricsService,
    songMatchingService,
    storageService,
    databaseService,
    shareService,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        Provider<DatabaseService>.value(value: databaseService),
        BlocProvider(create: (context) => songBloc),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'Zimi',
          theme: themeService.theme,
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool isListening = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with animated title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Colors.purple.shade300,
                          Colors.pinkAccent,
                        ],
                      ).createShader(bounds),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText(
                            'Lyrics Sync',
                            textStyle: const TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            speed: const Duration(milliseconds: 200),
                          ),
                        ],
                        repeatForever: true,
                        isRepeatingAnimation: true,
                      ),
                    ),
                    const Spacer(),
                    // Optional: Add a glowing effect
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.pinkAccent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children:  [
                    HomeScreen(),
                    SearchScreen(),
                    LibraryScreen(),
                    // SettingsScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: Colors.black.withOpacity(0.8),
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.5),
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.5),
              ),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.library_music,
                color: _currentIndex == 2 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.5),
              ),
              label: 'Library',
            ),
            // NavigationDestination(
            //   icon: Icon(
            //     Icons.settings,
            //     color: _currentIndex == 2 
            //         ? Colors.white 
            //         : Colors.white.withOpacity(0.5),
            //   ),
            //   label: 'Settings',
            // ),
          ],
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ),
    );
  }
}
