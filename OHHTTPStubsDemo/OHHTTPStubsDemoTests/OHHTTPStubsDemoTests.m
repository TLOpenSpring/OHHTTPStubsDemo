//
//  OHHTTPStubsDemoTests.m
//  OHHTTPStubsDemoTests
//
//  Created by Andrew on 16/4/22.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>
@interface OHHTTPStubsDemoTests : XCTestCase
@property (nonatomic,strong) NSURLSession *session;

@end

@implementation OHHTTPStubsDemoTests

- (void)setUp {
    [super setUp];
    
    self.session=[NSURLSession sharedSession];
}

/**
 *  测试文本的Stub任务
 */
-(void)testStubTextTask{
    //创建文本的模拟服务器
    [self createTextStub];
    //创建一个期望值
    XCTestExpectation *expection=[self expectationWithDescription:@"high expection"];
    
    NSURLSession *session=[NSURLSession sharedSession];
    
    NSString *urlString=@"stub.txt";
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString* receivedText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"返回的结果:%@",receivedText);
        
        XCTAssert(receivedText!=nil);
        
        [expection fulfill];
    }];
    
    [dataTask resume];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"出错了:%@",error.description);
        }
    }];
}

/**
 *  创建文本的TextStub
 */
-(void)createTextStub{
    // #1
    static id<OHHTTPStubsDescriptor> textStub = nil;
    
    // #2
    textStub= [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.pathExtension isEqualToString:@"txt"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        
        //文本路径
        NSString *path = OHPathForFile(@"stub.txt",self.class);
        
       //#3
        return [[OHHTTPStubsResponse responseWithFileAtPath:path
                                                 statusCode:200 headers:@{@"Content-Type":@"text/plain"}]
                requestTime:1.0f
                responseTime:OHHTTPStubsDownloadSpeedWifi];
        
    }];
    //#4
    textStub.name = @"text stub";
}

/**
 *  创建Image的stub
 */
-(void)createImageStub{
    static id<OHHTTPStubsDescriptor> imageStub = nil;
    
    imageStub=[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return [request.URL.pathExtension isEqualToString:@"png"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFile(@"stub.jpg", self.class) statusCode:200 headers:@{@"Content-Type":@"image/jpeg"}];
    }];
    
    imageStub.name=@"Image stub";
}
/**
 *  测试Image的模拟服务器
 */
- (void)testImageStubTask{
    
    [self createImageStub];
    
    XCTestExpectation *expection=[self expectationWithDescription:@"Image Expection"];
    
    NSURLSessionDataTask *dataStask=[self.session dataTaskWithURL:[NSURL URLWithString:@"test.png" relativeToURL:nil] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        UIImage *image=[UIImage imageWithData:data];
        
        NSLog(@"返回的image:%@",image.description);
        
        XCTAssert(image!=nil);
        
        [expection fulfill];
        
    }];
    
    [dataStask resume];
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"出错了:%@",error.description);
        }
    }];
    
}

-(void)testSessionDataTask{
    NSString* urlString = @"http://www.opensource.apple.com/source/Git/Git-26/src/git-htmldocs/git-commit.txt?txt";

    //创建一个期望值
    XCTestExpectation *expection=[self expectationWithDescription:@"high expection"];
    
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
       NSString* receivedText = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"返回的结果:%@",receivedText);
        
        XCTAssert(receivedText!=nil);
        
        [expection fulfill];
    }];
    
    [dataTask resume];
    
    [self waitForExpectationsWithTimeout:0.1 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"出错了:%@",error.description);
        }
    }];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    
    [OHHTTPStubs removeAllStubs];
    [super tearDown];
}

/**
 *  返回自定义的普通文本
 */
- (void)testExample {
    
    //开始模拟服务器
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        //发送请求的url后缀必须是.com结尾的
        return [request.URL.pathExtension isEqualToString:@"com"];
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        //创建一个字符串
        NSData * stubData = [@"hello world" dataUsingEncoding:NSUTF8StringEncoding];
        //响应数据
        /**
         *  responseWithData:返回的数据
            statusCode:状态码,200表示成功
            headers:http的header
         */
        return [OHHTTPStubsResponse responseWithData:stubData statusCode:200 headers:@{@"Content-Type":@"text/plain"}];
    }];
    
    
    //在XCT测试框架中，这个表示期望值，因为这个期望值是支持异步测试的，我们是异步请求，所以一定要是使用XCTestExpectation这个特性
     XCTestExpectation *expectation=[self expectationWithDescription:@"sessionDataTask expectation"];
    
    //创建session任务
    NSURLSessionDataTask *dataTask=[self.session dataTaskWithURL:[NSURL URLWithString:@"hello.com"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //解析返回的字符串
        NSString *resultStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"返回的数据:%@",resultStr);
        
        XCTAssert(resultStr!=nil);
        
        //断言返回的字符串是hello world,如果不是，则断言失败
        XCTAssertTrue([resultStr isEqualToString:@"hello world"]);
        
        //在想异步测试的地方加上下面这行代码
        [expectation fulfill];
    }];
    //启动任务
    [dataTask resume];
    
    
    //使用XCTestExpectation,必须设置如下的waitForExpectationsWithTimeout方法，如果超时则失败
    [self waitForExpectationsWithTimeout:4 handler:^(NSError * _Nullable error) {
        if(error){
            NSLog(@"出错了:%s",__FUNCTION__);
        }
    }];
   
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
