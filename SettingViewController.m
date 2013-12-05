//
//  SettingViewController.m
//  DownLoadManager
//
//  Created by chunyu.wang on 13-12-4.
//  Copyright (c) 2013年 11 111. All rights reserved.
//

#import "SettingViewController.h"
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

- (void)dealloc {
    [_countStepper release];
    [_countLab release];
    [super dealloc];
}
- (IBAction)valueChange:(UIStepper *)sender {
    [_countLab setText:[NSString stringWithFormat:@"%.0f",sender.value]];
    [[NSUserDefaults standardUserDefaults]setValue:_countLab.text forKey:@"kMaxRequestCount"];
}
@end
