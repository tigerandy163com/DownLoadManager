//
//  SettingViewController.m
//  DownLoadManager
//
//  Created by chunyu.wang on 13-12-4.
//  Copyright (c) 2013年 11 111. All rights reserved.
//

#import "SettingViewController.h"
#import "FilesDownManage.h"

#define Max 5
@interface SettingViewController ()

@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _countStepper.maximumValue = Max;
    _countLab.text =   [[NSUserDefaults standardUserDefaults] stringForKey:@"kMaxRequestCount"];
    _countStepper.value =[[[NSUserDefaults standardUserDefaults] valueForKey:@"kMaxRequestCount"]integerValue];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)valueChange:(UIStepper *)sender {
    [_countLab setText:[NSString stringWithFormat:@"%.0f",sender.value]];
    maxcount = sender.value;

}

- (IBAction)validchange:(id)sender {
    [[NSUserDefaults standardUserDefaults]setValue:_countLab.text forKey:@"kMaxRequestCount"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[FilesDownManage sharedFilesDownManage]startLoad];
}
@end
