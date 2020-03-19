import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_native_logan/flutter_native_logan.dart';
import 'package:flutter_native_logan/result.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _showText = 'you should init log first';

  @override
  initState() {
    initLog();
    super.initState();
  }

  Future<void> initLog() async {
    LoganResult result = await FlutterNativeLogan.init(
        '0123456789012345', '0123456789012345', 1024 * 1024 * 10);
    if (!mounted) return;
    setState(() {
      _showText = result.message;
    });
  }

  Future<void> log() async {
    String result = 'Write log succeed';
    try {
      await FlutterNativeLogan.log(10, 'this is log string ${DateTime.now().toString()}');
    } on PlatformException {
      result = 'Failed to write log';
    }
    if (!mounted) return;
    setState(() {
      _showText = result;
    });
  }

  Future<void> getUploadPath() async {
    final today = DateTime.now();
    final date = "${today.year.toString()}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final LoganResult result = await FlutterNativeLogan.getUploadPath(date);
    if (!mounted) return;
    setState(() {
      _showText = result.success ? result.data : result.message;
    });
  }

  Future<void> flush() async {
    String result = 'Flush log succeed';
    try {
      await FlutterNativeLogan.flush();
    } on PlatformException {
      result = 'Failed to flush log';
    }
    if (!mounted) return;
    setState(() {
      _showText = result;
    });
  }

  Future<void> cleanAllLog() async {
    String result = 'Clean log succeed';
    try {
      await FlutterNativeLogan.cleanAllLogs();
    } on PlatformException {
      result = 'Failed to clean log';
    }
    if (!mounted) return;
    setState(() {
      _showText = result;
    });
  }

  Future<void> uploadToServer() async {
    final today = DateTime.now();
    final date = "${today.year.toString()}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final LoganResult result = await FlutterNativeLogan.upload(
        'http://192.168.100.111:8080/api/logan/native',
        date,
        'FlutterTestAppId',
        'FlutterTestUnionId',
        'FlutterTestDeviceId'
    );
    if (!mounted) return;
    setState(() {
      _showText = result.success ? '上传成功' : result.message;
    });
  }

  Widget buttonWidge(String title, Function event) {
    Color color = Theme.of(context).primaryColor;
    return new Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new FlatButton(
          onPressed: event,
          child: Text(title),
          color: color,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buttonSection = new Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buttonWidge('flush', flush),
            buttonWidge('cleanAllLog', cleanAllLog),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            buttonWidge('log', log),
            buttonWidge('getUploadUrl', getUploadPath),
            buttonWidge('uploadToServer', uploadToServer),
          ],
        ),
      ],
    );

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              new Container(
                margin: const EdgeInsets.only(top: 30.0),
                child: buttonSection,
              ),
              new Container(
                margin: const EdgeInsets.only(top: 30.0,left: 10,right: 10),
                child: new Text(_showText),
              )
            ],
          )),
    );
  }
}
