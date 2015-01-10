//
//  CollapsableTVC.h
//  CollapsableTVC
//
//  Created by Prem kumar on 07/05/14.
//  Copyright (c) 2014 Happiest Minds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollapsableTableHeaderView.h"

@interface CollapsableTVC : UITableViewController

@property (nonatomic,assign) id<TapDelegateMethod> tapViewDelegate;

@end
