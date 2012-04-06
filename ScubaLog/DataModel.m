//
//  DataModel.m
//  ScubaLog
//
//  Created by Kann Vearasilp on 4/2/12.
//  Copyright (c) 2012 Universität Rostock. All rights reserved.
//

#import "DataModel.h"
#import "ScubaLog.h"

@implementation DataModel

@synthesize scubaLogList;


#pragma mark - save and load data

- (NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

- (NSString *)dataFilePath{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"ScubaLog.plist"];
}

- (void)saveScubaLogLists
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:scubaLogList forKey:@"ScubaLogLists"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

- (void)loadScubaLogLists
{
    NSString *path = [self dataFilePath];
    if (([[NSFileManager defaultManager] fileExistsAtPath:path])) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        scubaLogList = [unarchiver decodeObjectForKey:@"ScubaLogLists"];
        [unarchiver finishDecoding];
    } else {
        scubaLogList = [[NSMutableArray alloc] initWithCapacity:20];
    }
}


#pragma mark - Taking care of first time usage

- (void)registerDefault
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithBool:YES], @"FirstTime",
                                nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

- (void)handleFirstTime
{
    BOOL firsttime = [[NSUserDefaults standardUserDefaults] boolForKey:@"FirstTime"];
    if (firsttime) {
        ScubaLog *scubaLog = [[ScubaLog alloc] init];
        scubaLog.name = @"First Dive";
        [scubaLogList addObject:scubaLog];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"FirstTime"];
    }
}


#pragma mark - init

- (id)init
{
    if ((self = [super init])) {
        [self loadScubaLogLists];
        [self registerDefault];
        [self handleFirstTime];
    }

    return self;
}

@end




















