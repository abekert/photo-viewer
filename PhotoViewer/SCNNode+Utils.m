//
//  SCNNode+Utils.m
//  PhotoViewer
//
//  Created by Alexander Bekert on 26/11/13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import "SCNNode+Utils.h"

@implementation SCNNode (Utils)

- (SCNNode *)addChildNodeNamed:(NSString *)name fromSceneNamed:(NSString *)path {
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
    
    // add to the container passed in argument
    [self addChildNode:node];
    
    // return the added node
    return node;
}

@end
