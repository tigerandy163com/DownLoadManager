//
//  DownloadCell.m


#import "DownloadCell.h"

#import "FilesDownManage.h"
#import "DownloadViewController.h"
@implementation DownloadCell
@synthesize fileInfo;
@synthesize progress1;
@synthesize fileName;
@synthesize fileCurrentSize;
@synthesize fileSize;
@synthesize timelable;
@synthesize operateButton;
@synthesize request;
@synthesize averagebandLab;
@synthesize sizeinfoLab;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)dealloc
{
    [request release];
    [operateButton release];
    [fileName release];
    [fileCurrentSize release];
    [fileSize release];
    [progress1 release];
    [fileInfo release];
    [timelable release];
    [averagebandLab release];
    [sizeinfoLab release];
    [_fileImage release];
    [_fileTypeLab release];
    [_typeImage release];
    [super dealloc];
}

- (IBAction)deleteRquest:(id)sender {
    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
    [filedownmanage deleteRequest:request];
       if ([self.delegate respondsToSelector:@selector(ReloadDownLoadingTable)]) 
    [((DownloadViewController*)self.delegate) ReloadDownLoadingTable];
}

-(IBAction)operateTask:(id)sender
{

    FileModel *downFile=self.fileInfo;
    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
    if(downFile.isDownloading)//文件正在下载，点击之后暂停下载 有可能进入等待状态
    {
        [operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-开始按钮.png"] forState:UIControlStateNormal];
        [filedownmanage stopRequest:request];
    }
    else
    {
            [operateButton setBackgroundImage:[UIImage imageNamed:@"下载管理-暂停按钮.png"] forState:UIControlStateNormal];
            if (downFile.post) {
            }else
                [filedownmanage resumeRequest:request];
    }
    //暂停意味着这个Cell里的ASIHttprequest已被释放，要及时更新table的数据，使最新的ASIHttpreqst控制Cell
    if ([self.delegate respondsToSelector:@selector(ReloadDownLoadingTable)]) {
           [((DownloadViewController*)self.delegate) ReloadDownLoadingTable];
    }
}
@end
