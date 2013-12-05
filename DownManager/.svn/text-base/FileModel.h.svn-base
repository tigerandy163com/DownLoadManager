
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface FileModel : NSObject {
    
}

@property(nonatomic,retain)NSString *fileID;
@property(nonatomic,retain)NSString *fileName;
@property(nonatomic,retain)NSString *fileSize;
@property(nonatomic,retain)NSString *fileType;
// 0:@"Video" ;1:@"Audio";2:@"Image";3:@"File"4:Record

@property(nonatomic)BOOL isFirstReceived;//是否是第一次接受数据，如果是则不累加第一次返回的数据长度，之后变累加
@property(nonatomic,retain)NSString *fileReceivedSize;
@property(nonatomic,retain)NSMutableData *fileReceivedData;//接受的数据
@property(nonatomic,retain)NSString *fileURL;
@property(nonatomic,retain)NSString *time;
@property(nonatomic,retain)NSString *targetPath;
@property(nonatomic,retain)NSString *tempPath;
@property(nonatomic)BOOL isDownloading;//是否正在下载
@property(nonatomic)BOOL  willDownloading;
@property(nonatomic)BOOL error;
@property(nonatomic)BOOL isP2P;//是否是p2p下载
@property BOOL post;
@property int PostPointer;
@property(nonatomic,retain)NSString *postUrl;
@property (nonatomic,retain)NSString *fileUploadSize;
@property(nonatomic,retain)NSString *usrname;
@property(nonatomic,retain)NSString *MD5;
@property(nonatomic,retain)UIImage *fileimage;

@end
