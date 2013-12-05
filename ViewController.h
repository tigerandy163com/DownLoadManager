//
//  ViewController.h
//  DownLoadManager
//
//  Created by chunyu.wang on 13-12-4.
//  Copyright (c) 2013年 11 111. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{
    NSMutableArray* downContentDatas;
    NSArray* downURLArr;
}
@property (retain, nonatomic) IBOutlet UITableView *theTable;

@end
