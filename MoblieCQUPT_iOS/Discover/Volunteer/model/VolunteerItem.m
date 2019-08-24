//
//  QueryDataModel.m
//  MoblieCQUPT_iOS
//
//  Created by MaggieTang on 12/10/2017.
//  Copyright © 2017 Orange-W. All rights reserved.
//

#import "VolunteerItem.h"

@implementation VolunteerItem

- (void)getVolunteerInfoWithUserName:(NSString *)userName andPassWord:(NSString *)passWord finishBlock:(void (^)(VolunteerItem *volunteer))finish {
//    NSString *url = @"https://getman.cn/mock/volunteer";

    NSString *url = [NSString stringWithFormat:@"http://www.zycq.org/app/api/ver2.0.php?os=3&v=3&m=login&uname=%@&upass=%@", userName, passWord];
    HttpClient *client = [HttpClient defaultClient];
    [client requestWithPath:url method:HttpRequestGet parameters:nil prepareExecute:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *status = responseObject[@"c"];
        if ([status isEqual:[NSNumber numberWithInteger:0]]) {
            self.uid = [NSString stringWithFormat:@"%@", responseObject[@"d"][@"uid"]];
            self.sid = [NSString stringWithFormat:@"%@", responseObject[@"d"][@"sid"]];
            
            NSString *url = [NSString stringWithFormat:@"http://www.zycq.org/app/api/ver2.0.php?os=3&v=3&id=%@&p=1&m=hour_vol", self.uid];
//            NSLog(@"%@, %@",self.uid, [self.uid class]);
//            NSString *encryptPasswd = [self aesEncrypt:self.uid];
//            NSLog(@"'%@'", encryptPasswd);
//            NSString *url = @"https://getman.cn/mock/volunteerEvent";
            [client requestWithPath:url method:HttpRequestGet parameters:nil prepareExecute:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSMutableArray *temp = [NSMutableArray arrayWithCapacity:10];
                for (NSDictionary *dict in responseObject[@"d"][@"list"]) {
                    VolunteeringEventItem *volEvent = [[VolunteeringEventItem alloc] initWithDictinary:dict];
                    [temp addObject:volEvent];
                }
                self.eventsArray = temp;
                [self sortEvents];
                
                NSInteger hour = 0;
                for (VolunteeringEventItem *event in self.eventsArray) {
                    hour += [event.hour integerValue];
                }
                self.hour = [NSString stringWithFormat:@"%ld", hour];
                
                finish(self);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSucceeded" object:nil];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                NSLog(@"请求志愿活动详情失败！-- error:%@", error);
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];
            }];
        } else {
            NSLog(@"登陆失败！");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"登陆失败！ ---- ERROR:%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginFailed" object:nil];
    }];
}

// 加密
-(NSString *)aesEncrypt:(NSString *)plainText{
    NSString *secretkey = @"redrockvolunteer";
    NSString *cipherText = aesEncryptString(plainText, secretkey);
    return cipherText;
}

// 将志愿活动按时间排序
- (void)sortEvents {
    // 获取当前时间
    NSDate  *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    NSInteger year=[components year];
    
    NSMutableArray *allEvents = [NSMutableArray array];
    NSMutableArray *eventInAYear = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        for (VolunteeringEventItem *event in self.eventsArray) {
            if ([[event.creatTime substringToIndex:4] isEqualToString:[NSString stringWithFormat:@"%ld", year - i]]) {
                [eventInAYear addObject:event];
            }
        }
        [allEvents addObject:[eventInAYear mutableCopy]];
        [eventInAYear removeAllObjects];
    }
    self.eventsSortedByYears = allEvents;
}

@end
