//
//  Frame.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26/11/13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "Frame.h"

@implementation Frame

- (id)initWithImage:(NSImage *)newImage
{
    self = [super init];
    if (self) {
        image = newImage;
        
//        [self initTestImage];
        
        [self addFrame];
        [self setFrameApects];
        [self setFrameImage];
    }
    
    return self;
}

- (void)initTestImage
{
    NSString *path = [[NSBundle bundleWithPath:@"~/Pictures"] pathForResource:@"Fallout-3-01" ofType:@"jpeg"];
    image = [[NSImage alloc] initWithContentsOfFile:path];
}

- (void)addFrame
{
    frame = [self addChildNodeNamed:@"Frame" fromSceneNamed:@"Frame"];
}

- (void)setFrameApects
{
    if (!image) {
        return;
    }
    
    float basicScale = 0.1;
    
    float x = 1 * basicScale * image.size.width / image.size.height;
    float y = 2 * basicScale * image.size.height / image.size.width;
    float z = basicScale;
    
    frame.scale = SCNVector3Make(x, y, z);
}

- (void)setFrameImage
{
    SCNNode *photoNode = [frame childNodeWithName:@"Photo" recursively:YES];
    
//    SCNMaterial *newPhotoMaterial = [SCNMaterial material];
    
    SCNMaterial *photoMaterial = [photoNode.geometry materialWithName:@"Photo"];
    photoMaterial.diffuse.contents = image;
}

- (void)placeImage:(NSImage *)newImage
{
    image = newImage;
    [self setFrameApects];
    [self setFrameImage];
}

- (void)placeImageWithImagePath:(NSString *)path
{
    image = [[NSImage alloc] initWithContentsOfFile:path];
    [self placeImage:image];
}

- (void)placeImageWithImageURL:(NSURL *)url
{
    image = [[NSImage alloc] initWithContentsOfURL:url];
    [self placeImage:image];
}

@end
