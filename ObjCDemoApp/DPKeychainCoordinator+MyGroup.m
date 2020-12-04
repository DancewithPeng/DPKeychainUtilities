//
//  DPKeychainCoordinator+MyGroup.m
//  ObjCDemoApp
//
//  Created by 张鹏 on 2020/12/4.
//

#import "DPKeychainCoordinator+MyGroup.h"

@implementation DPKeychainCoordinator (MyGroup)

+ (DPKeychainCoordinator *)groupCoordinator {
    static DPKeychainCoordinator *_groupCoordinator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _groupCoordinator = [DPKeychainCoordinator coordinatorWithGroupID:@"group.com.woshipm"];
    });
    return _groupCoordinator;
}

@end
