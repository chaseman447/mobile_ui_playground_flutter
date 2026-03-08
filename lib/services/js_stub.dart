// Stub implementation for mobile platforms
// This provides the same interface as dart:js but does nothing

class JsObject {
  static dynamic jsify(dynamic object) => object;
}

class JsContext {
  bool hasProperty(String property) => false;
  dynamic callMethod(String method, [List? args]) => null;
  dynamic operator [](String key) => null;
}

final context = JsContext();

dynamic allowInterop(dynamic function) => function;
