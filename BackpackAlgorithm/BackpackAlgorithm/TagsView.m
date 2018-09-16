
//
//  TagsView.m
//  test
//
//  Created by Kirn on 2018/9/15.
//  Copyright © 2018 Kirn. All rights reserved.
//

#import "TagsView.h"
@interface TagsView()
@property (nonatomic, assign) NSInteger width;
@end

@implementation TagsView
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if(self.width != self.bounds.size.width) {
        self.width = self.bounds.size.width;
        
        for (UIView *view in self.subviews) {
            [view removeFromSuperview];
        }
        
        UIFont *font = [UIFont systemFontOfSize:12];
        // Tags
        NSMutableArray *items = [[self items:200 from:1 to:20] mutableCopy];
        // Tag Widths
        NSMutableArray *vws = [[self itemWidth:items font:font] mutableCopy];
        
        CGFloat offsetY = 0;
        __block CGFloat offsetX = 0;
        while (items.count) {
            // 每一组背包
            NSIndexSet *selIndexSet = [self backpack:vws width:self.width];
            [selIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *item = items[idx];
                UILabel *lbl = [UILabel new];
                lbl.font = font;
                lbl.text = item;
                lbl.textAlignment = NSTextAlignmentCenter;
                lbl.textColor = [UIColor colorWithWhite:0.3 alpha:1];
                lbl.layer.borderColor = UIColor.blackColor.CGColor;
                lbl.layer.borderWidth = 0.5;
                lbl.backgroundColor = [self randomColor];
                [self addSubview:lbl];
                NSInteger itemWidth = [vws[idx] intValue];
                lbl.frame = CGRectMake(offsetX, offsetY, itemWidth, 30);
                offsetX += itemWidth;
            }];
            offsetY += 30;
            offsetX = 0;
            [items removeObjectsAtIndexes:selIndexSet];
            [vws removeObjectsAtIndexes:selIndexSet];
        }
        self.contentSize = CGSizeMake(self.bounds.size.width, offsetY);
    }
}

- (UIColor *)randomColor
{
    CGFloat r = [self randomNumber:0 to:100]/100.0;
    CGFloat g = [self randomNumber:0 to:100]/100.0;
    CGFloat b = [self randomNumber:0 to:100]/100.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

/**
 随机产生一组Tags，仅限测试用

 @return 随机Tags数组
 */
- (NSArray<NSString *> *)items:(NSInteger)total from:(NSInteger)from to:(NSInteger)to
{
    NSParameterAssert(total > 0);
    NSParameterAssert(from < to);
    NSMutableArray *items = [NSMutableArray array];
    for(NSInteger i = 0; i < total; i++) {
        NSInteger count = [self randomNumber:from to:to];
        unichar *chars = malloc(sizeof(unichar) * count);
        unichar *h = chars;
        for (int i = 0; i < count; i++) {
            // A~Z
            *h = [self randomNumber:65 to:90];
            h++;
        }
        NSString *item = [NSString stringWithCharacters:chars length:count];
        free(chars);
        [items addObject:item];
    }
    return items;
}


/**
 计算Tag的宽度

 @param items Tags
 @param font Tag字体
 @return Tag宽度
 */
- (NSArray<NSNumber *> *)itemWidth:(NSArray<NSString *> *)items font:(UIFont *)font
{
    NSMutableArray *widths = [NSMutableArray array];
    for (NSString *item in items) {
        CGSize size = [item sizeWithAttributes:@{NSFontAttributeName: font}];
        [widths addObject:@(ceilf(size.width + 20))];
    }
    return widths;
}

/**
 产生随机整数

 @param from 最小整数
 @param to 最大整数
 @return 随机数
 */
-(NSInteger)randomNumber:(NSInteger)from to:(NSInteger)to
{
    return (from + (arc4random() % (to - from + 1)));
}


/**
 背包算法

 @param vws 价值&重量输入(每个Tag的宽度)
 @param width 背包容量(每行Tag能占用的最大宽度)
 @return 背包内容物品选择情况(Tag的选择情况)
 */
- (NSIndexSet *)backpack:(NSArray<NSNumber *> *)vws width:(NSInteger)width
{
    // 背包可选择物品数量
    int n = (int)vws.count;
    
    // 背包容量
    int c = (int)width;
    
    // 物品价值数组
    int *v = malloc(sizeof(int) * (n + 1));
    
    // 物品重量数组
    int *w = malloc(sizeof(int) * (n + 1));
    
    // 初始化价值数组和重量数组
    *v = 0;
    *w = 0;
    int *vh = v;
    int *wh = w;
    for (int i = 0; i < n; i++) {
        *++vh = [vws[i] intValue];
        *++wh = [vws[i] intValue];
    }
    
    // 构造二维转移矩阵，并初始化为0
    int **m = (int **)malloc(sizeof(int *) * (n + 1));
    for(int i = 0; i < n + 1; i++) {
        *(m + i) = (int *)malloc(sizeof(int) * (c + 1));
        for (int j = 0; j < c + 1; j++) {
            *(*(m + i) + j) = 0;
        }
    }
    
    // 构造转移矩阵
    for(int i = 1; i <= n; i++) {
        for (int j = 1; j <= c; j++) {
            if (j >= w[i]) {
                m[i][j] = MAX(m[i - 1][j], m[i - 1][j - w[i]] + v[i]);
            }else {
                m[i][j] = m[i - 1][j];
            }
        }
    }
    
    // 标记物品选择情况
    int *x = malloc(sizeof(int) * (n + 1));
    for(int i = n; i > 1; i--) {
        if(m[i][c] == m[i-1][c]) {
            x[i] = 0;
        }else {
            x[i] = 1;
            c-= w[i];
        }
    }
    x[1] = (m[1][c] > 0) ? 1 : 0;
    
    // 返回物品选择情况
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 1; i <= n; i++) {
        if (x[i] == 1) {
            [indexSet addIndex:i - 1];
        }
    }
    
    // 回收资源
    free(v);
    free(w);
    free(x);
    for(int i = 0; i < n; i++) {
        free(*(m + i));
    }
    
    return indexSet;
}
@end
