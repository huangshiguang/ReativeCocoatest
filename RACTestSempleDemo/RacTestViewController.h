//
//  RacTestViewController.h
//  RACTestSempleDemo
//
//  Created by 黄世光 on 2016/11/17.
//  Copyright © 2016年 黄世光. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa.h>
@interface RacTestViewController : UIViewController
@property (nonatomic,strong)RACSubject *delegateSignal;
@property (weak, nonatomic) IBOutlet UIScrollView *MyScrollView;

@end
