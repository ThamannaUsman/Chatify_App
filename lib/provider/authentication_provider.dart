import 'package:chatify_app/services/database_service.dart';
import 'package:chatify_app/services/navigation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../models/chat_user.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

   late ChatUser user;

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    _auth.authStateChanges().listen((_user){
      if(_user !=null){
      _databaseService.updateUserLatSeenTime(_user.uid);
      _databaseService.getUser(_user.uid).then((_snapshot){
        Map<String,dynamic> _userData=_snapshot.data()! as  Map<String,dynamic>;
        user=ChatUser.fromJson({
          'uid':_user.uid,
          'name':_userData['name'],
          'email': _userData['email'],
          'last_active': _userData['last_active'],
          'image': _userData['image'],

        });
        _navigationService.removeAndNavigateToRoute('/home');
      });
      }else{

        _navigationService.removeAndNavigateToRoute('/login');
      }
    });
  }

  Future<void> loginUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } on FirebaseAuthException {
      print('Error logging user into Firebase');
    } catch (e) {
      print(e);
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(
      String _email, String _password) async {
    try {
      UserCredential _credential=
      await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      return _credential.user!.uid;
    } on FirebaseAuthException {
      print('Error registering user ');
    } catch (e) {
      print(e);
    }
  }
  Future<void> logout()async{
    try {
      await _auth.signOut();
    }  catch (e) {
      print(e);
    }
  }
}
