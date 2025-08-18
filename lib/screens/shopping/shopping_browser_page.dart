import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart'; // Temporarily disabled

class ShoppingBrowserPage extends StatefulWidget {
  final String url;

  const ShoppingBrowserPage({Key? key, required this.url}) : super(key: key);

  @override
  State<ShoppingBrowserPage> createState() => _ShoppingBrowserPageState();
}

class _ShoppingBrowserPageState extends State<ShoppingBrowserPage> {
  // late final WebViewController _controller; // Temporarily disabled

  @override
  void initState() {
    super.initState();
    // _controller = WebViewController() // Temporarily disabled
    //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shop View")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              "Shopping Browser",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text("URL: ${widget.url}"),
            SizedBox(height: 16),
            Text(
              "WebView temporarily disabled\nfor testing core features",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
