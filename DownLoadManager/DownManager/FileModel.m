

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
@end
