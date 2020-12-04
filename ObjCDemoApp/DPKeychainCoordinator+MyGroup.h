//
//  DPKeychainCoordinator+MyGroup.h
//  ObjCDemoApp
//
//  Created by 张鹏 on 2020/12/4.
//

#import <DPKeychainUtilities/DPKeychainUtilities.h>

NS_ASSUME_NONNULL_BEGIN

@interface DPKeychainCoordinator (MyGroup)

@property (nonatomic, readonly, class) DPKeychainCoordinator *groupCoordinator;

@end

NS_ASSUME_NONNULL_END
