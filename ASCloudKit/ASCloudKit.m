//
//  ASCloudKit.m
//  ASCloudKit
//
//  Created by Hasan Adil on 5/31/15.
//  Copyright (c) 2015 Assemble Labs. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "ASCloudKit.h"

@interface ASCloudKit()

@property (nonatomic, strong) dispatch_queue_t clouldQueue;

@end

@implementation ASCloudKit

#pragma mark accessors

-(dispatch_queue_t) clouldQueue {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        _clouldQueue = dispatch_queue_create("cloud", DISPATCH_QUEUE_CONCURRENT);
    });
    return _clouldQueue;
}

#pragma mark outgoing

-(void) modifyPublicRecordOfType:(NSString*)recordType usingDictionary:(NSDictionary*)info
                    withProgress:(void(^)(double progress, NSError *error))progress
                   andCompletion:(void(^)(NSArray *saved, NSArray *deleted, NSError *error))completion {
    
    CKRecord* record = [[CKRecord alloc] initWithRecordType:recordType];
    NSArray* keys = [info allKeys];
    for (NSString* key in keys) {
        [record setObject:info[key] forKey:key];
    }
    
    CKModifyRecordsOperation* operation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[record] recordIDsToDelete:@[]];
    [operation setModifyRecordsCompletionBlock:^(NSArray *saved, NSArray *deleted, NSError *error) {
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil, error);
                });
            }
        }
        else {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(saved, deleted, nil);
                });
            }
        }
    }];
    
    [operation setPerRecordProgressBlock:^(CKRecord *record, double progressAmount) {
        if (progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                progress(progressAmount, nil);
            });
        }
    }];
    
    CKContainer* container = [CKContainer defaultContainer];
    CKDatabase* cloudDatabase = [container publicCloudDatabase];
    [cloudDatabase addOperation:operation];
}

#pragma mark incoming

-(void) performPublicQueryForRecordOfType:(NSString*)recordType usingPredicate:(NSPredicate*)predicate withCompletion:(void(^)(NSArray* results, NSError* error))completion {
    
    CKQuery* query = [[CKQuery alloc] initWithRecordType:recordType predicate:predicate];
    CKContainer* container = [CKContainer defaultContainer];
    CKDatabase* cloudDatabase = [container publicCloudDatabase];
    [cloudDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *records, NSError *error) {
        if (error) {
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, error);
                });
            }
        }
        else {
            if (records) {
                NSMutableArray* results = [NSMutableArray array];
                for (CKRecord* record in records) {
                    NSMutableDictionary* info = [NSMutableDictionary dictionary];
                    
                    NSArray* keys = [record allKeys];
                    for (NSString* key in keys) {
                        id value = [record objectForKey:key];
                        [info setObject:value forKey:key];
                    }
                    
                    [results addObject:[NSDictionary dictionaryWithDictionary:info]];
                }
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion([NSArray arrayWithArray:results], nil);
                    });
                }
            }
            else {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, error);
                    });
                }
            }
            
            /*
            if (records && [records count] > 0) {
                
                
                CKRecord* record = [records objectAtIndex:0];
                NSString* routeJson = [record objectForKey:@"route"];
                NSData* routeData = [routeJson dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* routeDict = [NSJSONSerialization JSONObjectWithData:routeData options:0 error:&error];
                NSString* kml = [routeDict objectForKey:@"kml"];
                
                NSNumber* n = [routeDict objectForKey:@"type"];
                ASRouteType routeType = (ASRouteType)n.integerValue;
                
                ASRoute* route = [me createRouteForMap:mapToImportInto ofType:routeType withTitle:@"Imported" andKml:kml andColor:colorHex];
                
                NSError* error = nil;
                [route.managedObjectContext save:&error];
                if (error) {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil, nil, error);
                        });
                    }
                }
                else {
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion(nil, route, nil);
                        });
                    }
                }
            }
            else {
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, nil, nil);
                    });
                }
            }
             */
        }
        
    }];
}

@end





































