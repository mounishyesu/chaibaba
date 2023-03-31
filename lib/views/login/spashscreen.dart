import 'dart:async';
import 'dart:convert';

import 'package:chai/helpers/utilities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/constraints.dart';
import '../apicalls/restapi.dart';
import 'loginscreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double opacityLevel = 1.0;
  String completeImage = "";


  void _changeOpacity() {
    setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
  }

  @override
  void initState() {
    super.initState();
    settingsApicall();
    Timer(Duration(seconds: 5), () {
      _changeOpacity();
      _navigateToLogin();
    });
    // getLoginstatus().then((status) {
    //   if (status) {
    //     _navigateToHome();
    //     print('IF');
    //   } else {
    //     _navigateToLogin();
    //     print('ELSE');
    //   }
    // });
  }

  // getLoginstatus() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await Future.delayed(Duration(milliseconds: 1500));
  //   if (prefs.getBool('isLogin') == null) {
  //     return false;
  //   }
  //   else{
  //     return true;
  //   }
  // }

  // void _navigateToHome() {
  //   Timer(Duration(seconds: 3), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuditHome())));
  //
  // }
  void _navigateToLogin() {
    Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: bordertextcolor,
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: AnimatedOpacity(
                opacity: opacityLevel,
                duration: Duration(seconds: 3),
                child: Container(
                  decoration: BoxDecoration(
                     /* color: yellowColor*/ borderRadius: BorderRadius.circular(15)),
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Image.asset('assets/images/chaibabalogo.png',height: 250,width: 250,),
                    ],
                  ),
                )),
          )
        ],
      ),
    ));
  }
  settingsApicall() async {
    ApiService.get("app-settings").then((success) {
      setState(() {
        var data = jsonDecode(success.body); //store response as string
        var body = data['settings'];
        String appLogo = body['siteLogo'];
        String appLogopath = data['app_logo_path'];
        completeImage = appLogopath + appLogo;
        Utilities.companyLogo = completeImage;
        print('logo $appLogo $appLogopath $completeImage');
      });
    });
  }
}
