library flutter_recaptcha_v2_compat_compat;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class RecaptchaV2 extends StatefulWidget {
  final String apiKey;
  final String apiSecret;
  final String pluginURL;
  final RecaptchaV2Controller controller;

  final ValueChanged<bool>? onVerifiedSuccessfully;
  final ValueChanged<String>? onVerifiedError;

  final EdgeInsetsGeometry? padding;

  RecaptchaV2({
    required this.apiKey,
    required this.apiSecret,
    required this.controller,
    required this.pluginURL,
    this.onVerifiedSuccessfully,
    this.onVerifiedError,
    this.padding,
  });

  @override
  State<StatefulWidget> createState() => _RecaptchaV2State();
}

class _RecaptchaV2State extends State<RecaptchaV2>
    with TickerProviderStateMixin {
  late RecaptchaV2Controller controller;
  late WebViewController webViewController;

  void verifyToken(String token) async {
    String url = "https://www.google.com/recaptcha/api/siteverify";
    http.Response response = await http.post(Uri.parse(url), body: {
      "secret": widget.apiSecret,
      "response": token,
    });

    // print("Response status: ${response.statusCode}");
    // print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      dynamic json = jsonDecode(response.body);
      if (json['success']) {
        widget.onVerifiedSuccessfully?.call(true);
      } else {
        widget.onVerifiedSuccessfully?.call(false);
        widget.onVerifiedError?.call(json['error-codes'].toString());
      }
    }
  }

  void _reload() {
    webViewController.clearCache();
    webViewController.reload();
  }

  @override
  void initState() {
    controller = widget.controller;
    controller.onReload = _reload;
    super.initState();
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'RecaptchaFlutterChannel',
        onMessageReceived: (JavaScriptMessage receiver) {
          String _token = receiver.message;
          if (_token.contains("verify")) {
            _token = _token.substring(7);
          }
          verifyToken(_token);
        },
      )
      ..loadRequest(Uri.parse("${widget.pluginURL}?api_key=${widget.apiKey}"));
  }

  @override
  void didUpdateWidget(RecaptchaV2 oldWidget) {
    if (widget.controller != oldWidget.controller) {
      controller = widget.controller;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller.onReload = null;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
      child: WebViewWidget(controller: webViewController),
    );
  }
}

class RecaptchaV2Controller extends ChangeNotifier {
  bool isDisposed = false;
  VoidCallback? onReload;

  void reload() {
    if (!isDisposed) onReload?.call();
  }

  @override
  void dispose() {
    isDisposed = true;
    onReload = null;
    super.dispose();
  }
}
