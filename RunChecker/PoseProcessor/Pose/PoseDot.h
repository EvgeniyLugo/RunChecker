//
//  PoseDot.h
//  PoseReader
//
//  Created by Evgeniy Lugovoy on 15.11.2019.
//  Copyright © 2019 MeadowsPhoneTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface PoseDot : NSObject

///Номер опорной точки
@property (nonatomic) int dotNumber;
///Позиция опорной точки
@property (nonatomic) simd_int2 dotPos;

@end

NS_ASSUME_NONNULL_END
