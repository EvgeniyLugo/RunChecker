//
//  NostalgiaCamera.mm
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 19.11.2019.
//

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h>
#include "NostalgiaCamera.h"
//#include "TfliteWrapper.h"
//#include "PoseParse.hpp"

using namespace std;
using namespace cv;


@interface NostalgiaCamera () <CvVideoCameraDelegate>
@end


@implementation NostalgiaCamera
{
//    UIViewController<NostalgiaCameraDelegate> * delegate;
    UIImageView * imageView;
    CvVideoCamera * videoCamera;
    ImageProcessor * imageProcessor;
}

- (id)initWithProcessor: (ImageProcessor *)processor andImageView:(UIImageView*)iv
{
//    delegate = c;
    imageView = iv;
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView]; // Init with the UIImageView from the ViewController
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack; // Use the back camera
//    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront; // Use the front camera
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait; // Ensure proper orientation
    videoCamera.rotateVideo = YES; // Ensure proper orientation
    videoCamera.defaultFPS = 30; // How often 'processImage' is called, adjust based on the amount/complexity of images
    videoCamera.delegate = self;
    imageProcessor = processor;
    //videoCamera.recordVideo = YES;

    return self;
}

- (void)processImage:(cv::Mat &)frame {
    [imageProcessor processImage:frame];

    return;
}

- (void)start
{
    [videoCamera start];
}

- (void)stop
{
    [videoCamera stop];
}

@end
