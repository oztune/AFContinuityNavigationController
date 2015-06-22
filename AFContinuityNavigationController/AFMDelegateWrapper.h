
@import Foundation;

#import "AFMProxy.h"

/*
 A proxy with only two receivers,
 broken down to make it simple to wrap a
 delegate inside a subclass
 */
@interface AFMDelegateWrapper : AFMProxy

@property (nonatomic, weak) id userDelegate;

- (id)initWithMainDelegate:(id)mainDelegate;

@end
