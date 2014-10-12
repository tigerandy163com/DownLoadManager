

#import "FileModel.h"


@implementation FileModel
@synthesize fileID;
@synthesize fileName;
@synthesize fileSize;
@synthesize fileType;
@synthesize isFirstReceived;
@synthesize fileReceivedData;
@synthesize fileReceivedSize;
@synthesize fileURL;
@synthesize targetPath;
@synthesize tempPath;

@synthesize error;
@synthesize time;
@synthesize MD5,fileimage;

-(id)init{
    self = [super init];
    
    return self;
}
-(void)dealloc{
    [fileID release];
    [fileName release];
    [fileSize release];
    [fileReceivedData release];
    [fileURL release];
    [time release];
    [targetPath release];
    [tempPath release];
    [fileType release];
    [MD5 release];
    [fileimage release];
    [super dealloc];
}
@end
