
@import Foundation;

// See http://danielemargutti.com/wp-content/uploads/2014/02/logical_path_message_objc@2x.png
// For message interception flow

// TODO: Read this: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtForwarding.html#//apple_ref/doc/uid/TP40008048-CH105-SW1
/*
 Exerpt:
 In addition to respondsToSelector: and isKindOfClass:, the instancesRespondToSelector: method should also mirror the forwarding algorithm. If protocols are used, the conformsToProtocol: method should likewise be added to the list. Similarly, if an object forwards any remote messages it receives, it should have a version of methodSignatureForSelector: that can return accurate descriptions of the methods that ultimately respond to the forwarded messages; for example, if an object is able to forward a message to its surrogate, you would implement methodSignatureForSelector: as follows:
 */

@class AFMProxy;

//@protocol AFProxyDelegate < NSObject>
//
//@optional
//
//- (void)proxy:(AFProxy *)proxy willForwardInvocation:(NSInvocation *)invocation;
//- (void)proxy:(AFProxy *)proxy didForwardInvocation:(NSInvocation *)invocation;
//
//@end
//
/**
 Maintains a weak reference to all of its receivers.
 Forwards all methods to them.
 */
@interface AFMProxy : NSProxy

- (id)init;
- (void)addReceiver:(id)aReceiver;
- (void)removeReceiver:(id)aReceiver;

+ (AFMProxy *)proxyWithReceivers:(NSArray *)receivers;

@end