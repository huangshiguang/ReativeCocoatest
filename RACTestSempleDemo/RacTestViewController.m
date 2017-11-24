//
//  RacTestViewController.m
//  RACTestSempleDemo
//
//  Created by 黄世光 on 2016/11/17.
//  Copyright © 2016年 黄世光. All rights reserved.
//

#import "RacTestViewController.h"

@interface RacTestViewController ()
@property(nonatomic,weak)UIButton *myBtn;
@end

@implementation RacTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildMyScrollView];
    [self creatButton];//代替代理
    //    [self test1];//创建信号，发送信号
//        [self test2];//RACSubject
//        [self test3];//RACReplaySubject
    //    [self test4];//遍历数组
    //    [self test5];//遍历字典
        [self test6];//RACCommand
    //    [self test7];
    [self observeContentOffset];
}
-(void)buildMyScrollView{
    self.MyScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*2);
    self.MyScrollView.backgroundColor = [UIColor redColor];
}
- (void)creatButton{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20, 100, 50, 50)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    self.myBtn = btn;
    [self.view addSubview:btn];
}
-(void)btnClick{
    //通知第一个控制器，告诉它，按钮被点了
    if(self.delegateSignal){
        [self.delegateSignal sendNext:@"我第2个页面点击了按钮"];
    }
}
- (void)observeContentOffset{
    @weakify(self)
    [RACObserve(self.MyScrollView, contentOffset)subscribeNext:^(id x) {
        NSLog(@"y--->%@",x);
        @strongify(self);
        if (self.MyScrollView.contentOffset.y > 50) {
            self.myBtn.hidden = YES;
        }else if(self.MyScrollView.contentOffset.y < -20){
            self.myBtn.hidden = NO;
        }
    }];
}
- (void)test7{
    //1.创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@1];
        return nil;
    }];
    //2.创建链接
    RACMulticastConnection *connect = [signal publish];
    //3.订阅信号
    //注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接，就会一次性调用所有订阅者的sendnext
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者1的信号");
    }];
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"订阅者2的信号");
    }];
    //4.连接，激活信号
    [connect connect];
    
}
- (void)test6{
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"执行命令");
        //创建空信号，必须返回信号
        //returen [RACSignal empty];
        
        //创建信号，用来传递数据
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"请求数据"];
            //注意：数据传递完之后要完成
            [subscriber sendCompleted];
            return nil;
        }];
    }];
    //强引用命令，不要被销毁，否则接收不到数据
    [command.executionSignals subscribeNext:^(id x) {
        [x subscribeNext:^(id x) {
            NSLog(@"接受数据%@",x);
        }];
    }];
    
    //RAC高级用法
    //switchToLatest:用于signals,获取singnal of signals发出的最新信号，也就是直接拿到RACCommand中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"接受数据%@",x);
    }];
    //监听命令执行，skip表示跳过第1次信号。
    [[command.executing skip:1] subscribeNext:^(id x) {
        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        }else{
            NSLog(@"执行完成");
        }
    }];
    //5.执行命令
    [command execute:@1];
    //执行命令--》正在执行--》请求数据--》接受数据
}

- (void)test5{
    NSDictionary *dict = @{@"me":@"18",@"you":@"19"};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple *x) {
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"key->%@,value->%@",key,value);
    }];
}
- (void)test4{
    NSArray *numbers = @[@1,@2,@3,@4];
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}
- (void)test3{
    //1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    //2.发送信号
    [replaySubject sendNext:@1];
    [replaySubject sendNext:@2];
    
    //3.订阅信号
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第一个订阅者%@",x);
    }];
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"第二个订阅者%@",x);
    }];
    //创建信号---》发送信号---（存起来要发的值）-----》订阅信号（遍历取出存起来的值）【和RACSubject 的执行顺序有区别】
}
- (void)test2{
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.订阅信号
    [subject subscribeNext:^(id x) {
        //block调用时刻：当信号发出新值就会调用；
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        //block调用时刻：当信号发出新值就会被调用；
        NSLog(@"第二个订阅者%@",x);
    }];
    //3.发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendCompleted];
    [subject sendNext:@3];
    //创建信号---》订阅信号---》发送信号-----》再次发送信号————————》终止--x-->第三次发送信号
}
- (void)test1{
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //block 调用时刻 ：每当有订阅者订阅信号，就会调用block
        //2.发送信号
        [subscriber sendNext:@1];
        //如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable];取消订阅信号。
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            //block 调用时刻：当信号发送完成或发送错误，内部会自动调用这个block，取消订阅信号。
            //执行完block后，当前信号就不在被订阅了；
            NSLog(@"信号被销毁");
        }];
    }];
    //3.订阅信号，才会激活信号。
    [siganl subscribeNext:^(id x) {
        //block 调用时刻，每当有信号发出数据，就会调用block。
        NSLog(@"接受到数据：%@",x);
    }];
    //断点运行可知先1订阅信号->2发送信号->3执行订阅信号的block—>4.信号发送完成->5.信号完成的block
}

@end
