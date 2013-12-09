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

- (void)loadPicturesAtURLs:(NSArray *)urls;

@end
