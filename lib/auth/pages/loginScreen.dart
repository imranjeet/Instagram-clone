import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:namaste/util/constant.dart';
import 'package:namaste/views/screens/redirect_main_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/authentications.dart';
import '../pages/signupScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String _fcmToken;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _fcmToken = token;
      });
    });
  }

  void login() {
    if (formkey.currentState.validate()) {
      formkey.currentState.save();
      signin(email, password, context).then((value) {
        if (value != null) {
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(
          //         builder: (context) => MainScreen(currentUserId: value.uid)),
          //     (Route<dynamic> route) => false);
        }
      });
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Image.asset(
              //   "assets/images/logo.png",
              //   height: 60,
              //   width: 60,
              // ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Login Here",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.90,
              //   child: Form(
              //     key: formkey,
              //     child: Column(
              //       children: <Widget>[
              //         TextFormField(
              //           decoration: InputDecoration(
              //               border: OutlineInputBorder(), labelText: "Email"),
              //           validator: MultiValidator([
              //             RequiredValidator(
              //                 errorText: "This Field Is Required"),
              //             EmailValidator(errorText: "Invalid Email Address"),
              //           ]),
              //           onChanged: (val) {
              //             email = val;
              //           },
              //         ),
              //         Padding(
              //           padding: const EdgeInsets.symmetric(vertical: 15.0),
              //           child: TextFormField(
              //             obscureText: true,
              //             decoration: InputDecoration(
              //                 border: OutlineInputBorder(),
              //                 labelText: "Password"),
              //             validator: MultiValidator([
              //               RequiredValidator(
              //                   errorText: "Password Is Required"),
              //               MinLengthValidator(6,
              //                   errorText: "Minimum 6 Characters Required"),
              //             ]),
              //             onChanged: (val) {
              //               password = val;
              //             },
              //           ),
              //         ),
              //         RaisedButton(
              //           // passing an additional context parameter to show dialog boxs
              //           onPressed: login,
              //           color: Colors.green,
              //           textColor: Colors.white,
              //           child: Text(
              //             "Login",
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () => googleSignIn(_fcmToken).then((value) => {
                      if (value)
                        {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => RedirectMainScreen()),
                              (Route<dynamic> route) => false),
                        }
                      else
                        {showInSnackBar("Sign in failed! try again")}
                    }),
                // FirebaseUser user = await FirebaseAuth.instance.currentUser();

                //   Navigator.of(context).pushReplacement(MaterialPageRoute(
                //       builder: (context) => MainScreen(currentUserId: user.uid),(Route<dynamic> route) => false));
                // }),
                child: Image(
                  image: AssetImage('assets/images/google_signin_button.png'),
                  width: 180.0,
                  height: 70,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              // InkWell(
              //   onTap: () {
              //     // send to login screen
              //     Navigator.of(context).push(MaterialPageRoute(
              //         builder: (context) => SignUpScreen(fcmToken: _fcmToken)));
              //   },
              //   child: Text(
              //     "Sign Up Here",
              //     style: TextStyle(
              //         color: Colors.deepOrange,
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold),
              //   ),
              // ),
              PrivacyPolicyUrl(),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyUrl extends StatelessWidget {
  const PrivacyPolicyUrl({
    Key key,
  }) : super(key: key);

  _launchURL() async {
    const url = privacyPolicyUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 65.0, top: 14.0, right: 65.0, bottom: 14.0),
      child: InkWell(
        onTap: () => _launchURL(),
        child: Text(
          'By signing up you accept the Terms of Service and Privacy Policy',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }
}
