import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energya_ind/core/models/authority_model.dart';

class UserModel {
  String name, email, password, phone, type;
  Timestamp createdAt;

  // int authorityId;
  //List<int> authorityIds;
  List<AuthorityModel> authorities;
  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.createdAt,
    // required this.authorityId,
    //required this.authorityIds,
    required this.authorities,
    required this.type,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? password,
    String? phone,
    Timestamp? createdAt,
    //int? authorityId,
    //List<int>? authorityIds,
    String? type,
    List<AuthorityModel>? authorities,
  }) {
    return UserModel(
        createdAt: createdAt ?? this.createdAt,
        //  authorityId: authorityId ?? this.authorityId,
        //authorityIds: authorityIds ?? this.authorityIds,
        authorities: authorities ?? this.authorities,
        password: password ?? this.password,
        email: email ?? this.email,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        type: type ?? this.type);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'createdAt': createdAt.millisecondsSinceEpoch,
      /* //'authorityId': authorityId,
      'authorityIds': authorityIds,
      //'authorityName': authos[authorityId],
      'authorityNames': authorityIds
          .map((id) =>AuthorityModel.authos[id].name)
          .toList(), // أسماء الصلاحيات
       */
      'authorities': AuthorityModel.authos.map((autho) {
        return {
          'autho': autho.name,
          'dir': autho.dir,
          'isActive': false,
        };
      }).toList(),
      'password': password,
      'email': email,
      'name': name,
      'phone': phone,
      'type': 'user',
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      createdAt: Timestamp.fromMillisecondsSinceEpoch(map['createdAt']),
      //authorityId: map['authorityId'] as int,
      // authorityIds: List<int>.from(map['authorityIds']),
      authorities: (map['authorities'] as List<dynamic>?)
              ?.map((autho) => AuthorityModel.fromMap(autho))
              .toList() ??
          [],
      password: map['password'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      type: map['type'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.createdAt == createdAt &&
        // other.authorityId == authorityId &&
        other.authorities == authorities &&
        other.email == email &&
        other.name == name &&
        other.password == password &&
        other.phone == phone;
  }

  @override
  int get hashCode =>
      createdAt.hashCode ^
      //authorityId.hashCode ^
      authorities.hashCode ^
      email.hashCode ^
      phone.hashCode ^
      password.hashCode ^
      name.hashCode;
}

List<Map<String, dynamic>> authos = [
  {
    'autho': 'Prepration',
    'dir': [1]
  },
  {
    'autho': 'Assembly',
    'dir': [2]
  },
  {
    'autho': 'Welding',
    'dir': [3]
  },
  {
    'autho': 'Visual',
    'dir': [4]
  },
  {
    'autho': 'Follow-Up',
    'dir': [5, 6, 7]
  },
  {
    'autho': 'Painting',
    'dir': [6]
  },
  {'autho': 'Dispatch', 'dir': []},
  {
    'autho': 'Galvanization',
    'dir': [5, 6]
  },
  {
    'autho': 'Cutting',
    'dir': [3] // Cutting → Visual
  },
];

/// Returns the correct authos list based on project type.
/// T-L projects use Cutting flow, others use standard SS-L flow.
List<Map<String, dynamic>> getAuthosForProject(String filePath) {
  if (AuthorityModel.isTLProject(filePath)) {
    // T-L flow: Cutting → Visual → Follow-Up → Painting/Dispatch/Galvanization
    return [
      {
        'autho': 'Cutting',
        'dir': [3]
      }, // → Visual
      {
        'autho': 'Assembly',
        'dir': [2]
      }, // placeholder (unused for T-L)
      {
        'autho': 'Welding',
        'dir': [3]
      }, // placeholder (unused for T-L)
      {
        'autho': 'Visual',
        'dir': [4]
      }, // → Follow-Up
      {
        'autho': 'Follow-Up',
        'dir': [5, 6, 7]
      }, // → Painting/Dispatch/Galvanization
      {
        'autho': 'Painting',
        'dir': [6]
      }, // → Dispatch
      {'autho': 'Dispatch', 'dir': []}, // end
      {
        'autho': 'Galvanization',
        'dir': [5, 6]
      }, // → Painting/Dispatch
      {
        'autho': 'Cutting',
        'dir': [3]
      }, // index 8
    ];
  }
  return authos;
}
