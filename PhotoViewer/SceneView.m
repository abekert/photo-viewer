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
{
    NSInteger currentPhotoIndex;
    NSArray *videoFormats;
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
    
    // Video formats
    videoFormats = @[@"m4v", @"mpg", @"mp4"];
    
    // Debug Info
//    self.showsStatistics = YES;
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

- (NSDragOperation)dragOperationForPasteboard:(NSPasteboard *)pasteboard {
    if ([[pasteboard types] containsObject:NSURLPboardType]) {
        NSURL *fileURL = [NSURL URLFromPasteboard:pasteboard];
        
        NSString *pathExtension = [fileURL pathExtension];
        
        if ([[NSImage imageFileTypes] containsObject:pathExtension])
        {
            return NSDragOperationCopy;
        }
        
        if ([videoFormats containsObject:pathExtension]) {
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
        NSMutableArray *photoUrls = [[NSMutableArray alloc] initWithCapacity:urls.count];
        NSMutableArray *videoUrls = [[NSMutableArray alloc] initWithCapacity:urls.count];

        for (NSURL *url in urls) {
            NSString *pathExtension = [url pathExtension];
            if ([[NSImage imageFileTypes] containsObject:pathExtension])
                [photoUrls addObject:url];
        }
        
        for (NSURL *url in urls) {
            NSString *pathExtension = [url pathExtension];
            if ([videoFormats containsObject:pathExtension])
                [videoUrls addObject:url];
        }
        
        Scene *scene = (Scene *)self.scene;
        [scene loadPicturesAtURLs:photoUrls videosURLs:videoUrls withCompletion:^{
            [self accentCameraAtPhotoWithIndex:0 needToPutOutOfFocus:NO];
        }];

        
        return YES;
    }
    
    return NO;
}

#pragma mark Transitions

- (void)accentCameraAtPhotoWithIndex:(NSInteger)index needToPutOutOfFocus:(BOOL)needToPutOutOfFocus
{
    Scene *scene = (Scene *)self.scene;
    NSArray *pictures = scene.frames;
    
    if ((!pictures) || (pictures.count == 0))
        return;
    
    // Correct index if needed
    if (index < 0) {
        index = pictures.count - 1;
    }
    else
        index = index % pictures.count;
    
    // Put current picture out of focus
    if (needToPutOutOfFocus) {
        [scene.frames[currentPhotoIndex] putOutFocus];
    }

    // Save new photo index
    currentPhotoIndex = index;
    
    Frame *picture = scene.frames[index];
    SCNNode *cameraNode = [scene.rootNode childNodeWithName:@"camera" recursively:YES];
    
    // Put picture in focus
    [picture putInFocus];
    
    // Move spotlight
    [scene focusSpotlightAt:picture];
    
    // Camera
    SCNVector3 destinationCamera = picture.cameraPosition;
    SCNVector4 temporaryRotation = [self cameraRotationForCameraPosition:cameraNode.position andPicture:picture];
    SCNVector4 destinationRotation = [self cameraRotationForCameraPosition:destinationCamera andPicture:picture];

    // Animate transaction
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [SCNTransaction setCompletionBlock:^{
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2];
        cameraNode.position = destinationCamera;
        cameraNode.rotation = destinationRotation;
        cameraNode.camera.focalSize = scene.defaultFocalSize;
        [SCNTransaction commit];
    }];
    
    cameraNode.rotation = temporaryRotation;
    cameraNode.camera.focalSize = 200;
    [SCNTransaction commit];
}

- (SCNVector4)cameraRotationForCameraPosition:(SCNVector3)cameraPosition andPicture:(SCNNode *)node
{
    double angle = atan(fabs(cameraPosition.x - node.position.x) / fabs(cameraPosition.z - node.position.z));
    
    if (cameraPosition.x > node.position.x) {
        return SCNVector4Make(0, 1, 0, angle);
    }
    else
        return SCNVector4Make(0, 1, 0, -angle);
}

- (void)keyUp:(NSEvent *)theEvent
{
    switch( [theEvent keyCode] ) {
        case 124:       // right arrow
            [self accentCameraAtPhotoWithIndex:currentPhotoIndex + 1 needToPutOutOfFocus:YES];
            break;
            
        case 123:       // left arrow
            [self accentCameraAtPhotoWithIndex:currentPhotoIndex - 1 needToPutOutOfFocus:YES];
            break;
            
        default:
            break;
    }
}

@end
