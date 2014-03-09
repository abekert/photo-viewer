//
//  AppDelegate.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

#pragma mark - Awake from nib

- (void)awakeFromNib {
    // Configure the SCNView.
    self.view.allowsCameraControl = NO;              // Allow the user to manipulate the 3D model using SCNView's default behavior.
    self.view.jitteringEnabled = YES;                 // Improve the antialiasing when the scene is stationary.
    self.view.playing = YES;                          // Play the animations.
    self.view.autoenablesDefaultLighting = YES;       // Automatically light scenes that have no light.
	self.view.backgroundColor = [NSColor blackColor]; // Set a black background.
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}


@end
