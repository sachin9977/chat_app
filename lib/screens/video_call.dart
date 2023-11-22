import 'dart:convert';
import 'package:http/http.dart';
import 'package:chat_app/helper/dailogs.dart';
import 'package:flutter/material.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:chat_app/models/chat_user.dart';

class VideoCallScreen extends StatefulWidget {
  final ChatUser user;
  const VideoCallScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late AgoraClient client;

  @override
  void initState() {
    super.initState();
    sendCallNotification(widget.user.pushToken, widget.user.name);
    initAgora();
  }

  Future<void> sendCallNotification(
      String receiverToken, String callerName) async {
    const String serverKey =
        'AAAAOPyl00U:APA91bEpbQDtOHpFxPQ_p_AaLQT8mDaxOk1sXDrAqfgLBcnLXm_UpI6H5wU_fgmnuRenf1zBw2NGAtr_cPLkKzABBurI1-6XHSM6So3RC7ocYbj7TuEsvUh_OlQgWRQ3ktkvNrsEHbV1';

    final response = await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'to': receiverToken,
          'notification': {
            'title': 'Incoming Call',
            'body': '$callerName is calling you.',
          },
          'data': {
            'type': 'call',
            'caller_name': callerName,
          },
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Notification sent');
    } else {
      print('Failed to send notification');
    }
  }

  Future<void> initAgora() async {
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: "17328ab6d2be4cf4a9dfbf7bba035ede",
        channelName: "call",
        username: widget.user.name,
      ),
    );
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(widget.user.name),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            AgoraVideoViewer(
              showAVState: true,
              client: client,
              layoutType: Layout.floating,
              enableHostControls: true,
            ),
            AgoraVideoButtons(
              onDisconnect: () {
                Navigator.pop(context);
                Dialogs.showSnackbar(
                  context,
                  "Call Disconnected",
                );
              },
              autoHideButtons: true,
              autoHideButtonTime: 3,
              client: client,
              enabledButtons: [
                BuiltInButtons.callEnd,
                BuiltInButtons.toggleMic,
                BuiltInButtons.switchCamera,
                BuiltInButtons.toggleCamera,
              ],
              addScreenSharing: false,
            ),
          ],
        ),
      ),
    );
  }
}
