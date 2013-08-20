//
//  ListViewController.h
//  TeamNote
//
//  Created by Joshua Areogun on 7/27/13.
//  Copyright (c) 2013 Joshua Areogun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>


@property(nonatomic, strong) NSArray *NoteTitles;
@property(nonatomic, strong)NSArray *NoteContents;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@end
