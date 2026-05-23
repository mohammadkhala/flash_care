class Content {
  Content({
    String? id,
    String? object,
    int? created,
    String? model,
    List<Choices>? choices,
    Usage? usage,
    ContentError? error,
    String? systemFingerprint,
  }) {
    _id = id;
    _object = object;
    _created = created;
    _model = model;
    _choices = choices;
    _usage = usage;
    _error = error;
    _systemFingerprint = systemFingerprint;
  }

  Content.fromJson(dynamic json) {
    _id = json['id'];
    _object = json['object'];
    _created = json['created'];
    _model = json['model'];
    if (json['choices'] != null) {
      _choices = [];
      json['choices'].forEach((v) {
        _choices?.add(Choices.fromJson(v));
      });
    }
    _usage = json['usage'] != null ? Usage.fromJson(json['usage']) : null;
    _error =
        json['error'] != null ? ContentError.fromJson(json['error']) : null;
    _systemFingerprint = json['system_fingerprint'];
  }

  String? _id;
  String? _object;
  int? _created;
  String? _model;
  List<Choices>? _choices;
  Usage? _usage;
  ContentError? _error;
  String? _systemFingerprint;

  String? get id => _id;

  String? get object => _object;

  int? get created => _created;

  String? get model => _model;

  List<Choices>? get choices => _choices;

  Usage? get usage => _usage;

  ContentError? get error => _error;

  String? get systemFingerprint => _systemFingerprint;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['object'] = _object;
    map['created'] = _created;
    map['model'] = _model;
    if (_choices != null) {
      map['choices'] = _choices?.map((v) => v.toJson()).toList();
    }
    if (_usage != null) {
      map['usage'] = _usage?.toJson();
    }
    if (_error != null) {
      map['error'] = _error?.toJson();
    }
    map['system_fingerprint'] = _systemFingerprint;
    return map;
  }
}

class Usage {
  Usage({
    int? promptTokens,
    int? completionTokens,
    int? totalTokens,
  }) {
    _promptTokens = promptTokens;
    _completionTokens = completionTokens;
    _totalTokens = totalTokens;
  }

  Usage.fromJson(dynamic json) {
    _promptTokens = json['prompt_tokens'];
    _completionTokens = json['completion_tokens'];
    _totalTokens = json['total_tokens'];
  }

  int? _promptTokens;
  int? _completionTokens;
  int? _totalTokens;

  int? get promptTokens => _promptTokens;

  int? get completionTokens => _completionTokens;

  int? get totalTokens => _totalTokens;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['prompt_tokens'] = _promptTokens;
    map['completion_tokens'] = _completionTokens;
    map['total_tokens'] = _totalTokens;
    return map;
  }
}

class Choices {
  Choices({
    int? index,
    Message? message,
    dynamic logprobs,
    String? finishReason,
  }) {
    _index = index;
    _message = message;
    _logprobs = logprobs;
    _finishReason = finishReason;
  }

  Choices.fromJson(dynamic json) {
    _index = json['index'];
    _message =
        json['message'] != null ? Message.fromJson(json['message']) : null;
    _logprobs = json['logprobs'];
    _finishReason = json['finish_reason'];
  }

  int? _index;
  Message? _message;
  dynamic _logprobs;
  String? _finishReason;

  int? get index => _index;

  Message? get message => _message;

  dynamic get logprobs => _logprobs;

  String? get finishReason => _finishReason;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['index'] = _index;
    if (_message != null) {
      map['message'] = _message?.toJson();
    }
    map['logprobs'] = _logprobs;
    map['finish_reason'] = _finishReason;
    return map;
  }
}

class Message {
  Message({
    String? role,
    String? content,
    dynamic refusal,
  }) {
    _role = role;
    _content = content;
    _refusal = refusal;
  }

  Message.fromJson(dynamic json) {
    _role = json['role'];
    _content = json['content'];
    _refusal = json['refusal'];
  }

  String? _role;
  String? _content;
  dynamic _refusal;

  String? get role => _role;

  String? get content => _content;

  dynamic get refusal => _refusal;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['role'] = _role;
    map['content'] = _content;
    map['refusal'] = _refusal;
    return map;
  }
}

class ContentError {
  ContentError({
    String? message,
    String? type,
    dynamic param,
    String? code,
  }) {
    _message = message;
    _type = type;
    _param = param;
    _code = code;
  }

  ContentError.fromJson(dynamic json) {
    _message = json['message'];
    _type = json['type'];
    _param = json['param'];
    _code = json['code'];
  }

  String? _message;
  String? _type;
  dynamic _param;
  String? _code;

  String? get message => _message;

  String? get type => _type;

  dynamic get param => _param;

  String? get code => _code;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = _message;
    map['type'] = _type;
    map['param'] = _param;
    map['code'] = _code;
    return map;
  }
}
