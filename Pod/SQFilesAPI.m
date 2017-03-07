//
//  SQFilesAPI.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQFilesAPI.h"
#import "SQFilesServerManager.h"
#import "SQFilesHelper.h"
#import "SQFilesContainer.h"

#define kMainQueue dispatch_get_main_queue()



@interface SQFilesAPI()

@property (readwrite, nonatomic) NSString *accessToken;

@end



@implementation SQFilesAPI

+ (instancetype)sharedInstance {
    static SQFilesAPI *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQFilesAPI alloc] init];
    });
    return instance;
}


#pragma mark - API methods

- (void)loadFilesWithToken:(NSString *)accessToken
               closeButton:(BOOL)closeButton
      selectedFileDelegate:(id <SQFileSelectorProtocol>)delegate
                    result:(void(^)(BOOL success))success {
    
    self.delegate = delegate;
    self.closeButton = closeButton;
    self.accessToken = accessToken;
    
    // send request to server to get files assigned to account
    // and then parse these files into categories and subcategories
    [self loadFilesFromServer:^(NSArray *files) {
        if (files) {
            [SQFilesHelper parseFilesMainArray:files withHandler:^(NSMutableArray *mySectionsArray, NSMutableArray *sampleSectionsArray) {
                dispatch_async(kMainQueue, ^{
                    SQFilesContainer *filesContainer = [SQFilesContainer sharedInstance];
                    [filesContainer setMySectionsArray:[mySectionsArray copy]];
                    [filesContainer setSampleSectionsArray:[sampleSectionsArray copy]];
                    success(YES);
                });
            }];
        } else
            success(NO);
    }];
}



- (void)loadFilesFromServer:(void (^)(NSArray *files))files {
    [[SQFilesServerManager sharedInstance] getForFilesWithToken:self.accessToken onSuccess:^(NSArray *filesList) {
        if (filesList) {
            files(filesList);
            
        } else {
            files(nil);
        }
        
    } onFailure:^(NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        files(nil);
    }];
}



@end
