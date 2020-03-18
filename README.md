# flutter\_native\_logan


这个项目是[Logan](https://flutter.dev/developing-packages/) Flutter版本，通过ffi的方式直接调用logan动态库


### 引用方式

```

flutter_native_logan
	git:
		url: https://github.com/fishCoder/flutter_native_logan.git
		ref: master


```

### 初始化

```

 LoganResult result = await FlutterNativeLogan.init(
        '0123456789012345', '0123456789012345', 1024 * 1024 * 10);


```

###  写日志

```

FlutterNativeLogan.log(10, 'this is log string ${DateTime.now().toString()}');

```

### 获取某天的日志文件路径

```
// 日期格式 yyyy-MM-dd
LoganResult result = await FlutterNativeLogan.getUploadPath(date);

```

### 上传服务器

```
// 日期格式 yyyy-MM-dd

  final LoganResult result = await FlutterNativeLogan.upload(
        'http://127.0.0.1:8080/logan/upload',
        date,
        'FlutterTestAppId',
        'FlutterTestUnionId',
        'FlutterTestDeviceId'
    );

```