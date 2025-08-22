abstract class HttpErrorConnection implements Exception {
  final int status;
  final String message;
  final String? description;

  HttpErrorConnection({required this.status, required this.message, this.description});

  @override
  String toString() {
    return "Error $status, $message, $description";
  }
}

class UnauthorizedException extends HttpErrorConnection {
  UnauthorizedException({required super.status, required super.message, super.description});
}

class UnprocessableEntityException extends HttpErrorConnection {
  UnprocessableEntityException({required super.status, required super.message, super.description});
}

class ServerErrorException extends HttpErrorConnection {
  ServerErrorException({required super.status, required super.message, super.description});
}

class MaintenanceException extends HttpErrorConnection {
  MaintenanceException({required super.status, required super.message, super.description});
}

class TimeoutException extends HttpErrorConnection {
  TimeoutException({required super.status, required super.message, super.description});
}

class ComingsoonException extends HttpErrorConnection {
  ComingsoonException({required super.status, required super.message, super.description});
}

class CrashException extends HttpErrorConnection {
  CrashException({required super.status, required super.message, super.description});
}

class EmptyStateException extends HttpErrorConnection {
  EmptyStateException({required super.status, required super.message, super.description});
}

class AccountBlockedException extends HttpErrorConnection {
  AccountBlockedException({required super.status, required super.message, super.description});
}

class TooManyRequestException extends HttpErrorConnection {
  TooManyRequestException({required super.status, required super.message, super.description});
}

class BadRequestException extends HttpErrorConnection {
  BadRequestException({required super.status, required super.message, super.description});
}

class NetworkException extends HttpErrorConnection {
  NetworkException({required super.status, required super.message, super.description});
}

class UnknownException extends HttpErrorConnection {
  UnknownException({required super.status, required super.message, super.description});
}