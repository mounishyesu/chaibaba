import 'package:flutter/material.dart';

import '../../widgets/constraints.dart';

class LoginScreenTopImage extends StatelessWidget {
  LoginScreenTopImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text(
        //   "Sign In",
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        SizedBox(height: defaultPadding * 2),
        Row(
          children: [
            Spacer(),
            // Expanded(
            //   flex: 1,
            //   child:  Image.asset("assets/images/login_logo.png",),
            // ),
            Spacer(),
          ],
        ),
        // SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}