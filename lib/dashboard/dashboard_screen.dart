import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:waydchatapp/dashboard/dashboard_screens/chat_screen.dart';
import 'package:waydchatapp/modal/userClass.dart';
import 'package:waydchatapp/theme/colors.dart';
import 'package:waydchatapp/theme/decorations.dart';
import 'package:waydchatapp/theme/fonts.dart';

class DashboardScreen extends StatefulWidget {
  static String name = 'dashboard_screen';
  int currentScreenIndex = 0;

  final Function? signOut;
  final String userName;
  final String id;

  DashboardScreen(this.userName, this.id, this.signOut, {Key? key})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  var profilesInstance = FirebaseFirestore.instance.collection("userProfile");

  /// STREAMS FOR USER

  Stream<List<User>> getAllUsers() {
    return profilesInstance
        .snapshots()
        .map((event) => User.fromJson(event, widget.id));
  }

  ///--------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryBlack87,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15),
              child: InkWell(
                onTap: () {
                  showAlert(context, widget.signOut!());
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: kPrimaryImageFitB0R30,
                ),
              ),
            ),
            const Text(
              'Chat',
              style: kWhiteNormal,
            ),
            InkWell(
              onTap: () {
                showAllUsers(context);
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 15),
                child: Icon(Icons.add_circle_outlined),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: kPrimaryTransparent,
          highlightColor: kPrimaryTransparent,
        ),
        child: BottomNavigationBar(
          elevation: 20.0,
          backgroundColor: kPrimaryBlack,
          type: BottomNavigationBarType.fixed,
          currentIndex: widget.currentScreenIndex,
          onTap: (index) {
            setState(() {
              widget.currentScreenIndex = index;
            });
          },
          selectedFontSize: 14.0,
          unselectedFontSize: 14.0,
          selectedItemColor: kPrimaryPinkAccent700,
          unselectedItemColor: kPrimaryUnselectedItemColor,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.message_rounded),
              label: 'Chat',
              backgroundColor: kPrimaryBlack,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none),
              label: 'Notifications',
              backgroundColor: kPrimaryBlack,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.keyboard_arrow_down_sharp),
              label: 'More',
              backgroundColor: kPrimaryBlack,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: _dashboardScreen(context),
      ),
    );
  }

  Widget _dashboardScreen(BuildContext context) {
    return widget.currentScreenIndex == 0
        ? ChatScreenWidget(widget.id)
        : Container();
  }

  /// SIGN OUT POPUP
  void showAlert(BuildContext context, function) {
    int index = 0;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(0),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 200,
                decoration: kPrimaryR15,
                child: Center(
                  child: InkWell(
                    onTap: () {
                      index = 1;
                      function;
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 150,
                      height: 75,
                      decoration: kPrimaryRedAccentR10,
                      child: const Center(
                        child: Text(
                          "Sign out",
                          style: k18BlackBold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
    ).then((value) {
      if (index != 0) {
        Navigator.of(context).pop();
      }
    });
  }

  /// LOAD ALL NO CHAT USERS
  void showAllUsers(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: StreamBuilder(
          stream: getAllUsers(),
          builder: (builder, snapshot) {
            if (snapshot.hasData) {
              List<User> allUsersList = snapshot.data as List<User>;

              return Container(
                padding: const EdgeInsets.only(top: 10),
                width: 150,
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text('Choose person:', style: k20BlackBold),
                      const SizedBox(
                        height: 20,
                      ),
                      allUsersList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const ScrollPhysics(),
                              itemCount: allUsersList.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        writeMessage(
                                            widget.id,
                                            allUsersList[index].id,
                                            DateTime.now()
                                                .microsecondsSinceEpoch
                                                .toString());
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        allUsersList[index].name,
                                        style: k15BlackBold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    )
                                  ],
                                );
                              },
                            )
                          : const Center(
                              child: SizedBox(
                                width: 150,
                                height: 200,
                                child: Text('No available users'),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox(
                width: 150,
                height: 200,
                child: Text('No registered users'),
              );
            }
          },
        ),
      ),
    );
  }

  /// NODE.JS CLOUD FUNCTION
  Future<void> writeMessage(
      String myId, String userId, String timeMessage) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('createChat');
    try {
      await callable.call(<String, dynamic>{
        'myId': myId,
        'userId': userId,
        'time': timeMessage,
        'chatId': "$myId-$userId",
      });
    } catch (e) {
      //
    }
  }
}
