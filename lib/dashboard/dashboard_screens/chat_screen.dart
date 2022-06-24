
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:waydchatapp/modal/userClass.dart';
import 'package:waydchatapp/modal/usersChats.dart';
import 'package:waydchatapp/shared/placeholder_image.dart';
import 'package:waydchatapp/theme/colors.dart';
import 'package:waydchatapp/theme/decorations.dart';
import 'package:waydchatapp/theme/fonts.dart';

class ChatScreenWidget extends StatefulWidget {
  final String id;
   ChatScreenWidget(this.id, {Key? key}) : super(key: key);

  @override
  _ChatScreenWidgetState createState() => _ChatScreenWidgetState();
}

final myController = TextEditingController();

class _ChatScreenWidgetState extends State<ChatScreenWidget> {

  bool loaded = false;

  List<User> allUsers = [];
  String searchText = '';
  var messageInstance = FirebaseFirestore.instance.collection("messages");

  Stream<UserChats> readChats() {
    return messageInstance
        .snapshots()
        .map((event) => UserChats.fromJson(event));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 40,
                  decoration: kPrimaryB1_5BlackR6,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: myController,
                          textAlignVertical: TextAlignVertical.center,
                          cursorHeight: 11,
                          style: k13BlackNormal,
                          decoration: kPrimaryDashboardSearch,
                          onChanged: (value) {
                            searchText = value;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder(
              stream: readChats(),
              builder: (builder, snapshot) {
                if (snapshot.hasData) {
                  UserChats chats = snapshot.data as UserChats;
                  return FutureBuilder(
                      future: _getAllUsers(chats),
                      builder: (builder, snapshot) {
                        return loaded
                            ? allUsers.isNotEmpty
                            ? ListView.builder(
                          shrinkWrap: true,
                          physics: const ScrollPhysics(),
                          itemCount: allUsers.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (BuildContext context,
                              int index) {
                            String? firstName;

                            /// ----------------------------------------------------
                            String? name = allUsers[index].name;

                            /// ----------------------------------------------------
                            var lastMessageTimeDate = DateTime
                                .fromMicrosecondsSinceEpoch(
                                int.parse(allUsers[index]
                                    .timeStamp));

                            /// ----------------------------------------------------
                            String
                            lastMessageTimeDateStringTmp =
                            lastMessageTimeDate
                                .toString()
                                .split(" ")[1];
                            String lastMessageTimeDateString =
                                "${lastMessageTimeDateStringTmp.split(":")[0]}:${lastMessageTimeDateStringTmp.split(":")[1]}";

                            /// ----------------------------------------------------
                            final difference = daysBetween(
                              lastMessageTimeDate,
                              DateTime.now(),
                            );

                            /// ----------------------------------------------------
                            final dayIfDiffHigherThanOneNum =
                                lastMessageTimeDate.weekday;

                            /// ----------------------------------------------------
                            String dayIfDiffHigherThanOne =
                            getDateString(
                                dayIfDiffHigherThanOneNum);

                            /// ----------------------------------------------------
                            firstName = allUsers[index]
                                .name
                                .split(" ")
                                .first;

                            /// ----------------------------------------------------
                            return _userWidgetCard(
                                context,
                                index,
                                name,
                                firstName,
                                difference,
                                lastMessageTimeDateString,
                                dayIfDiffHigherThanOne);
                          },
                        )
                            : const Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Center(
                            child: (Text(
                              "No chats found",
                              style: k15BlackBold,
                            )),
                          ),
                        )
                            : SizedBox(
                          height:
                          MediaQuery.of(context).size.height,
                          child: const Center(
                            child: SpinKitFoldingCube(
                              color: kPrimaryGreenAccent,
                              size: 40.0,
                            ),
                          ),
                        );
                      });
                } else {
                  return Container();
                }
              })
        ],
      ),
    );
  }

  /// LOAD ALL CHAT USERS
  Future<List<User>> _getAllUsers(UserChats allChats) async {
    allUsers = [];
    loaded = false;

    var _instance = FirebaseFirestore.instance;
    CollectionReference userA = _instance.collection("userProfile");

    for (int i = 0; i < allChats.idChat.length; i++) {
      String userIdOne = allChats.idChat[i].split("-")[0];
      String userIdTwo = allChats.idChat[i].split("-")[1];

      if (userIdOne == widget.id) {
        DocumentSnapshot snapshot = await userA.doc(userIdTwo).get();
        CollectionReference lastMessage = FirebaseFirestore.instance
            .collection("messages")
            .doc(allChats.idChat[i])
            .collection(allChats.idChat[i]);

        var lastMessageTime =
        await lastMessage.get().then((value) => {value.docs.last.id});

        DocumentSnapshot snapshotMessage =
        await lastMessage.doc(lastMessageTime.last).get();

        var data = snapshot.data() as Map;
        var dataMessage = snapshotMessage.data() as Map;

        if (data["name"]
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          allUsers.add(User(
              name: data["name"],
              email: data["email"],
              id: data["id"],
              timeStamp: dataMessage["timeStamp"],
              idFrom: dataMessage["idFrom"],
              content: dataMessage["content"]));
        }
      } else if (userIdTwo == widget.id) {
        DocumentSnapshot snapshot = await userA.doc(userIdOne).get();
        CollectionReference lastMessage = FirebaseFirestore.instance
            .collection("messages")
            .doc(allChats.idChat[i])
            .collection(allChats.idChat[i]);

        var lastMessageTime =
        await lastMessage.get().then((value) => {value.docs.last.id});

        DocumentSnapshot snapshotMessage =
        await lastMessage.doc(lastMessageTime.last).get();

        var data = snapshot.data() as Map;
        var dataMessage = snapshotMessage.data() as Map;

        if (data["name"]
            .toString()
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          allUsers.add(User(
              name: data["name"],
              email: data["email"],
              id: data["id"],
              timeStamp: dataMessage["timeStamp"],
              idFrom: dataMessage["idFrom"],
              content: dataMessage["content"]));
        }
      }
    }

    for (int i = 0; i < allUsers.length; i++) {
      for (int j = i + 1; j < allUsers.length; j++) {
        if (allUsers[i].email == allUsers[j].email) {
          allUsers.removeAt(j);
        }
      }
    }

    loaded = true;
    return allUsers;
  }

  /// USER WIDGET CARD
  Widget _userWidgetCard(BuildContext context, index, name, firstName,
      difference, lastMessageTimeDateString, dayIfDiffHigherThanOne) {
    return InkWell(
      onTap: () async {
        // open chat
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          image: DecorationImage(
                            image: AssetImage(
                                PlaceholderImage.randomPlaceholderImagePath(
                                    index + 1)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: SizedBox(
                          width: 120,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 200,
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: kBlackBold,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width: 200,
                                child: Text(
                                  allUsers[index].idFrom == widget.id
                                      ? "You: ${allUsers[index].content}"
                                      : '$firstName: ${allUsers[index].content}',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(difference == 0
                      ? lastMessageTimeDateString
                      : difference == 1
                      ? 'Yesterday'
                      : dayIfDiffHigherThanOne.toString()),
                ],
              ),
            ),
            Container(
              height: 1,
              color: kPrimaryGrey,
            )
          ],
        ),
      ),
    );
  }

  /// FUNCTIONS FOR DATE TIME FROM LAST MESSAGE
  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  String getDateString(int weekday) {
    final dayIfDiffHigherThanOneNum = weekday;
    String dayIfDiffHigherThanOne = '';
    switch (dayIfDiffHigherThanOneNum) {
      case 1:
        dayIfDiffHigherThanOne = 'Monday';
        break;
      case 2:
        dayIfDiffHigherThanOne = 'Tuesday';
        break;
      case 3:
        dayIfDiffHigherThanOne = 'Wednesday';
        break;
      case 4:
        dayIfDiffHigherThanOne = 'Thursday';
        break;
      case 5:
        dayIfDiffHigherThanOne = 'Friday';
        break;
      case 6:
        dayIfDiffHigherThanOne = 'Saturday';
        break;
      default:
        dayIfDiffHigherThanOne = 'Sunday';
        break;
    }

    return dayIfDiffHigherThanOne;
  }
///--------------------------------------------------------
}
