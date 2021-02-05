import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firestore = Firestore.instance;
final storageRef = FirebaseStorage.instance.ref();
final storageImagesRef = FirebaseStorage.instance.ref().child('images');
final usersRef = _firestore.collection('users');
final postsRef = _firestore.collection('posts');
final followersRef = _firestore.collection('followers');
final followingRef = _firestore.collection('following');
final feedsRef = _firestore.collection('feeds');
final likesRef = _firestore.collection('likes');
final commentsRef = _firestore.collection('comments');
final activitiesRef = _firestore.collection('activities');

ButtonStyle logInSignUpBtnStyle = TextButton.styleFrom(
  textStyle: TextStyle(color: Colors.black, fontSize: 20.0),
  primary: Colors.white,
  backgroundColor: Colors.black,
  side: BorderSide(color: Colors.black, width: 1),
  elevation: 20,
  minimumSize: Size(100, 50),
);
