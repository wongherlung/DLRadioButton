#import "DLRadioButton.h"

static const CGFloat kDefaulIconSize = 15.0;
static const CGFloat kDefaultMarginWidth = 5.0;
static NSString * const kGeneratedIconName = @"Generated Icon";
static BOOL _groupModifing = NO;

@implementation DLRadioButton

- (void)setOtherButtons:(NSArray *)otherButtons {
    if (![DLRadioButton isGroupModifing]) {
        [DLRadioButton groupModifing:YES];
        for (DLRadioButton *radioButton in otherButtons) {
            NSMutableArray *otherButtonsForCurrentButton = [[NSMutableArray alloc] initWithArray:otherButtons];
            [otherButtonsForCurrentButton addObject:self];
            [otherButtonsForCurrentButton removeObject:radioButton];
            [radioButton setOtherButtons:[otherButtonsForCurrentButton copy]];
        }
        [DLRadioButton groupModifing:NO];
    }
    _otherButtons = otherButtons;
}

- (void)setIcon:(UIImage *)icon {
    _icon = icon;
    [self setImage:self.icon forState:UIControlStateNormal];
}

- (void)setIconSelected:(UIImage *)iconSelected {
    _iconSelected = iconSelected;
    [self setImage:self.iconSelected forState:UIControlStateSelected];
    [self setImage:self.iconSelected forState:UIControlStateSelected | UIControlStateHighlighted];
}

- (void)setMultipleSelectionEnabled:(BOOL)multipleSelectionEnabled {
    if (![DLRadioButton isGroupModifing]) {
        [DLRadioButton groupModifing:YES];
        for (DLRadioButton *radioButton in self.otherButtons) {
            radioButton.multipleSelectionEnabled = multipleSelectionEnabled;
        }
        [DLRadioButton groupModifing:NO];
    }
    _multipleSelectionEnabled = multipleSelectionEnabled;
}

#pragma mark - Helpers

- (void)drawButton {
    if (!self.icon || [self.icon.accessibilityIdentifier isEqualToString:kGeneratedIconName]) {
        self.icon = [self drawIconWithSelection:NO];
    }
    if (!self.iconSelected || [self.iconSelected.accessibilityIdentifier isEqualToString:kGeneratedIconName]) {
        self.iconSelected = [self drawIconWithSelection:YES];
    }
    CGFloat marginWidth = self.marginWidth ? self.marginWidth : kDefaultMarginWidth;
    BOOL isRightToLeftLayout = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        isRightToLeftLayout = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
    }
    if (self.isIconOnRight) {
        self.imageEdgeInsets = isRightToLeftLayout ?
        UIEdgeInsetsMake(0, 0, 0, self.frame.size.width - self.icon.size.width) :
        UIEdgeInsetsMake(0, self.frame.size.width - self.icon.size.width, 0, 0);
        self.titleEdgeInsets = isRightToLeftLayout ?
        UIEdgeInsetsMake(0, marginWidth + self.icon.size.width, 0, -self.icon.size.width) :
        UIEdgeInsetsMake(0, -self.icon.size.width, 0, marginWidth + self.icon.size.width);
    } else {
        if (isRightToLeftLayout) {
            self.imageEdgeInsets = UIEdgeInsetsMake(0, marginWidth, 0, 0);
        } else {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, marginWidth, 0, 0);
        }
    }
}

- (UIImage *)drawIconWithSelection:(BOOL)selected {
    UIColor *defaulColor = selected ? [self titleColorForState:UIControlStateSelected | UIControlStateHighlighted] : [self titleColorForState:UIControlStateNormal];
    UIColor *iconColor = self.iconColor ? self.iconColor : defaulColor;
    UIColor *indicatorColor = self.indicatorColor ? self.indicatorColor : defaulColor;
    CGFloat iconSize = self.iconSize ? self.iconSize : kDefaulIconSize;
    CGFloat iconStrokeWidth = self.iconStrokeWidth ? self.iconStrokeWidth : iconSize / 9;
    CGFloat indicatorSize = self.indicatorSize ? self.indicatorSize : iconSize * 0.5;
    
    CGRect rect = CGRectMake(0, 0, iconSize, iconSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
    
    // draw icon
    UIBezierPath* iconPath;
    CGRect iconRect = CGRectMake(iconStrokeWidth / 2, iconStrokeWidth / 2, iconSize - iconStrokeWidth, iconSize - iconStrokeWidth);
    if (self.isIconSquare) {
        iconPath = [UIBezierPath bezierPathWithRect:iconRect];
    } else {
        iconPath = [UIBezierPath bezierPathWithOvalInRect:iconRect];
    }
    [iconColor setStroke];
    iconPath.lineWidth = iconStrokeWidth;
    [iconPath stroke];
    CGContextAddPath(context, iconPath.CGPath);
    
    // draw indicator
    if (selected) {
        // This part is edited by wongherlung so that the indicator looks like a tick.
        CGRect group = CGRectMake(CGRectGetMinX(rect) + 3, CGRectGetMinY(rect) + 3, CGRectGetWidth(rect) - 6, CGRectGetHeight(rect) - 6);
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(CGRectGetMinX(group) + 0.27083 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.54167 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.41667 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.68750 * CGRectGetHeight(group))];
        [bezierPath addLineToPoint: CGPointMake(CGRectGetMinX(group) + 0.75000 * CGRectGetWidth(group), CGRectGetMinY(group) + 0.35417 * CGRectGetHeight(group))];
        bezierPath.lineCapStyle = kCGLineCapSquare;
        
        [indicatorColor setStroke];
        bezierPath.lineWidth = 1.3;
        [bezierPath stroke];
        
        CGContextAddPath(context, bezierPath.CGPath);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    
    image.accessibilityIdentifier = kGeneratedIconName;
    return image;
}

- (void)touchDown {
    [self setSelected:YES];
}

- (void)initRadioButton {
    [super addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchUpInside];
}

- (void)prepareForInterfaceBuilder {
    [self initRadioButton];
    [self drawButton];
}

#pragma mark - DLRadiobutton

+ (void)groupModifing:(BOOL)chaining {
    _groupModifing = chaining;
}

+ (BOOL)isGroupModifing {
    return _groupModifing;
}

- (void)deselectOtherButtons {
    for (UIButton *button in self.otherButtons) {
        [button setSelected:NO];
    }
}

- (DLRadioButton *)selectedButton {
    if (!self.isMultipleSelectionEnabled) {
        if (self.selected) {
            return self;
        } else {
            for (DLRadioButton *radioButton in self.otherButtons) {
                if (radioButton.selected) {
                    return radioButton;
                }
            }
        }
    }
    return nil;
}

- (NSArray *)selectedButtons {
    NSMutableArray *selectedButtons = [[NSMutableArray alloc] init];
    if (self.selected) {
        [selectedButtons addObject:self];
    }
    for (DLRadioButton *radioButton in self.otherButtons) {
        if (radioButton.selected) {
            [selectedButtons addObject:radioButton];
        }
    }
    return selectedButtons;
}

#pragma mark - UIButton

- (UIColor *)titleColorForState:(UIControlState)state {
    UIColor *normalColor = [super titleColorForState:UIControlStateNormal];
    if (state == (UIControlStateSelected | UIControlStateHighlighted)) {
        UIColor *selectedOrHighlightedColor = [super titleColorForState:UIControlStateSelected | UIControlStateHighlighted];
        if (selectedOrHighlightedColor == normalColor || selectedOrHighlightedColor == nil) {
            selectedOrHighlightedColor = [super titleColorForState:UIControlStateSelected];
        }
        if (selectedOrHighlightedColor == normalColor || selectedOrHighlightedColor == nil) {
            selectedOrHighlightedColor = [super titleColorForState:UIControlStateHighlighted];
        }
        [self setTitleColor:selectedOrHighlightedColor forState:UIControlStateSelected | UIControlStateHighlighted];
    }
    
    return [super titleColorForState:state];
}

#pragma mark - UIControl

- (void)setSelected:(BOOL)selected {
    if (self.isMultipleSelectionEnabled) {
        [super setSelected:!self.isSelected];
    } else {
        [super setSelected:selected];
        if (selected) {
            [self deselectOtherButtons];
        }
    }
}

#pragma mark - UIView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initRadioButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initRadioButton];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawButton];
}

@end