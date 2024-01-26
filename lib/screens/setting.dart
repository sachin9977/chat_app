import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/helper/dailogs.dart';
import 'package:chat_app/main.dart';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/profile_screen.dart';
import 'package:chat_app/screens/settingScreen/help.dart';
import 'package:chat_app/screens/settingScreen/my_connection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
            width: MediaQuery.of(context).size.width / 1,
            height: MediaQuery.of(context).size.height / 2,
            color: Color.fromARGB(179, 11, 2, 31),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CircleAvatar(
                    radius: 60,
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
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
                SizedBox(
                  height: 14,
                ),
                Text(
                  "Hey, ${APIs.me.name.split(' ').first}",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 240, 0, 0),
            padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(60),
                    topLeft: Radius.circular(60)),
                color: Colors.white),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ));
                  },
                  leading: Icon(Icons.person_2_outlined),
                  title: Text("Edit Profile"),
                  trailing: Icon(Icons.keyboard_arrow_right_outlined),
                  subtitle: Text("Sachin"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyConnection(),
                        ));
                  },
                  leading: Icon(Icons.group),
                  title: Text("Your Connection"),
                  trailing: Icon(Icons.keyboard_arrow_right_outlined),
                  subtitle: Text("Sachin"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpScreen(),
                        ));
                  },
                  leading: Icon(Icons.help),
                  title: Text("Help"),
                  trailing: Icon(Icons.keyboard_arrow_right_outlined),
                  subtitle: Text("Sachin"),
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: Text("Invite a Friend"),
                  trailing: Icon(Icons.keyboard_arrow_right_outlined),
                  subtitle: Text("Sachin"),
                ),
                ListTile(
                  onTap: () async {
                    Dialogs.showProgressbar(context);
                    await APIs.updateActiveStatus(false);
                    await APIs.auth.signOut().then((value) async {
                      await GoogleSignIn().signOut().then((value) {
                        // For Hiding Progress dialog
                        Navigator.pop(context);
                        // For moving to home screen
                        Navigator.pop(context);
                        APIs.auth = FirebaseAuth.instance;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ));
                      });
                    });
                  },
                  leading: Icon(Icons.logout_outlined),
                  title: Text("Log Out"),
                  trailing: Icon(Icons.keyboard_arrow_right_outlined),
                  subtitle: Text("${APIs.me.name.split(' ').first}"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
