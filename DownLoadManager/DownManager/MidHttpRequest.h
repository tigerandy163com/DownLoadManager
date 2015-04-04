//
//  MidHttpRequest.h
//  DownLoadManager
//
//  Created by chunyu on 15/4/4.
//  Copyright (c) 2015年 11 111. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MidHttpRequest;
@protocol MidHttpRequestDelegate <NSObject>

-(void)requestFailed:(MidHttpRequest *)request;
-(void)requestStarted:(MidHttpRequest *)request;
-(void)request:(MidHttpRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders;
-(void)request:(MidHttpRequest *)request didReceiveBytes:(long long)bytes;
-(void)requestFinished:(MidHttpRequest *)request;
- (void)request:(MidHttpRequest *)request willRedirectToURL:(NSURL *)newURL;
@end

@interface MidHttpRequest : NSObject
@property (assign, nonatomic) id<MidHttpRequestDelegate> delegate;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *originalURL;

@property (strong, nonatomic) NSDictionary *userInfo;
@property (assign, nonatomic) NSInteger tag;
@property (strong, nonatomic) NSString *downloadDestinationPath;
@property (strong, nonatomic) NSString *temporaryFileDownloadPath;
@property (strong,readonly,nonatomic) NSError *error;
- (instancetype)initWithURL:(NSURL*)url;
- (void)startAsynchronous;
- (BOOL)isFinished;
- (BOOL)isExecuting;
- (void)cancel;
@end
