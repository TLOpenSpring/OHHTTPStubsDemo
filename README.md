# OHHTTPStubsDemo
OHHTTPStubs 模拟服务器框架的例子

[OHHTTPStubs](https://github.com/AliSoftware/OHHTTPStubs)是一个模拟网络请求的一个框架，它使用起来非常方便和强大，它能帮你

1. 测试你的app仿真一个服务器（比如加载一个本地文件）,模拟网络慢的情况等
2. 使用伪造的网络数据编写单元测试


##简单用法

##在Objc中

```
[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
  return [request.URL.host isEqualToString:@"mywebservice.com"];
} withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
  // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
  NSString* fixture = OHPathForFile(@"wsresponse.json", self.class);
  return [OHHTTPStubsResponse responseWithFileAtPath:fixture
            statusCode:200 headers:@{@"Content-Type":@"application/json"}];
}];
```

##在swift中

```
stub(isHost("mywebservice.com")) { _ in
  // Stub it with our "wsresponse.json" stub file (which is in same bundle as self)
  let stubPath = OHPathForFile("wsresponse.json", self.dynamicType)
  return fixture(stubPath!, headers: ["Content-Type":"application/json"])
}
```