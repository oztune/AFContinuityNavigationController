
#import "AFUMorphView.h"
#import "AFUtils.h"

@interface AFUMorphView ()
{
    CGPoint finalViewInitialScale;
}

@property (nonatomic, strong) UIImageView *initialView, *finalView;

@end

@implementation AFUMorphView

- (id)initWithFrame:(CGRect)frame {
    return [self initWithInitialView:nil finalView:nil];
}

- (id)initWithInitialView:(UIView *)initialView finalView:(UIView *)finalView {
    return [self initWithInitialView:initialView finalView:finalView maintainAspectRatio:NO];
}

- (id)initWithInitialView:(UIView *)initialView finalView:(UIView *)finalView maintainAspectRatio:(BOOL)maintainAspectRatio {
    NSParameterAssert(initialView != nil);
    NSParameterAssert(finalView != nil);
    
    self = [super initWithFrame:CGRectZero];
    if (self) {        
        _initialView = [AFUtils captureView:initialView];
        _finalView = [AFUtils captureView:finalView];
        
        [self addSubview:_initialView];
        [self addSubview:_finalView];
        
        CGRect frame = CGRectUnion(_initialView.bounds, _finalView.bounds);
        
        self.frame = frame;
        
        CGPoint center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
        
        _initialView.layer.position = center;
        _finalView.layer.position = center;
        
        finalViewInitialScale.x = _initialView.bounds.size.width / _finalView.bounds.size.width;
        if (maintainAspectRatio) {
            finalViewInitialScale.y = finalViewInitialScale.x;
        } else {
            finalViewInitialScale.y = _initialView.bounds.size.height / _finalView.bounds.size.height;
        }
        
        self.morphProgress = 0.0;
    }
    return self;
}

- (void)setMorphProgress:(CGFloat)morphProgress {
    _morphProgress = morphProgress;
    
    _initialView.alpha = AFMathLerp(1.0, 0.0, morphProgress);
    _finalView.alpha = AFMathLerp(0.0, 1.0, morphProgress);
    
    CGPoint scale;
    
    scale.x = AFMathLerp(finalViewInitialScale.x, 1.0, morphProgress);
    scale.y = AFMathLerp(finalViewInitialScale.y, 1.0, morphProgress);
    _finalView.transform = CGAffineTransformMakeScale(scale.x, scale.y);
    
    scale.x = AFMathLerp(1.0, 1.0 / finalViewInitialScale.x, morphProgress);
    scale.y = AFMathLerp(1.0, 1.0 / finalViewInitialScale.y, morphProgress);
    _initialView.transform = CGAffineTransformMakeScale(scale.x, scale.y);
}

@end