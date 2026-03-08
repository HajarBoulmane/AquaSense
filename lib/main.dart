import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'screens/main_shell.dart';
import 'utils/lang.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AquaSenseApp());
}

class AquaSenseApp extends StatelessWidget {
  const AquaSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LangProvider(
      child: AnimatedBuilder(
        animation: langNotifier,
        builder: (context, _) => MaterialApp(
          title: 'AquaSense',
          debugShowCheckedModeBanner: false,
          // RTL support for Arabic
          builder: (context, child) => Directionality(
            textDirection: langNotifier.dir,
            child: child!,
          ),
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF060D1A),
            colorScheme: const ColorScheme.dark(
              primary:   Color(0xFF00B4FF),
              secondary: Color(0xFF00FFC8),
              error:     Color(0xFFFF3B5C),
              surface:   Color(0xFF0B1629),
            ),
            textTheme: GoogleFonts.dmSansTextTheme(
              ThemeData.dark().textTheme,
            ),
            useMaterial3: true,
          ),
          home: const MainShell(),
        ),
      ),
    );
  }
}