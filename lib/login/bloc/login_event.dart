

import 'package:flutter/material.dart';

@immutable
abstract class LoginEvent{}

class LoginPageLoaded extends LoginEvent {}

class LoginButtonPressed extends LoginEvent {}