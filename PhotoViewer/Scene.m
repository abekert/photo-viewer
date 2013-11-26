//
//  Scene.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "Scene.h"

@implementation Scene

//- (id)init
//{
//    self = [super init];
//    if (self) {
////        NSLog(@"Scene init");
////        [self addFrame];
////        
////        self.rootNode.camera.zFar = 1000000;
////        [self addText:@"Hello"];
//    }
//    
//    return self;
//}

- (void)addContent
{
    
    SCNNode *cameraNode = [SCNNode node];
	cameraNode.camera = [SCNCamera camera];
	cameraNode.position = SCNVector3Make(0, 5, 100);
    cameraNode.rotation = SCNVector4Make(0, 0, 0, 0);
    cameraNode.camera.zFar = 1000000;
    
//    self.rootNode.camera = cameraNode;
    
    [self addFloor];
    
    [self addFrame];

}

- (void)addFloor
{
    SCNNode *floorNode = [SCNNode node];
    SCNFloor *floor = [SCNFloor floor];
    floorNode.geometry = floor;
    [self.rootNode addChildNode:floorNode];
    
    NSImage *image = [NSImage imageNamed:@"floor-frames"];
    image.size = NSSizeFromCGSize(CGSizeMake(2000, 20000));
//    floor.firstMaterial.diffuse.contents = image;
    
    SCNMaterial *material = floor.firstMaterial;
    material.diffuse.contents = image;
    [floorNode.geometry insertMaterial:material atIndex:0];
    
    
//    SCNFloor *floor = [SCNFloor floor];
//    SCNNode *floorNode = [SCNNode node];
//    floor.reflectivity = 0.5;
//    floor.reflectionFalloffStart = 0.0;
//    floor.reflectionFalloffEnd = 5.0;
//    
//    NSImage *image = [NSImage imageNamed:@"floor-frames"];
//    image.size = NSSizeFromCGSize(CGSizeMake(2000, 20000));
//    floor.firstMaterial.diffuse.contents = image;
//    
//    floor.firstMaterial.diffuse.wrapS = SCNRepeat;
//    floor.firstMaterial.diffuse.wrapT = SCNRepeat;
//
//    floorNode.geometry = floor;
//    [self.rootNode addChildNode:floorNode];
}


- (void)addFrame
{
//    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Frame" withExtension:@"dae"];
//    SCNScene *scene = [SCNScene sceneWithURL:url options:nil error:nil];
//    SCNNode *nodeToAdd = [SCNNode node];
//    for (SCNNode *node in scene.rootNode.childNodes) {
//        [nodeToAdd addChildNode:node];
//    } ;
//    [self.rootNode addChildNode:nodeToAdd];
    

    [self addChildNodeNamed:@"Frame" fromSceneNamed:@"Frame" withScale:0];
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

- (SCNNode *)addChildNodeNamed:(NSString *)name fromSceneNamed:(NSString *)path withScale:(CGFloat)scale {
    SCNNode *node = nil;
    
    // load the scene from the specified file
    SCNScene *scene = [SCNScene sceneNamed:path];
    
    // retrieve the root node
    node = scene.rootNode;
    
    // search for the node named "childNodeName"
    if (name) {
        node = [node childNodeWithName:name recursively:YES];
    }
    else {
        //take first child if no name is passed
        node = node.childNodes[0];
    }
    
//    if (scale != 0) {
//        // rescale based on the current bounding box and the desired scale
//        // align the node to 0 on the Y axis
//        SCNVector3 min, max;
//        [node getBoundingBoxMin:&min max:&max];
//        
//        GLKVector3 mid = GLKVector3Add(SCNVector3ToGLKVector3(min), SCNVector3ToGLKVector3(max));
//        mid = GLKVector3MultiplyScalar(mid, 0.5);
//        mid.y = min.y; //align on bottom
//        
//        GLKVector3 size = GLKVector3Subtract(SCNVector3ToGLKVector3(max), SCNVector3ToGLKVector3(min));
//        CGFloat maxSize = MAX(MAX(size.x, size.y), size.z);
//        
//        scale = scale / maxSize;
//        mid = GLKVector3MultiplyScalar(mid, scale);
//        mid = GLKVector3Negate(mid);
//        
//        node.scale = SCNVector3Make(scale, scale, scale);
//        node.position = SCNVector3FromGLKVector3(mid);
//    }
    
    // add to the container passed in argument
    [self addChildNode:node];
    
    // return the added node
    return node;
}

- (void)addChildNode:(SCNNode *)node
{
    [[self rootNode] addChildNode:node];
}

@end
