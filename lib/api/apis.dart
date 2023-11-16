import 'dart:convert';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIs {
  // For Authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // For Accessing cloud Firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // For Accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // For storing self info.
  static late ChatUser me;

  static User get user => auth.currentUser!;

  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

// for getting firebase Message Token

  static Future<void> getFirebaseMsgToken() async {
    await fMessaging.requestPermission();

    fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        print(t);
        print('rttttttttttttttttttttttt');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

// For Sending Push Notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": user.displayName,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${me.id} ",
        },
      };
      // var url = Uri.https('example.com', 'whatsit/create');
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAOPyl00U:APA91bEpbQDtOHpFxPQ_p_AaLQT8mDaxOk1sXDrAqfgLBcnLXm_UpI6H5wU_fgmnuRenf1zBw2NGAtr_cPLkKzABBurI1-6XHSM6So3RC7ocYbj7TuEsvUh_OlQgWRQ3ktkvNrsEHbV1'
          },
          body: jsonEncode(body));
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print(e);
      print("SendNotification");
    }
  }

  //  For checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //  For adding a chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      return false;
    }
  }

  //  For getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        getFirebaseMsgToken();
        await APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // For Creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey I'm Using BaatChit",
        name: user.displayName.toString(),
        createdAt: time,
        isOnline: false,
        id: user.uid,
        lastActive: time,
        email: user.email.toString(),
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // // For getting all users from firestore database
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
  //     List<String> userIds) {
  //   return APIs.firestore
  //       .collection('users')
  //       .where('id', whereIn: userIds)
  //       .snapshots();
  // }

  // // For getting id's of known user from firestore database
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
  //   return APIs.firestore
  //       .collection('users')
  //       .doc(user.uid)
  //       .collection('my_users')
  //       .snapshots();
  // }

  // For getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    if (userIds.isNotEmpty) {
      // Add a check here
      return APIs.firestore
          .collection('users')
          .where('id', whereIn: userIds)
          .snapshots();
    } else {
      // Return an empty stream or handle the case where userIds is empty
      return Stream.empty();
    }
  }

// For getting id's of known user from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUserId() {
    return APIs.firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

// for adding an user to my user when first msg is send.
  static Future<void> sendFirstMsg(
      ChatUser chatuser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatuser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) {
      sendMessage(chatuser, msg, type);
    });
  }

  //  For Updating user info
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

// Update profile pic of user
  static Future<void> updateProfilePic(File file) async {
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
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

// for getting specific user info.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return APIs.firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // Update Online or last active status of user

  static Future<void> updateActiveStatus(bool isonline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isonline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  // *****************Chat Screen related API ********************

  // chats (Collection) ---> conversation_id (doc) ---> message (collection) ---> message (doc)

  // Used for getting conversation_Id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/message/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatuser, String msg, Type type) async {
    //  Message sending time also used as message ID
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message = Message(
        toId: chatuser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatuser.id)}/message/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatuser, type == Type.text ? msg : 'image'));
  }

// Update read status of msg.
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/message/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

// get only last message of a specific chat
  static Stream<QuerySnapshot> getLastMessage(ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/message/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

// Sending chat Images

  static Future<void> sendChatImage(
    ChatUser chatUser,
    File file,
  ) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    // storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    // uploading image to storage
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transfered : ${p0.bytesTransferred / 1000} kb');
    });
    // updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

// for deleting msg

  static Future<void> deleteMsg(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/message/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  // Update msg
  static Future<void> UpdateMsg(Message message, updatedMsg, context) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/message/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
    // Navigator.pop(context);
  }
}
