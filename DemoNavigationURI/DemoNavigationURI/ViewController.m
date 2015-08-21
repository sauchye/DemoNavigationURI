//
//  ViewController.m
//  DemoNavigationURI
//
//  Created by Ralph Li on 8/11/15.
//  Copyright (c) 2015 LJC. All rights reserved.
//


#define kButtonIndex (10000)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define kAppDisplayName [[NSBundle mainBundle].localizedInfoDictionary objectForKey:@"CFBundleDisplayName"]

#import "ViewController.h"
#import "SYPopView.h"
@import CoreLocation;
@import MapKit;


@interface ViewController ()<SYPopViewDelegate>

@property (nonatomic, strong) NSString *urlScheme;
@property (nonatomic, strong) NSString *appName;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) SYPopView *popView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    self.urlScheme = @"demoURI://";
    self.appName = @"demoURI";
    self.coordinate = CLLocationCoordinate2DMake(22.560131849189876,113.95401330887923);
}

#pragma mark - 解决导航中到达终点 距离偏差很大
- (CLLocationCoordinate2D)transformCoordinatesLatitude:(double)latitude longitude:(double)longitude{
    
    double x = longitude - 0.0065, y = latitude - 0.006;
    double z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    double theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    double gg_lng = z * cos(theta);
    double gg_lat = z * sin(theta);
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(gg_lat, gg_lng);
    return coor;
}


//查看iOS设备安装地图情况
-(NSArray *)checkInstallMapApps{
    //@"comgooglemaps://"
    NSArray *mapSchemeArr = @[@"iosamap://navi",@"baidumap://map/"];
    
    NSMutableArray *appListArr = [[NSMutableArray alloc] initWithObjects:@"苹果地图", nil];
    
    for (int i = 0; i < [mapSchemeArr count]; i++) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[mapSchemeArr objectAtIndex:i]]]]) {
            if (i == 0){
                [appListArr addObject:@"高德地图"];
            }else if (i == 1){
                [appListArr addObject:@"百度地图"];
            }
        }
    }
    
    //    [appListArr addObject:@"显示路线"];
    return appListArr;
}

#pragma mark - iOS>=7.0 UI初始化
static const int  chooseNavigationViewTag = 111111;
- (IBAction)iOS7ActionSheetClick:(UIButton *)sender {
    
    NSArray *buttons = [self checkInstallMapApps];
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    bgView.backgroundColor = [UIColor blackColor];
    _popView = [[SYPopView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-51*buttons.count-20-64)/2, SCREEN_WIDTH, 51 * buttons.count + 20) title:@"选择地图" buttonData:buttons];
    _popView.alpha = 1.0;
    _popView.delegate = self;
    _popView.backgroundColor = [UIColor whiteColor];
    
    [UIView animateWithDuration:0.3 animations:^{
        _popView.alpha = 1.0;
        bgView.alpha = 0;
    }];
    
    
    bgView.tag = chooseNavigationViewTag;
    bgView.alpha = 0.85;
    [self.view addSubview:bgView];
    [bgView addSubview:_popView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAllNavigationView)];
    
    [bgView addGestureRecognizer:tap];
    __weak typeof(self) weakSelf = self;
    _popView.buttonClickIndexBlock = ^(NSInteger buttonIndex, NSString *mapName){
        
        //            __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        NSLog(@"%@",mapName);
        bgView.alpha = 1.0;
        [bgView removeFromSuperview];
        //[mapName isEqualToString:@"苹果地图"]
        if (buttonIndex == kButtonIndex) {
            if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]){
                
                MKMapItem *userCurrentLocation = [MKMapItem mapItemForCurrentLocation];
                MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:weakSelf.coordinate addressDictionary:nil]];
                
                [MKMapItem openMapsWithItems:@[userCurrentLocation, toLocation]
                               launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
                
                
            }else if (buttonIndex == kButtonIndex+1){
                
                [weakSelf judgeIsInstallMapName:mapName urlScheme:weakSelf.urlScheme CLLocationCoordinate2D:weakSelf.coordinate];
            }else if (buttonIndex == kButtonIndex + 2){
                
//                [weakSelf judgeIsInstallMapName:mapName urlScheme:self.urlScheme CLLocationCoordinate2D:self.coordinate];
            }
        }
        
    };

}

#pragma mark - SYPopViewDelegate Method
- (void)mapButtonClickTag:(NSInteger)tag mapType:(NSString *)type{
    
    [self hideAllNavigationView];
    if (tag == kButtonIndex) {
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]){
            
            MKMapItem *userCurrentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:nil]];
            
            [MKMapItem openMapsWithItems:@[userCurrentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];}
        
    }else if (tag == kButtonIndex + 1){
        
        [self judgeIsInstallMapName:type urlScheme:self.urlScheme CLLocationCoordinate2D:self.coordinate];
        
    }else if(tag == kButtonIndex + 2){
        
        [self judgeIsInstallMapName:type urlScheme:self.urlScheme CLLocationCoordinate2D:self.coordinate];
    }
}

- (void)judgeIsInstallMapName:(NSString *)mapType urlScheme:(NSString *)urlScheme CLLocationCoordinate2D:(CLLocationCoordinate2D)coor{
    
    [self hideAllNavigationView];
    
    if ([mapType isEqualToString:@"高德地图"]) {
        //高德地图 判断是否安装了高德地图
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",kAppDisplayName,urlScheme,coor.latitude, coor.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }else if ([mapType isEqualToString:@"百度地图"]){
        if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]){
            NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",coor.latitude, coor.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
}



#pragma mark - tap events
-(void)hideAllNavigationView{
    [_popView removeFromSuperview];
    UIView *allView = (UIView *)[self.view viewWithTag:chooseNavigationViewTag];
    [allView removeFromSuperview];
}


#pragma mark - iOS>=8.0
- (IBAction)iOS8ActionSheetClick:(UIButton *)sender {
    __block NSString *urlScheme = self.urlScheme;
    __block NSString *appName = self.appName;
    __block CLLocationCoordinate2D coordinate = self.coordinate;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //这个判断其实是不需要的
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
            
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=目的地&mode=driving&coord_type=gcj02",coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2",appName,urlScheme,coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",appName,urlScheme,coordinate.latitude, coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",urlString);
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            
        }];
        
        [alert addAction:action];
    }
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
