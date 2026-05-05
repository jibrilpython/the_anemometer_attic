import 'package:flutter/services.dart';
import 'package:the_anemometer_attic/initial_screen.dart';
import 'package:the_anemometer_attic/providers/user_provider.dart';
import 'package:the_anemometer_attic/screens/add_screen.dart';
import 'package:the_anemometer_attic/screens/info_screen.dart';
import 'package:the_anemometer_attic/screens/showcase_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:the_anemometer_attic/utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_anemometer_attic/screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(ProviderScope(child: MyApp(preferences: preferences)));
}

class MyApp extends ConsumerWidget {
  final SharedPreferences preferences;
  const MyApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProv = ref.watch(userProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'The Anemometer Attic',
            theme: appTheme,
            home: userProv.firstTimeUser
                ? const InitialScreen()
                : const MainNavigation(),
            routes: {
              '/home': (context) => const MainNavigation(),
              '/initial_screen': (context) => const InitialScreen(),
              '/showcase': (context) => const ShowcaseScreen(),
              '/add_screen': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>? ??
                    {};
                return AddScreen(
                  isEdit: args['isEdit'] as bool? ?? false,
                  currentIndex: args['currentIndex'] as int? ?? 0,
                );
              },
              '/info_screen': (context) {
                final args =
                    ModalRoute.of(context)?.settings.arguments
                        as Map<String, dynamic>? ??
                    {};
                return InfoScreen(index: args['index'] as int? ?? 0);
              },
            },
          ),
        );
      },
    );
  }
}
