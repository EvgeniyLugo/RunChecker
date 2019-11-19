//
//  Pose.h
//  RunChecker
//
//  Created by Evgeniy Lugovoy on 19.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Pose : NSObject
///Номер скелета в общем списке распознанных скелетов
@property (nonatomic) int personNumber;
///Список опорных точек скелета
@property (nonatomic, strong) NSMutableArray *dots;
@end

NS_ASSUME_NONNULL_END
