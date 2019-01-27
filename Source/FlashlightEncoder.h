//
//  FlashlightEncoder.h
//  MorseRelay
//
//  Created by Nicolas Degen on 14.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlashlightEncoder : NSObject
-(id) init;
-(void) emitMorseWord: (NSString*) word;
-(void) emitMorseMessage: (NSString*) message;
-(void) cancelMorseEmission;
@property void (^terminationCallback)(void); //(void(^)()) terminationCallback;
@property void (^signalAction)(bool); //(void(^)(bool)) signalAction;
@property bool deviceHasTorch;
@end

NS_ASSUME_NONNULL_END
