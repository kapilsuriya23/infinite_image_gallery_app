class AppException implements Exception {
  const AppException(this.message);
  final String message;
  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(
      [super.message = 'No internet connection. Check your network and retry.']);
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class ApiKeyMissingException extends AppException {
  const ApiKeyMissingException()
      : super('Pixabay API key is missing.\n'
            'Add PIXABAY_API_KEY=your_key to the .env file in the project root.');
}

class DownloadException extends AppException {
  const DownloadException(super.message);
}

class PermissionException extends AppException {
  const PermissionException(super.message);
}

String errorMessage(Object e) =>
    e is AppException ? e.message : 'Something went wrong. Please try again.';