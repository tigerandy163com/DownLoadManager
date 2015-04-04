
#import <Foundation/Foundation.h>
typedef enum {
		Downloading,//下载中
		WillDownload,//等待下载
		StopDownload//停止下载
}DownLoadState;
@interface FileModel : NSObject {
    
}

@property(nonatomic,strong)NSString *fileID;
@property(nonatomic,strong)NSString *fileName;
@property(nonatomic,strong)NSString *fileSize;
@property(nonatomic,strong)NSString *fileType;
// 0:@"Video" ;1:@"Audio";2:@"Image";3:@"File"4:Record

@property(nonatomic,assign)BOOL isFirstReceived;//是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加
@property(nonatomic,strong)NSString *fileReceivedSize;
@property(nonatomic,strong)NSMutableData *fileReceivedData;//接受的数据
@property(nonatomic,strong)NSString *fileURL;
@property(nonatomic,strong)NSString *time;
@property(nonatomic,strong)NSString *targetPath;
@property(nonatomic,strong)NSString *tempPath;
/*下载状态的逻辑是这样的：三种状态，下载中，等待下载，停止下载

当超过最大下载数时，继续添加的下载会进入等待状态，当同时下载数少于最大限制时会自动开始下载等待状态的任务。
可以主动切换下载状态
所有任务以添加时间排序。
*/
@property DownLoadState downloadState;
@property(nonatomic, assign)BOOL error;
@property(nonatomic,strong)NSString *MD5;
@property(nonatomic,strong)UIImage *fileimage;

@end
