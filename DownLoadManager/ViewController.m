//
//  ViewController.m
//  DownLoadManager
//
//  Created by chunyu.wang on 13-12-4.
//  Copyright (c) 2013年 11 111. All rights reserved.
//

#import "ViewController.h"
#include "FilesDownManage.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [FilesDownManage sharedFilesDownManageWithBasepath:@"DownLoad" TargetPathArr:[NSArray arrayWithObject:@"DownLoad/mp3"]];
       NSArray *onlineBooksUrl = [NSArray arrayWithObjects:@"http://219.239.26.20/download/53546556/76795884/2/dmg/232/4/1383696088040_516/QQ_V3.0.1.dmg",
                               @"http://219.239.26.11/download/46280417/68353447/3/dmg/105/192/1369883541097_192/KindleForMac._V383233429_.dmg",
                               @"http://free2.macx.cn:81/Tools/Office/UltraEdit-v4-0-0-7.dmg",
                               
                               @"http://124.254.47.46/download/53349786/76725509/1/exe/13/154/53349786_1/QQ2013SP4.exe",
                               @"http://dldir1.qq.com/qqfile/qq/QQ2013/QQ2013SP5/9050/QQ2013SP5.exe",

                               @"http://dldir1.qq.com/qqfile/tm/TM2013Preview1.exe",
                               @"http://dldir1.qq.com/invc/tt/QQBrowserSetup.exe",
                               @"http://dldir1.qq.com/music/clntupate/QQMusic_Setup_100.exe",
                               @"http://dl_dir.qq.com/invc/qqpinyin/QQPinyin_Setup_4.6.2028.400.exe",nil];
    
    NSArray *names = [NSArray arrayWithObjects:@"MacQQ", @"KindleForMac",@"UltraEdit",@"QQ2013SP4",@"QQ2013SP5",@"TM2013",@"QQBrowser",@"QQMusic",@"QQPinyin",nil];
    
    downContentDatas = [[NSMutableArray alloc]initWithArray:names];
    downURLArr = [[NSArray alloc]initWithArray:onlineBooksUrl];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [downURLArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"contentCell";     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    //增加下面的cell配置，让在标志为“myCell"的单元格中显示list数据
    NSInteger row = [indexPath row];
    UILabel* lab = (UILabel*)[cell viewWithTag:10];
    lab.text = [downContentDatas objectAtIndex:row];
    UIButton *but = (UIButton*)[cell viewWithTag:11];
    [but setTag:row];
    [but addTarget:self action:@selector(ClickDownBut:) forControlEvents:UIControlEventTouchDown];
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_theTable release];

    [super dealloc];
}
- (void)ClickDownBut:(UIButton *)sender {
    
    NSString* urlStr = [downURLArr objectAtIndex:sender.tag];
    NSString* name =  [downContentDatas objectAtIndex:sender.tag];
    NSLog(@"Url:%@,Name:%@",urlStr,name);
    [ [FilesDownManage sharedFilesDownManage]downFileUrl:urlStr filename:name filetarget:@"mp3" fileimage:nil];
}
@end
