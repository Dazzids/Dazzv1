import 'package:dazz/src/states/profile_image_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

//Bloc
import 'package:dazz/src/states/auth_state.dart';
import 'package:dazz/src/blocs/auth/auth_bloc.dart';
import 'package:dazz/src/blocs/login/login_bloc.dart';
import 'package:dazz/src/blocs/login/login_logic.dart';
import 'package:dazz/src/blocs/signup/signup_bloc.dart';
import 'package:dazz/src/blocs/signup/signup_logic.dart';

//Pages
import 'package:dazz/src/pages/pre_home_page.dart';
import 'package:dazz/src/pages/local_auth_page.dart';
import 'package:dazz/src/pages/splash_screen_page.dart';
import 'package:dazz/src/pages/error_page.dart';
import 'package:dazz/src/pages/login_page.dart';
import 'package:dazz/src/pages/signup_page.dart';
import 'package:dazz/src/pages/welcome_page.dart';

//Utils
import 'package:dazz/constants.dart';
import 'package:dazz/src/theme/theme.dart';
import 'package:dazz/src/utils/dazz_localizations.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    if (inDebug) return ErrorPage();
    // In release builds, show a yellow-on-blue message instead:
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Error! ${details.exception}',
        style: TextStyle(color: Colors.red),
        textDirection: TextDirection.ltr,
      ),
    );
  };
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeChanger()),
      BlocProvider(create: (_) => AuthBloc()),
      BlocProvider(create: (_) => LoginBloc(logic: SimpleLoginLogic())),
      BlocProvider(create: (_) => SignupBloc(awsLogic: SignUpFirebaseLogic())),
      ChangeNotifierProvider(
        create: (BuildContext context) => AuthUserState(),
      ),
      ChangeNotifierProvider(create: (_) => ProfileImage())
    ],
    child: DazzApp(),
  ));
}

class DazzApp extends StatefulWidget {
  @override
  _DazzAppState createState() => _DazzAppState();
}

class _DazzAppState extends State<DazzApp> {
   AuthUserState authUserState;
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Provider.of<ThemeChanger>(context);

    return MaterialApp(
      builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget),
          maxWidth: 1200,
          minWidth: 450,
          defaultScale: true,
          breakpoints: [
            ResponsiveBreakpoint.resize(450, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.autoScale(1000, name: TABLET),
            ResponsiveBreakpoint.resize(1200, name: DESKTOP),
            ResponsiveBreakpoint.autoScale(2460, name: "4K"),
          ],
          background: Container(color: dScaffoldColor)),
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error en ${snapshot.error.toString()}');
            return Center(child: Text('Error al cargar firebase'));
          } else if (snapshot.hasData) {
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  switchOutCurve: Threshold(0),
                  duration: Duration(milliseconds: 250),
                  child: _buildPage(context, state),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    final curvedAnimation = CurvedAnimation(
                        parent: animation, curve: Curves.easeInOut);
                    return SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(1.0, 0.0), end: Offset.zero)
                          .animate(curvedAnimation),
                      child: child,
                    );
                  },
                );
              },
            );
          } else {
            return SplashScreen();
          }
        },
      ),
      theme: appTheme.currentTheme,
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('en'), Locale('es')],
      localizationsDelegates: [
        DazzLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
    );
  }

  Widget _buildPage(BuildContext context, AuthState state) {
    if (state is AuthInitial) {
      return SplashScreen();
    }

    if (state is AuthWelcomeState) {
      return WelcomePage();
    }

    if (state is AuthLoginState) {
      return LoginPage();
    }

    if (state is AuthSignUpState) {
      return SignUpPage();
    }

    // if (state is AuthSessionState) {
    //   return HomePage();
    // }

    // if (state is AuthVerificationState) {
    //   return VerificationPAge();
    // }

    if (state is AuthSessionState || state is AuthVerificationState) {
      return PreHomePage();
    }

    if (state is AuthReLoginState) {
      return LocalAuthPage();
    }

    return ErrorPage();
  }
}
