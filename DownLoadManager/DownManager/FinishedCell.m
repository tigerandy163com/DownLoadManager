//
//  FinishedCell.m


#import "FinishedCell.h"
#import "FilesDownManage.h"
#import "DownloadViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation FinishedCell

@synthesize fileInfo;
@synthesize  fileImage,fileName,fileSize,fileTypeLab,timelable;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)deleteFile:(id)sender{
    [[FilesDownManage sharedFilesDownManage]  deleteFinishFile:fileInfo];
    if ([self.delegate respondsToSelector:@selector(deleteFinishedFile:)]) {
        [(DownloadViewController*)self.delegate deleteFinishedFile:fileInfo];
    }
    
}

- (IBAction)openFile:(UIButton *)sender {

}
- (void)dealloc
{
    
    [fileInfo release];
    [fileSize release];
    [fileTypeLab release];
    [fileImage release];
    [timelable release];
    [fileName release];
    [super dealloc];
}
@end
