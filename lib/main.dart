import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/progress_repository.dart';
import 'firebase_options.dart';
import 'presentation/cubits/progress/progress_cubit.dart';
import 'presentation/cubits/quiz/quiz_cubit.dart';
import 'presentation/cubits/word/word_cubit.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const DevocaApp());
}

class DevocaApp extends StatelessWidget {
  const DevocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WordCubit()),
        BlocProvider(create: (_) => QuizCubit()),
        BlocProvider(create: (_) => ProgressCubit(ProgressRepository())),
      ],
      child: MaterialApp.router(
        title: 'Devoca',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4355B9),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          cardTheme: const CardThemeData(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          navigationBarTheme: const NavigationBarThemeData(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
