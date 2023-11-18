import 'dart:io';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dailogs.dart';

class ProfileProvider extends ChangeNotifier {
  String? _image;

  String? get image => _image;

  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For Accessing cloud Firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For Accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // For storing self info.
  // static late ChatUser me; // Initializing the 'me' field

  static User get user => auth.currentUser!;

  Future<void> pickImageFromGallery(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      Navigator.pop(context);
      notifyListeners();
      _image = pickedImage.path;
      notifyListeners();
      updateProfilePic(File(_image!));
    }
  }

  Future<void> pickImageFromCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      Navigator.pop(context);
      
      _image = image.path;
      notifyListeners();
      updateProfilePic(File(_image!));
    }
    notifyListeners();
  }

  Future<void> updateProfilePic(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    // storage file ref with path
    final ref = storage.ref().child('profilepic/${user.uid}.$ext');

    // uploading image to storage
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transfered : ${p0.bytesTransferred / 1000} kb');
    });
    // updating image in firestore database
    APIs.me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': APIs.me.image,
    });
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    Dialogs.showProgressbar(context);
    await APIs.updateActiveStatus(false);
    await APIs.auth.signOut().then((value) async {
      await GoogleSignIn().signOut().then((value) {
        Navigator.pop(context);
        Navigator.pop(context);
        APIs.auth = FirebaseAuth.instance;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      });
    });
    notifyListeners();
  }

  static Future<void> updateUserInfo(context) async {
    await firestore.collection('users').doc(user.uid).update({
      'name': APIs.me.name,
      'about': APIs.me.about,
    });
    Dialogs.showSnackbar(context, "Profile Updated Successfully");
  }
}
