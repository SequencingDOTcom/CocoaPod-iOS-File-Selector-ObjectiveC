//
//  SQMyFilesViewController.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQMyFilesViewController.h"
#import "SQFilesHelper.h"
#import "SQFilesContainer.h"
#import "SQSectionInfo.h"
#import "SQExtendedNavBarView.h"
#import "SQSegmentedControlHelper.h"
#import "SQSampleFilesViewController.h"
#import "SQTableCell.h"
#import "SQPopoverInfoViewController.h"
#import "SQFilesAPI.h"

#define kMainQueue dispatch_get_main_queue()


@interface SQMyFilesViewController () <UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet SQExtendedNavBarView *extendedNavBarView;

// files source
@property (strong, nonatomic) NSArray *filesArray;
@property (strong, nonatomic) NSArray *filesHeightsArray;

// buttons
@property (strong, nonatomic) UIBarButtonItem   *continueButton;
@property (strong, nonatomic) UIBarButtonItem   *infoButton;

// file details / selection index
@property (strong, nonatomic) NSIndexPath       *nowSelectedFileIndexPath;
@property (strong, nonatomic) NSDictionary      *categoryIndexes;

@end


@implementation SQMyFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // prepare navigation bar
    self.title = @"My Files";
    [self.navigationItem setTitle:@"Select file"];
    
    // extended navigation bar
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // set up images from bundle
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ResourceBundle" ofType:@"bundle"];
    
    NSString *transparentPixelImageName = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"nav_clear_pixel" ofType:@"png"];
    UIImage *transparentPixel = [[UIImage alloc] initWithContentsOfFile:transparentPixelImageName];
    [self.navigationController.navigationBar setShadowImage:transparentPixel];
    
    NSString *pixelImageName = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"nav_pixel" ofType:@"png"];
    UIImage *pixel = [[UIImage alloc] initWithContentsOfFile:pixelImageName];
    [self.navigationController.navigationBar setBackgroundImage:pixel forBarMetrics:UIBarMetricsDefault];
    
    // [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"TransparentPixel"]];
    // [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Pixel"] forBarMetrics:UIBarMetricsDefault];
    
    
    // set image for tab bar item
    NSString *myFilesItem = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"myfiles" ofType:@"png"];
    // UIImage *myFilesImage = [[UIImage alloc] initWithContentsOfFile:myFilesItem];
    
    NSString *sampleFilesItem = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"samplefiles" ofType:@"png"];
    // UIImage *sampleFilesImage = [[UIImage alloc] initWithContentsOfFile:sampleFilesItem];
    
    UITabBarItem *myItem = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:0];
    myItem.image = [UIImage imageNamed:myFilesItem];
    
    UITabBarItem *sampleItem = (UITabBarItem *)[self.tabBarController.tabBar.items objectAtIndex:1];
    sampleItem.image = [UIImage imageNamed:sampleFilesItem];
    
    // infoButton
    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(showInfoPopover) forControlEvents:UIControlEventTouchUpInside];
    self.infoButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // continueButton
    self.continueButton = [[UIBarButtonItem alloc] initWithTitle:@"Continue"
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(fileIsSelected)];
    self.continueButton.enabled = NO;
    
    // rightBarButtonItems
    NSArray *rightButtonsArray = [[NSArray alloc] initWithObjects:self.continueButton, self.infoButton, nil];
    self.navigationItem.rightBarButtonItems = rightButtonsArray;
    
    // "Back" button
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(backButtonPressed)];
    [self.navigationItem setLeftBarButtonItem:backButton animated:YES];
    
    // prepare tableView
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // allows using "native" radio button for selecting row
    [self.tableView setEditing:YES animated:YES];
    
    // prepare array with segmented control items and indexes in source
    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
    
    // checking if we have no myFiles assigned to account
    if ([filesContainer.mySectionsArray count] > 0) {
        NSDictionary *itemsAndIndexes = [SQSegmentedControlHelper prepareSegmentedControlItemsAndCategoryIndexes:filesContainer.mySectionsArray];
        NSArray *segmentedControlItems = [itemsAndIndexes objectForKey:@"items"];
        self.categoryIndexes = [itemsAndIndexes objectForKey:@"indexes"];
        
        // segmented control init
        UISegmentedControl *fileTypeSelect = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
        [fileTypeSelect addTarget:self action:@selector(segmentControlAction:) forControlEvents:UIControlEventValueChanged];
        [fileTypeSelect sizeToFit];
        [fileTypeSelect setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.extendedNavBarView addSubview:fileTypeSelect];
        
        // adding constraints for segmented control
        NSLayoutConstraint *xCenter = [NSLayoutConstraint constraintWithItem:fileTypeSelect
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.extendedNavBarView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0];
        NSLayoutConstraint *yCenter = [NSLayoutConstraint constraintWithItem:fileTypeSelect
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.extendedNavBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1
                                                                    constant:0];
        [self.extendedNavBarView addConstraint:xCenter];
        [self.extendedNavBarView addConstraint:yCenter];
        
        
        // select first item in segmentedControl and assign related source
        fileTypeSelect.selectedSegmentIndex = 0;
        SQSectionInfo *section = (filesContainer.mySectionsArray)[0];
        self.filesArray = section.filesArray;
        self.filesHeightsArray = section.rowHeights;
        
    } else {
        // switch to Sample files if my files are absent
        [self.tabBarController setSelectedIndex:1];
        [[[[self.tabBarController tabBar]items]objectAtIndex:0]setEnabled:FALSE];
    }
    
}


#pragma mark -
#pragma mark Actions

- (void)segmentControlAction:(UISegmentedControl *)sender {
    self.nowSelectedFileIndexPath = nil;
    self.continueButton.enabled = NO;
    
    self.filesArray = nil;
    self.filesHeightsArray = nil;
    [self.tableView reloadData];
    
    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
    SQSectionInfo *section = [[SQSectionInfo alloc] init];
    
    NSString *selectedSegmentItem = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    
    int indexOfSectionInArray = [[self.categoryIndexes objectForKey:selectedSegmentItem] intValue];
    section = (filesContainer.mySectionsArray)[indexOfSectionInArray];
    
    self.filesArray = section.filesArray;
    self.filesHeightsArray = section.rowHeights;
    [self.tableView reloadData];
}

- (void)fileIsSelected {
    NSDictionary *selectedFile = [[NSDictionary alloc] init];
    selectedFile = (self.filesArray)[self.nowSelectedFileIndexPath.row];
    
    [[[SQFilesAPI sharedInstance] fileSelectedHandler] handleFileSelected:selectedFile];
    
    [self backButtonPressed];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filesArray count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [(self.filesHeightsArray)[indexPath.row] floatValue];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    SQTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSDictionary *tempFile = [[NSDictionary alloc] init];
    tempFile = (self.filesArray)[indexPath.row];
    NSString *fileName = [SQFilesHelper prepareTextFromMyFile:tempFile];
    
    cell.cellLabel.text = fileName;
    cell.cellLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.tintColor = [UIColor blueColor];
    
    return cell;
}


#pragma mark -
#pragma mark Cells selection

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 3;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.nowSelectedFileIndexPath == nil) {
        self.nowSelectedFileIndexPath = indexPath;
    } else {
        if (self.nowSelectedFileIndexPath != indexPath) {
            [self.tableView deselectRowAtIndexPath:self.nowSelectedFileIndexPath animated:YES];
            self.nowSelectedFileIndexPath = indexPath;
        }
    }
    self.continueButton.enabled = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.nowSelectedFileIndexPath = nil;
    self.continueButton.enabled = NO;
}


#pragma mark -
#pragma mark Navigation

- (void)backButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
- (void)showDetails {
    [self performSegueWithIdentifier:@"SHOW_FILE_DETAILS" sender:nil];
} */


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    /*
    NSDictionary *selectedFile = [[NSDictionary alloc] init];
    SQSectionInfo *sectionInfo = (self.sampleSectionInfoArray)[self.nowSelectedFileIndexPath.section];
    selectedFile = [sectionInfo.filesArray objectAtIndex:self.nowSelectedFileIndexPath.row];
    
    self.fileDetails.text = [SQDemoDataCell prepareText:self.nowSelectedFile];
     
    if ([segue.destinationViewController isKindOfClass:[DetailsViewController class]]) {
        [[segue destinationViewController] setNowSelectedFile:selectedFile];
    }
    */
}


#pragma mark -
#pragma mark Popover

- (void)showInfoPopover {
    UIViewController *popoverContentController = [[UIViewController alloc] initWithNibName:@"SQPopoverInfoViewController" bundle:nil];
    
    CGFloat height = [SQPopoverInfoViewController heightForPopoverWidth:self.view.bounds.size.width - 30];
    popoverContentController.preferredContentSize = CGSizeMake(self.view.bounds.size.width - 30, height);
    
    // Set the presentation style to modal and delegate so that the below methods get called
    popoverContentController.modalPresentationStyle = UIModalPresentationPopover;
    popoverContentController.popoverPresentationController.delegate = self;
    
    [self presentViewController:popoverContentController animated:YES completion:nil];
}

- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController {
    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popoverPresentationController.barButtonItem = self.infoButton;
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
