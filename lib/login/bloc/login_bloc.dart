
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:waydchatapp/login/bloc/login_event.dart';
import 'package:waydchatapp/login/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginLoading());

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if(event is LoginPageLoaded) {
      yield* _loginPageLoadedToState();
    }
  }

  Stream<LoginState> _loginPageLoadedToState() async* {
    try {
      yield LoginLoaded();
    } catch (error) {
      yield LoginNotLoaded();
    }
  }

}