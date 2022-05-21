import 'dart:convert';
import 'dart:typed_data';

import 'package:example/presentation/load_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:simple_isolate/simple_isolate.dart';

class AppIO extends StatelessWidget {
  const AppIO({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    for (final runner in SimpleIsolates.activeRunners) {
      runner.close();
    }
    return const MaterialApp(
      home: Scaffold(
        body: LoadingPage(),
      ),
    );
  }
}
