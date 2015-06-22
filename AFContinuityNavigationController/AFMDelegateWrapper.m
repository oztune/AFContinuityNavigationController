
#import "AFMDelegateWrapper.h"
#import "AFMProxy.h"

@interface AFMDelegateWrapper()

@property (nonatomic, weak) id mainDelegate;

@end

@implementation AFMDelegateWrapper

- (id)initWithMainDelegate:(id)mainDelegate {
	NSParameterAssert(mainDelegate != nil);
	
	self = [super init];
	if (self) {
		self.mainDelegate = mainDelegate;
		[self addReceiver:mainDelegate];
	}
	return self;
}

#pragma mark - Properties

- (void)setUserDelegate:(id)userDelegate {
	if (_userDelegate) {
		[self removeReceiver:_userDelegate];
	}
	_userDelegate = userDelegate;
	
	if (_userDelegate) {
		[self addReceiver:_userDelegate];
	}
}

@end
