import 'dart:convert';

import 'package:simple_isolate/src/classes/post.dart';
import 'package:simple_isolate/src/classes/request.dart';
import 'package:simple_isolate/src/simple_isolate.dart';
import 'package:http/http.dart' as http;

void main() async {
  final runner = await SimpleIsolates.getRunner();

  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/comments'));

  final request = RequestSync<List<Post>>(
      arguments: {'response' : response},
      callBack: (arguments){
        final response = arguments['response'] as http.Response;
        final comments = json.decode(utf8.decode(response.bodyBytes));
        final result = (comments as List<dynamic>).map((post){
          return Post.fromJson(post);
        });
        return result.toList();
      }
  );
  final result = await runner.run(request);
  print('get ${result?.length}');

  runner.close();
}