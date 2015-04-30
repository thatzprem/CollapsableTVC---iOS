//
//  CollapsableTableViewHeaderViewController.m
//  CollapsableTableView
//
//  Created by S Prem Kumar on 30/04/14.
//  Copyright (c) 2014 FreakApps. All rights reserved.
//


#import "CollapsableTableHeaderView.h"

@implementation CollapsableTableHeaderView


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:.211 green:.808 blue:.605 alpha:1.000];
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped)];
        self.tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.tapRecognizer];
    }
    return self;
}

- (void) headerTapped
{
    if ([self.tapDelegate respondsToSelector:@selector(tappedViewIdentifier:)]) {
        [self.tapDelegate tappedViewIdentifier:self.tag];
    }
}

@end
