//
//  ViewController.m
//  定位
//
//  Created by 魏忠海 on 16/6/7.
//  Copyright © 2016年 魏忠海. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *cllocationM;
@property (weak, nonatomic) IBOutlet UILabel *latitude;
@property (weak, nonatomic) IBOutlet UILabel *longitude;
@property (weak, nonatomic) IBOutlet UILabel *altitude;
@property (weak, nonatomic) IBOutlet UILabel *speed;
@property (weak, nonatomic) IBOutlet UILabel *course;
@property (weak, nonatomic) IBOutlet UILabel *averageVelocity;
@property (weak, nonatomic) IBOutlet UILabel *averageVelocitysmall;
@property (weak, nonatomic) IBOutlet UILabel *TotalDistance;
- (IBAction)begin:(UIButton *)sender;

- (IBAction)end:(UIButton *)sender;
@property (nonatomic, strong) CLLocation *prevLocation;
@property (nonatomic, assign) CGFloat sumDistance;
@property (nonatomic, assign) CGFloat sumTime;
@end

@implementation ViewController
//步数需要添加  监听摇晃手势
- (void)viewDidLoad {
    [super viewDidLoad];
    self.cllocationM = [[CLLocationManager alloc]init];
    self.cllocationM.delegate=self;//遵守代理协议
    self.cllocationM.desiredAccuracy = kCLLocationAccuracyBest;//设置定位服务的精度
    [self.cllocationM requestAlwaysAuthorization];
    self.cllocationM.distanceFilter=1;//设置距离控制器为100表示每移动100米更新一次位置
    
}
#pragma mark 当用户获取到位置信息时调用
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"定位到了");
    //依次是经度、纬度、高度、速度、方向
    self.latitude.text = [NSString stringWithFormat:@"%g",((CLLocation *)[locations lastObject]).coordinate.latitude];
    self.longitude.text = [NSString stringWithFormat:@"%g",((CLLocation *)[locations lastObject]).coordinate.longitude];
    self.altitude.text = [NSString stringWithFormat:@"%g",((CLLocation *)[locations lastObject]).altitude];
    self.speed.text = [NSString stringWithFormat:@"%g",((CLLocation *)[locations lastObject]).speed];
    self.course.text = [NSString stringWithFormat:@"%g",((CLLocation *)[locations lastObject]).course];
    //获取最后一位定位数据
    CLLocation *newLocation = [locations lastObject];
    if (newLocation.horizontalAccuracy < kCLLocationAccuracyHundredMeters && newLocation.speed > 0) {
        if (self.prevLocation) {
            //计算本次定位数据与上次定位数据之间的时间差
            NSTimeInterval dTime = [newLocation.timestamp timeIntervalSinceDate:self.prevLocation.timestamp];
            //累计骑行时间
            self.sumTime += dTime;
            //计算本次定位数据与上次定位数据之间的距离
            CGFloat distance = [newLocation distanceFromLocation:self.prevLocation];
            //如果距离小于1米，则忽略本次数据，直接返回方法
            if (distance < 1) {
                return;
            }
            //累加移动距离
            self.sumDistance += distance;
            NSLog(@"%g++++%g+++++%g+++++%g",self.sumTime,dTime,distance,self.sumDistance);
            self.averageVelocity.text = [NSString stringWithFormat:@"%g千米/小时\n%g米/秒",self.sumDistance / self.sumTime * 3.6,self.sumDistance / self.sumTime];
            self.averageVelocitysmall.text = [NSString stringWithFormat:@"%g千米/小时\n%g米/秒",distance / dTime * 3.6,distance / dTime];
            self.TotalDistance.text = [NSString stringWithFormat:@"%g米",self.sumDistance];
        }
        self.prevLocation = newLocation;
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"没定位到");
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)begin:(UIButton *)sender {
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"开始定位");
        [self.cllocationM startUpdatingLocation];//开始监听定位信息
    }else{
        NSLog(@"定位无效\"");
    }
}

- (IBAction)end:(UIButton *)sender {
    [self.cllocationM stopUpdatingLocation];//开始监听定位信息
}
@end
