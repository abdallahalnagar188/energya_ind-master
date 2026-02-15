// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class AuthorityModel {
  String name;
  List<int> dir;
  bool isActive;

  AuthorityModel({
    required this.name,
    required this.dir,
    this.isActive = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'dir': dir,
      'isActive': isActive,
    };
  }

  factory AuthorityModel.fromMap(Map<String, dynamic> map) {
    return AuthorityModel(
      name: map['autho'] as String,
      // dir: List<int>.from((map['dir'] as List<int>)),
      dir: List<int>.from(map['dir']?.map((e) => e is int ? e : 0) ?? []),
      isActive: map['isActive'] as bool,
    );
  }

  AuthorityModel copyWith({
    String? name,
    List<int>? dir,
    bool? isActive,
  }) {
    return AuthorityModel(
      name: name ?? this.name,
      dir: dir ?? this.dir,
      isActive: isActive ?? this.isActive,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthorityModel.fromJson(String source) =>
      AuthorityModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'AuthorityModel(name: $name, dir: $dir, isActive: $isActive)';

  @override
  bool operator ==(covariant AuthorityModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        listEquals(other.dir, dir) &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => name.hashCode ^ dir.hashCode ^ isActive.hashCode;

  static List<AuthorityModel> authos = [
    AuthorityModel(
      name: 'Prepration',
      dir: [1],
    ),
    AuthorityModel(
      name: 'Assembly',
      dir: [2],
    ),
    AuthorityModel(
      name: 'Welding',
      dir: [3],
    ),
    AuthorityModel(
      name: 'Visual',
      dir: [4],
    ),
    AuthorityModel(
      name: 'Follow-Up',
      dir: [5, 6, 7],
    ),
    AuthorityModel(
      name: 'Painting',
      dir: [6],
    ),
    AuthorityModel(
      name: 'Dispatch',
      dir: [],
    ),
    AuthorityModel(
      name: 'Galvanization',
      dir: [5, 6],
    ),
  ];
}
