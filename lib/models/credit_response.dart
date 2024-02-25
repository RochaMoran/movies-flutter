import 'dart:convert';

import 'package:movies/models/cast.dart';

class CreditsResponse {
  int id;
  List<Cast> cast;
  List<Cast> crew;

  CreditsResponse({
      required this.id,
      required this.cast,
      required this.crew,
  });

  factory CreditsResponse.fromRawJson(String str) => CreditsResponse.fromJson(json.decode(str));

  factory CreditsResponse.fromJson(Map<String, dynamic> json) => CreditsResponse(
      id: json["id"],
      cast: List<Cast>.from(json["cast"].map((x) => Cast.fromJson(x))),
      crew: List<Cast>.from(json["crew"].map((x) => Cast.fromJson(x))),
  );
}

