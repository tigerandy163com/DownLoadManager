//
//  DownloadDelegate.h


#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol DownloadDelegate <NSObject>

-(void)startDownload:(ASIHTTPRequest *)request;
-(void)updateCellProgress:(ASIHTTPRequest *)request;
-(void)finishedDownload:(ASIHTTPRequest *)request;
-(void)allowNextRequest;//处理一个窗口内连续下载多个文件且重复下载的情况
@end
