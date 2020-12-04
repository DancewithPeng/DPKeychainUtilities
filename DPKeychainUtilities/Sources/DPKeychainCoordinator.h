//
//  DPKeychainCoordinator.h
//  DPKeychainUtilities
//
//  Created by 张鹏 on 2020/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 协调器错误域
extern NSString * const DPKeychainCoordinatorErrorDomain;

/// 协调器错误码
typedef NS_ENUM(NSUInteger, DPKeychainCoordinatorErrorCode) {
    /// 未知错误
    DPKeychainCoordinatorErrorCodeUnknownError,
    /// 重复项
    DPKeychainCoordinatorErrorCodeDuplicateItem,
    /// 没有权限
    DPKeychainCoordinatorErrorCodePermissionDenied,
    /// 数据项不存在
    DPKeychainCoordinatorErrorCodeItemNotExists,
};

/// 钥匙串协调器
@interface DPKeychainCoordinator : NSObject

/// 默认的协调器
+ (instancetype)defaultCoordinator;

/// 根据钥匙串访问组ID创建协调器
/// @param keychainAccessGroupID 钥匙串访问组ID
+ (instancetype)coordinatorWithGroupID:(NSString *)keychainAccessGroupID;

/// 保存账号-密码
/// @param account 账号
/// @param password 密码
/// @param domain 域名
/// @param error 错误
- (void)savePassword:(NSString *)password
          forAccount:(NSString *)account
              domain:(NSString *)domain
               error:(NSError **)error;

/// 获取密码
/// @param account 对应的账号
/// @param domain 对应的域名
/// @param error 错误
- (nullable NSString *)fetchPasswordForAccount:(NSString *)account
                                        domain:(NSString *)domain
                                         error:(NSError **)error;

/// 删除密码
/// @param account 对应的账号
/// @param domain 对应的域名
/// @param error 错误
- (void)deletePasswordForAccount:(NSString *)account
                          domain:(NSString *)domain
                           error:(NSError **)error;

/// 保存数据
/// @param data 要保存的数据
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (void)saveData:(NSData *)data
          forKey:(NSString *)key
         service:(nullable NSString *)service
           error:(NSError **)error;

/// 获取数据
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (nullable NSData *)fetchDataForKey:(NSString *)key
                             service:(nullable NSString *)service
                               error:(NSError **)error;

/// 删除数据
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (void)deleteDataForKey:(NSString *)key
                 service:(nullable NSString *)service
                   error:(NSError **)error;

@end

/// 基础数据类型的操作方法
@interface DPKeychainCoordinator (BasicDataType)

/// 保存对象
/// @param object 对象
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (void)saveObject:(id<NSCoding>)object
            forKey:(NSString *)key
           service:(nullable NSString *)service
             error:(NSError **)error;

/// 获取对象
/// @param cls 对象类型
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (nullable id<NSCoding>)fetchObjectForClass:(Class)cls
                                         key:(NSString *)key
                                     service:(nullable NSString *)service
                                       error:(NSError **)error;

/// 保存数值
/// @param number 数值
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (void)saveNumber:(NSNumber *)number
            forKey:(NSString *)key
           service:(nullable NSString *)service
             error:(NSError **)error;

/// 获取数值
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (nullable NSNumber *)fetchNumberForKey:(NSString *)key
                                 service:(nullable NSString *)service
                                   error:(NSError **)error;

/// 保存字符串
/// @param string 字符串
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (void)saveString:(NSString *)string
            forKey:(NSString *)key
           service:(nullable NSString *)service
             error:(NSError **)error;

/// 获取字符串
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (nullable NSString *)fetchStringForKey:(NSString *)key
                                 service:(nullable NSString *)service
                                   error:(NSError **)error;

/// 保存布尔值
/// @param boolValue 数值
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (void)saveBool:(BOOL)boolValue
          forKey:(NSString *)key
         service:(nullable NSString *)service
           error:(NSError **)error;

/// 获取布尔值
/// @param key 对应的key
/// @param service 对应的服务（模块）标识，如果不设置，则使用App的Bundle ID
/// @param error 错误
- (BOOL)fetchBoolForKey:(NSString *)key
                service:(nullable NSString *)service
                  error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
