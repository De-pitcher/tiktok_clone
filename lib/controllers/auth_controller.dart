// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart' as model;
import '../services/image_picker_service.dart';
import '../views/auth/login_screen.dart';
import '../views/home_screen.dart';

class AuthController extends GetxController {
  final FirebaseAuth firebaseAuthInstance;
  final FirebaseFirestore firebaseFirestoreInstance;
  final FirebaseStorage firebaseStorageInstance;
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  late Rx<File?> _pickedImage;
  AuthController({
    required this.firebaseAuthInstance,
    required this.firebaseFirestoreInstance,
    required this.firebaseStorageInstance,
  });

  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuthInstance.currentUser);
    _user.bindStream(firebaseAuthInstance.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => const LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  Future<XFile?> pickImage(ImagePickerService imagePicker) async {
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) _pickedImage = Rx<File?>(File(pickedImage.path));

    return pickedImage;
  }

  Future<String?> uploadToStorage(File image) async {
    String? downloadUrl;
    try {
      Reference ref = firebaseStorageInstance
          .ref()
          .child('profilePics')
          .child(firebaseAuthInstance.currentUser!.uid);

      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snap = await uploadTask;
      downloadUrl = await snap.ref.getDownloadURL();
    } catch (e) {
      // Get.snackbar('Error uploading picture', e.toString());
    }
    if (downloadUrl == null) {
      log('downloarUrl: NULL');
    } else {
      log('downloarUrl: $downloadUrl');
    }
    return downloadUrl;
  }

  // registering the user
  Future<void> registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // save out user to our ath and firebase firestore
        UserCredential cred =
            await firebaseAuthInstance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String? downloadUrl = await uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl ?? '',
        );
        await firebaseFirestoreInstance
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
      } else {
        throw Exception('Please enter all field');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuthInstance.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        throw Exception('Please enter all the fields');
        // Get.snackbar(
        //   'Error Logging in',
        //   'Please enter all the fields',
        // );
      }
    } catch (e) {
      // Get.snackbar(
      //   'Error Loggin gin',
      //   e.toString(),
      // );
    }
  }

  Future<bool> signOut() async =>
      firebaseAuthInstance.signOut().then((value) => true).onError((e, _) {
        Get.snackbar('Error signing out', e.toString());
        return false;
      });
}
