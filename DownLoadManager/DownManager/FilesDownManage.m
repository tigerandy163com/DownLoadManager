
//  FilesDownManage.m
//  Created by yu on 13-1-21.
//

#import "FilesDownManage.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"

#define TEMPPATH [CommonHelper getTempFolderPathWithBasepath:_basepath]

@implementation FilesDownManage
@synthesize downinglist=_downinglist;
@synthesize fileInfo = _fileInfo;
@synthesize downloadDelegate=_downloadDelegate;
@synthesize finishedlist=_finishedList;
@synthesize isFistLoadSound=_isFirstLoadSound;
@synthesize basepath = _basepath;
@synthesize filelist = _filelist;
@synthesize targetPathArray = _targetPathArray;
@synthesize VCdelegate = _VCdelegate;
@synthesize count;
static   FilesDownManage *sharedFilesDownManage = nil;
NSInteger  maxcount;

#pragma mark -- init methods --
+ (FilesDownManage *) sharedFilesDownManage{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] init];
        }
    }
    return  sharedFilesDownManage;
}

+ (FilesDownManage *) sharedFilesDownManageWithBasepath:(NSString *)basepath
                                         TargetPathArr:(NSArray *)targetpaths{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] initWithBasepath: basepath  TargetPathArr:targetpaths];
        }
    }
    if (![sharedFilesDownManage.basepath isEqualToString:basepath]) {
        //如果你更换了下载缓存目录，之前的缓存目录下载信息的plist文件将被删除，无法使用
        [sharedFilesDownManage cleanLastInfo];
        sharedFilesDownManage.basepath = basepath;
        [sharedFilesDownManage loadTempfiles];
        [sharedFilesDownManage loadFinishedfiles];
    }
    sharedFilesDownManage.basepath = basepath;
    sharedFilesDownManage.targetPathArray =[NSMutableArray arrayWithArray:targetpaths];
    return  sharedFilesDownManage;
}
- (id)init{
    self = [super init];
    if (self != nil) {
        self.count = 0;
        if (self.basepath!=nil) {
            [self loadFinishedfiles];
            [self loadTempfiles];
            
        }
        
    }
    return self;
}
-(id)initWithBasepath:(NSString *)basepath
        TargetPathArr:(NSArray *)targetpaths{
    self = [super init];
    if (self != nil) {
        self.basepath = basepath;
        _targetPathArray = [[NSMutableArray alloc]initWithArray:targetpaths];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString * Max= [userDefaults valueForKey:@"kMaxRequestCount"];
        if (Max==nil) {
            [userDefaults setObject:@"5" forKey:@"kMaxRequestCount"];
            Max =@"5";
        }
        [userDefaults synchronize];
        maxcount = [Max integerValue];
        _filelist = [[NSMutableArray alloc]init];
        _downinglist=[[NSMutableArray alloc] init];
        _finishedList = [[NSMutableArray alloc] init];
        self.isFistLoadSound=YES;
        self.count = 0;
        if (self.basepath!=nil) {
            [self loadFinishedfiles];
            [self loadTempfiles];
            
        }
        
    }
    return self;
}

-(void)cleanLastInfo{
    for (MidHttpRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    [self saveFinishedFile];
    [_downinglist removeAllObjects];
    [_finishedList removeAllObjects];
    [_filelist removeAllObjects];
    
}



#pragma mark- -- 创建一个下载任务 --
-(void)downFileUrl:(NSString*)url
          filename:(NSString*)name
        filetarget:(NSString *)path
         fileimage:(UIImage *)image

{
    
    //因为是重新下载，则说明肯定该文件已经被下载完，或者有临时文件正在留着，所以检查一下这两个地方，存在则删除掉
    self.TargetSubPath = path;
    
    _fileInfo = [[FileModel alloc]init];
    if (!name) {
        name = [url lastPathComponent];
    }
    _fileInfo.fileName = name;
    _fileInfo.fileURL = url;
    
    NSDate *myDate = [NSDate date];
    _fileInfo.time = [CommonHelper dateToString:myDate];
    // NSInteger index=[name rangeOfString:@"."].location;
    _fileInfo.fileType=[name pathExtension];
    path= [CommonHelper getTargetPathWithBasepath:_basepath subpath:path];
    path = [path stringByAppendingPathComponent:name];
    _fileInfo.targetPath = path ;
    _fileInfo.fileimage = image;
    _fileInfo.downloadState = Downloading;
    _fileInfo.error = NO;
     NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: _fileInfo.fileName]  ;
    _fileInfo.tempPath = tempfilePath;
    if([CommonHelper isExistFile: _fileInfo.targetPath])//已经下载过一次
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件已下载，是否重新下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return;
    }
    //    //存在于临时文件夹里
    tempfilePath =[tempfilePath stringByAppendingString:@".plist"];
    if([CommonHelper isExistFile:tempfilePath])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件已经在下载列表中了，是否重新下载？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
        return;
    }
    
    //若不存在文件和临时文件，则是新的下载
    [self.filelist addObject:_fileInfo];
    
    [self startLoad];
    if(self.VCdelegate!=nil && [self.VCdelegate respondsToSelector:@selector(allowNextRequest)])
    {
        [self.VCdelegate allowNextRequest];
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件成功添加到下载队列" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    return;
    
}
#pragma mark  --下载开始--

-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    for(MidHttpRequest *tempRequest in self.downinglist)
    {
        /**
         注意这里判读是否是同一下载的方法，asihttprequest 有三种url：
         url，originalurl，redirectURL
         经过实践，应该使用originalurl,就是最先获得到的原下载地址
         **/
        
        NSLog(@"%@",[tempRequest.url absoluteString]);
        if([[[tempRequest.originalURL absoluteString]lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent]])
        {
            if ([tempRequest isExecuting]&&isBeginDown) {
                return;
            }else if ([tempRequest isExecuting]&&!isBeginDown)
            {
                [tempRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];
                [tempRequest cancel];
                [self.downloadDelegate updateCellProgress:tempRequest];
                return;
            }
        }
    }
    
    [self saveDownloadFile:fileInfo];
    
    //NSLog(@"targetPath %@",fileInfo.targetPath);
    //按照获取的文件名获取临时文件的大小，即已下载的大小
    
     NSFileManager *fileManager=[NSFileManager defaultManager];
    NSData *fileData=[fileManager contentsAtPath:fileInfo.tempPath];
    NSInteger receivedDataLength=[fileData length];
    fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%zd", receivedDataLength];
    
    NSLog(@"start down::已经下载：%@",fileInfo.fileReceivedSize);
    MidHttpRequest* midRequest = [[MidHttpRequest alloc]initWithURL: [NSURL URLWithString:fileInfo.fileURL]];
    midRequest.downloadDestinationPath = fileInfo.targetPath;
    midRequest.temporaryFileDownloadPath = fileInfo.tempPath;
    midRequest.delegate = self;
    [midRequest setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信息
     if (isBeginDown) {
        [midRequest startAsynchronous];
    }
    
    //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
    BOOL exit = NO;
    for(MidHttpRequest *tempRequest in self.downinglist)
    {
        //  NSLog(@"!!!!---::%@",[tempRequest.url absoluteString]);
        if([[[tempRequest.url absoluteString]lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent] ])
        {
            [self.downinglist replaceObjectAtIndex:[_downinglist indexOfObject:tempRequest] withObject:midRequest ];
            
            exit = YES;
            break;
        }
    }
    
    if (!exit) {
        
        [self.downinglist addObject:midRequest];
        NSLog(@"EXIT!!!!---::%@",[midRequest.url absoluteString]);
    }
    [self.downloadDelegate updateCellProgress:midRequest];
    
}
#pragma mark --存储下载信息到一个plist文件--
-(void)saveDownloadFile:(FileModel*)fileinfo{
    NSData *imagedata =UIImagePNGRepresentation(fileinfo.fileimage);
    
    NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:fileinfo.fileName,@"filename",fileinfo.fileURL,@"fileurl",fileinfo.time,@"time",_basepath,@"basepath",_TargetSubPath,@"tarpath" ,fileinfo.fileSize,@"filesize",fileinfo.fileReceivedSize,@"filerecievesize",imagedata,@"fileimage",nil];
    
    NSString *plistPath = [fileinfo.tempPath stringByAppendingPathExtension:@"plist"];
    if (![filedic writeToFile:plistPath atomically:YES]) {
        NSLog(@"write plist fail");
    }
}

#pragma mark- --自动处理下载状态的算法--

/*下载状态的逻辑是这样的：三种状态，下载中，等待下载，停止下载
 
 当超过最大下载数时，继续添加的下载会进入等待状态，当同时下载数少于最大限制时会自动开始下载等待状态的任务。
 可以主动切换下载状态
 所有任务以添加时间排序。
 */

-(void)startLoad{
    NSInteger num = 0;
    NSInteger max = maxcount;
    for (FileModel *file in _filelist) {
        if (!file.error) {
            if (file.downloadState==Downloading) {
                
                if (num>=max) {
                    file.downloadState=WillDownload;
                }else
                    num++;
                
            }
        }
    }
    if (num<max) {
        for (FileModel *file in _filelist) {
            if (!file.error) {
                if (file.downloadState==WillDownload) {
                    num++;
                    if (num>max) {
                        break;
                    }
                    file.downloadState=Downloading;
                }
            }
        }
        
    }
    for (FileModel *file in _filelist) {
        if (!file.error) {
            if (file.downloadState==Downloading) {
                [self beginRequest:file isBeginDown:YES];
            }else
                [self beginRequest:file isBeginDown:NO];
        }
    }
    self.count = [_filelist count];
}
#pragma mark -
#pragma mark - --恢复下载--
-(void)resumeRequest:(MidHttpRequest *)request{
    NSInteger max = maxcount;
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    NSInteger downingcount =0;
    NSInteger indexmax =-1;
    for (FileModel *file in _filelist) {
        if (file.downloadState==Downloading) {
            downingcount++;
            if (downingcount==max) {
                indexmax = [_filelist indexOfObject:file];
            }
        }
    }//此时下载中数目是否是最大，并获得最大时的位置Index
    if (downingcount==max) {
        FileModel *file  = [_filelist objectAtIndex:indexmax];
            if (file.downloadState==Downloading) {
                file.downloadState=WillDownload;
            }
    }//中止一个进程使其进入等待

    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
			file.downloadState = Downloading;
            file.error = NO;
        }
    }//重新开始此下载
    [self startLoad];
}
#pragma mark - --暂停下载--
-(void)stopRequest:(MidHttpRequest *)request{
    NSInteger max = maxcount;
    if([request isExecuting])
    {
        [request cancel];
    }
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {

			file.downloadState = StopDownload;
            break;
        }
    }
    NSInteger downingcount =0;

    for (FileModel *file in _filelist) {
        if (file.downloadState==Downloading) {
            downingcount++;
        }
    }
    if (downingcount<max) {
        for (FileModel *file in _filelist) {
            if (file.downloadState==WillDownload){
				file.downloadState=Downloading;
                break;
            }
        }
    }

    [self startLoad];

    
}
#pragma mark - --删除下载--
-(void)deleteRequest:(MidHttpRequest *)request{
    bool isexecuting = NO;
    if([request isExecuting])
    {
        [request cancel];
        isexecuting = YES;
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    FileModel *fileInfo=(FileModel*)[request.userInfo objectForKey:@"File"];
    NSString *path=fileInfo.tempPath;

    NSString *configPath=[NSString stringWithFormat:@"%@.plist",path];
    [fileManager removeItemAtPath:path error:&error];
    [fileManager removeItemAtPath:configPath error:&error];
   // [self deleteImage:fileInfo];
    
    if(!error)
    {
        NSLog(@"%@",[error description]);
    }

    NSInteger delindex =-1;
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            delindex = [_filelist indexOfObject:file];
            break;
        }
    }
    if (delindex!=NSNotFound) 
    [_filelist removeObjectAtIndex:delindex];
  
    [_downinglist removeObject:request];
    
    if (isexecuting) {
       // [self startWaitingRequest];
        [self startLoad];
    }
     self.count = [_filelist count];
}

#pragma mark - --可能的UI操作接口 --
-(void)clearAllFinished{
    [_finishedList removeAllObjects];
}
-(void)clearAllRquests{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    for (MidHttpRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
        FileModel *fileInfo=(FileModel*)[request.userInfo objectForKey:@"File"];
        NSString *path=fileInfo.tempPath;;
        NSString *configPath=[NSString stringWithFormat:@"%@.plist",path];
        [fileManager removeItemAtPath:path error:&error];
        [fileManager removeItemAtPath:configPath error:&error];
        //  [self deleteImage:fileInfo];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
        
    }
    [_downinglist removeAllObjects];
    [_filelist removeAllObjects];
}

-(void)restartAllRquests{
    
    for (MidHttpRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    
    [self startLoad];
}
#pragma mark- --从这里获取上次未完成下载的信息--
/*
 将本地的未下载完成的临时文件加载到正在下载列表里,但是不接着开始下载
 
 */
-(void)loadTempfiles
{
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    NSArray *filelist=[fileManager contentsOfDirectoryAtPath:TEMPPATH error:&error];
    if(!error)
    {
        NSLog(@"%@",[error description]);
    }
    NSMutableArray *filearr = [[NSMutableArray alloc]init];
    for(NSString *file in filelist)
    {
        NSString *filetype = [file  pathExtension];
        if([filetype isEqualToString:@"plist"])
            [filearr addObject:[self getTempfile:[TEMPPATH stringByAppendingPathComponent:file]]];
    }
    
    NSArray* arr =  [self sortbyTime:(NSArray *)filearr];
    [_filelist addObjectsFromArray:arr];
    
    [self startLoad];
}

-(FileModel *)getTempfile:(NSString *)path{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:path];
    FileModel *file = [[FileModel alloc]init];
    file.fileName = [dic objectForKey:@"filename"];
    file.fileType = [file.fileName pathExtension ];
    file.fileURL = [dic objectForKey:@"fileurl"];
    file.fileSize = [dic objectForKey:@"filesize"];
    file.fileReceivedSize= [dic objectForKey:@"filerecievesize"];
    self.basepath = [dic objectForKey:@"basepath"];
    self.TargetSubPath = [dic objectForKey:@"tarpath"];
    NSString*  path1= [CommonHelper getTargetPathWithBasepath:_basepath subpath:_TargetSubPath];
    path1 = [path1 stringByAppendingPathComponent:file.fileName];
    file.targetPath = path1;
    NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: file.fileName];
    file.tempPath = tempfilePath;
    file.time = [dic objectForKey:@"time"];
    file.fileimage = [UIImage imageWithData:[dic objectForKey:@"fileimage"]];
    file.downloadState =StopDownload;
     file.error = NO;
    
    NSData *fileData=[[NSFileManager defaultManager ] contentsAtPath:file.tempPath];
    NSInteger receivedDataLength=[fileData length];
    file.fileReceivedSize=[NSString stringWithFormat:@"%zd",receivedDataLength];
    return file;
}
-(NSArray *)sortbyTime:(NSArray *)array{
    NSArray *sorteArray1 = [array sortedArrayUsingComparator:^(id obj1, id obj2){
        FileModel *file1 = (FileModel *)obj1;
        FileModel *file2 = (FileModel *)obj2;
        NSDate *date1 = [CommonHelper makeDate:file1.time];
        NSDate *date2 = [CommonHelper makeDate:file2.time];
        if ([[date1 earlierDate:date2]isEqualToDate:date2]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([[date1 earlierDate:date2]isEqualToDate:date1]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        return (NSComparisonResult)NSOrderedSame;
    }];
    return sorteArray1;
}
#pragma mark- --已完成的下载任务在这里处理--
/*
	将本地已经下载完成的文件加载到已下载列表里
 */
-(void)loadFinishedfiles
{
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistPath = [[document stringByAppendingPathComponent:self.basepath]stringByAppendingPathComponent:@"finishPlist.plist"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:plistPath]) {
        NSMutableArray *finishArr = [[NSMutableArray alloc]initWithContentsOfFile:plistPath];
        for (NSDictionary *dic in finishArr) {
            FileModel *file = [[FileModel alloc]init];
            file.fileName = [dic objectForKey:@"filename"];
            file.fileType = [file.fileName pathExtension ];
            file.fileSize = [dic objectForKey:@"filesize"];
            file.targetPath = [dic objectForKey:@"filepath"];
            file.time = [dic objectForKey:@"time"];
            file.fileimage = [UIImage imageWithData:[dic objectForKey:@"fileimage"]];
            [_finishedList addObject:file];
        }
        //self.finishedlist = finishArr;
    }
    //    else
    //        [[NSFileManager defaultManager]createFileAtPath:plistPath contents:nil attributes:nil];
    
}

-(void)saveFinishedFile{
    //[_finishedList addObject:file];
    if (_finishedList==nil) {
        return;
    }
    NSMutableArray *finishedinfo = [[NSMutableArray alloc]init];
    for (FileModel *fileinfo in _finishedList) {
        NSData *imagedata =UIImagePNGRepresentation(fileinfo.fileimage);
        NSDictionary *filedic = [NSDictionary dictionaryWithObjectsAndKeys:fileinfo.fileName,@"filename",fileinfo.time,@"time",fileinfo.fileSize,@"filesize",fileinfo.targetPath,@"filepath",imagedata,@"fileimage", nil];
        [finishedinfo addObject:filedic];
    }
    NSString *document = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *plistPath = [[document stringByAppendingPathComponent:self.basepath]stringByAppendingPathComponent:@"finishPlist.plist"];
    if (![finishedinfo writeToFile:plistPath atomically:YES]) {
        NSLog(@"write plist fail");
    }
}
-(void)deleteFinishFile:(FileModel *)selectFile{
    [_finishedList removeObject:selectFile];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:selectFile.targetPath]) {
        [fm removeItemAtPath:selectFile.targetPath error:nil];
    }
    [self saveFinishedFile];
}
#pragma mark -

#pragma mark -- ASIHttpRequest回调委托 --

//出错了，如果是等待超时，则继续下载
-(void)requestFailed:(MidHttpRequest *)request
{
    NSError *error=[request error];
    NSLog(@"ASIHttpRequest出错了!%@",error);
    if (error.code==4) {
        return;
    }
    if ([request isExecuting]) {
        [request cancel];
    }
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    fileInfo.downloadState = StopDownload;
    fileInfo.error = YES;
    for (FileModel *file in _filelist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
			file.downloadState = StopDownload;

            file.error = YES;
        }
    }
    [self.downloadDelegate updateCellProgress:request];
}

-(void)requestStarted:(MidHttpRequest *)request
{
    NSLog(@"开始了!");
}

-(void)request:(MidHttpRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"收到回复了！");
 
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
	fileInfo.isFirstReceived = YES;

    NSString *len = [responseHeaders objectForKey:@"Content-Length"];//
        // NSLog(@"%@,%@,%@",fileInfo.fileSize,fileInfo.fileReceivedSize,len);
    //这个信息头，首次收到的为总大小，那么后来续传时收到的大小为肯定小于或等于首次的值，则忽略
    if ([fileInfo.fileSize longLongValue]> [len longLongValue])
    {
        return;
    }
   
        fileInfo.fileSize = [NSString stringWithFormat:@"%lld",  [len longLongValue]];
        [self saveDownloadFile:fileInfo];
    
}


-(void)request:(MidHttpRequest *)request didReceiveBytes:(long long)bytes
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    NSLog(@"%@,%lld",fileInfo.fileReceivedSize,bytes);
    if (fileInfo.isFirstReceived) {
        fileInfo.isFirstReceived=NO;
        fileInfo.fileReceivedSize =[NSString stringWithFormat:@"%lld",bytes];
    }
    else if(!fileInfo.isFirstReceived)
    {

        fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%lld",[fileInfo.fileReceivedSize longLongValue]+bytes];
    }
    
    if([self.downloadDelegate respondsToSelector:@selector(updateCellProgress:)])
    {
        [self.downloadDelegate updateCellProgress:request];
    }
   
}

//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(MidHttpRequest *)request
{
    FileModel *fileInfo=(FileModel *)[request.userInfo objectForKey:@"File"];
    
     [_finishedList addObject:fileInfo];
    NSString *configPath=[fileInfo.tempPath stringByAppendingString:@".plist"];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    if([fileManager fileExistsAtPath:configPath])//如果存在临时文件的配置文件
    {
        [fileManager removeItemAtPath:configPath error:&error];
        if(!error)
        {
            NSLog(@"%@",[error description]);
        }
    }
    

    [_filelist removeObject:fileInfo];
    [_downinglist removeObject:request];
    [self saveFinishedFile];
    [self startLoad];
  
    if([self.downloadDelegate respondsToSelector:@selector(finishedDownload:)])
    {
        [self.downloadDelegate finishedDownload:request];
    }
}

#pragma mark - --UIAlertViewDelegate--

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)//确定按钮
    {
        
        NSFileManager *fileManager=[NSFileManager defaultManager];
        NSError *error;
        NSInteger delindex =-1;
        if([CommonHelper isExistFile:_fileInfo.targetPath])//已经下载过一次该音乐
        {
            if ([fileManager removeItemAtPath:_fileInfo.targetPath error:&error]!=YES) {
                
                NSLog(@"删除文件出错:%@",[error localizedDescription]);
            }
            
            
        }else{
            for(MidHttpRequest *request in self.downinglist)
            {
                FileModel *fileModel=[request.userInfo objectForKey:@"File"];
                if([fileModel.fileName isEqualToString:_fileInfo.fileName])
                {
                    //[self.downinglist removeObject:request];
                    if ([request isExecuting]) {
                        [request cancel];
                    }
                    delindex = [_downinglist indexOfObject:request];
                    //  [self deleteImage:fileModel];
                    break;
                }
            }
            [_downinglist removeObjectAtIndex:delindex];
            
            for (FileModel *file in _filelist) {
                if ([file.fileName isEqualToString:_fileInfo.fileName]) {
                    delindex = [_filelist indexOfObject:file];
                    break;
                }
            }
            [_filelist removeObjectAtIndex:delindex];
            //存在于临时文件夹里
            NSString * tempfilePath =[_fileInfo.tempPath stringByAppendingString:@".plist"];
            if([CommonHelper isExistFile:tempfilePath])
            {
                if ([fileManager removeItemAtPath:tempfilePath error:&error]!=YES) {
                    NSLog(@"删除临时文件出错:%@",[error localizedDescription]);
                }
                
            }
            if([CommonHelper isExistFile:_fileInfo.tempPath])
            {
                if ([fileManager removeItemAtPath:_fileInfo.tempPath error:&error]!=YES) {
                    NSLog(@"删除临时文件出错:%@",[error localizedDescription]);
                }
            }
            
        }
        
        self.fileInfo.fileReceivedSize=[CommonHelper getFileSizeString:@"0"];
        [_filelist addObject:_fileInfo];
        [self startLoad];
        //        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该文件已经添加到您的下载列表中了！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        //        [alert show];
        //        [alert release];
        
    }
    if(self.VCdelegate!=nil && [self.VCdelegate respondsToSelector:@selector(allowNextRequest)])
    {
        [self.VCdelegate allowNextRequest];
    }
}

@end
