//
//  SQFilesHelper.m
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQFilesHelper.h"
#import "SQSectionInfo.h"
#import "SQFilesContainer.h"


// fileCategory name for UI
static NSString *const SAMPLE_ALL_FILES_CATEGORY_NAME       = @"All";
static NSString *const SAMPLE_MEN_FILES_CATEGORY_NAME       = @"Men";
static NSString *const SAMPLE_WOMEN_FILES_CATEGORY_NAME     = @"Women";

static NSString *const UPLOADED_FILES_CATEGORY_NAME     = @"Uploaded";
static NSString *const SHARED_FILES_CATEGORY_NAME       = @"Shared";
static NSString *const APPLICATION_FILES_CATEGORY_NAME  = @"From Apps";
static NSString *const ALTRUIST_FILES_CATEGORY_NAME     = @"Altruist";

// fileCategory name in response
static NSString *const SAMPLE_FILES_CATEGORY_TAG        = @"Community";
static NSString *const UPLOADED_FILES_CATEGORY_TAG      = @"Uploaded";
static NSString *const SHARED_FILES_CATEGORY_TAG        = @"SharedToMe";
static NSString *const APPLICATION_FILES_CATEGORY_TAG   = @"FromApps";
static NSString *const ALTRUIST_FILES_CATEGORY_TAG      = @"AllWithAltruist";


@implementation SQFilesHelper


#pragma mark -
#pragma mark Parse Files

+ (void)parseFilesMainArray:(NSArray *)filesMainArray
                withHandler:(FilesCallback)callback {

    // For each category/section, set up a corresponding SectionInfo object to contain the category name, list of files and height for each row.
    NSMutableArray *sampleInfoArray = [[NSMutableArray alloc] init];    // array for section info for sample files
    NSMutableArray *myInfoArray     = [[NSMutableArray alloc] init];    // array for section info for my files
    
    SQSectionInfo *sectionSampleAll     = [[SQSectionInfo alloc] initWithName:SAMPLE_ALL_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionSampleMen     = [[SQSectionInfo alloc] initWithName:SAMPLE_MEN_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionSampleWomen   = [[SQSectionInfo alloc] initWithName:SAMPLE_WOMEN_FILES_CATEGORY_NAME];
    
    SQSectionInfo *sectionUploaded      = [[SQSectionInfo alloc] initWithName:UPLOADED_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionShared        = [[SQSectionInfo alloc] initWithName:SHARED_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionFromApps      = [[SQSectionInfo alloc] initWithName:APPLICATION_FILES_CATEGORY_NAME];
    SQSectionInfo *sectionAltruist      = [[SQSectionInfo alloc] initWithName:ALTRUIST_FILES_CATEGORY_NAME];
    
    NSArray *categories = @[SAMPLE_FILES_CATEGORY_TAG,
                            UPLOADED_FILES_CATEGORY_TAG,
                            SHARED_FILES_CATEGORY_TAG,
                            APPLICATION_FILES_CATEGORY_TAG,
                            ALTRUIST_FILES_CATEGORY_TAG];
    
    for (int i = 0; i < [filesMainArray count]; i++) {
        
        NSDictionary *tempFile = [filesMainArray objectAtIndex:i];
        NSString *tempCategoryName = [tempFile objectForKey:@"FileCategory"];
        int category = (int)[categories indexOfObject:tempCategoryName];
        
        switch (category) {
            case 0: {   // Sample Files Category
                [self addFile:tempFile intoSection:sectionSampleAll];
                
                if ([[tempFile objectForKey:@"Sex"] containsString:@"Male"]) {
                    [self addFile:tempFile intoSection:sectionSampleMen];
                } else {
                    [self addFile:tempFile intoSection:sectionSampleWomen];
                }
            } break;
                
            case 1: {   // Uploaded Files Category
                [self addFile:tempFile intoSection:sectionUploaded];
            } break;
            
            case 2: {   // Shared Files Category
                [self addFile:tempFile intoSection:sectionShared];
            } break;
            
            case 3: {   // From Apps Files Category
                [self addFile:tempFile intoSection:sectionFromApps];
            } break;
                
            case 4: {   // Altruist Files Category
                [self addFile:tempFile intoSection:sectionAltruist];
            } break;
                
            default:
                break;
        }   // end of switch
    }   // end of for cycle
    
    // saving sections/categories to main Sample Array
    if ([sectionSampleAll.filesArray count] > 0) {
        [sampleInfoArray addObject:sectionSampleAll];
    }
    if ([sectionSampleMen.filesArray count] > 0) {
        [sampleInfoArray addObject:sectionSampleMen];
    }
    if ([sectionSampleWomen.filesArray count] > 0) {
        [sampleInfoArray addObject:sectionSampleWomen];
    }
    
    // saving sections/categories to main My Array
    if ([sectionUploaded.filesArray count] > 0) {
        [myInfoArray addObject:sectionUploaded];
    }
    if ([sectionShared.filesArray count] > 0) {
        [myInfoArray addObject:sectionShared];
    }
    if ([sectionFromApps.filesArray count] > 0) {
        [myInfoArray addObject:sectionFromApps];
    }
    if ([sectionAltruist.filesArray count] > 0) {
        [myInfoArray addObject:sectionAltruist];
    }
    
    // return back the result
    callback(myInfoArray, sampleInfoArray);
}


#pragma mark -
#pragma mark Add file into section

+ (void)addFile:(NSDictionary *)file intoSection:(SQSectionInfo *)section {
    CGFloat tempHeight = 44.f;
    
    if ([section.sectionName containsString:@"Sample"] || [section.sectionName containsString:@"All"] || [section.sectionName containsString:@"Men"] || [section.sectionName containsString:@"Women"]) {
        
        //calculate height for sample file
        
        // NSString *tempText = [self prepareTextFromFile:file AndFileType:section.sectionName];
        NSAttributedString *tempText = [self prepareTextFromSampleFile:file];
        tempHeight = [self heightForRowSampleFile:tempText];
        
    } else {
        // otherwise calculate height for my file
        
        NSString *tempText = [self prepareTextFromMyFile:file];
        tempHeight = [self heightForRow:tempText];
    }
    
    [section addFile:file withHeight:tempHeight];
}


#pragma mark -
#pragma mark Height for row

+ (CGFloat)heightForRow:(NSString *)text {
    UIFont *font = [UIFont systemFontOfSize:13.f];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0, -1);
    shadow.shadowBlurRadius = 0.5;
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    [paragraph setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraph setAlignment:NSTextAlignmentLeft];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                font, NSFontAttributeName,
                                paragraph, NSParagraphStyleAttributeName,
                                shadow, NSShadowAttributeName, nil];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(270, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    if (CGRectGetHeight(rect) < 42.960938f) {
        return 44.0f;
    } else {
        return CGRectGetHeight(rect) + 10;
    }
}


+ (CGFloat)heightForRowSampleFile:(NSAttributedString *)text {
    CGRect rect = [text boundingRectWithSize:CGSizeMake(260, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        context:nil];
    if (CGRectGetHeight(rect) < 40.f) {
        return 44.0f;
    } else {
        return CGRectGetHeight(rect) + 15;
    }
}


#pragma mark -
#pragma mark Prepare text

+ (NSString *)prepareTextFromMyFile:(NSDictionary *)file {
    NSMutableString *preparedText = [[NSMutableString alloc] init];
    NSString *filename = [file objectForKey:@"Name"];
    NSString *tempString = [NSString stringWithFormat:@"%@", filename];
    [preparedText appendString:tempString];
    return [preparedText copy];
}


+ (NSAttributedString *)prepareTextFromSampleFile:(NSDictionary *)file {
    // NSMutableString *preparedText = [[NSMutableString alloc] init];
    
    NSString *friendlyDesk1 = [file objectForKey:@"FriendlyDesc1"];
    NSString *friendlyDesk2 = [file objectForKey:@"FriendlyDesc2"];
    
    NSString *tempString = [NSString stringWithFormat:@"%@\n%@", friendlyDesk1, friendlyDesk2];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:tempString];
    
    [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.f] range:NSMakeRange(0, [friendlyDesk1 length])];
    [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.f] range:NSMakeRange([friendlyDesk1 length] + 1, [friendlyDesk2 length])];
    
    // [preparedText appendString:attString];
    return [attString copy];
}


+ (NSString *)prepareText:(NSDictionary *)demoText {
    NSMutableString *preparedText = [[NSMutableString alloc] init];
    NSArray *keys = [NSArray arrayWithArray:[demoText allKeys]];
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString *key in sortedKeys) {
        id obj = [demoText objectForKey:key];
        NSString *tempString = [NSString stringWithFormat:@"%@: %@\n", key, obj];
        [preparedText appendString:tempString];
    }
    
    return preparedText;
}

@end
