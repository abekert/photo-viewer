//
//  Scene.h
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import "Frame.h"

@interface Scene : SCNScene
{
    NSInteger xPosition;
}
@property (strong) Frame *frame;
@property (nonatomic, readonly) NSMutableArray *pictures;

- (void)loadPicturesAtURLs:(NSArray *)urls;
- (void)loadPicturesAtURLs:(NSArray *)urls withCompletion:(void (^)(void))block;
- (void)focusSpotlightAt:(SCNNode *)node;

@end