//
//  SceneView.h
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface SceneView : SCNView
{
    NSInteger currentPhotoIndex;
    
    NSArray *videoFormats;
}
@property SCNMaterial *selectedMaterial;

@end
