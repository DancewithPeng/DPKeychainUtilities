//
//  DPKeychainUtilitiesTests.m
//  DPKeychainUtilitiesTests
//
//  Created by 张鹏 on 2020/12/2.
//

#import <XCTest/XCTest.h>
#import <DPKeychainUtilities/DPKeychainUtilities.h>

@interface DPKeychainUtilitiesTests : XCTestCase

@end

@implementation DPKeychainUtilitiesTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testAddItem {
    NSDictionary *item = @{
        (__bridge_transfer NSString *)kSecClass: (__bridge_transfer NSString *)kSecClassGenericPassword,
        (__bridge_transfer NSString *)kSecAttrAccount: @"18675515266",
        (__bridge_transfer NSString *)kSecValueData: [@"123456" dataUsingEncoding:NSUTF8StringEncoding],
    };

    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)item, nil);
    XCTAssert(status == errSecSuccess, "添加不成功");
    
    NSLog(@"添加数据项到钥匙串成功^_^");
}

- (void)testSaveAccountPassword {
    NSError *error = nil;
    [DPKeychainCoordinator.defaultCoordinator saveAccount:@"18675515266"
                                                 password:@"1234567890"
                                                forDomain:@"woshipm.com"
                                                    error:&error];
    XCTAssertNil(error);
}

@end
