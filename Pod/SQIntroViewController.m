//
//  SQIntroViewController.m
//  Pods
//
//  Created by Bogdan Laukhin on 6/1/16.
//
//

#import "SQIntroViewController.h"


#define FILES_CONTROLLER_SEGUE_ID @"SHOW_FILES_SEGUE_ID"


@interface SQIntroViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end



@implementation SQIntroViewController

#pragma mark -
#pragma mark View Lyfecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
}




#pragma mark -
#pragma mark Action

- (IBAction)segmentedControlAction:(UISegmentedControl *)sender {
    NSString *selectedSegmentItem = [sender titleForSegmentAtIndex:sender.selectedSegmentIndex];
    
    if ([selectedSegmentItem containsString:@"Sample"]) {
        NSLog(@"%@", selectedSegmentItem);
        [self performSegueWithIdentifier:FILES_CONTROLLER_SEGUE_ID sender:@0]; // @1
        
    } else {
        NSLog(@"%@", selectedSegmentItem);
        [self performSegueWithIdentifier:FILES_CONTROLLER_SEGUE_ID sender:@0];
    }
}


#pragma mark -
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:FILES_CONTROLLER_SEGUE_ID]) {
        NSNumber *indexToShow = sender;
        UITabBarController *tabBar = segue.destinationViewController;
        [tabBar setSelectedIndex:indexToShow.unsignedIntegerValue];
    }
}



#pragma mark -
#pragma mark Other methods

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
