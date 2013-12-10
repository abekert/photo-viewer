//
//  Frame.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26/11/13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "Frame.h"

#define FRAME_HIGHT 60

@implementation Frame

- (id)initWithImage:(NSImage *)newImage
{
    self = [super init];
    if (self) {
        image = newImage;
        
        [self addFrame];
        [self setFrameImage];
    }
    
    return self;
}

- (void)addFrame
{
    frame = [self addChildNodeNamed:@"frame-layer" fromSceneNamed:@"frames"];
}

- (Orientation)orientation
{
    if (image) {
        if (image.size.height > image.size.width) {
            return OrientationVertical;
        }
    }
    
    return OrientationHorizontal;
}

- (void)setFrameImage
{
    SCNNode *photoNode = [frame childNodeWithName:@"frame" recursively:YES];
    
    if ([self orientation] == OrientationVertical) {
        photoNode.rotation = SCNVector4Make(0, 1, 0, M_PI);
        frame.position = SCNVector3Make(frame.position.x - 50, frame.position.y - 50, frame.position.z);
        
        image = [self rotateIndividualImage:image clockwise:NO];
    }
    else
    {
        photoNode.rotation = SCNVector4Make(0, 1, 0, M_PI_2);
    }
    
    SCNMaterial *photoMaterial = [photoNode.geometry materialWithName:@"photo"];
    photoMaterial.diffuse.contents = image;
}

- (void)placeImage:(NSImage *)newImage
{
    image = newImage;
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

#pragma mark Positions

- (SCNVector3)cameraPosition
{
    return SCNVector3Make(self.position.x + 20, self.position.y + 15, self.position.z + 100);
}

- (SCNVector3)spotlightPosition
{
    return SCNVector3Make(self.position.x, self.position.y + 50, self.position.z + 10);
}

#pragma mark Rotate

- (NSImage *)rotateIndividualImage: (NSImage *)sourceImage clockwise: (BOOL)clockwise
{
    NSImage *existingImage = sourceImage;
    NSSize existingSize = sourceImage.size;
    
    /**
     * Get the size of the original image in its raw bitmap format.
     * The bestRepresentationForDevice: nil tells the NSImage to just
     * give us the raw image instead of it's wacky DPI-translated version.
     */
//    existingSize.width = [[existingImage bestRepresentationForDevice: nil] pixelsWide];
//    existingSize.height = [[existingImage bestRepresentationForDevice: nil] pixelsHigh];
    
    NSSize newSize = NSMakeSize(existingSize.height, existingSize.width);
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:newSize];
    
    [rotatedImage lockFocus];
    
    /**
     * Apply the following transformations:
     *
     * - bring the rotation point to the centre of the image instead of
     *   the default lower, left corner (0,0).
     * - rotate it by 90 degrees, either clock or counter clockwise.
     * - re-translate the rotated image back down to the lower left corner
     *   so that it appears in the right place.
     */
    NSAffineTransform *rotateTF = [NSAffineTransform transform];
    NSPoint centerPoint = NSMakePoint(newSize.width / 2, newSize.height / 2);
    
    [rotateTF translateXBy: centerPoint.x yBy: centerPoint.y];
    [rotateTF rotateByDegrees: (clockwise) ? - 90 : 90];
    [rotateTF translateXBy: -centerPoint.y yBy: -centerPoint.x];
    [rotateTF concat];
    
    /**
     * We have to get the image representation to do its drawing directly,
     * because otherwise the stupid NSImage DPI thingie bites us in the butt
     * again.
     */
    NSRect r1 = NSMakeRect(0, 0, newSize.height, newSize.width);
    [[existingImage bestRepresentationForDevice: nil] drawInRect: r1];
    
    [rotatedImage unlockFocus];
    
    return rotatedImage;
}

@end
