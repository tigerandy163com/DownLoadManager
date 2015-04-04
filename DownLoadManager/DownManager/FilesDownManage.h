//
//  FilesDownManage.h
//  Created by yu on 13-1-21.


#import <Foundation/Foundation.h>

#import "CommonHelper.h"
#import "DownloadDelegate.h"
#import "FileModel.h"
#import "MidHttpRequest.h"
extern NSInteger  maxcount;

@interface FilesDownManage : NSObject<MidHttpRequestDelegate>
{
    NSInteger type;
    int count;
    
}
@property int count;
@property(nonatomic,assign)id<DownloadDelegate> VCdelegate;//获得下载事件的vc，用在比如多选图片后批量下载的情况，这时需配合 allowNextRequest 协议方法使用
@property(nonatomic,assign)id<DownloadDelegate> downloadDelegate;//下载列表delegate

@property(nonatomic,strong)NSString *basepath;
@property(nonatomic,strong)NSString *TargetSubPath;
@property(nonatomic,strong)NSMutableArray *finishedlist;//已下载完成的文件列表（文件对象）

@property(nonatomic,strong)NSMutableArray *downinglist;//正在下载的文件列表(ASIHttpRequest对象)
@property(nonatomic,strong)NSMutableArray *filelist;
@property(nonatomic,strong)NSMutableArray *targetPathArray;

@property(nonatomic,strong)FileModel *fileInfo;
@property(nonatomic)BOOL isFistLoadSound;//是否第一次加载声音，静音


+(FilesDownManage *) sharedFilesDownManage;
//＊＊＊第一次＊＊＊初始化是使用，设置缓存文件夹和已下载文件夹，构建下载列表和已下载文件列表时使用
+(FilesDownManage *) sharedFilesDownManageWithBasepath:(NSString *)basepath
                                         TargetPathArr:(NSArray *)targetpaths;

-(void)clearAllRquests;
-(void)clearAllFinished;
-(void)resumeRequest:(MidHttpRequest *)request;
-(void)deleteRequest:(MidHttpRequest *)request;
-(void)stopRequest:(MidHttpRequest *)request;
-(void)saveFinishedFile;
-(void)deleteFinishFile:(FileModel *)selectFile;
-(void)downFileUrl:(NSString*)url
          filename:(NSString*)name
        filetarget:(NSString *)path
         fileimage:(UIImage *)image
         ;
-(void)startLoad;
-(void)restartAllRquests;

@end


