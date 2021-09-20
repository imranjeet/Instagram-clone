
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:namaste/util/constant.dart';
import 'package:namaste/views/screens/redirect_main_screen.dart';
import '../controllers/authentications.dart';
import '../pages/loginScreen.dart';

class SignUpScreen extends StatefulWidget {
  final String fcmToken;

  const SignUpScreen({Key key, this.fcmToken}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String email;
  String password;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String _fcmToken;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

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

  void handleSignup() {
    if (formkey.currentState.validate()) {
      formkey.currentState.save();
      signUp(email.trim(), password, context).then((value) async {
        if (value != null) {
          const _url = '$baseUrl/store-google-user';
          print(value.displayName);
          print(value.email);
          print(value.uid);
          print(value.photoUrl);
          try {
            FormData formData = new FormData.fromMap({
              "uid": value.uid,
              "name": value.displayName,
              "email": value.email,
              "profileUrl": value.photoUrl,
              "fcm_token": widget.fcmToken,
            });
            Response response = await Dio().post(
              _url,
              data: formData,
            );
            if (response.data != null) {
              // Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(
              //         builder: (context) =>
              //             MainScreen(currentUserId: value.uid)),
              //     (Route<dynamic> route) => false);
            }
            print("Video response: $response");
          } catch (error) {
            print(error);
            throw error;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  "SignUp",
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                child: Form(
                  key: formkey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: "Email"),
                        validator: (_val) {
                          if (_val.isEmpty) {
                            return "Can't be empty";
                          } else {
                            return null;
                          }
                        },
                        onChanged: (val) {
                          email = val;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Password"),
                          validator: MultiValidator([
                            RequiredValidator(
                                errorText: "This Field Is Required."),
                            MinLengthValidator(6,
                                errorText: "Minimum 6 Characters Required.")
                          ]),
                          onChanged: (val) {
                            password = val;
                          },
                        ),
                      ),
                      RaisedButton(
                        onPressed: handleSignup,
                        color: Colors.green,
                        textColor: Colors.white,
                        child: Text(
                          "Sign Up",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () => googleSignIn(_fcmToken).whenComplete(() {
                  // FirebaseUser user = await FirebaseAuth.instance.currentUser();

                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => RedirectMainScreen()),
                      (Route<dynamic> route) => false);
                }),
                child: Image(
                  image: AssetImage('assets/images/google_signin_button.png'),
                  width: 180.0,
                  height: 70,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              InkWell(
                onTap: () {
                  // send to login screen
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                },
                child: Text(
                  "Login Here",
                  style: TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              PrivacyPolicyUrl(),
            ],
          ),
        ),
      ),
    );
  }
}
