//
//  SQFilesAPI.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import "SQFileSelectorProtocol.h"


@interface SQFilesAPI : NSObject

// instance for protocol delegate
@property (nonatomic) id <SQFileSelectorProtocol> delegate;
@property (nonatomic) BOOL closeButton;

@property (strong, nonatomic) NSString *selectedFileID;
@property (strong, nonatomic) NSString *videoFileName;

// designated initializer
+ (instancetype)sharedInstance;


- (void)loadFilesWithToken:(NSString *)accessToken
               closeButton:(BOOL)closeButton
      selectedFileDelegate:(id <SQFileSelectorProtocol>)delegate
                    result:(void(^)(BOOL success))success;


@end
