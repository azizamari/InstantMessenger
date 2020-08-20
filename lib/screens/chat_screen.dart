import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id ="ChatScreen";
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore=Firestore.instance;
  final _auth=FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String messageText;

  void getCurrentUser()async{
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }
    catch(e){
      print(e);
    }
  }
  /*void getMessages() async{
    final messages= await _firestore.collection('messages').getDocuments();
    for ( var message in messages.documents){
      print(message.data);
    }*/
  void messagesStream() async{
    await for(var snapshot in _firestore.collection("messages").snapshots()){
      for(var message in snapshot.documents) {
        print(message.data);
      }
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messagesStream();
                /*_auth.signOut();
                Navigator.pop((context));*/
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("messages").snapshots(),
              // ignore: missing_return
              builder:(context, snapshot){
                if(snapshot.hasData){
                  final messages=snapshot.data.documents;
                  List<Text> messageWidgets=[];
                  for(var message in messages){
                    final messageText=message.data["text"];
                    final messageSender=message.data["sender"];
                    final messageWidget=Text('$messageText from $messageSender',style: TextStyle(color: Colors.black,fontSize: 20),);
                    messageWidgets.add(messageWidget);
                  }
                  return Column(children: messageWidgets);
                }
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: TextField(
                        style: TextStyle(color: Colors.black,fontSize: 20),
                        onChanged: (value) {
                          messageText=value;
                        },
                        decoration: InputDecoration(hintText: "Type your message here...",hintStyle: TextStyle(color: Colors.grey,fontSize: 20),),
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection("messages").add({
                        "text":messageText,
                        "sender":loggedInUser.email
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
