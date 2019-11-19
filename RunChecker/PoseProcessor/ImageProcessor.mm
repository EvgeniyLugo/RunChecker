//
//  ImageProcessing.m
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 19.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//

#import "ImageProcessor.h"
#include "TfliteWrapper.h"
#include "PoseParse.hpp"
#import <simd/simd.h>

using namespace std;
using namespace cv;

@implementation ImageProcessor
{
    UIViewController<ImageProcessorDelegate> * delegate;
    TfliteWrapper  *tfLiteWrapper;
    CDecodePose *pDecodePose;
    float minPoseConfidence;
    float minPartConfidence;
    int maxPoseDection;
    map<int, map<int, vector<int> > > result;
}

-(id) initWithController: (UIViewController<ImageProcessorDelegate>*)c
{
    delegate = c;
    tfLiteWrapper = [[TfliteWrapper alloc]init];
    tfLiteWrapper = [tfLiteWrapper initWithModelFileName:@"multi_person_mobilenet_v1_075_float"];
    if(![tfLiteWrapper setUpModelAndInterpreter])
    {
        NSLog(@"Failed To Load Model");
        return self;
    }
    
    minPoseConfidence = 0.5;
    minPartConfidence = 0.1;
    maxPoseDection = 5;
    pDecodePose = new CDecodePose();

    return self;

}

- (void)processImage:(Mat &)frame {
    cv::Mat small;
    int height = frame.rows;
    int width = frame.cols;
    cv::resize(frame, small, cv::Size(pDecodePose->m_inputWidth, pDecodePose->m_inputHeight), 0, 0, CV_INTER_LINEAR);
    float_t *input = [tfLiteWrapper inputTensortFloatAtIndex:0];
    //NSLog(@"Input: %f", *input);
    
    //BGRA2RGB
    int inputCnt=0;
    for (int row = 0; row < small.rows; row++)
    {
        uchar* data = small.ptr(row);
        for (int col = 0; col < small.cols; col++)
        {
            input[inputCnt++] = (float)data[col * 4 + 2]/255.0; // Red
            input[inputCnt++] = (float)data[col * 4 + 1]/255.0; // Green
            input[inputCnt++] = (float)data[col * 4 ]/255.0; // Bule
        }
    }
    
    if([tfLiteWrapper invokeInterpreter])
    {
        result.clear();
        float_t *score = [tfLiteWrapper outputTensorAtIndex:0];
        float_t *shortOffset  = [tfLiteWrapper outputTensorAtIndex:1];
        float_t *middleOffset = [tfLiteWrapper outputTensorAtIndex:2];
        pDecodePose->decode(score, shortOffset, middleOffset, result);
    }
    
    int poseCnt = 0;
    Pose *pose = [[Pose alloc] init];
    map<int, map<int, vector<int> > >::reverse_iterator it;
    for(it = result.rbegin(); it != result.rend(); ++it)
    {
        if(poseCnt++ > maxPoseDection)
            break;
        
        if(it->first/INT_TO_FLOAT < minPoseConfidence)
            break;
        
//        NSLog(@"Output: score [%d]", it->first);
        
        if(it->second.size() != pDecodePose->m_kCnt)
        {
            NSLog(@"Warning: Pose Count[%lu] ！= 17", it->second.size() );
            continue;
        }
        
        pose.personNumber = poseCnt - 1;
        
        for(int i=0; i< it->second.size(); i++)
        {
            PoseDot *dot = [[PoseDot alloc] init];
            dot.dotNumber = i;
            float score = it->second[i][5]/INT_TO_FLOAT;
            if(score < minPartConfidence)
                continue;
            
            int pointH = int((it->second[i][6]/10000.0) * height);
            int pointW = int((it->second[i][7]/10000.0) * width);
            simd_int2 point;
            point.x = pointH;
            point.y = pointW;
            dot.dotPos = point;
            [pose.dots addObject:dot];
            cv::Point center = cv::Point(pointW, pointH);
            if (i == 5) {
                cv::circle(frame, center, 8, Scalar(127,0,0), 2);
            }
            else if (i == 6) {
                cv::circle(frame, center, 8, Scalar(0,127,0), 2);
            }
            else if (i == 11) {
                cv::circle(frame, center, 8, Scalar(0,0,127), 3);
            }
            else if (i == 12) {
                cv::circle(frame, center, 8, Scalar(127,127,0), 3);
            }
            else {
                cv::circle(frame, center, 5, Scalar(0,255,255));
            }
        }
        
        for(int i=0; i < pDecodePose->m_eCnt; i++)
        {
            int srcKeypoint = pDecodePose->m_childOrder[i];
            int tagKeypoint = pDecodePose->m_parentOrder[i];
            float srcScore = it->second[srcKeypoint][5]/INT_TO_FLOAT;
            float tagScore = it->second[tagKeypoint][5]/INT_TO_FLOAT;
            if(srcScore < minPartConfidence || tagScore < minPartConfidence)
                continue;
            
            int srcH = int((it->second[srcKeypoint][6]/INT_TO_FLOAT) * height);
            int srcW = int((it->second[srcKeypoint][7]/INT_TO_FLOAT) * width);
            int tagH = int((it->second[tagKeypoint][6]/INT_TO_FLOAT) * height);
            int tagW = int((it->second[tagKeypoint][7]/INT_TO_FLOAT) * width);

            cv::line(frame,cv::Point(srcW, srcH), cv::Point(tagW, tagH), Scalar(255,0,255));
//            NSLog(@"Output: [%d], [%d] - [%d] [%d] -> [%d] [%d]", srcKeypoint, tagKeypoint, srcH, srcW, tagH, tagW);
        }
        [delegate poseIsReady:pose];
    }
//    NSLog(@"Output: ------");
    return;
}

@end
