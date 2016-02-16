//
//  ScanQRCodeViewController.m
//  STZxingQRCode
//
//  Created by Mac on 16/2/15.
//  Copyright © 2016年 st. All rights reserved.
//

#import "ScanQRCodeViewController.h"
#import "ViewController.h"

#import <ZXingObjC/ZXingObjC.h>

#define SCANNER_WIDTH 230
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define IOS7 [[[UIDevice currentDevice] systemVersion]floatValue]>=7.0
#define Height (IOS7?64:44)

@interface ScanQRCodeViewController ()<ZXCaptureDelegate>
{
    BOOL isScaned;
}

@property (nonatomic, strong) ZXCapture * capture;
@property (nonatomic, strong) UILabel *resultLabel; //结果lable
@property (nonatomic,strong) UIImageView *lineView; //扫描线
@property (nonatomic,assign) BOOL willUp;           //扫描移动方向
@property (nonatomic,strong) NSTimer *timer;        //扫描线定时器

@end

@implementation ScanQRCodeViewController
{
    CGFloat scanner_X;
    CGFloat scanner_Y;
    CGRect viewFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    //设置相机
    [self setupCamera];
    self.capture.delegate = self;
    [self.timer setFireDate:[NSDate distantPast]];
    
    UIButton * startBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-60, 80, 50)];
    startBtn.backgroundColor = [UIColor yellowColor];
    [startBtn setTitle:@"继续扫" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    UIButton * backBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, SCREEN_HEIGHT-60, 80, 50)];
    backBtn.backgroundColor = [UIColor yellowColor];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
}


- (void)click:(UIButton *)sender
{
    [self.capture start];
}

- (void)backClick:(UIButton *)sender
{
    ViewController * vc = [[ViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)setupCamera
{
    isScaned = NO;
    //扫描器初始化
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera    = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.layer.frame = self.view.bounds;
    self.capture.rotation = 90.0f;    //可以竖屏扫描条形码
    [self.view.layer addSublayer:self.capture.layer];
    [self.capture.layer setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    //坐标初始化
    CGRect frame = self.view.frame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        viewFrame=CGRectMake(frame.origin.y, frame.origin.x, frame.size.height, frame.size.width);
    }else{
        viewFrame=self.view.frame;
    }
    CGPoint centerPoint  = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT-Height)/2);
    //扫描框的x、y坐标
    scanner_X=centerPoint.x-(SCANNER_WIDTH/2);
    scanner_Y=centerPoint.y-(SCANNER_WIDTH/2);
    //半透明背景初始化
    [self initBackgroundView];
    //扫描框
    UIImageView *borderView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"border"]];
    borderView.frame=CGRectMake(scanner_X-5, scanner_Y-5, SCANNER_WIDTH+10, SCANNER_WIDTH+10);
    [self.view addSubview:borderView];
    //扫描线
    self.lineView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line"]];
    self.lineView.frame=CGRectMake(scanner_X, scanner_Y, SCANNER_WIDTH, 2);
    [self.view addSubview:self.lineView];
    self.timer=[NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(lineAnimation) userInfo:nil repeats:YES];
}


-(void)initBackgroundView{
    CGRect scannerFrame = CGRectMake(scanner_X, scanner_Y,SCANNER_WIDTH, SCANNER_WIDTH);
    float x=scannerFrame.origin.x;
    float y=scannerFrame.origin.y;
    float width  =scannerFrame.size.width;
    float height =scannerFrame.size.height;
    float mainWidth = SCREEN_WIDTH;
    
    UIView *upView      =[[UIView alloc]initWithFrame:CGRectMake(0, 0, mainWidth, y)];
    UIView *leftView    =[[UIView alloc]initWithFrame:CGRectMake(0, y, x, height)];
    UIView *rightView   =[[UIView alloc]initWithFrame:CGRectMake(x+width, y, mainWidth-x-width, height)];
    UIView *downView    =[[UIView alloc]initWithFrame:CGRectMake(0, y+height, mainWidth, SCREEN_HEIGHT-y-height)];
    NSArray *viewArray  =[NSArray arrayWithObjects:upView,downView,leftView,rightView, nil];
    for (UIView *view in viewArray) {
        view.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        [self.view addSubview:view];
    }
}


//扫描线动画
-(void)lineAnimation{
    float y=self.lineView.frame.origin.y;
    if (y<=scanner_Y) {
        self.willUp=NO;
    }else if(y>=scanner_Y+SCANNER_WIDTH){
        self.willUp=YES;
    }
    if(self.willUp){
        y-=2;
        self.lineView.frame=CGRectMake(scanner_X, y, SCANNER_WIDTH, 2);
    }else{
        y+=2;
        self.lineView.frame=CGRectMake(scanner_X, y, SCANNER_WIDTH, 2);
    }
}


#pragma mark -ZXCaptureDelegate
-(void)captureResult:(ZXCapture *)capture result:(ZXResult *)result{
    

       NSLog(@"扫描的内容是：%@",result.text);
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"二维码或条形码" message:[NSString stringWithFormat:@"扫到的内容是：%@",result.text] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        [self.capture stop];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
