//
//  BMSettings.m
//  BeMotion
//
//  Created by Govinda Pingali on 2/14/16.
//  Copyright © 2016 Plasmatio Tech. All rights reserved.
//

#import "BMSettings.h"
#import "BMConstants.h"
#import "BMAudioController.h"

static NSString* const kRanOnceKey          = @"settings.ranOnce";
static NSString* const kIndexPathsKey       = @"settings.sampleIndexPaths";

@implementation BMSettings


#pragma mark - Init

- (id)init {
    
    if ((self = [super init])) {
        [self load];
    }
    
    return self;
}


#pragma mark - Singleton

+ (instancetype)userSettings {
    static BMSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BMSettings alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark - Interface methods

- (void)save {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    
    // Saving Ran Once
    [defaults setObject:[NSNumber numberWithBool:self.ranOnce] forKey:kRanOnceKey];
    
    
    // Saving Sample Index Paths
    NSMutableArray* trackIndexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumTracks; i++) {
        BMIndexPath* indexPath = [[BMAudioController sharedController] getIndexPathForTrack:i];
        NSArray* array = [[NSArray alloc] initWithObjects:@(indexPath.library), @(indexPath.section), @(indexPath.index), nil];
        [trackIndexPaths addObject:array];
    }
    [defaults setObject:trackIndexPaths forKey:kIndexPathsKey];
    
    
    [defaults synchronize];
}



#pragma mark - Private Methods


- (void)load {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    // Loading Ran Once
    _ranOnce = [defaults boolForKey:kRanOnceKey];
    
    
    // Loading Index Paths
    
    if (_ranOnce) {
        
        NSArray* indexPaths = (NSArray*)[defaults objectForKey:kIndexPathsKey];
        for (int i=0; i < indexPaths.count; i++) {
            NSArray* array = (NSArray*)[indexPaths objectAtIndex:i];
            BMIndexPath* path = [[BMAudioController sharedController] getIndexPathForTrack:i];
            path.library = [[array objectAtIndex:0] intValue];
            path.section = [[array objectAtIndex:1] intValue];
            path.index   = [[array objectAtIndex:2] intValue];
            if ([[BMAudioController sharedController] loadAudioFileIntoTrack:i atIndexPath:path] != 0) {
                NSLog(@"Error Loading Audio File at NSUserDefaults!");
            }
        }
        
    } else {
        
        for (int i=0; i < kNumTracks; i++) {
            BMIndexPath* path = [[BMAudioController sharedController] getIndexPathForTrack:i];
            path.library = 0;
            path.section = 0;
            path.index = i;
            if ([[BMAudioController sharedController] loadAudioFileIntoTrack:i atIndexPath:path] != 0) {
                NSLog(@"Error Loading Audio File at NSUserDefaults!");
            }
        }
    }
}


@end
