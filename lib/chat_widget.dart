import 'package:alaket_ios/chat.dart';
import 'package:alaket_ios/data.dart';
import 'package:alaket_ios/state/feedState.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatTab extends StatefulWidget {
  ChatTab({Key key}) : super(key: key);

  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  Stream chatRoomsStream;

  Future<Stream<QuerySnapshot>> getChatRooms() async {
    return FirebaseFirestore.instance
        .collection("chatrooms")
        .orderBy("lastMessageSendTs", descending: true)
        .where("users", arrayContains: FirebaseAuth.instance.currentUser.uid)
        .snapshots();
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return ChatRoomListTile(
                      ds["lastMessage"],
                      ds.id,
                      FirebaseAuth.instance.currentUser.uid,
                      ds["lastMessageSendBy"],
                      ds["lastMessageSendTs"]);
                })
            : Center(child: Text('Здесь будут ваши сообщения'));
      },
    );
  }

  init() async {
    chatRoomsStream = await getChatRooms();
    setState(() {});
  }

  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser != null) {
      init();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Сообщения',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: chatRoomsList(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage,
      chatRoomId,
      uid,
      lastMessageSendBy,
      lastMessageSendTs;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.uid,
      this.lastMessageSendBy, this.lastMessageSendTs);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String uriImage, name, surname, username, fullname;
  Map<String, Color> contactsColorMap = new Map();
  var baseColor;

  getThisUserInfo() async {
    username = widget.chatRoomId.replaceAll(widget.uid, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = querySnapshot.docs[0]['name'] ?? '';
    surname = querySnapshot.docs[0].data()['surname'] ?? '';
    uriImage = querySnapshot.docs[0]['avatars'] ?? null;
    setState(() {});
  }

  colors() async {
    List<Color> _colorList = [
      Colors.pink[400],
      Colors.pinkAccent,
      Colors.red[400],
      Colors.redAccent,
      Colors.deepOrange[400],
      Colors.deepOrangeAccent,
      Colors.orange[800],
      Colors.orangeAccent[700],
      Colors.amber[900],
      Colors.lime[800],
      Colors.lightGreen[700],
      Colors.green[600],
      Colors.teal[400],
      Colors.cyan[600],
      Colors.lightBlue[600],
      Colors.lightBlueAccent[700],
      Colors.blue[600],
      Colors.blueAccent,
      Colors.indigo[400],
      Colors.indigoAccent,
      Colors.purple[400],
      Colors.purpleAccent[400],
      Colors.deepPurple[400],
      Colors.deepPurpleAccent,
      Colors.blueGrey[400],
      Colors.brown[400],
      Colors.grey[600],
    ];

    var hash = name.hashCode;
    var index = hash % _colorList.length;
    setState(() {
      baseColor = _colorList[index];
    });
  }

  @override
  void initState() {
    getThisUserInfo();
    colors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      username,
                    )));
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: uriImage != null && uriImage != ''
                        ? Container(
                            height: 45,
                            width: 45,
                            child: CachedNetworkImage(
                              imageUrl: uriImage,
                              // cacheManager: DefaultCacheManager(),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholderFadeInDuration:
                                  Duration(milliseconds: 500),
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300].withOpacity(0.3),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          )
                        : Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(45)),
                            child: Center(
                              child: Text(
                                name != null && name != ''
                                    ? (surname != null
                                            ? name[0] + surname[0]
                                            : name[0])
                                        .toUpperCase()
                                    : widget.chatRoomId.toString(),
                                maxLines: 1,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 250,
                        child: Text(
                          name != null && name != ''
                              ? surname != null
                                  ? name + ' ' + surname
                                  : name
                              : widget.chatRoomId.toString(),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            widget.lastMessageSendBy == widget.uid
                                ? Text(
                                    'Вы: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  )
                                : SizedBox(),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: RichText(
                                overflow: TextOverflow.ellipsis,
                                strutStyle: StrutStyle(fontSize: 12.0),
                                text: TextSpan(
                                    style: TextStyle(color: Colors.black),
                                    text: widget.lastMessage),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
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
