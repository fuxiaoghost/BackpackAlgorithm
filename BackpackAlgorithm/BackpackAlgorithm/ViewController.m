//
//  ViewController.m
//  BackpackAlgorithm
//
//  Created by Kirn on 2018/9/16.
//  Copyright © 2018 Kirn. All rights reserved.
//

#import "ViewController.h"
#import "TagsView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TagsView *tagsView = [TagsView new];
    tagsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:tagsView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[tagsView]-20-|" options:0 metrics:nil views:@{@"tagsView": tagsView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[tagsView]-20-|" options:0 metrics:nil views:@{@"tagsView": tagsView}]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
