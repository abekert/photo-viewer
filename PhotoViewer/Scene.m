//
//  Scene.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "Scene.h"

@implementation Scene

- (id)init
{
    self = [super init];
    if (self) {
        [self addContent];
        [self addCamera];
        xPosition = 0;
    }
    
    return self;
}

- (void)addContent
{
    [self addFloor];
    [self addLight];
//    [self addFrameWithImage:nil];
    [self addText:@"Drag your photos here"];
}

#pragma mark Camera

- (void)addCamera
{
    SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = [SCNCamera camera];
	cameraNode.position = SCNVector3Make(70, 50, 120);
    cameraNode.rotation = SCNVector4Make(1, 0, 0, -M_PI_2 / 4);
    
    cameraNode.light = [SCNLight light];
    cameraNode.light.type = SCNLightTypeSpot;

    [cameraNode.light setAttribute:@1 forKey:SCNLightSpotInnerAngleKey];
    [cameraNode.light setAttribute:@100 forKey:SCNLightSpotOuterAngleKey];
    
    cameraNode.camera.zFar = 10000;
    cameraNode.name = @"camera";
    
    [self.rootNode addChildNode:cameraNode];
}

- (void)adjustCamera
{
    SCNNode *cameraNode = [self.rootNode childNodeWithName:@"camera" recursively:YES];

    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:0.5];
    [SCNTransaction setCompletionBlock:^{
        
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.3];

        cameraNode.camera.focalDistance = 130;
        cameraNode.camera.focalBlurRadius = 10;
        cameraNode.camera.focalSize = 60;
        cameraNode.camera.aperture = 0.5;

        [SCNTransaction commit];

    }];
    
    cameraNode.camera.focalDistance = 2;
    cameraNode.camera.focalBlurRadius = 16;
    cameraNode.camera.focalSize = 80;
    cameraNode.camera.aperture = 1;
    
    [SCNTransaction commit];
}

- (void)resetCamera
{
    SCNNode *cameraNode = [self.rootNode childNodeWithName:@"camera" recursively:YES];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:2];
    
    cameraNode.camera.focalDistance = 0;
    cameraNode.camera.focalBlurRadius = 0;
    cameraNode.camera.focalSize = 0;
    cameraNode.camera.aperture = 0;
    
    [SCNTransaction commit];
}

#pragma mark Floor

- (void)addFloor
{
    SCNFloor *floor = [SCNFloor floor];
    SCNNode *floorNode = [SCNNode node];
    floor.reflectivity = 0.5;
    floor.reflectionFalloffStart = 0.0;
    floor.reflectionFalloffEnd = 5.0;
    
    NSImage *image = [NSImage imageNamed:@"floor-frames"];
    image.size = NSSizeFromCGSize(CGSizeMake(2000, 20000));
    floor.firstMaterial.diffuse.contents = image;
    
    floor.firstMaterial.diffuse.wrapS = SCNRepeat;
    floor.firstMaterial.diffuse.wrapT = SCNRepeat;

    floorNode.geometry = floor;
    [self.rootNode addChildNode:floorNode];
}

#pragma mark Light

- (void)addLight
{
    [self addSpotLight];
}

- (void)addSpotLight
{
    SCNNode *lightNode = [SCNNode node];
    
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeSpot;
    lightNode.position = SCNVector3Make(60, 25, 20);
    [lightNode.light setAttribute:@1 forKey:SCNLightSpotInnerAngleKey];
    [lightNode.light setAttribute:@300 forKey:SCNLightSpotOuterAngleKey];
    [lightNode.light setAttribute:@1000 forKey:SCNLightShadowFarClippingKey];

    lightNode.name = @"spotlight";
    [self.rootNode addChildNode:lightNode];
}

- (void)focusSpotlightAt:(Frame *)frame
{
    SCNNode *spotLight = [self.rootNode childNodeWithName:@"spotlight" recursively:YES];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:2];
    
    spotLight.position = frame.spotlightPosition;
    spotLight.constraints = @[[SCNLookAtConstraint lookAtConstraintWithTarget:frame]];
    
    [SCNTransaction commit];
}

#pragma mark Text

- (void)addText:(NSString *)textString
{
    SCNMaterial *material = [[SCNMaterial alloc] init];
    material.emission.contents = [NSColor blackColor];
    material.diffuse.contents = [NSColor whiteColor];
    material.lightingModelName = SCNLightingModelBlinn;
    
    SCNText *text = [SCNText textWithString:textString extrusionDepth:10];
    text.font = [NSFont fontWithName:@"Arial" size:14];
    text.materials = @[material];
    text.alignmentMode = kCAAlignmentNatural;
    
    SCNNode *textNode = [SCNNode nodeWithGeometry:text];
    textNode.name = @"text";
    textNode.position = SCNVector3Make(0, 0, -100);
    textNode.opacity = 0;
    [self.rootNode addChildNode:textNode];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:2];
    
    textNode.position = SCNVector3Make(0, 0, 0);
    textNode.opacity = 1;

    [SCNTransaction commit];
}

- (void)hideTextWithCompletion:(void (^)(void))block
{
    SCNNode *textNode = [self.rootNode childNodeWithName:@"text" recursively:YES];
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:2];
    [SCNTransaction setCompletionBlock:^{
        [textNode removeFromParentNode];
        if (block) {
            block();
        };
    }];
    textNode.position = SCNVector3Make(0, 0, 100);
    textNode.opacity = 0;
    
    [SCNTransaction commit];
}

#pragma mark Pictures

- (void)loadPicturesAtURLs:(NSArray *)urls
{
    [self loadPicturesAtURLs:urls withCompletion:nil];
}

- (void)loadPicturesAtURLs:(NSArray *)urls withCompletion:(void (^)(void))block
{
    SCNNode *cameraNode = [self.rootNode childNodeWithName:@"camera" recursively:YES];
    cameraNode.rotation = SCNVector4Make(0, 0, 0, 0);
    
    [self clearPictures];
    _pictures = [[NSMutableArray alloc] initWithCapacity:urls.count];
    
    for (NSURL *url in urls) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
        Frame *frame = [self addFrameWithImage:image];
        frame.position = SCNVector3Make(frame.position.x + xPosition, frame.position.y, frame.position.z);

        xPosition += 100;
        
        [_pictures addObject:frame];
    }
    [self focusSpotlightAt:_pictures[0]];
    [self hideTextWithCompletion:block];
    [self adjustCamera];
}

- (Frame *)addFrameWithImage:(NSImage *)image
{
    Frame *frame = [[Frame alloc] initWithImage:image];
    [self.rootNode addChildNode:frame];
    frame.name = @"frame";

    frame.opacity = 0;
    frame.position = SCNVector3Make(frame.position.x, frame.position.y + 50, frame.position.z - 200);
    
    [SCNTransaction begin];
    [SCNTransaction setAnimationDuration:2];

    frame.position = SCNVector3Make(frame.position.x, frame.position.y, frame.position.z + 200);
    frame.opacity = 1;
    
    [SCNTransaction commit];

    return frame;
}


- (void)clearPictures
{
    xPosition = 0;
    for (SCNNode *node in _pictures) {
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2];
        [SCNTransaction setCompletionBlock:^{
            [node removeFromParentNode];
        }];
        
        node.position = SCNVector3Make(node.position.x, node.position.y, node.position.z + 200);
        node.opacity = 0;
        
        [SCNTransaction commit];

    }
    
    [_pictures removeAllObjects];
    _pictures = nil;
}

@end
