
import 'package:asia_bazar_seller/blocs/global_bloc/state.dart';
import 'package:asia_bazar_seller/models/user.dart';
import 'package:flutter/foundation.dart';

abstract class AuthenticationState extends GlobalState {}

class UnAuthenticatedState extends AuthenticationState {}

class OtpVerificationState extends AuthenticationState {}

class AuthenticatedState extends AuthenticationState {
  final User user;
  AuthenticatedState({@required this.user});
}

class FetchingState extends AuthenticationState {}
class OtpSentState extends AuthenticationState{}