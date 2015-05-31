//
//  ASCloudKit.h
//  ASCloudKit
//
//  Created by Hasan Adil on 5/31/15.
//  Copyright (c) 2015 Assemble Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASCloudKit : NSObject

-(void) modifyPublicRecordOfType:(NSString*)recordType usingDictionary:(NSDictionary*)info
                    withProgress:(void(^)(double progress, NSError *error))progress
                   andCompletion:(void(^)(NSArray *saved, NSArray *deleted, NSError *error))completion;

-(void) performPublicQueryForRecordOfType:(NSString*)recordType usingPredicate:(NSPredicate*)predicate withCompletion:(void(^)(NSArray* results, NSError* error))completion;

@end
