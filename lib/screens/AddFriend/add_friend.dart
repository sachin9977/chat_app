// ignore_for_file: unnecessary_import

import 'package:chat_app/api/apis.dart';
import 'package:chat_app/screens/ViewProfileScreen2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({Key? key}) : super(key: key);

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  late CollectionReference<Map<String, dynamic>> usersCollection;
  List<String> sentRequests = [];
  late Future<List<Map<String, dynamic>>> friendRequests;

  @override
  void initState() {
    super.initState();
    usersCollection = FirebaseFirestore.instance.collection('users');
    fetchSentRequests();

    // Replace 'currentUserId' with the actual ID of the logged-in user.
    friendRequests = getFriendRequests(APIs.me.id);
  }

  void fetchSentRequests() async {
    DocumentSnapshot<Map<String, dynamic>> userDoc =
        await usersCollection.doc(APIs.me.id).get();

    if (userDoc.exists) {
      setState(() {
        sentRequests = List<String>.from(userDoc.get('sentRequests') ?? []);
      });
    }
  }

  Future<void> sendFriendRequest(
      String senderId, String receiverId, context) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> senderSnapshot =
          await usersCollection.doc(senderId).get();

      if (senderSnapshot.exists) {
        Map<String, dynamic> senderData = senderSnapshot.data() ?? {};

        await usersCollection
            .doc(receiverId)
            .collection('friendRequests')
            .doc(senderId)
            .set(senderData);

        await usersCollection.doc(senderId).update({
          'sentRequests': FieldValue.arrayUnion([receiverId]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Request sent successfully")),
        );
      } else {
        print('Sender document does not exist');
      }
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DocumentSnapshot> filterCurrentUser(List<DocumentSnapshot> docs) {
      return docs.where((doc) => doc.id != APIs.me.id).toList();
    }

//     DocumentReference<Map<String, dynamic>> usCollection = FirebaseFirestore
//         .instance
//         .collection('users')
//         .doc(APIs.me.id)
//         .collection('my_users')
//         .doc();

//     DocumentReference<Map<String, dynamic>> uCollection =
//         FirebaseFirestore.instance.collection('users').doc(uid);

// // Comparing the IDs of the two documents
//     bool areIdsEqual = usCollection.id == uCollection.id;

//     print('Are IDs equal: $areIdsEqual');

    return Scaffold(
      body: Stack(
        children: [
          Container(
              padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
              width: MediaQuery.of(context).size.width / 1,
              height: MediaQuery.of(context).size.height / 3,
              color: Color.fromARGB(179, 11, 2, 31),
              child: Text(
                "Add Friend",
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              )),
          Container(
            margin: EdgeInsets.fromLTRB(0, 140, 0, 0),
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(60),
                    topLeft: Radius.circular(60)),
                color: Colors.white),
            width: MediaQuery.of(context).size.width / 1,
            height: MediaQuery.of(context).size.height / 1,
            child: Column(
              children: [
                Container(
                  height: 100,
                  // padding: EdgeInsets.all(10),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: friendRequests,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('');
                      } else {
                        // Display the friend requests in a ListView or any other widget
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final friendRequestId = snapshot.data![index];
                            return ListTile(
                              leading: CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      NetworkImage(friendRequestId['image'])),
                              title: Text(friendRequestId['name']),
                              subtitle: Text('You Got an Friend Request'),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            acceptFriendRequest(
                                                friendRequestId, APIs.me.id);
                                          });
                                        },
                                        icon: Icon(Icons.verified_outlined)),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            removeRequest(
                                                friendRequestId, APIs.me.id);
                                          });
                                        },
                                        icon: Icon(Icons.close))
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Container(
                  height: 200,
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('No users found'),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error fetching data'),
                        );
                      }
                      List<DocumentSnapshot> filteredUsers =
                          filterCurrentUser(snapshot.data!.docs);
                      // Filter out the currently logged-in user and already added users

                      return GridView.builder(
                        padding: EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          var userData = filteredUsers[index].data()!;
                          bool isRequested = sentRequests.contains(
                              (userData as Map<String, dynamic>)['id']);

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewProfileScreen2(profiledata: userData,),
                                  ));
                            },
                            child: Container(
                              margin: EdgeInsets.all(4),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 4,
                                    offset: Offset(4, 4),
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 4,
                                    offset: Offset(-4, -4),
                                    spreadRadius: 0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundImage:
                                        NetworkImage(userData['image'] ?? ''),
                                  ),
                                  Text(
                                    userData['name'] ?? 'No username',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      if (!isRequested) {
                                        await sendFriendRequest(APIs.me.id,
                                            userData['id'], context);
                                        setState(() {
                                          sentRequests.add(userData['id']);
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(Icons.group_add_sharp),
                                          Text(
                                            isRequested
                                                ? "Added"
                                                : "Add Friend",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future isUserAlreadyAdded(String userId) async {
  try {
    // Query the specific user's 'my_user' collection to check if the user is added
    DocumentSnapshot myUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('my_user')
        .doc(APIs.me.id)
        .get();

    return myUserDoc.exists;
  } catch (e) {
    print('Error checking if user is already added: $e');
    return false;
  }
}

Future<List<Map<String, dynamic>>> getFriendRequests(String userId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('friendRequests')
        .get();

    // Retrieve sender's information for each friend request
    final friendRequestsData =
        await Future.wait<Map<String, dynamic>>(snapshot.docs.map((doc) async {
      final senderId = doc.id;
      final senderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .get();

      // Check if sender's document exists
      if (senderSnapshot.exists) {
        // Get sender's data
        Map<String, dynamic> senderData =
            senderSnapshot.data() as Map<String, dynamic>;
        return senderData;
      } else {
        print(
            'Sender document does not exist for friend request from $senderId');
        return {}; // or return null; depending on how you want to handle this case
      }
    }));

    // Remove empty maps (failed to retrieve sender's information)
    final filteredFriendRequestsData =
        friendRequestsData.where((data) => data.isNotEmpty).toList();

    return filteredFriendRequestsData;
  } catch (e) {
    print('Error getting friend requests: $e');
    return [];
  }
}

Future<void> acceptFriendRequest(
    Map<String, dynamic> senderData, String receiverId) async {
  try {
    // Move the sender's info to the my_users collection
    await FirebaseFirestore.instance
        .collection(
            'users') // Assuming the users collection is the parent collection
        .doc(receiverId)
        .collection('my_users')
        .doc(senderData['id'])
        .set(senderData);

    // Delete the friend request from the receiver's friendRequests collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('friendRequests')
        .doc(senderData['id'])
        .delete();
  } catch (e) {
    print('Error accepting friend request: $e');
  }
}

Future<void> removeRequest(
    Map<String, dynamic> senderData, String receiverId) async {
  try {
    // Delete the friend request from the receiver's friendRequests collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('friendRequests')
        .doc(senderData['id'])
        .delete();
  } catch (e) {
    print('Error accepting friend request: $e');
  }
}
