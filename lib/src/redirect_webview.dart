import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Internal key used to indicate an error occurred in the WebView.
const String kWebpayErrorKey = '_webpay_error';
const String kWebpayErrorCodeKey = '_webpay_error_code';
const String kWebpayErrorMessageKey = '_webpay_error_message';

/// WebView page that handles the Interswitch redirect checkout flow.
///
/// Loads an HTML form that POSTs to Interswitch, then intercepts the
/// redirect back to [siteRedirectUrl] to capture the payment response.
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final webViewController = WebViewController.fromPlatformCreationParams(
      params,
    );

    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            // Only handle main frame errors (not sub-resources like images/scripts)
            if (error.isForMainFrame == true && mounted) {
              Navigator.pop(context, {
                kWebpayErrorKey: true,
                kWebpayErrorCodeKey: error.errorCode,
                kWebpayErrorMessageKey: error.description,
              });
            }
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith(widget.siteRedirectUrl)) {
              final uri = Uri.parse(request.url);
              final params = Map<String, dynamic>.from(uri.queryParameters);
              if (mounted) {
                Navigator.pop(context, params);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(widget.html);

    if (webViewController.platform is AndroidWebViewController) {
      (webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = webViewController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Make Payment')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator.adaptive(),
                    SizedBox(height: 16),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
