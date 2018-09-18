//
//  FlashlightEncoder.h
//  MorseRelay
//
//  Created by Nicolas Degen on 14.07.18.
//  Copyright © 2018 nide. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlashlightEncoder : NSObject
-(id) init;
-(void) emitMorseWord: (NSString*) word;
-(void) emitMorseMessage: (NSString*) message;
-(void) cancelMorseEmission;
@end
