import 'package:equatable/equatable.dart';

abstract class LlmFailure extends Equatable {
  const LlmFailure();

  @override
  List<Object> get props => [];
}

class LlmNetworkFailure extends LlmFailure {
  final String message;
  final int? statusCode;

  const LlmNetworkFailure({required this.message, this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];

  @override
  String toString() =>
      'LlmNetworkFailure(message: $message, statusCode: $statusCode)';
}

class LlmParsingFailure extends LlmFailure {
  final String message;

  const LlmParsingFailure({required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'LlmParsingFailure(message: $message)';
}

class LlmAuthenticationFailure extends LlmFailure {
  final String message;

  const LlmAuthenticationFailure({required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'LlmAuthenticationFailure(message: $message)';
}

class LlmUnknownFailure extends LlmFailure {
  final String message;

  const LlmUnknownFailure({required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => 'LlmUnknownFailure(message: $message)';
}
