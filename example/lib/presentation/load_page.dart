import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:simple_isolate/simple_isolate.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  Future<List<dynamic>> getComments() async {
    final runner = await SimpleIsolates.getRunner();
    final request = RequestAsync(
        arguments: {},
        callBack: (args) async {
          final response = await get(
              Uri.parse('https://jsonplaceholder.typicode.com/comments'));
          final list = [];
          for (int i = 0; i < 1000; i++) {
            final comments = json.decode(utf8.decode(response.bodyBytes));
            list.addAll(comments);
          }
          return list;
        });

    final result = await runner.run<List<dynamic>>(request);
    runner.close();
    return result ?? [];
  }

  Future<List<dynamic>> getCommentsWithoutIsolate() async {
    final response =
    await get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));
    final list = [];
    for (int i = 0; i < 1000; i++) {
      final comments = json.decode(utf8.decode(response.bodyBytes));
      list.addAll(comments);
    }
    return list;
  }

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  String status = '';
  String contactsCount = '0';

  @override
  void initState() {
    status = 'не загружено';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
                'Индикатор ниже показывает плавность анимации при выполнении функции'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: () async {
                          setState(() {
                            status = 'Загрузка';
                            contactsCount = '0';
                          });
                          final contacts = await widget.getComments();
                          setState(() {
                            status = 'Загружено';
                            contactsCount = contacts.length.toString();
                          });
                        },
                        child: const Text('загрузить контакты через изолят')),
                    TextButton(
                        onPressed: () async {
                          setState(() {
                            status = 'Загрузка';
                            contactsCount = '0';
                          });
                          final contacts = await widget.getCommentsWithoutIsolate();
                          setState(() {
                            status = 'Загружено';
                            contactsCount = contacts.length.toString();
                          });
                        },
                        child: const Text('загрузить контакты без изолята'))
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),
            Text(status),
            const SizedBox(height: 20),
            Text(contactsCount),
          ],
        ));
  }
}
