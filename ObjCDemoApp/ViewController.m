//
//  ViewController.m
//  ObjCDemoApp
//
//  Created by 张鹏 on 2020/12/2.
//

#import "ViewController.h"
#import <DPKeychainUtilities/DPKeychainUtilities.h>
#import "DPKeychainCoordinator+MyGroup.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加密码
    NSError *error = nil;
    [DPKeychainCoordinator.defaultCoordinator savePassword:@"123456" forAccount:@"18675515266" domain:@"woshipm.com" error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        NSLog(@"密码保存成功");
    }
    
    NSString *str = @"Hello World";
    [DPKeychainCoordinator.groupCoordinator saveData:[str dataUsingEncoding:NSUTF8StringEncoding] forKey:@"demo" service:@"user.demo" error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        NSLog(@"数据保存成功");
    }
}

- (IBAction)fetchPasswordButtonDidTap:(id)sender {
    NSError *error = nil;
    NSString *password =
    [DPKeychainCoordinator.defaultCoordinator fetchPasswordForAccount:@"18675515266" domain:@"woshipm.com" error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        NSLog(@"密码获取成功: %@", password);
    }
}

- (IBAction)updatePasswordButtonDidTap:(id)sender {
    
    NSError *error = nil;
    [DPKeychainCoordinator.defaultCoordinator savePassword:@"654321" forAccount:@"18675515266" domain:@"woshipm.com" error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        NSLog(@"密码修改成功");
    }
}

- (IBAction)deletePasswordButtonDidTap:(id)sender {
    NSError *error = nil;
    [DPKeychainCoordinator.defaultCoordinator deletePasswordForAccount:@"18675515266" domain:@"woshipm.com" error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        NSLog(@"密码删除成功");
    }
}

- (IBAction)fetchValueButtonDidTap:(id)sender {
    NSError *error = nil;
    NSNumber *data =
//    [DPKeychainCoordinator.defaultCoordinator fetchDataForKey:@"demo" service:@"user.demo" error:&error];
    [DPKeychainCoordinator.defaultCoordinator fetchNumberForKey:@"demo" service:nil error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
//        NSLog(@"数据获取成功: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSLog(@"获取数值成功: %@", data);
    }
}

- (IBAction)updateValueButtonDidTap:(id)sender {
    NSString *str = @"how are you";
    NSError *error = nil;
//    [DPKeychainCoordinator.defaultCoordinator saveData:[str dataUsingEncoding:NSUTF8StringEncoding] forKey:@"demo" service:@"user.demo" error:&error];
    [DPKeychainCoordinator.defaultCoordinator saveNumber:@(19.65) forKey:@"demo" service:nil error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        NSLog(@"数据修改成功");
    }
    
    [[DPKeychainCoordinator coordinatorWithGroupID:@"group.mygroup.id"] saveBool:YES forKey:@"isGreat" service:@"user.demo" error:&error];;
}

- (IBAction)deleteValueButtonDidTap:(id)sender {
    NSError *error = nil;
    [DPKeychainCoordinator.defaultCoordinator deleteDataForKey:@"demo" service:nil error:&error];
    if (error) {
        NSLog(@"%@", error);
    } else {
        NSLog(@"数据删除成功");
    }
}

@end
