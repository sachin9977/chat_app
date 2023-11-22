// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQUfY7_VJw-yqA1yxgpAwW3KPO__j_PRs',
    appId: '1:244756894533:android:8fe4204a02f786f83ea42c',
    messagingSenderId: '244756894533',
    projectId: 'baat-chit-85abb',
    storageBucket: 'baat-chit-85abb.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBI5UcLqYleFSOUH_Nb7CohmCDJCHjbc8M',
    appId: '1:244756894533:ios:fba7eb0b2df773053ea42c',
    messagingSenderId: '244756894533',
    projectId: 'baat-chit-85abb',
    storageBucket: 'baat-chit-85abb.appspot.com',
    androidClientId: '244756894533-fvis4f147mg2dsqkrqbe95ondr4jeaen.apps.googleusercontent.com',
    iosClientId: '244756894533-j1l7b4c02gafnvnjhu4deuiis3k49kh1.apps.googleusercontent.com',
    iosBundleId: 'com.chat.baatchit',
  );
}
