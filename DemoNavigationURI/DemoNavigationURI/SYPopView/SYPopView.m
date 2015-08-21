//
//  SYPopView.m
//  DemoNavigationURI
//
//  Created by Sauchye on 8/21/15.
//  Copyright (c) 2015 sauchye.com. All rights reserved.
//  https://github.com/sauchye
//  http://sauchye.com/



#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define RGB(r, g, b)                        [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.0f]
#define kGROUP_TABLEVIEW_BACKGROUN RGB(238, 238, 244)
#define kButtonIndex (10000)


#import "SYPopView.h"
@interface SYPopView ()

@property (nonatomic, strong) UIView    *allView;
@property (nonatomic, strong) UILabel   *titleLbl;

@end

@implementation SYPopView



- (id)initWithFrame:(CGRect)frame title:(NSString *)title buttonData:(NSArray *)buttons{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        static  const CGFloat  buttonHeight = 50;
        _titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 15)];
        _titleLbl.text = [NSString stringWithFormat:@"%@",title];
        _titleLbl.textAlignment = NSTextAlignmentCenter;
        _titleLbl.font = [UIFont systemFontOfSize:13.0];
        [self addSubview:_titleLbl];
        self.userInteractionEnabled = YES;
        
        _btnData = buttons;
        for (NSInteger i = 0; i < _btnData.count; i++) {
            _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            _button.frame = CGRectMake(0,CGRectGetMaxY(_titleLbl.frame)+5+(buttonHeight+1)* i, frame.size.width, buttonHeight);
            [_button setTitle:_btnData[i] forState:UIControlStateNormal];
            
            [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_button setBackgroundColor:kGROUP_TABLEVIEW_BACKGROUN];
            _button.tag = i + kButtonIndex;
            [self addSubview:_button];
            [_button addTarget:self action:@selector(chooseMapTypeClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRemoveView)];
        [self.superview addGestureRecognizer:tap];
    }
    return self;
}



- (void)chooseMapTypeClick:(UIButton *)sender{
    
    NSLog(@"%ld",sender.tag);
    [self tapRemoveView];
    //    if (_buttonClickIndexBlock) {
    //        _buttonClickIndexBlock(sender.tag, _btnData[sender.tag - kButtonIndex]);
    //    }

    if (_delegate) {
        [_delegate mapButtonClickTag:sender.tag mapType:_btnData[sender.tag-kButtonIndex]];
    }
    
    
}

- (void)tapRemoveView{
    [self removeFromSuperview];
}
@end
