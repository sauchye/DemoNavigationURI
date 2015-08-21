//
//  SYPopView.h
//  DemoNavigationURI
//
//  Created by Sauchye on 8/21/15.
//  Copyright (c) 2015 sauchye.com. All rights reserved.
//  https://github.com/sauchye
//  http://sauchye.com/

#import <UIKit/UIKit.h>

@protocol SYPopViewDelegate <NSObject>

@optional
- (void)mapButtonClickTag:(NSInteger)tag mapType:(NSString *)type;

@end
@interface SYPopView : UIView
/***  button数据源*/
@property (nonatomic, strong) NSArray   *btnData;
/***  button按钮*/
@property (nonatomic, strong) UIButton   *button;

@property (nonatomic, weak) id<SYPopViewDelegate>delegate;

/***  重写重新初始化*/
- (id)initWithFrame:(CGRect)frame title:(NSString *)title buttonData:(NSArray *)buttons;

/***  block回调  默认使用此方法*/
@property (nonatomic, copy) void(^buttonClickIndexBlock)(NSInteger buttonIndex, NSString *mapName);

@end
