import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void showSnackBarMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
}

void httpErrorHandle({
  required http.Response response,
  required Function onSuccess,
  required Function(String) onError,
}) {
  switch (response.statusCode) {
    case 200:
      onSuccess();
      break;
    case 400:
      onError(jsonDecode(response.body)['msg']);
      break;
    case 500:
      onError(jsonDecode(response.body)['error']);
      break;
    default:
      onError(response.body);
  }
}
