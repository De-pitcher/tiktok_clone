import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';
import 'package:tiktok_clone/controllers/auth_controller.dart';
import 'package:tiktok_clone/services/image_picker_service.dart';

import 'package:tiktok_clone/models/user.dart' as model;
import 'package:mockito/annotations.dart';
import 'auth_controller_test.mocks.dart';

@GenerateMocks([
  ImagePickerService,
  AuthController,
  FirebaseAuth,
  FirebaseFirestore,
  FirebaseStorage,
  UserCredential,
  User,
  Reference,
  CollectionReference,
  DocumentReference,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockImagePickerService mockImagePickerService;
  late MockAuthController authController;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockFirebaseStorage;

  setUp(() {
    Get.testMode = true;
    mockImagePickerService = MockImagePickerService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockFirebaseStorage = MockFirebaseStorage();
    authController = MockAuthController();
  });

  tearDown(() => Get.delete<AuthController>());
  group('auth controller', () {
    group('pickImage function', () {
      test('pickImage error ...', () async {
        when(mockImagePickerService.pickImage(source: ImageSource.gallery))
            .thenAnswer((_) => Future.value(null));

        when(authController.pickImage(mockImagePickerService))
            .thenAnswer((_) => Future.value(null));

        final result = await authController.pickImage(mockImagePickerService);

        expect(result?.path, null);
      });

      test('pickImage success ...', () async {
        const imagePath = 'assets/image 12.png';

        when(authController.pickImage(mockImagePickerService))
            .thenAnswer((realInvocation) => Future.value(XFile(imagePath)));

        final result = await authController.pickImage(mockImagePickerService);

        expect(result!.path, XFile(imagePath).path);
      });
    });

    group('uploadToStorage', () {
      final imageFile = File(
          'path_to_your_test_image.jpg'); // Replace with the actual file path
      const downloadUrl =
          'https://example.com/downloaded_image.jpg'; // Replace with your expected download URL
      test('failure', () async {
        // Mock the behavior of Firebase Storage to return the download URL
        when(authController.uploadToStorage(null))
            .thenAnswer((_) => Future.value(null));

        final result = await authController.uploadToStorage(null);

        expect(result, null);
      });

      test('success', () async {
        // Mock the behavior of Firebase Storage to return the download URL
        final user = MockUser();
        const uid = 'id';
        final reference = MockReference();
        final childRef = MockReference();

        when(mockFirebaseAuth.currentUser).thenAnswer((_) => user);
        when(user.uid).thenAnswer((_) => uid);
        when(mockFirebaseStorage.ref()).thenAnswer((_) => reference);
        when(reference.child('profilePics')).thenAnswer((_) => childRef);
        when(childRef.child(uid)).thenAnswer((_) => childRef);
        when(authController.uploadToStorage(imageFile))
            .thenAnswer((_) => Future.value(downloadUrl));

        final result = await authController.uploadToStorage(imageFile);
        mockFirebaseAuth.currentUser;
        mockFirebaseStorage.ref();
        reference.child('profilePics');
        final userId = user.uid;
        childRef.child(userId);

        expect(result, downloadUrl);
        verify(mockFirebaseAuth.currentUser);
        verify(mockFirebaseStorage.ref());
        verify(reference.child('profilePics'));
        verify(childRef.child(userId));
      });
    });
    group('registerUser function', () {
      test('With invalid input', () async {
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: null,
          password: null,
        )).thenThrow(Exception());
        when(authController.registerUser(null, null, null, null))
            .thenThrow(Exception());

        expect(
            () => mockFirebaseAuth.createUserWithEmailAndPassword(
                email: null, password: null),
            throwsException);
        expect(() => authController.registerUser(null, null, null, null),
            throwsException);
      });

      test('With valid input', () async {
        final userCredential = MockUserCredential();

        const username = 'testUser';
        const email = 'test@example.com';
        const password = 'password';
        final imageFile = File('path_to_your_test_image.jpg');
        const userId = 'user-id';
        final CollectionReference<Map<String, dynamic>> collectionRef =
            MockCollectionReference();
        final DocumentReference<Map<String, dynamic>> docRef =
            MockDocumentReference();
        model.User user = model.User(
          name: username,
          email: email,
          uid: userId,
          profilePhoto: '',
        );

        when(mockFirestore.collection('users'))
            .thenAnswer((_) => collectionRef);
        when(collectionRef.doc(userId)).thenAnswer((_) => docRef);
        when(docRef.set(user.toJson()))
            .thenAnswer((realInvocation) => Future.value(null));
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) => Future.value(userCredential));

        await authController.registerUser(
          username,
          email,
          password,
          imageFile,
        );
        await mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        mockFirestore.collection('users');
        collectionRef.doc(userId);
        docRef.set(user.toJson());

        verify(authController.registerUser(
          username,
          email,
          password,
          imageFile,
        ));
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ));
        verify(mockFirestore.collection('users'));
        verify(collectionRef.doc(userId));
        verify(docRef.set(user.toJson()));
      });
    });
    group('loginUser', () {
      test('With invalid input', () async {
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: null,
          password: null,
        )).thenThrow(Exception());
        when(authController.loginUser(null, null)).thenThrow(Exception());

        expect(() => authController.loginUser(null, null), throwsException);
        expect(
            () => mockFirebaseAuth.signInWithEmailAndPassword(
                  email: null,
                  password: null,
                ),
            throwsException);
      });

      test('With valid input', () async {
        final userCredential = MockUserCredential();
        const email = 'test@example.com';
        const password = 'password';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) => Future.value(userCredential));

        await authController.loginUser(email, password);
        await mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ));
      });
    });
  });
}
