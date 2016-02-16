//
//  ViewController.m
//  STZxingQRCode
//
//  Created by Mac on 15/7/15.
//  Copyright © 2015年 st. All rights reserved.
//

#import "ViewController.h"
#import "ScanQRCodeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor purpleColor];
    UIButton * startBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [startBtn setImage:[UIImage imageNamed:@"saoyisao"] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
}

- (void)click:(UIButton *)sender
{
    ScanQRCodeViewController * scanVC = [[ScanQRCodeViewController alloc] init];
    [self presentViewController:scanVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
