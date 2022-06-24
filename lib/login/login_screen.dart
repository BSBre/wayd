import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:waydchatapp/dashboard/dashboard_screen.dart';
import 'package:waydchatapp/login/bloc/login_bloc.dart';
import 'package:waydchatapp/login/bloc/login_event.dart';
import 'package:waydchatapp/login/bloc/login_state.dart';
import 'package:waydchatapp/theme/colors.dart';
import 'package:waydchatapp/theme/decorations.dart';
import 'package:waydchatapp/theme/fonts.dart';

import '../modal/userClass.dart';

class LoginScreen extends StatefulWidget {
  static String name = 'login_screen';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class _LoginScreenState extends State<LoginScreen> {
  final docs = FirebaseFirestore.instance.collection('userProfile');
  GoogleSignInAccount? _currentUser;
  String _contactText = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact(_currentUser!);
      }
    });
    _googleSignIn.signInSilently();
  }

  /// GOOGLE SIGN IN FUNCTIONS
  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    setState(() {
      _contactText = 'Loading contact info...';
    });
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = 'People API gave a ${response.statusCode} '
            'response. Check logs for details.';
      });
      return;
    }
    final Map<String, dynamic> data =
    json.decode(response.body) as Map<String, dynamic>;
    final String? namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = 'I see you know $namedContact!';
      } else {
        _contactText = 'No contacts to display.';
      }
    });
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'] as List<dynamic>?;
    final Map<String, dynamic>? contact = connections?.firstWhere(
          (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    ) as Map<String, dynamic>?;
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
            (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      ) as Map<String, dynamic>?;
      if (name != null) {
        return name['displayName'] as String?;
      }
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    try {
      final currUser = await _googleSignIn.signIn();
      if(currUser == null) return;
      _currentUser = currUser;
      setState(() {});
    } catch (error) {
      //
    }
  }

  static Future<void> _handleSignOut() => _googleSignIn.disconnect();
  ///-------------------------------------------------------------


  /// LAUNCH URL FUNCTION
  void _launchURL(url) async {
    if (!await launch(url)) throw 'Could not launch $url';
  }
  ///-------------------------------------------------------------

  /// CREATING NEW USER AND 10 MORE TEST USERS
  Future _createUser(User user) async {
    for(int i = 0; i < 10; i++) {
      User userTest = User(email: 'testmail$i@gmail.com', idFrom: "", content: "", timeStamp: "", name: "Test Name$i", id: "11652936041511234281$i");

      final json = userTest.toJson();

      await docs.doc(userTest.id).set(json);
    }

    final json = user.toJson();
    await docs.doc(user.id).set(json);
  }
  ///-------------------------------------------------------------

  /// NEXT PAGE FUNCTION
  void nextPage() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        alignment: Alignment.center,
        child: DashboardScreen(_currentUser!.displayName!, _currentUser!.id, _handleSignOut),
      ),
    );
  }
  ///-------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => LoginBloc()
                ..add(
                  LoginPageLoaded(),
                ),
            ),
          ],
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              if (state is LoginLoading) {
                return _buildLoading();
              } else if (state is LoginLoaded) {
                return _buildLoaded();
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 16.0, left: 16.0),
                  child: Text(
                    "Error",
                    style: k16BlackNormal,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: const Center(
        child: SpinKitFoldingCube(
          color: kPrimaryGreenAccent,
          size: 40.0,
        ),
      ),
    );
  }

  Widget _buildLoaded() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          const Text(
            'Chat App',
            style: k50BlackBold,
          ),
          const SizedBox(),
          Column(
            children: [
              InkWell(
                onTap: () async {
                  await _handleSignIn();
                  if(_currentUser != null) {
                    final user = User(name: _currentUser!.displayName ?? "Incognito User", email: _currentUser!.email, id: _currentUser!.id, timeStamp: "", idFrom: "", content: "");
                    _createUser(user);
                  }
                  nextPage();
                },
                child: Container(
                  width: 250,
                  height: 50,
                  decoration: kPrimaryGreenAccentB2R10,
                  child: const Center(
                    child: Text(
                      'Sign in with Google',
                      style: k18BlackBold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () async {
                  const url = 'https://www.google.com/';
                  _launchURL(url);
                },
                child: const Text('Terms and condition'),
              ),
            ],
          ),
          const SizedBox(),
        ],
      ),
    );
  }
}
