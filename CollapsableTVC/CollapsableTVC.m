//
//  CollapsableTVC.m
//  CollapsableTVC
//
//  Created by Prem kumar on 07/05/14.
//  Copyright (c) 2014 Happiest Minds. All rights reserved.
//

#import "CollapsableTVC.h"
#import "CollapsableTableHeaderView.h"

@interface CollapsableTVC ()<TapDelegateMethod>

@property (nonatomic,assign) int rowCount;
@property (nonatomic,strong) NSMutableArray *headerSectionsArray;

@end

@implementation CollapsableTVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.rowCount = 0;
    
    NSLog(@"%d",[self.headerSectionsArray count]);
    NSLog(@"%@",self.headerSectionsArray);
}

-(NSMutableArray *)headerSectionsArray
{
    if (!_headerSectionsArray)
    {
        _headerSectionsArray = [[NSMutableArray alloc] init];
        NSDictionary *dict=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
        NSArray *itemsArray = [dict valueForKey:@"Items"];
        [self.headerSectionsArray addObjectsFromArray:itemsArray];
    }
    return _headerSectionsArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.headerSectionsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return 5;
    // Return the number of rows in the section.
    NSDictionary *dictionary = [self.headerSectionsArray objectAtIndex:section];
    NSMutableDictionary *sectionDetailsDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    int rowCount = [sectionDetailsDictionary[@"rows"] intValue];
    return rowCount;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //Creating custom view.

    CollapsableTableHeaderView *aViewController = [[CollapsableTableHeaderView alloc] init];
    aViewController.frame = CGRectMake(0.0, 0.0, 100.0, 64.0);
    aViewController.tapDelegate = self;
    aViewController.tag = section;
    
    return aViewController;
}

- (void) tappedViewIdentifier:(NSInteger) identifier
{
    [self expandOrCollapseSection:identifier];
}

- (void)expandOrCollapseSection:(NSInteger)section
{
    NSMutableDictionary *sectionDetailsDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.headerSectionsArray objectAtIndex:section]];
    int rowCount = [sectionDetailsDictionary[@"rows"] intValue];

    BOOL inCollapsedState = [sectionDetailsDictionary[@"isCollapsed"] boolValue];
    
    //Expand.
    if (!inCollapsedState || rowCount  == 0 )
    {
        NSMutableArray *cellsArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < 4; i++)
        {
            rowCount++;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            [cellsArray addObject:indexPath];
        }
        sectionDetailsDictionary[@"isCollapsed"] = @YES;
        sectionDetailsDictionary[@"rows"] = @(rowCount);
        [self.headerSectionsArray replaceObjectAtIndex:section withObject:sectionDetailsDictionary];
        
        [self.tableView insertRowsAtIndexPaths:cellsArray withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadData];
    }
    else if(inCollapsedState || rowCount > 0) //Collapse.
    {
        NSMutableArray *cellsArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < 4; i++)
        {
            rowCount--;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            [cellsArray addObject:indexPath];
        }
        sectionDetailsDictionary[@"isCollapsed"] = @NO;
        sectionDetailsDictionary[@"rows"] = @(rowCount);
        [self.headerSectionsArray replaceObjectAtIndex:section withObject:sectionDetailsDictionary];
        
        [self.tableView deleteRowsAtIndexPaths:cellsArray withRowAnimation:UITableViewRowAnimationLeft];
    }
    else
    {

    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 100.0f;
}

#pragma mark - Table view data source


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    // Configure the cell...
    
    return cell;
}


@end
