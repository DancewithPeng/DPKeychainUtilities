//
//  DPKeychainCoordinator.m
//  DPKeychainUtilities
//
//  Created by 张鹏 on 2020/12/3.
//

#import "DPKeychainCoordinator.h"

/// 协调器错误域
NSString * const DPKeychainCoordinatorErrorDomain = @"com.dp.DPKeychainUtilities.CoordinatorEror";

@interface DPKeychainCoordinator ()

/// 钥匙串访问组ID
@property (nonatomic, copy, nullable) NSString *keychainAccessGroupID;

@end

@implementation DPKeychainCoordinator

#pragma mark - Initializations

+ (instancetype)defaultCoordinator {
    return [[DPKeychainCoordinator alloc] init];
}

+ (instancetype)coordinatorWithGroupID:(NSString *)keychainAccessGroupID {
    DPKeychainCoordinator *coordinator = [[DPKeychainCoordinator alloc] init];
    coordinator.keychainAccessGroupID = keychainAccessGroupID;
    return coordinator;
}

#pragma mark - Interfaces

// 保存账号密码
- (void)savePassword:(NSString *)password
          forAccount:(NSString *)account
              domain:(NSString *)domain
               error:(NSError *__autoreleasing  _Nullable *)error {
    
    [self saveItemWithClass:(__bridge_transfer NSString *)kSecClassInternetPassword
                 attributes:@{
                     (__bridge_transfer NSString *)kSecAttrServer: domain,
                     (__bridge_transfer NSString *)kSecAttrAccount: account,
                 }
                      value:[password dataUsingEncoding:NSUTF8StringEncoding]
                      error:error];
}

// 获取密码
- (nullable NSString *)fetchPasswordForAccount:(NSString *)account
                                        domain:(NSString *)domain
                                         error:(NSError *__autoreleasing  _Nullable *)error {
    CFTypeRef result =
    [self fetchItemWithClass:(__bridge_transfer NSString *)kSecClassInternetPassword
                       query:@{
                           (__bridge_transfer NSString *)kSecAttrServer: domain,
                           (__bridge_transfer NSString *)kSecAttrAccount: account,
                           (__bridge_transfer NSString *)kSecReturnData: @(YES),
                       }
                       error:error];
    if (*error) {
        return nil;
    }
    
    NSData *data = (__bridge_transfer NSData *)result;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

// 删除密码
- (void)deletePasswordForAccount:(NSString *)account
                          domain:(NSString *)domain
                           error:(NSError *__autoreleasing  _Nullable *)error {
    [self deleteItemWithClass:(__bridge_transfer NSString *)kSecClassInternetPassword
                        query:@{
                            (__bridge_transfer NSString *)kSecAttrServer: domain,
                            (__bridge_transfer NSString *)kSecAttrAccount: account,
                        }
                        error:error];
}

// 保存数据
- (void)saveData:(NSData *)data
          forKey:(NSString *)key
         service:(NSString *)service
           error:(NSError *__autoreleasing  _Nullable *)error {
        
    NSDictionary *query = @{
        (__bridge_transfer NSString *)kSecAttrAccount: key,
    };
    query = [self reconstructQuery:query withService:service];
    
    [self saveItemWithClass:(__bridge_transfer NSString *)kSecClassGenericPassword
                 attributes:query
                      value:data
                      error:error];
}

// 获取数据
- (NSData *)fetchDataForKey:(NSString *)key
                    service:(NSString *)service
                      error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSDictionary *query = @{
        (__bridge_transfer NSString *)kSecAttrAccount: key,
        (__bridge_transfer NSString *)kSecReturnData: @(YES),
    };
    query = [self reconstructQuery:query withService:service];
    
    CFTypeRef result =
    [self fetchItemWithClass:(__bridge_transfer NSString *)kSecClassGenericPassword
                       query:query
                       error:error];
    if (*error) {
        return nil;
    }
    
    NSData *data = (__bridge_transfer NSData *)result;
    return data;
}

// 删除数据
- (void)deleteDataForKey:(NSString *)key
                 service:(NSString *)service
                   error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSDictionary *query = @{
        (__bridge_transfer NSString *)kSecAttrAccount: key,
    };
    query = [self reconstructQuery:query withService:service];
    
    [self deleteItemWithClass:(__bridge_transfer NSString *)kSecClassGenericPassword
                        query:query
                        error:error];
}

#pragma mark - Helper Methods

/// 保存Item到Keychain
- (void)saveItemWithClass:(NSString *)class
               attributes:(nullable NSDictionary *)attributes
                    value:(NSData *)value
                    error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithDictionary:@{
        (__bridge_transfer NSString *)kSecClass: class,
    }];
    
    if (attributes.count > 0) {
        [item addEntriesFromDictionary:attributes];
    }
    
    if (self.keychainAccessGroupID && self.keychainAccessGroupID.length > 0) {
        [item setObject:self.keychainAccessGroupID forKey:(__bridge_transfer NSString *)kSecAttrAccessGroup];
    }
    
    if (value) {
        [item setObject:value forKey:(__bridge_transfer NSString *)kSecValueData];
    }
    
    // 添加Item
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)item, nil);
    
    if (status == errSecMissingEntitlement) {
        // 没有权限
        *error = [self permissionDeniedError];
        return;
    }
    
    if (status == errSecDuplicateItem) {
        // 更新密码
        [self updateItemWithClass:class query:attributes attributes:attributes value:value error:error];
        return;
    }
    
    // 操作失败
    if (status != errSecSuccess) {
        *error = [self unknownErrorWithOSStatus:status];
        return;
    }
}

/// 更新Keychain Item
- (void)updateItemWithClass:(NSString *)class
                      query:(nullable NSDictionary *)query
                 attributes:(nullable NSDictionary *)attributes
                      value:(NSData *)value
                      error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSMutableDictionary *queryOptions = [[NSMutableDictionary alloc] initWithDictionary:@{
        (__bridge_transfer NSString *)kSecClass: class,
    }];
    
    if (query) {
        [queryOptions addEntriesFromDictionary:query];
    }
    
    if (self.keychainAccessGroupID && self.keychainAccessGroupID.length > 0) {
        [queryOptions setObject:self.keychainAccessGroupID forKey:(__bridge_transfer NSString *)kSecAttrAccessGroup];
    }
    
    NSMutableDictionary *newValues = [[NSMutableDictionary alloc] initWithDictionary:@{
        (__bridge_transfer NSString *)kSecValueData: value,
    }];
    
    if (attributes.count > 0) {
        [newValues addEntriesFromDictionary:attributes];
    }
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)queryOptions, (__bridge CFDictionaryRef)newValues);
    
    if (status == errSecMissingEntitlement) {
        // 没有权限
        *error = [self permissionDeniedError];
        return;
    }
    
    if (status == errSecItemNotFound) {
        *error = [self itemNotExistsError];
        return;
    }
    
    if (status != errSecSuccess) {
        *error = [self unknownErrorWithOSStatus:status];
        return;
    }
}

/// 获取Item数据，包括保存的数据及标识属性
- (nullable CFTypeRef)fetchItemWithClass:(NSString *)class
                                   query:(NSDictionary *)query
                                   error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSMutableDictionary *queryOptions = [[NSMutableDictionary alloc] initWithDictionary:@{
        (__bridge_transfer NSString *)kSecClass: class,
    }];
    
    if (query) {
        [queryOptions addEntriesFromDictionary:query];
    }
    
    if (self.keychainAccessGroupID && self.keychainAccessGroupID.length > 0) {
        [queryOptions setObject:self.keychainAccessGroupID forKey:(__bridge_transfer NSString *)kSecAttrAccessGroup];
    }
    
    CFTypeRef result;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)queryOptions, &result);
    
    if (status == errSecMissingEntitlement) {
        // 没有权限
        *error = [self permissionDeniedError];
        return nil;
    }
    
    if (status == errSecItemNotFound) {
        *error = [self itemNotExistsError];
        return nil;
    }
    
    if (status != errSecSuccess) {
        *error = [self unknownErrorWithOSStatus:status];
        return nil;
    }
    
    return result;
}

/// 获取Item数据，包括保存的数据及标识属性
- (void)deleteItemWithClass:(NSString *)class
                      query:(NSDictionary *)query
                      error:(NSError *__autoreleasing  _Nullable *)error {
    
    NSMutableDictionary *queryOptions = [[NSMutableDictionary alloc] initWithDictionary:@{
        (__bridge_transfer NSString *)kSecClass: class,
    }];
    
    if (query) {
        [queryOptions addEntriesFromDictionary:query];
    }
    
    if (self.keychainAccessGroupID && self.keychainAccessGroupID.length > 0) {
        [queryOptions setObject:self.keychainAccessGroupID forKey:(__bridge_transfer NSString *)kSecAttrAccessGroup];
    }
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)queryOptions);
    
    if (status == errSecMissingEntitlement) {
        // 没有权限
        *error = [self permissionDeniedError];
        return;
    }
    
    if (status == errSecItemNotFound) {
        *error = [self itemNotExistsError];
        return;
    }
    
    if (status != errSecSuccess) {
        *error = [self unknownErrorWithOSStatus:status];
        return;
    }
}

/// 为query添加service属性
- (NSDictionary *)reconstructQuery:(NSDictionary *)query withService:(NSString *)service {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:query];
    
    if (service == nil) {
        service = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    }
    
    if (service) {
        [result setObject:service forKey:(__bridge_transfer NSString *)kSecAttrService];
    }
    
    return result;
}

/// 生成数据项不存在的错误
- (NSError *)itemNotExistsError {
    return [NSError errorWithDomain:DPKeychainCoordinatorErrorDomain
                               code:DPKeychainCoordinatorErrorCodeItemNotExists
                           userInfo:@{
                               NSLocalizedFailureReasonErrorKey: [self localizedStringForKey:@"itemNotExistsErrorMessage"],
                           }];
}

/// 生成没有数据权限的错误
- (NSError *)permissionDeniedError {
    return [NSError errorWithDomain:DPKeychainCoordinatorErrorDomain
                               code:DPKeychainCoordinatorErrorCodePermissionDenied
                           userInfo:@{
                               NSLocalizedFailureReasonErrorKey: [self localizedStringForKey:@"permissionDeniedErrorMessage"],
                           }];
}

/// 生成未知的错误
- (NSError *)unknownErrorWithOSStatus:(OSStatus)status {
    return [NSError errorWithDomain:DPKeychainCoordinatorErrorDomain
                               code:DPKeychainCoordinatorErrorCodeUnknownError
                           userInfo:@{
                               NSLocalizedFailureReasonErrorKey: [self localizedStringForKey:@"unknownErrorMessage"],
                               @"OSStatus": @(status)
                           }];
}

/// 获取本地化字符串
- (NSString *)localizedStringForKey:(NSString *)key {
    return NSLocalizedStringFromTableInBundle(key,
                                              @"Localized",
                                              [NSBundle bundleForClass:DPKeychainCoordinator.class],
                                              "错误提示");
}

@end

/// 基础数据类型的操作方法
@implementation DPKeychainCoordinator (BasicDataType)

/// 保存对象
- (void)saveObject:(id<NSCoding>)object
           forKey:(NSString *)key
          service:(nullable NSString *)service
            error:(NSError **)error {
    NSData *data;
    if (@available(iOS 11.0, *)) {
        data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:error];
    } else {
        data = [NSKeyedArchiver archivedDataWithRootObject:object];
    }
    
    if (*error) {
        return;
    }
    [self saveData:data forKey:key service:service error:error];
}

/// 获取对象
- (id<NSCoding>)fetchObjectForClass:(Class)cls
                                key:(NSString *)key
                            service:(NSString *)service
                              error:(NSError *__autoreleasing  _Nullable *)error {
    NSData *data =
    [self fetchDataForKey:key service:service error:error];
    if (*error) {
        return nil;
    }
    
    id result;
    if (@available(iOS 11.0, *)) {
        result = [NSKeyedUnarchiver unarchivedObjectOfClass:cls fromData:data error:error];
    } else {
        result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if (*error) {
        return nil;
    }
    
    return result;
}

/// 保存字符串
- (void)saveString:(NSString *)string
            forKey:(NSString *)key
           service:(NSString *)service
             error:(NSError *__autoreleasing  _Nullable *)error {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self saveData:data forKey:key service:service error:error];
}

/// 获取字符串
- (NSString *)fetchStringForKey:(NSString *)key
                        service:(NSString *)service
                          error:(NSError *__autoreleasing  _Nullable *)error {
    NSData *data =
    [self fetchDataForKey:key service:service error:error];
    if (*error) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

/// 保存数值
- (void)saveNumber:(NSNumber *)number
            forKey:(NSString *)key
           service:(NSString *)service
             error:(NSError *__autoreleasing  _Nullable *)error {
    [self saveObject:number forKey:key service:service error:error];
}

/// 获取数值
- (NSNumber *)fetchNumberForKey:(NSString *)key
                        service:(NSString *)service
                          error:(NSError *__autoreleasing  _Nullable *)error {
    id number =
    [self fetchObjectForClass:NSNumber.class key:key service:service error:error];
    if (*error) {
        return nil;
    }
    return number;
}

/// 保存布尔值
- (void)saveBool:(BOOL)boolValue
          forKey:(NSString *)key
         service:(NSString *)service
           error:(NSError *__autoreleasing  _Nullable *)error {
    [self saveNumber:@(boolValue) forKey:key service:service error:error];
}

/// 获取布尔值
- (BOOL)fetchBoolForKey:(NSString *)key
                service:(NSString *)service
                  error:(NSError *__autoreleasing  _Nullable *)error {
    NSNumber *number =
    [self fetchNumberForKey:key service:service error:error];
    if (*error) {
        return NO;
    }
    return number.boolValue;
}

@end

