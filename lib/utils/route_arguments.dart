class RouteArguments {
  static final RouteArguments _instance = RouteArguments._internal();
  factory RouteArguments() => _instance;
  RouteArguments._internal();

  final Map<String, dynamic> _arguments = {};
  final Map<String, String> _queryParameters = {};

  void setArguments(Map<String, dynamic>? args) {
    _arguments.clear();
    if (args != null) {
      _arguments.addAll(args);
    }
  }

  void setQueryParameters(Map<String, String>? params) {
    _queryParameters.clear();
    if (params != null) {
      _queryParameters.addAll(params);
    }
  }

  Map<String, dynamic> get arguments => Map.from(_arguments);

  Map<String, String> get queryParameters => Map.from(_queryParameters);

  dynamic operator [](String key) => _arguments[key] ?? _queryParameters[key];

  void operator []=(String key, dynamic value) {
    _arguments[key] = value;
  }

  void clear() {
    _arguments.clear();
    _queryParameters.clear();
  }
}

final routeArguments = RouteArguments();
