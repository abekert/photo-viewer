//
//  AppDelegate.h
//  PhotoViewer
//
//  Created by Alexander Bekert on 26.11.13.
//  Copyright (c) 2013 Alexander Bekert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SceneView.h"
#import "Scene.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet SceneView *view;
@property (strong) Scene *scene;


@end
