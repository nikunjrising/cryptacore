import 'package:cryptacore/controller/UserController.dart';
import 'package:cryptacore/ui/dashboard/dashboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../demo/MiningScreen.dart';
import '../ui/auth/login.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final UserController userController = Get.put(UserController());

  var isGoogleLoading = false.obs;
  var isGuestLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeGoogleSignIn();
  }

  // ---------------------------
  // Initialize Google Sign In
  // ---------------------------
  Future<void> _initializeGoogleSignIn() async {
    try {
      await _googleSignIn.initialize();
    } catch (e) {
      print("Google Sign-In initialization error: $e");
    }
  }

  // ---------------------------
  // SIGN IN WITH GOOGLE
  // ---------------------------
  Future<void> signInWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      errorMessage.value = '';

      if (!_googleSignIn.supportsAuthenticate()) {
        errorMessage.value = 'Google Sign-In not supported on this platform';
        isGoogleLoading.value = false;
        return;
      }


      // await _googleSignIn.authenticate(); // Opens Google popup
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // Process the signed-in user
      await _handleUserSignedIn(googleUser);

    } catch (error) {
      isGoogleLoading.value = false;

      if (error is GoogleSignInException &&
          error.code != GoogleSignInExceptionCode.canceled) {
        errorMessage.value = 'Google Sign-In error: ${error.description}';
      } else {
        print('Unknown error $error');
        errorMessage.value = 'Unknown error: $error';
      }
    }
  }

  // ---------------------------
  // GOOGLE AUTH EVENT HANDLER
  // ---------------------------
  Future<void> _handleUserSignedIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.idToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCred =
      await _auth.signInWithCredential(credential);

      final firebaseUser = userCred.user!;
      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      // CREATE USER IN FIRESTORE
      await userController.createUser(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? "",
        email: firebaseUser.email ?? "",
        imageUrl: firebaseUser.photoURL ?? "",
        fcmToken: fcmToken ?? "",
        isGuest: false,
      );

      isGoogleLoading.value = false;
      // Get.offAll(() => MiningScreen());
      Get.offAll(() => Dashboard());

    } catch (error) {
      isGoogleLoading.value = false;
      errorMessage.value = 'Failed to sign in with Google: $error';
      print("Firebase sign-in error: $error");
    }
  }

  // ---------------------------
  // SIGN IN AS GUEST
  // ---------------------------
  Future<void> signInAsGuest() async {
    try {
      isGuestLoading.value = true;
      errorMessage.value = '';

      final UserCredential userCred = await _auth.signInAnonymously();
      final firebaseUser = userCred.user!;
      final String? fcmToken = await FirebaseMessaging.instance.getToken();

      // CREATE GUEST USER IN FIRESTORE
      await userController.createUser(
        uid: firebaseUser.uid,
        name: "Guest User",
        email: "",
        imageUrl: "",
        fcmToken: fcmToken ?? "",
        isGuest: true,
      );

      isGuestLoading.value = false;
      // Get.offAll(() => MiningScreen());
      Get.offAll(() => Dashboard());

    } catch (error) {
      isGuestLoading.value = false;
      errorMessage.value = 'Failed to sign in as guest: $error';
      print("Guest Sign-In Error: $error");
    }
  }

  // ---------------------------
  // SIGN OUT
  // ---------------------------
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await _auth.signOut();
    } catch (error) {
      print("Sign out error: $error");
    }
  }

  Future<void> deleteCurrentUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await _googleSignIn.disconnect();
      await _auth.signOut();
      if (user != null) {
        await user.delete();
        print("User account deleted.");

        Get.offAll(() => LoginScreen());
      }
    } catch (e) {
      print("Delete user error: $e");
    }
  }


  // ---------------------------
  // GETTERS
  // ---------------------------
  bool get isSignedIn => _auth.currentUser != null;

  User? get currentUser => _auth.currentUser;
  String? get email => _auth.currentUser?.email;

  bool get isGuestUser => _auth.currentUser?.isAnonymous ?? false;
}


