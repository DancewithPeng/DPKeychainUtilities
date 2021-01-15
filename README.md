# DPKeychainUtilities

方便使用的钥匙串工具

[TOC]

## 导入

### Cocoapods

```ruby
pod 'DPKeychainUtilities', '~> 1.0.0'
```

## 使用

### 密码相关操作

保存密码

```objc
NSError *error = nil;
[DPKeychainCoordinator.defaultCoordinator savePassword:@"123456" forAccount:@"186xxxxxx" domain:@"dpdev.cn" error:&error];
if (error) {
    NSLog(@"%@", error);
} else {
    NSLog(@"密码保存成功");
}
```

> 如果对应的账号的密码已经存在，则会更新密码，如不存在，则会新增

获取密码

```objc
NSError *error = nil;
NSString *password =
[DPKeychainCoordinator.defaultCoordinator fetchPasswordForAccount:@"186xxxxxx" domain:@"dpdev.cn" error:&error];
if (error) {
    NSLog(@"%@", error);
} else {
    NSLog(@"密码获取成功: %@", password);
}
```

删除密码

```objc
NSError *error = nil;
[DPKeychainCoordinator.defaultCoordinator deletePasswordForAccount:@"186xxxxxx" domain:@"dpdev.cn" error:&error];
if (error) {
    NSLog(@"%@", error);
} else {
    NSLog(@"密码删除成功");
}
```

### 通用数据相关操作

保存数据

```objc
NSString *str = @"Hello World";
[DPKeychainCoordinator.defaultCoordinator saveData:[str dataUsingEncoding:NSUTF8StringEncoding] forKey:@"demo" service:@"user.demo" error:&error];
if (error) {
    NSLog(@"%@", error);
} else {
    NSLog(@"数据保存成功");
}
```

获取数据

```objc
NSError *error = nil;
NSNumber *data =
[DPKeychainCoordinator.defaultCoordinator fetchDataForKey:@"demo" service:@"user.demo" error:&error];
if (error) {
    NSLog(@"%@", error);
} else {
		NSLog(@"数据获取成功: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
}

```

删除数据

```objc
NSError *error = nil;
[DPKeychainCoordinator.defaultCoordinator deleteDataForKey:@"demo" service:@"user.demo" error:&error];
if (error) {
    NSLog(@"%@", error);
} else {
    NSLog(@"数据删除成功");
}
```

#### 通用数据便捷操作

为了方便处理常用数据，同时提供了Object、String、Number和Bool类型的便捷操作方法：

- `- saveObject:forKey:service:error:`
- `- fetchObjectForClass:key:service:error:`

- `- saveNumber:forKey:service:error:`
- `- fetchNumberForKey:service:error:`
- `- saveString:forKey:service:error:`
- `- fetchStringForKey:service:error:`
- `- saveBool:forKey:service:error:`
- `- fetchBoolForKey:service:error:`

###  Access Group

如果需要使用Keychain Access Group相关功能，只需要通过groupID来获取DPKeychainCoordinator对象即可

```objc
[[DPKeychainCoordinator coordinatorWithGroupID:@"group.mygroup.id"] saveBool:YES forKey:@"isGreat" service:@"user.demo" error:&error];;
```



## LICENSE

DPKeychainUtilities is released under the MIT license. See [LICENSE](LICENSE)for details.

