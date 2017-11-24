//
//  ViewController.m
//  RACTestSempleDemo
//
//  Created by 黄世光 on 2016/11/17.
//  Copyright © 2016年 黄世光. All rights reserved.
//

#import "ViewController.h"
#import "RacTestViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //我的实验button
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(20, 100, 200, 200)];
    button.backgroundColor = [UIColor orangeColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}
-(void)buttonClick:(UIButton*)sender{
    NSLog(@"按钮点击了");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MyStoryboard" bundle:[NSBundle mainBundle]];
    RacTestViewController *vc = [sb instantiateViewControllerWithIdentifier:@"MySB"];
    //设置代理信号
    vc.delegateSignal = [RACSubject subject];
    //订阅代理信号
    [vc.delegateSignal subscribeNext:^(id x) {
        NSLog(@"下个页面的操作是，%@",x);
        [sender setTitle:[NSString stringWithFormat:@"%@",x] forState:UIControlStateNormal];
        
    }];
    if (vc) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
