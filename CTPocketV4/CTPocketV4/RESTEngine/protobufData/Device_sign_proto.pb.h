// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ES_ProtocolBuffers.h"

@class DeviceSignRequest;
@class DeviceSignRequest_Builder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif


@interface DeviceSignProtoRoot : NSObject {
}
+ (ES_PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(ES_PBMutableExtensionRegistry*) registry;
@end

@interface DeviceSignRequest : ES_PBGeneratedMessage {
@private
  BOOL hasDeviceId_:1;
  NSString* deviceId;
}
- (BOOL) hasDeviceId;
@property (readonly, retain) NSString* deviceId;

+ (DeviceSignRequest*) defaultInstance;
- (DeviceSignRequest*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (DeviceSignRequest_Builder*) builder;
+ (DeviceSignRequest_Builder*) builder;
+ (DeviceSignRequest_Builder*) builderWithPrototype:(DeviceSignRequest*) prototype;
- (DeviceSignRequest_Builder*) toBuilder;

+ (DeviceSignRequest*) parseFromData:(NSData*) data;
+ (DeviceSignRequest*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (DeviceSignRequest*) parseFromInputStream:(NSInputStream*) input;
+ (DeviceSignRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (DeviceSignRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (DeviceSignRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface DeviceSignRequest_Builder : ES_PBGeneratedMessage_Builder {
@private
  DeviceSignRequest* result;
}

- (DeviceSignRequest*) defaultInstance;

- (DeviceSignRequest_Builder*) clear;
- (DeviceSignRequest_Builder*) clone;

- (DeviceSignRequest*) build;
- (DeviceSignRequest*) buildPartial;

- (DeviceSignRequest_Builder*) mergeFrom:(DeviceSignRequest*) other;
- (DeviceSignRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (DeviceSignRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasDeviceId;
- (NSString*) deviceId;
- (DeviceSignRequest_Builder*) setDeviceId:(NSString*) value;
- (DeviceSignRequest_Builder*) clearDeviceId;
@end

