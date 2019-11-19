//
//  Pose.m
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 19.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//

#import "Pose.h"

@implementation Pose

- (id) init {
    self = [super init];
    
    self.dots = [[NSMutableArray alloc] init];
    
    return self;
}

@end
