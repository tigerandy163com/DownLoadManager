//
//  DownloadDelegate.h


#import <Foundation/Foundation.h>
#import "MidHttpRequest.h"

@protocol DownloadDelegate <NSObject>

-(void)startDownload:(MidHttpRequest *)request;
-(void)updateCellProgress:(MidHttpRequest *)request;
-(void)finishedDownload:(MidHttpRequest *)request;
-(void)allowNextRequest;//处理一个窗口内连续下载多个文件且重复下载的情况
@end
