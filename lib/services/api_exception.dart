class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class RateLimitException extends ApiException {
  final int? retryAfterSeconds;

  RateLimitException({
    super.message =
        'Market data rate limit reached (HTTP 429). Please wait a moment before trying again.',
    this.retryAfterSeconds,
  }) : super(statusCode: 429);
}

class NetworkException extends ApiException {
  NetworkException({
    super.message =
        'Unable to connect to crypto market servers. Please check your internet connection.',
  });
}

class NotFoundException extends ApiException {
  NotFoundException({
    super.message = 'Requested crypto asset or resource was not found.',
  }) : super(statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({
    super.message =
        'Cryptocurrency data server error. Please try again later.',
    super.statusCode,
  });
}
