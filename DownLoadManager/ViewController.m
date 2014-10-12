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
       NSArray *onlineBooksUrl = [NSArray arrayWithObjects:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V3.1.2.dmg",
                               @"http://dldir1.qq.com/qqfile/qq/QQ6.4/12593/QQ6.4.exe",
                               @"http://dldir1.qq.com/qqfile/tm/TM2009Beta3.4_chs.exe",
                               @"http://dldir1.qq.com/qqfile/tm/TM2013Preview1.exe",
                               @"http://dldir1.qq.com/invc/tt/QQBrowserSetup.exe",
                               @"http://dldir1.qq.com/music/clntupate/QQMusic_Setup_100.exe",
                               @"http://dl_dir.qq.com/invc/qqpinyin/QQPinyin_Setup_4.6.2028.400.exe",nil];
    
    NSArray *names = [NSArray arrayWithObjects:@"MacQQ", @"qq",@"TM2009",@"TM2013",@"QQBrowser",@"QQMusic",@"QQPinyin",nil];
    
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
