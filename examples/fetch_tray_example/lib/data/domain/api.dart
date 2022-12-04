class Api {
  final String? title;
  final String? description;
  final bool? https;
  final String? category;
  final String? link;

  Api({this.title, this.description, this.https, this.category, this.link});

  factory Api.fromJson(Map<String, dynamic> json) {
    return Api(
      title: json["API"],
      description: json["description"],
      https: json["HTTPS"],
      category: json["Category"],
      link: json["Link"],
    );
  }
}
