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

@property (nonatomic, readonly) NSMutableArray *frames;

- (void)focusSpotlightAt:(SCNNode *)node;
- (double)defaultFocalSize;

- (void)loadPicturesAtURLs:(NSArray *)urls videosURLs:(NSArray *)videoURLs withCompletion:(void (^)(void))block;

@end
