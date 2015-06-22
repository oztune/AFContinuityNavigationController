
#import "AFUTitleView.h"

@implementation AFUTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView) {
        [_contentView removeFromSuperview];
    }
    
    _contentView = contentView;
    
    if (contentView) {
        [self addSubview:contentView];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fittingSize = [_contentView sizeThatFits:size];
    fittingSize.width = 1.0;
    return fittingSize;
}

- (void)layoutSubviews {
    if (_contentView) {
        [_contentView layoutIfNeeded];
        
        CGRect bounds = self.bounds;
        _contentView.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    }
}

@end
