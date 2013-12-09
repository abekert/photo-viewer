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
        [self addText:@"Hello"];
        xPosition = 0;
    }
    
    return self;
}

- (void)addContent
{
    [self addFloor];
//    [self addFrameWithImage:nil];
//    [self addText:@"Hello"];
}

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


- (Frame *)addFrameWithImage:(NSImage *)image
{
    Frame *frame = [[Frame alloc] initWithImage:image];
    [self.rootNode addChildNode:self.frame];
    frame.name = @"frame";
    
    return frame;
}

- (void)addText:(NSString *)textString
{
    SCNMaterial *material = [[SCNMaterial alloc] init];
    material.emission.contents = [NSColor blackColor];
    material.diffuse.contents = [NSColor blueColor];
    material.lightingModelName = SCNLightingModelBlinn;
    
    SCNText *text = [SCNText textWithString:textString extrusionDepth:10];
    text.font = [NSFont fontWithName:@"Arial" size:14];
    text.materials = @[material];
    text.alignmentMode = kCAAlignmentCenter;
    
    SCNNode *textNode = [SCNNode nodeWithGeometry:text];
    textNode.position = SCNVector3Make(-70, -3, 0);
    [self.rootNode addChildNode:textNode];
}

- (void)loadPicturesAtURLs:(NSArray *)urls
{
    for (NSURL *url in urls) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:url];
        Frame *frame = [self addFrameWithImage:image];
        frame.position = SCNVector3Make(-xPosition, -10, 0);
        xPosition += 100;
    }
}

@end
