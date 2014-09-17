//
//  AppDelegate.h
//  SyncUtil
//
//  Created by Roger Chen on 9/16/14.
//  Copyright (c) 2014 Roger Chen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *textDestination;
@property (weak) IBOutlet NSTextField *textSource;
@property (unsafe_unretained) IBOutlet NSTextView *outputView;

- (IBAction)setDestination:(id)sender;
- (IBAction)setSource:(id)sender;
- (IBAction)startSync:(id)sender;

- (const char*)browse;
- (void)startThreadedTask:(NSTask *)task;

@end
