//
//  NostalgiaCamera.h
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 19.11.2019.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageProcessor.h"

//// Protocol for callback action
//@protocol NostalgiaCameraDelegate <NSObject>
//
//- (void)matchedItem;
//
//@end

// Public interface for camera. ViewController only needs to init, start and stop.
@interface NostalgiaCamera : NSObject

//-(id) initWithController: (UIViewController<NostalgiaCameraDelegate>*)c processor: (ImageProcessor *)p andImageView: (UIImageView*)iv;
-(id) initWithProcessor: (ImageProcessor *)processor andImageView: (UIImageView*)iv;
-(void)start;
-(void)stop;

@end
