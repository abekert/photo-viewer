//
//  SceneView.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "SceneView.h"
#import "Scene.h"
#import "Frame.h"

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
	cameraNode.position = SCNVector3Make(0, 200, 10);
    cameraNode.rotation = SCNVector4Make(0, 0, 0, 0);
    cameraNode.camera.zFar = 1000000;
    [self.scene.rootNode addChildNode:cameraNode];
    
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
    
    // Load a scene
    Scene *scene = [Scene scene];
    self.scene = scene;
    
    // Setup camera
    SCNNode *cameraNode = [scene.rootNode childNodeWithName:@"camera" recursively:YES];
    self.pointOfView = cameraNode;

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
        
        if ([[NSImage imageFileTypes] containsObject:pathExtension])
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
        NSMutableArray *confirmedUrls = [[NSMutableArray alloc] initWithCapacity:urls.count];
        
        for (NSURL *url in urls) {
//            NSLog(@"%@\n", url.path);
            NSString *pathExtension = [url pathExtension];
            if ([[NSImage imageFileTypes] containsObject:pathExtension])
                [confirmedUrls addObject:url];
        }
        
        Scene *scene = (Scene *)self.scene;
        [scene loadPicturesAtURLs:confirmedUrls withCompletion:^{
            [self accentCameraAtPhotoWithIndex:0];
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)accentCameraAtPhotoWithIndex:(NSInteger)index
{
    Scene *scene = (Scene *)self.scene;
    NSArray *pictures = scene.pictures;
    if ((!pictures) ||
        (pictures.count == 0))
        return;
    
    if (index < 0) {
        index = pictures.count - 1;
    }
    else
        index = index % pictures.count;
    currentPhotoIndex = index;
    
    Frame *picture = scene.pictures[index];
    SCNNode *cameraNode = [scene.rootNode childNodeWithName:@"camera" recursively:YES];
    
    // Move spotlight
    [scene focusSpotlightAt:picture];
    
    //long duration
    float duration = 2.0;
    
    //animate the point of view with default timing function
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [SCNTransaction setCompletionBlock:^{
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:duration];
        cameraNode.position = picture.cameraPosition;
        [SCNTransaction commit];
    }];
    cameraNode.constraints = @[[SCNLookAtConstraint lookAtConstraintWithTarget:picture]];

    [SCNTransaction commit];
}

- (void)keyUp:(NSEvent *)theEvent
{
    switch( [theEvent keyCode] ) {
        case 126:       // up arrow
        case 125:       // down arrow
        case 124:       // right arrow
            currentPhotoIndex++;
            [self accentCameraAtPhotoWithIndex:currentPhotoIndex];
            break;
            
        case 123:       // left arrow
            currentPhotoIndex--;
            [self accentCameraAtPhotoWithIndex:currentPhotoIndex];
            break;
            
            NSLog(@"Arrow key pressed!");
            break;
        default:
            NSLog(@"Key pressed: %@", theEvent);
            break;
    }
}

@end
