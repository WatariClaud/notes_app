// ignore: file_names
import 'package:flutter/material.dart';

// Widget to show icon & heading
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1.0, // take up the full width
      child: SizedBox(
        height: 65,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // flexbox that renders children on extreme opposite sides based on 'grow'
          children: [
            Expanded(
              flex: 1, // set 'grow' to full (take all space left by other siblings)
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/elastic_logo.png', // using transparent image for logo
                    fit: BoxFit.cover,
                    //width and height as per figma
                    width: 52,
                    height: 52,
                  ),
                  const Column(
                    mainAxisSize: MainAxisSize.min, // Adjust the mainAxisSize
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        " Elastic Team",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 0, 122, 1.0),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        " Notes App",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromRGBO(0, 0, 0, 1.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/images/network.png', // using transparent image for network icon
                fit: BoxFit.cover,
                // width and height as per figma,
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: HeaderWidget(),
      )
    ),
  ));
}
