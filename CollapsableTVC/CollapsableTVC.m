//
//  CollapsableTVC.m
//  CollapsableTVC
//
//  Created by Prem kumar on 07/05/14.
//  Copyright (c) 2014 FreakApps. All rights reserved.
//

#import "CollapsableTVC.h"
#import "CollapsableTableHeaderView.h"

#define kPListFileName          @"data"
#define kPListRootKey           @"Items"
#define kPlistIsCollapsedKey    @"isCollapsed"
#define kPlistRowsKey           @"rows"
#define kPlistPreviousStateKey  @"previousState"
#define kPlistSubItemsKey       @"subItems"

#define kHeaderHeight 50.0f
static NSString * const reuseIdentifier = @"CellID";

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
    
    NSLog(@"Page configuration details: %@",self.headerSectionsArray);
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(NSMutableArray *)headerSectionsArray
{
    if (!_headerSectionsArray)
    {
        _headerSectionsArray = [[NSMutableArray alloc] init];
        NSDictionary *dict=[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kPListFileName ofType:@"plist"]];
        NSArray *itemsArray = [dict valueForKey:kPListRootKey];
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
    int rowCount = [sectionDetailsDictionary[kPlistRowsKey] intValue];
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
    NSLog(@"Expanding section :%ld",(long)identifier);
    [self expandOrCollapseSection:identifier];
}

- (void)expandOrCollapseSection:(NSInteger)section
{
    NSMutableDictionary *sectionDetailsDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.headerSectionsArray objectAtIndex:section]];
    int rowCount = [sectionDetailsDictionary[kPlistRowsKey] intValue];
    
    BOOL inCollapsedState = [sectionDetailsDictionary[kPlistIsCollapsedKey] boolValue];
    
    //Expand.
    if (!inCollapsedState || rowCount  == 0 )
    {
        NSLog(@"Expanding section :%ld",(long)section);
        
        int rowsToAdd = [sectionDetailsDictionary[kPlistPreviousStateKey] intValue];

        // The user might not have any previsous state initially when opening up this section for the very first time. The below condition is to handle it
        if (rowsToAdd == 0) {
            NSLog(@"No Previous state stored. Adding 4 new sections");
            rowsToAdd = 4;
        }
        else {
            NSLog(@"Adding %ld rows to add from section's previous state",(long)rowsToAdd);
        }
        
        NSMutableArray *cellsArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < rowsToAdd; i++)
        {
            rowCount++;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            [cellsArray addObject:indexPath];
        }
        sectionDetailsDictionary[kPlistIsCollapsedKey] = @YES;
        sectionDetailsDictionary[kPlistRowsKey] = @(rowCount);
        
        [self.headerSectionsArray replaceObjectAtIndex:section withObject:sectionDetailsDictionary];
        
        [self.tableView insertRowsAtIndexPaths:cellsArray withRowAnimation:UITableViewRowAnimationLeft];
    }
    else if(inCollapsedState || rowCount > 0) //Collapse.
    {
        NSLog(@"Collapsing section :%ld",(long)section);
        //This variable is to capture the total number or rows to be removed. As many rows could get added dynamically.
        int rowsToRemove = rowCount;
        
        NSMutableArray *cellsArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < rowsToRemove; i++)
        {
            rowCount--;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
            [cellsArray addObject:indexPath];
        }
        
        sectionDetailsDictionary[kPlistIsCollapsedKey] = @NO;
        sectionDetailsDictionary[kPlistRowsKey] = @(rowCount);
        sectionDetailsDictionary[kPlistPreviousStateKey] = @(rowsToRemove);
        
        [self.headerSectionsArray replaceObjectAtIndex:section withObject:sectionDetailsDictionary];
        
        [self.tableView deleteRowsAtIndexPaths:cellsArray withRowAnimation:UITableViewRowAnimationLeft];
    }
    else
    {
        //Invalid operation:Neither expand or collapse.
        NSLog(@"Invalid operation:Neither expand or collapse.");
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"User selected row: %ld from section: %ld",(long)indexPath.row,(long)indexPath.section);

    if (indexPath.section == 0 && indexPath.row == 0) { //Add new row.
        
        NSLog(@"Adding new row to section: %ld",(long)indexPath.row);

        NSMutableDictionary *sectionDetailsDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.headerSectionsArray objectAtIndex:indexPath.section]];
        
        //Update row count
        int rowCount = [sectionDetailsDictionary[kPlistRowsKey] intValue];
        sectionDetailsDictionary[kPlistRowsKey] = @(++rowCount);
        
        //Create a new subitem element.
        NSMutableDictionary *newSubItemDetail = [[NSMutableDictionary alloc] init];
        newSubItemDetail[@"cellID"] = @"CellID";
        newSubItemDetail[@"cellHeight"] = @50;
        
        //Add the new subitem to the subitems array.
        NSMutableArray *subItemsArray = [NSMutableArray arrayWithArray:sectionDetailsDictionary[kPlistSubItemsKey]];
        [subItemsArray addObject:newSubItemDetail];
        sectionDetailsDictionary[kPlistSubItemsKey] = subItemsArray;

        //Update the tableview header with the changes.
        [self.headerSectionsArray replaceObjectAtIndex:indexPath.section withObject:sectionDetailsDictionary];
        
        //Update the rows in section 1
        NSRange range = NSMakeRange(0, 1);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
    }
    else if (indexPath.section == 0 && indexPath.row > 0) { //Delete new row.
        
        NSLog(@"Deleting row at : %ld",(long)indexPath.row);
        
        NSMutableDictionary *sectionDetailsDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.headerSectionsArray objectAtIndex:indexPath.section]];
        
        //Update the row count when a row is removed.
        int rowCount = [sectionDetailsDictionary[kPlistRowsKey] intValue];
        sectionDetailsDictionary[kPlistRowsKey] = @(--rowCount);
        
        //Remove the last element in the subitems array.
        NSMutableArray *subItemsArray = [NSMutableArray arrayWithArray:sectionDetailsDictionary[kPlistSubItemsKey]];
        [subItemsArray removeLastObject];
        sectionDetailsDictionary[kPlistSubItemsKey] = subItemsArray;

        //Update the tableview datasource array.
        [self.headerSectionsArray replaceObjectAtIndex:indexPath.section withObject:sectionDetailsDictionary];
        
        //Reload all rows in section 1
        NSRange range = NSMakeRange(0, 1);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        //Selection is right now enabled only for the first section.
        NSLog(@"Table view selection is not enabled for this section");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 30.0f;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Custom Cell    
    
    //Creating the subitems array to identify the corresponding cellID.
    NSMutableDictionary *sectionDetailsDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.headerSectionsArray objectAtIndex:indexPath.section]];
    NSArray *subItemsArray = sectionDetailsDictionary[kPlistSubItemsKey];
    
    NSString *cellID = nil;
    
    if (subItemsArray != nil && subItemsArray.count > 0) {
        NSDictionary *aCellDetailsDictionary = [subItemsArray objectAtIndex:indexPath.row];
        cellID = aCellDetailsDictionary[@"cellID"];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.backgroundColor = [UIColor clearColor];


    //This is just to udpate the text in the cell
    if (indexPath.row == 0) { //Add new row.
        cell.textLabel.text = @"Tap to ADD one new row to this section";
    }
    else if (indexPath.row > 0) { //Delete new row.
        cell.textLabel.text = @"Tap to DELETE the last row from this section";
    }
    else{
        cell.textLabel.text = @"";
    }
    
    return cell;
}


@end
