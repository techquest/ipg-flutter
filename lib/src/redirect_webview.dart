import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class RedirectWebViewPage extends StatefulWidget {
  final String html;
  final String siteRedirectUrl;

  const RedirectWebViewPage({
    super.key,
    required this.html,
    required this.siteRedirectUrl,
  });

  @override
  State<RedirectWebViewPage> createState() => _RedirectWebViewPageState();
}

class _RedirectWebViewPageState extends State<RedirectWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final redirectUri = Uri.parse(widget.siteRedirectUrl);

    developer.log("Loaded redirect URI: $redirectUri");

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            developer.log('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            developer.log('Page started loading: $url');
          },
          onPageFinished: (String url) {
            developer.log('Page finished loading: $url');
          },
          onWebResourceError: (error) {
            developer.log('''
                Page resource error:
                  code: ${error.errorCode}
                  description: ${error.description}
                  errorType: ${error.errorType}
                  isForMainFrame: ${error.isForMainFrame}
              ''');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Failed to load payment page: ${error.description}',
                  ),
                ),
              );
            }
          },
          onNavigationRequest: (request) {
            final currentUri = Uri.parse(request.url);
            if (request.url.startsWith(widget.siteRedirectUrl)) {
              final params = Map<String, dynamic>.from(
                currentUri.queryParameters,
              );
              params['returnUrl'] = request.url;
              developer.log('Redirected to: ${request.url}');
              developer.log('Params: $params');
              if (mounted) {
                Navigator.pop(context, params);
              }
              return NavigationDecision.prevent;
            }
            developer.log('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onHttpError: (error) {
            developer.log(
              'HTTP error occurred on page: status code (${error.response?.statusCode}) - ${error.response}',
            );
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('HTTP error: $error')));
            }
          },
          onUrlChange: (UrlChange change) {
            developer.log('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          developer.log('JavaScript message received: ${message.message}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message.message)));
        },
      )
      ..loadHtmlString(widget.html);

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redirect Checkout')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
