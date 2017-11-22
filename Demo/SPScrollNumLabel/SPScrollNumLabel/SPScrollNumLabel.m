//
//  SPScrollNumLabel.m
//  SPScrollNumLabel
//
//  Created by Tree on 2017/11/21.
//  Copyright © 2017年 Tr2e. All rights reserved.
//

#import "SPScrollNumLabel.h"

@interface SPScrollNumLabel (){
    BOOL has_centerPoint_detect;
    BOOL is_initializeFromXib;
}
@property (nonatomic, strong) UIColor *sp_textColor;// default is black
@property (nonatomic, copy) NSArray <NSString *> *sepNumArr;
@property (nonatomic, copy) NSArray <UILabel *> *sepLabelArr;

@end

@implementation SPScrollNumLabel

// initialize
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initailizeConfig];
    }
    return self;
}

- (void)layoutSubviews{
    if (!_targetNumber && !self.isCommonLabel) {
        self.targetNumber = 0;
    }
    [super layoutSubviews];
}

- (void)initailizeConfig{
    is_initializeFromXib = YES;
    if (!self.isCommonLabel) {
        self.sp_textColor = self.textColor;
        self.textColor = [UIColor clearColor];
    }
}

// function
- (void)increaseNumber:(NSInteger)increasedNum{
    self.targetNumber += increasedNum;
}

- (void)decreaseNumber:(NSInteger)decreasedNum{
    self.targetNumber -= decreasedNum;
}

- (void)operateNumberWithTarget:(NSInteger )targetNumber{
    __weak typeof(self) ws = self;
    [self seprateNumberToStringWithTarget:targetNumber operateHandler:^(NSArray *sepStrArr, NSArray *sepLabelArr) {
        [ws showScrollAnimiationWithSepStrArr:sepStrArr sepLableArr:sepLabelArr];
    }];
}

- (void)showScrollAnimiationWithSepStrArr:(NSArray <NSString *>*)sepStrArr sepLableArr:(NSArray <UILabel *> *)sepLabelArr{
    NSInteger targetLength = sepLabelArr.count;
    NSInteger hisLength = self.sepLabelArr.count;
    for (NSInteger i = 0; i < targetLength; i ++) {
        NSInteger targetIndex = targetLength - i - 1;
        NSInteger hisTargetIndex = hisLength - i - 1;
        if (i < hisLength) {
            if (![sepStrArr[targetIndex] isEqualToString:self.sepNumArr[hisTargetIndex]]) {
                BOOL increase = sepStrArr[targetIndex].integerValue > self.sepNumArr[hisTargetIndex].integerValue;
                // his label
                UILabel *hisLabel = self.sepLabelArr[hisTargetIndex];
                CGRect hisTargetFrame = CGRectOffset(hisLabel.frame, 0, (increase?-1:1)*hisLabel.frame.size.height);
                // new label
                UILabel *label = sepLabelArr[targetIndex];
                CGRect frame = label.frame;
                CGRect targetFrame = CGRectOffset(frame, 0, (increase?1:-1)*label.frame.size.height);
                label.frame = targetFrame;
                [UIView animateWithDuration:self.animateDuration?self.animateDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    hisLabel.frame = hisTargetFrame;
                    label.frame = frame;
                    hisLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    [hisLabel removeFromSuperview];
                }];
            }else{
                [self.sepLabelArr[hisTargetIndex] removeFromSuperview];
            }
        }else{
            UILabel *label = sepLabelArr[targetIndex];
            CGRect frame = label.frame;
            label.frame = CGRectOffset(frame, 0, -frame.size.height);
            [UIView animateWithDuration:self.animateDuration?self.animateDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                label.frame = frame;
            } completion:nil];
        }
    }
    
    if (hisLength > targetLength) {
        for (int i = 0; i < hisLength - targetLength; i ++) {
            UILabel *label = self.sepLabelArr[i];
            CGRect hisTargetFrame = CGRectOffset(label.frame, 0, -1*label.frame.size.height);
            [UIView animateWithDuration:self.animateDuration?self.animateDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                label.frame = hisTargetFrame;
                label.alpha = 0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        }
    }
    self.sepNumArr = sepStrArr;
    self.sepLabelArr = sepLabelArr;
}

// private operation
- (UILabel *)createLabelWithString:(NSString *)numberStr{
    UILabel *label = [[UILabel alloc] init];
    label.font = self.font;
    label.textColor = self.sp_textColor?self.sp_textColor:self.textColor;
    label.textAlignment = NSTextAlignmentLeft;
    label.text = numberStr;
    [label sizeToFit];
    return label;
}

- (void)seprateNumberToStringWithTarget:(NSInteger)target operateHandler:(void (^) (NSMutableArray<NSString *> *sepStrArr,NSMutableArray<UILabel *> *sepLabelArr)) handler{
    NSString *originNumStr = [NSString stringWithFormat:@"%ld",(long)target];
    NSMutableArray <NSString *> * sepStrArr = [[NSMutableArray alloc] initWithCapacity:originNumStr.length];
    NSMutableArray <UILabel *> * sepLabelArr = [[NSMutableArray alloc] initWithCapacity:sepStrArr.count];
    for (NSInteger i = 0 ; i < originNumStr.length; i ++) {
        // str
        NSString *subStr = [originNumStr substringWithRange:NSMakeRange(i, 1)];
        [sepStrArr addObject:subStr];
        // label
        UILabel *label = [self createLabelWithString:subStr];
        CGFloat labelHeight = label.frame.size.height;
        CGFloat selfHeight = self.frame.size.height;
        label.frame = (CGRect){CGPointMake(sepLabelArr.count?CGRectGetMaxX(sepLabelArr.lastObject.frame):0, (labelHeight < selfHeight ? (selfHeight - labelHeight)/2: 0)),label.frame.size};
        [sepLabelArr addObject:label];
        [self addSubview:label];
    }
    
    CGFloat labelHeight = sepLabelArr.lastObject.frame.size.height;
    CGFloat selfHeight = self.frame.size.height;
    CGRect changedFrame = (CGRect){self.frame.origin,CGSizeMake(CGRectGetMaxX(sepLabelArr.lastObject.frame), selfHeight<labelHeight?labelHeight:selfHeight)};
    
    // center point detect
    if (self.centerPointPriority && changedFrame.size.width != self.frame.size.width && has_centerPoint_detect) {
        changedFrame = CGRectOffset(changedFrame, (self.frame.size.width - changedFrame.size.width)/2, 0);
    }
    if (self.centerPointPriority && !has_centerPoint_detect) {
        changedFrame = CGRectOffset(changedFrame, - changedFrame.size.width/2, - changedFrame.size.height/2);
        has_centerPoint_detect = YES;
    }
    
    self.frame = changedFrame;
    handler([sepStrArr copy],[sepLabelArr copy]);
}

// set
- (void)setTextColor:(UIColor *)textColor{
    if (!is_initializeFromXib) {
        self.sp_textColor = textColor;
    }
    if (!self.isCommonLabel) {
        [super setTextColor:[UIColor clearColor]];
    }else{
        [super setTextColor:textColor];
    }
}

- (void)setIsCommonLabel:(BOOL)isCommonLabel{
    _isCommonLabel = isCommonLabel;
    [super setTextColor:isCommonLabel?self.sp_textColor:[UIColor clearColor]];
}

- (void)setText:(NSString *)text{
    [super setText:text];
    if (self.textColor == [UIColor clearColor] && self.isCommonLabel) {
        self.textColor = self.sp_textColor;
    }
}

- (void)setTargetNumber:(NSInteger)targetNumber{
    if (self.isCommonLabel) {
        return;
    }
    _targetNumber = targetNumber;
    [self operateNumberWithTarget:targetNumber];
    [self setText:[NSString stringWithFormat:@"%ld",(long)targetNumber]];
}

@end
