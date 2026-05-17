import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class SignPadTest extends StatelessWidget {
  const SignPadTest({super.key});

  @override
  Widget build(BuildContext context) {

    final control = HandSignatureControl(
      initialSetup: SignaturePathSetup(
        threshold: 3.0,
        smoothRatio: 0.65,
        velocityRange: 2.0,
        pressureRatio: 0.0,
        args: {'color': 'red'},
      ),
    );

    
    return BaseScreen(body: Scaffold(body: HandSignature(
          control: control,
          drawer: ShapeSignatureDrawer(
            color: Colors.blueGrey,
            width: 1.0,
            maxWidth: 10.0,
          ),
        ),
      ), isdash: false);
  }
}
