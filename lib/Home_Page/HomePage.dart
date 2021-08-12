import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:coquimbofc/Check_Connection/No%20Internet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HomePage extends StatefulWidget {
  final String url;

  HomePage({Key? key, required this.url}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int checkInt = 0;
  late ConnectivityResult previous;








  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blueAccent),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController?.reload();
        } else if (Platform.isIOS) {
          _webViewController?.loadUrl(
              urlRequest: URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );


    Connectivity().onConnectivityChanged.listen((ConnectivityResult connresult){
      if(connresult == ConnectivityResult.none){
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => No_Internet_Connection()), (route) => false );
      }else if(previous == ConnectivityResult.none){
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => No_Internet_Connection()), (route) => false );
      }

      previous = connresult;
    });




  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Do you want to exit Coquimbo FC?',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
       //  content: new Text(''),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(
              'No',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.lightGreenAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text(
              'Yes',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.orange),
            )
          ),
        ],
      ),
    )) ??
        false;
  }

  InAppWebViewController? _webViewController;
  double progress = 0;
  String url = '';

  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
        useOnDownloadStart: true,
      ),
      android: AndroidInAppWebViewOptions(
        initialScale: 100,
        useShouldInterceptRequest: true,
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  final urlController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            child: Column(
              children: [
                // progress < 1.0
                //     ? LinearProgressIndicator(
                //         value: progress,
                //         backgroundColor: Colors.white,
                //         valueColor:
                //             AlwaysStoppedAnimation<Color>(Colors.blueAccent!),
                //       )
                //     : Center(),
                Expanded(
                  child: InAppWebView(
                    key: webViewKey,
                    initialUrlRequest: URLRequest(
                      url: Uri.parse(widget.url),
                      headers: {},
                    ),
                    initialOptions: options,
                    pullToRefreshController: pullToRefreshController,
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                    onLoadStop: (controller, url) async {
                      pullToRefreshController.endRefreshing();
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onLoadError: (controller, url, code, message) {
                      pullToRefreshController.endRefreshing();
                    },
                    onProgressChanged: (controller, progress) {
                      if (progress == 100) {
                        pullToRefreshController.endRefreshing();
                      }
                      setState(() {
                         this.progress = progress / 100;
                        urlController.text = this.url;
                      });
                    },
                    onUpdateVisitedHistory: (controller, url, androidIsReload) {
                      setState(() {
                        this.url = url.toString();
                        urlController.text = this.url;
                      });
                    },
                    onConsoleMessage: (controller, consoleMessage) {
                      print(consoleMessage);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
