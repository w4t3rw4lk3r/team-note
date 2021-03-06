//
//  ListViewController.m
//  TeamNote
//
//  Created by Joshua Areogun on 7/27/13.
//  Copyright (c) 2013 Joshua Areogun. All rights reserved.
//

#import "ListViewController.h"
#import "AppDelegate.h"
#import "Note.h"
#import "otherNotesViewController.h"
#import "mainViewController.h"

@interface ListViewController ()
{
    NSMutableArray *allTopics;
    NSMutableArray *allContent;
    NSMutableArray *allDates;
    NSMutableArray *filteredStrings;
    NSMutableArray *stringDates;
    
    BOOL isFiltered;
    
    NSString *myTitle;
}

@end

@implementation ListViewController

@synthesize  NoteContents, NoteTitles, myTableView, managedObjectContext, searchBar;

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
    [self customizations];
    [self dataFetch];
    
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.searchBar.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self dataFetch];
    
    [self.myTableView reloadData];
    self.navigationController.toolbarHidden = NO;
}


- (IBAction)composeNotePressed:(id)sender
{
    [self showTopicMessage];
}

-(void)customizations
{
    
    //Navigation Bar & Buttons Customizations.
    
    self.navigationItem.title = @"All Notes";
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.title = @"Edit";
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir Next" size:15.0],NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:@"Storage" style:UIBarButtonItemStyleBordered target:self action:@selector(popCurrentViewController)];
    
    self.navigationItem.leftBarButtonItem = back;
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir Next" size:15.0],NSFontAttributeName,
                                                                   nil] forState:UIControlStateNormal];
    
    self.navigationController.toolbarHidden = NO;
    
   //Hide Searchbar on initial launch.
    
    CGRect bounds = self.tableView.bounds;
    bounds.origin.y = bounds.origin.y + self.searchBar.bounds.size.height;
    self.tableView.bounds = bounds;
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = NO;

}
//Custom Segue.

-(void)popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dataFetch
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.managedObjectContext = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateCreated" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSError *error;
    
    self.NoteTitles = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    allTopics = [[NSMutableArray alloc] init];
    allContent = [[NSMutableArray alloc] init];
    allDates = [[NSMutableArray alloc]init];
    
    for (Note *note in NoteTitles)
    {
        [allTopics addObject:note.title];
        [allContent addObject:note.content];
        [allDates addObject:note.dateCreated];
    }
}

//SearchBar Methods.

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0)
    {
        isFiltered = NO;
    }
    else
    {
        isFiltered = YES;
        
        filteredStrings = [[NSMutableArray alloc] init];
        
        for(NSString *str in allTopics)
        {
            NSRange stringRange = [str rangeOfString:searchText options:NSCaseInsensitiveSearch];
            
            if (stringRange.location != NSNotFound)
            {
                [filteredStrings addObject:str];
            }
        }
    }
    
    [self.myTableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

//tableView Data Handling.

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (isFiltered)
    {
        return [filteredStrings count];
    }
    
    return [allTopics count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!isFiltered)
    {
    
        Note *note = [NoteTitles objectAtIndex:indexPath.row];
    
        cell.textLabel.text = note.title;
        cell.textLabel.font = [UIFont fontWithName:@"Avenir Next" size:17.0];
    
        //detailTextlabel goes here!!!
        cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir Next" size:12.0];
    
        NSString *myDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        myDate =  [formatter stringFromDate:note.dateCreated];
    
        cell.detailTextLabel.text = myDate;
    }
    else
    {
        cell.textLabel.text = [filteredStrings objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"Avenir Next" size:17.0];
    }
    
    return cell;
}

//Table View Data Editing.

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing)
    {
        self.editButtonItem.title = NSLocalizedString(@"Done", @"Done");
    }
    else
    {
        self.editButtonItem.title = NSLocalizedString(@"Edit", @"Edit");
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSManagedObject *itemToDelete = [NoteTitles objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:itemToDelete];
        
        [allTopics removeObjectAtIndex:indexPath.row];
        [allContent removeObjectAtIndex:indexPath.row];
        [allDates removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"UnSaved Context Bro!!");
        }
    }
}

//New Note AlertView Popup.

-(void)showTopicMessage
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Enter A Title For This Note" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    
    message.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [message show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *button = [alertView buttonTitleAtIndex:1];
    
    if ([button isEqualToString:@"Done"])
    {
        UITextField *title = [alertView textFieldAtIndex:0];
        myTitle = title.text;
    }
    
    NSLog(@" %@ ", myTitle);
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([button isEqualToString:@"Done"])
    {
        [self performSegueWithIdentifier:@"composeNote" sender:self];
    }
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *input = [[alertView textFieldAtIndex:0] text];
    if([input length] >= 1)
    {
        return YES;
    }
    else
    {
        return NO;
 
    }
}

//Segue Handling. 

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"archiveDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        otherNotesViewController *destinationVC = segue.destinationViewController;
        
        destinationVC.noteTitle = [allTopics objectAtIndex:indexPath.row];
        destinationVC.noteContent = [allContent objectAtIndex:indexPath.row];
        destinationVC.noteDate = [stringDates objectAtIndex:indexPath.row];
    }
    
    else if ([segue.identifier isEqualToString:@"composeNote"])
    {
        mainViewController *destVC = segue.destinationViewController;
        
        destVC.myTitle = myTitle;
    }
    
}
@end
