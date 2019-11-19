//
//  ImageProcessing.h
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 19.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PoseDot.h"
#import "Pose.h"

NS_ASSUME_NONNULL_BEGIN
// Protocol for callback action
@protocol ImageProcessorDelegate <NSObject>
- (void)poseIsReady:(Pose *)pose;
@end

@interface ImageProcessor : NSObject
-(id) initWithController: (UIViewController<ImageProcessorDelegate>*)c;
#ifdef __cplusplus
- (void)processImage:(cv::Mat &)frame;
#endif
@end

NS_ASSUME_NONNULL_END
