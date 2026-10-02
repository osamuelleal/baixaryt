import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import 'pages/home_page.dart';
import 'services/yt_dlp.dart';

void main() {
  YtDlp.updated; // kick off the yt-dlp self-update in the background
  runApp(const BaixarYtApp());
}

class BaixarYtApp extends StatelessWidget {
  const BaixarYtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BaixarYT',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      theme: FTheme.neutral.light.desktop.toApproximateMaterialTheme(),
      darkTheme: FTheme.neutral.dark.desktop.toApproximateMaterialTheme(),
      // Follows the Windows light/dark setting.
      builder: (context, child) => FTheme(
        data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? FTheme.neutral.dark.desktop
            : FTheme.neutral.light.desktop,
        child: FToaster(child: child!),
      ),
      home: const HomePage(),
    );
  }
}
