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
       NSArray *onlineBooksUrl = [NSArray arrayWithObjects:@"http://wt.wishdown.com:8082/soft/%C4%B4%D6%B8%B9%C3%C4%EF.mp3?222018468612008x1367051811x222018515330154-8a9b57c765112a2d2d31c1deef595f83",
                               @"http://rs.qipaoxian.com/mp3file/images/res/ttres/111/2111_b51ef49b0c83ddbd44b959f651e32924.mp3",
                               @"http://rs.qipaoxian.com/mp3file/images/res/ttres/166/2166_1f241a1d90c211cbffaa58d09cf89019.mp3",
                               
                               @"http://rs.qipaoxian.com/mp3file/newmp3/004.mp3",
                               @"http://rs.qipaoxian.com/mp3file/images/res/ttres/98/2098_6826a39adbf50f53c36baa901b25fe70.mp3",

                               @"http://rs.qipaoxian.com/mp3file/newmp3/shui.mp3",
                               @"http://rs.qipaoxian.com/mp3file/newmp3/qiong.mp3",
                               @"http://rs.qipaoxian.com/mp3file/images/res/ttres/854/2854_c21cfcafe8fff8f50719f195ae937195.mp3",
                               @"http://rs.qipaoxian.com/mp3file/newmp3/hu.mp3",nil];
    
    NSArray *names = [NSArray arrayWithObjects:@"拇指姑娘.mp3", @"天鹅王子.mp3",@"笨汉斯.mp3",@"丑小鸭.mp3",@"园丁和主人.mp3",@"睡美人.mp3",@"穷人和富人.mp3",@"小人国.mp3",@"狐狸和马.mp3",nil];
    
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
