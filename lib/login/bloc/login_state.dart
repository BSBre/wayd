

import 'package:flutter/cupertino.dart';

@immutable
abstract class LoginState {}

class LoginLoading extends LoginState {}

class LoginLoaded extends LoginState {}

class LoginNotLoaded extends LoginState {}
