//
//  ViewController.m
//  ropeBallDemo
//
//  Created by 叶杨 on 16/3/25.
//  Copyright © 2016年 叶景天. All rights reserved.
//

#import "ViewController.h"
#import "AnimaView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AnimaView *animaView = [[AnimaView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:animaView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
