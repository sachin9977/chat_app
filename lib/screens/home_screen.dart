// ignore_for_file: unused_element

import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/dailogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import 'profile_screen.dart';

//home screen -- where all available contacts are shown
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched items
  final List<ChatUser> _searchList = [];
  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    //for updating user active status according to lifecycle events
    //resume -- active or online
    //pause  -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on & back button is pressed then close search
        //or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          //app bar
            // appBar: AppBar(
            //   // leading: const Icon(CupertinoIcons.home),
            //   title: _isSearching
            //       ? Padding(
            //           padding: const EdgeInsets.only(left: 20),
            //           child: TextField(
            //             decoration: const InputDecoration(
            //                 border: InputBorder.none,
            //                 hintText: 'Search by Name',
            //                 hintStyle: TextStyle(color: Colors.white)),
            //             autofocus: true,
            //             style: const TextStyle(
            //                 fontSize: 17,
            //                 letterSpacing: 0.5,
            //                 color: Colors.white),
            //             //when search text changes then updated search list
            //             onChanged: (val) {
            //               //search logic
            //               _searchList.clear();

            //               for (var i in _list) {
            //                 if (i.name
            //                         .toLowerCase()
            //                         .contains(val.toLowerCase()) ||
            //                     i.email
            //                         .toLowerCase()
            //                         .contains(val.toLowerCase())) {
            //                   _searchList.add(i);
            //                   setState(() {
            //                     _searchList;
            //                   });
            //                 }
            //               }
            //             },
            //           ),
            //         )
            //       : const Text('Baat-Chit'),
            //   actions: [
            //     //search user button
            //     IconButton(
            //         onPressed: () {
            //           setState(() {
            //             _isSearching = !_isSearching;
            //           });
            //         },
            //         icon: Icon(_isSearching
            //             ? CupertinoIcons.clear_circled_solid
            //             : Icons.search)),

            //     //more features button
            //       // IconButton(
            //       //     onPressed: () {
            //       //       Navigator.push(
            //       //           context,
            //       //           MaterialPageRoute(
            //       //               builder: (_) => ProfileScreen()));
            //       //     },
            //       //     icon: const Icon(Icons.more_vert))
            //   ],
            // ),

            //body
            body: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
              width: MediaQuery.of(context).size.width / 1,
              height: MediaQuery.of(context).size.height / 3,
              color: Color.fromARGB(179, 11, 2, 31),
              child: ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(60)),
                  child: Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                title: Text(
                  "Baat-Chit",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                trailing: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ));
                  },
                  child: SizedBox(
                    height: 45,
                    width: 45,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .1),
                      child: CachedNetworkImage(
                        // width: mq.width / 6,
                        // height: mq.height / 1,
                        fit: BoxFit.cover,
                        // imageUrl: widget.user.image,
                        imageUrl: APIs.me.image,
                        // placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 140, 0, 0),
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(60),
                      topLeft: Radius.circular(60)),
                  color: Colors.white),
              width: MediaQuery.of(context).size.width / 1,
              height: MediaQuery.of(context).size.height / 1,
              child: StreamBuilder(
                stream: APIs.getMyUserId(),

                //get id of only known users
                builder: (context, AsyncSnapshot<dynamic> snapshot) {
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                        stream: APIs.getAllUsers(snapshot.data?.docs
                                .map((e) => e.id)
                                .cast<String>()
                                .toList() ??
                            []),

                        //get only those user, who's ids are provided
                        builder: (context, AsyncSnapshot<dynamic> snapshot) {
                          switch (snapshot.connectionState) {
                            //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                            // return const Center(
                            //     child: CircularProgressIndicator());

                            //if some or all data is loaded then show it
                            case ConnectionState.active:
                            case ConnectionState.done:
                              // final data = snapshot.data?.docs;
                              // _list = data
                              //         ?.map((e) => ChatUser.fromJson(e.data()))
                              //         .toList() ??
                              //     [];

                              final data = snapshot.data?.docs;
                              _list = data
                                      ?.map((e) => ChatUser.fromJson(e.data()))
                                      .whereType<
                                          ChatUser>() // Filter out non-ChatUser objects
                                      .toList() ??
                                  [];

                              // Ensure that data is not null before performing the conversion
                              // ignore: unnecessary_null_comparison
                              if (_list != null) {
                                _list = _list.cast<
                                    ChatUser>(); // Cast the list to ChatUser if needed
                              } else {
                                // Handle the case where data is null or empty
                              }

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    itemCount: _isSearching
                                        ? _searchList.length
                                        : _list.length,
                                    padding:
                                        EdgeInsets.only(top: mq.height * .01),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                          user: _isSearching
                                              ? _searchList[index]
                                              : _list[index]);
                                    });
                              } else {
                                return const Center(
                                  child: Text('No Connections Found!',
                                      style: TextStyle(fontSize: 20)),
                                );
                              }
                          }
                        },
                      );
                  }
                },
              ),
            ),
          ],
        )

//           StreamBuilder(
//             stream: APIs.getMyUserId(),

//             //get id of only known users
//             builder: (context, AsyncSnapshot<dynamic> snapshot) {
//               switch (snapshot.connectionState) {
//                 //if data is loading
//                 case ConnectionState.waiting:
//                 case ConnectionState.none:
//                   return const Center(child: CircularProgressIndicator());

//                 //if some or all data is loaded then show it
//                 case ConnectionState.active:
//                 case ConnectionState.done:
//                   return StreamBuilder(
//                     stream: APIs.getAllUsers(snapshot.data?.docs
//                             .map((e) => e.id)
//                             .cast<String>()
//                             .toList() ??
//                         []),

//                     //get only those user, who's ids are provided
//                     builder: (context, AsyncSnapshot<dynamic> snapshot) {
//                       switch (snapshot.connectionState) {
//                         //if data is loading
//                         case ConnectionState.waiting:
//                         case ConnectionState.none:
//                         // return const Center(
//                         //     child: CircularProgressIndicator());

//                         //if some or all data is loaded then show it
//                         case ConnectionState.active:
//                         case ConnectionState.done:
//                           // final data = snapshot.data?.docs;
//                           // _list = data
//                           //         ?.map((e) => ChatUser.fromJson(e.data()))
//                           //         .toList() ??
//                           //     [];

//                           final data = snapshot.data?.docs;
//                           _list = data
//                                   ?.map((e) => ChatUser.fromJson(e.data()))
//                                   .whereType<
//                                       ChatUser>() // Filter out non-ChatUser objects
//                                   .toList() ??
//                               [];

// // Ensure that data is not null before performing the conversion
//                           // ignore: unnecessary_null_comparison
//                           if (_list != null) {
//                             _list = _list.cast<
//                                 ChatUser>(); // Cast the list to ChatUser if needed
//                           } else {
//                             // Handle the case where data is null or empty
//                           }

//                           if (_list.isNotEmpty) {
//                             return ListView.builder(
//                                 itemCount: _isSearching
//                                     ? _searchList.length
//                                     : _list.length,
//                                 padding: EdgeInsets.only(top: mq.height * .01),
//                                 physics: const BouncingScrollPhysics(),
//                                 itemBuilder: (context, index) {
//                                   return ChatUserCard(
//                                       user: _isSearching
//                                           ? _searchList[index]
//                                           : _list[index]);
//                                 });
//                           } else {
//                             return const Center(
//                               child: Text('No Connections Found!',
//                                   style: TextStyle(fontSize: 20)),
//                             );
//                           }
//                       }
//                     },
//                   );
//               }
//             },
//           ),
        ),
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.deepPurple,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon:
                        const Icon(Icons.email, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ))
              ],
            ));
  }
}
