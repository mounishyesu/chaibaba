import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../helpers/utilities.dart';
import '../../widgets/constraints.dart';
import '../apicalls/restapi.dart';
import '../home/home.dart';
import '../printer.dart';

class LoginForm extends StatefulWidget {
  LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController userName = TextEditingController();
  TextEditingController passWord = TextEditingController();
  bool _showPassword = false;
  bool isPermission = false;
  bool isOnline = true;

  @override
  void initState() {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      Utilities.requestPermission();
    } else if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Container(
            alignment: Alignment.topCenter,
            child: Image.network(
              Utilities.companyLogo.toString(),
              height: 300,
              width: 300,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: whiteColor,
            ),
            child: TextFormField(
              controller: userName,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSaved: (email) {},
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 15),
                border: InputBorder.none,
                hintText: "Enter Username",
                prefixIcon: Icon(
                  Icons.person,
                  color: bordertextcolor,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: defaultPadding),
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
              ),
              child: TextFormField(
                obscureText: !_showPassword,
                controller: passWord,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 15),
                  border: InputBorder.none,
                  hintText: "Enter Password",
                  prefixIcon: Icon(
                    Icons.lock,
                    color: bordertextcolor,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                    child: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: bordertextcolor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: defaultPadding),
          Center(
            child: Container(
              height: 50,
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: bordertextcolor,
                  // shape: RoundedRectangleBorder(
                  //   // borderRadius: BorderRadius.circular(15),
                  // ),
                ),
                onPressed: () async {
                  bool is_Online =
                      await Utilities.CheckUserConnection() as bool;
                  print("is_Online");
                  print(is_Online);
                  print("is_Online");
                  if (userName.text.isEmpty) {
                    Utilities.showAlert(context, 'Username Required');
                  } else if (passWord.text.isEmpty) {
                    Utilities.showAlert(context, 'Password Required');
                  } else if (!is_Online) {
                    Utilities.showAlert(
                        context, 'Check Your Internet Connection');
                  } else {
                    loginApiCall(
                        userName.text.toString(), passWord.text.toString());
                  }
                },
                child: Text(
                  "LOGIN",
                  style: TextStyle(color: whiteColor),
                ),
              ),
            ),
          ),
          SizedBox(height: 160),
        ],
      ),
    );
  }

  loginApiCall(userName, password) async {
    Map<String, dynamic> formMap = {"username": userName, "password": password};
    print(formMap);
    ApiService.post("app-login", formMap).then((success) {
      setState(() {
        var data = jsonDecode(success.body); //store response as string
        print('data-------------------->>$data');
        print(data['status']);
        if (data['status'] == "success") {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => PrintOrder()),
              (Route<dynamic> route) => false);
        } else {
          Utilities.Snackbar(context, "Invalid Username/Password");
        }
      });
    });
  }

  //login response//

  // {status: success, message: Successfully login., data: {userid: 4, username: dhanalakshmi, mobile: 9491771222, password: TVRJek5EVTI=, email: CB1@gmail.com, address: kkd, role_type: User, token: null, token_expire: null, status: 1, createdon: 0000-00-00 00:00:00, createdby: 0, updatedon: 10-06-2021, updatedby: 0}}

//login response//
}
