class Post {
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  Post.fromJson(dynamic jsonPost)
      : postId = jsonPost['postId'],
        id = jsonPost['id'],
        name = jsonPost['name'],
        email = jsonPost['email'],
        body = jsonPost['body'];
}
