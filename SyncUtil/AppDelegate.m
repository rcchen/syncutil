//
//  AppDelegate.m
//  SyncUtil
//
//  Created by Roger Chen on 9/16/14.
//  Copyright (c) 2014 Roger Chen. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (const char*)browse {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    NSInteger clicked = [panel runModal];
    if (clicked == NSFileHandlingPanelOKButton) {
        return [[[panel URL] path] fileSystemRepresentation];
    } else {
        return nil;
    }
}

- (void)quitApplication:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    [NSApp terminate:self];
}

- (IBAction)setSource:(id)sender {
    const char *url = [self browse];
    if (url) {
        [self.textSource setStringValue:[[NSString stringWithUTF8String:url] stringByAppendingString:@"/"]];
    }
}

- (IBAction)setDestination:(id)sender {
    const char *url = [self browse];
    if (url) {
        [self.textDestination setStringValue:[NSString stringWithUTF8String:url]];
    }
}

- (IBAction)startSync:(id)sender {
    
    // Initialize the rsync task
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/rsync"];
    
    // Set arguments for rsync
    NSArray *arguments = [[NSArray alloc] initWithObjects: @"-azP", [self.textSource stringValue], [self.textDestination stringValue], nil];
    [task setArguments:arguments];
    
    // Start a threaded task
    [self startThreadedTask:task];
    
}

- (void)startThreadedTask:(NSTask *)task {
    
    // Pipe data to the output window
    NSPipe *output = [NSPipe pipe];
    [task setStandardOutput:output];
    
    // File handler for streaming to NSScrollView
    NSFileHandle *outputHandler = [output fileHandleForReading];
    [outputHandler readInBackgroundAndNotify];
    
    // Launch threaded task
    [task launch];
    
    // Termination observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(taskDidTerminate:)
                                                 name:NSTaskDidTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateOutputView:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:outputHandler];
    
}

- (void)updateOutputView:(NSNotification *)notification {
    NSData *data = [[notification userInfo] objectForKey:@"NSFileHandleNotificationDataItem"];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString *attr = [[NSAttributedString alloc] initWithString:output];
        [[self.outputView textStorage] appendAttributedString:attr];
        [[self.outputView textStorage] setFont:[NSFont userFixedPitchFontOfSize:10.0]];
        [self.outputView scrollRangeToVisible:NSMakeRange([[self.outputView string] length], 0)];
    });
    
    [[notification object] readInBackgroundAndNotify];
}

- (void)taskDidTerminate:(NSNotification *)notification {
    NSLog(@"We done here");
}

@end
