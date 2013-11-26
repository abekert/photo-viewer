//
//  SceneView.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "SceneView.h"

@implementation SceneView

- (void)loadSceneAtURL:(NSURL *)url {
    // Clear any current selection.
    self.selectedMaterial = nil;
    
    // Load the specified scene. First create a dictionary containing the options we want.
    NSDictionary *options = @{
                              // Create normals if absent.
                              SCNSceneSourceCreateNormalsIfAbsentKey : @YES,
                              // Optimize the rendering by flattening the scene graph when possible. Note that this would prevent you from animating objects independantly.
                              SCNSceneSourceFlattenSceneKey : @YES
                              };
    
    // Load and set the scene.
    NSError * __autoreleasing error;
    SCNScene *scene = [SCNScene sceneWithURL:url options:options error:&error];
    if (scene) {
        self.scene = scene;
    }
    else {
        NSLog(@"Problem loading scene from %@\n%@", url, [error localizedDescription]);
    }
}

#pragma mark - Init

- (void)commonInit {
    // Register for the URL pasteboard type.
    [self registerForDraggedTypes:@[NSURLPboardType]];
}

- (id)initWithFrame:(NSRect)frameRect {
    if ((self = [super initWithFrame:frameRect])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Drag and drop

/*
 Support drag and drop of new dae files.
 */

- (NSDragOperation)dragOperationForPasteboard:(NSPasteboard *)pasteboard {
    // Only support drags from .dae files.
    if ([[pasteboard types] containsObject:NSURLPboardType]) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pasteboard];
        if ([[fileURL pathExtension] isEqualToString:@"dae"]) {
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return [self dragOperationForPasteboard:[sender draggingPasteboard]];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    return [self dragOperationForPasteboard:[sender draggingPasteboard]];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    
    if ([[pasteboard types] containsObject:NSURLPboardType]) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pasteboard];
        [self loadSceneAtURL:fileURL];
        return YES;
    }
    
    return NO;
}

@end
