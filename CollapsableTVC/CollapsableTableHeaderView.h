//
//  CollapsableTableViewHeaderViewController.h
//  CollapsableTableView
//
//  Created by S Rajkumar on 30/04/14.
//  Copyright (c) 2014 Happiest Minds. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapDelegateMethod <NSObject>

- (void) tappedViewIdentifier:(NSInteger) identifier;

@end

@interface CollapsableTableHeaderView : UIView

@property (nonatomic, assign) id<TapDelegateMethod> tapDelegate;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer* swipeRecognizer;

@end
