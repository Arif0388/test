class User {
  final String id;
  final String username;
  final String? token;
  final String firstname;
  final String lastname;
  final String displayName;
  final String userImg;
  final String userNameId;
  final String googleId;
  final bool verified;
  final String? college;

  User(
      {required this.id,
      required this.username,
      this.token,
      required this.firstname,
      required this.lastname,
      required this.displayName,
      required this.userImg,
      required this.userNameId,
      required this.googleId,
      required this.verified,
      this.college});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      displayName: json['displayName'],
      userImg: json['userImg'],
      userNameId: json['user_name'],
      googleId: json['googleId'],
      verified: json['admin'],
      college: json['college'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'displayName': displayName,
      'userImg': userImg,
      'userNameId': userNameId,
      'googleId': googleId,
      'verified': verified,
      'college': college,
    };
  }
}
