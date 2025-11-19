enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

class LoginState {
  final bool isRememberMeChecked;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    this.isRememberMeChecked = false,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isRememberMeChecked,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      isRememberMeChecked: isRememberMeChecked ?? this.isRememberMeChecked,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
