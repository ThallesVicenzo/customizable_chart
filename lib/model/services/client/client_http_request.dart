class ClientHttpRequest<T> {
  final T? data;
  final int? statusCode;
  final String? statusMessage;

  ClientHttpRequest({this.data, this.statusCode, this.statusMessage});

  @override
  String toString() {
    return 'ClientHttpResponse(statusCode: $statusCode, \n'
        'statusMessage: $statusMessage, \n'
        'data: ${data.toString()}) \n';
  }

  bool get isStatusCodeSuccess {
    if (statusCode == null) {
      return false;
    } else {
      return statusCode! >= 200 && statusCode! < 300;
    }
  }
}
