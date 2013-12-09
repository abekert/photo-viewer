//
//  SceneView.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "SceneView.h"
#import "Scene.h"

@implementation SceneView

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setCamera];
    }
    
    return self;
}

- (void)setCamera
{
    SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = [SCNCamera camera];
	cameraNode.position = SCNVector3Make(0, 5, 100);
    cameraNode.rotation = SCNVector4Make(0, 0, 0, 0);
    cameraNode.camera.zFar = 1000000;
    
    self.scene.rootNode.camera = cameraNode.camera;
    self.pointOfView = cameraNode;
}

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
    if ([[pasteboard types] containsObject:NSURLPboardType]) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pasteboard];
        
        NSString *pathExtension = [fileURL pathExtension];
        
        if (([pathExtension isEqualToString:@"jpg"]) ||
            ([pathExtension isEqualToString:@"jpeg"]) ||
            ([pathExtension isEqualToString:@"png"]))
        {
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
        
        NSArray *urls = [pasteboard readObjectsForClasses:@[[NSURL class]] options:nil];
        for (NSURL *url in urls) {
            NSLog(@"%@\n", url.path);
        }
        
        
//        NSURL *fileURL = [NSURL URLFromPasteboard:pasteboard];
//        NSLog(@"%@", fileURL.description);
        
        Scene *scene = (Scene *)self.scene;
//        [scene.frame placeImageWithImageURL:fileURL];
        [scene loadPicturesAtURLs:urls];
        
//        [self loadSceneAtURL:fileURL];
        return YES;
    }
    
    return NO;
}

@end
