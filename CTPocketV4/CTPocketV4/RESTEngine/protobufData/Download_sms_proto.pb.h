// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ES_ProtocolBuffers.h"

#import "Base_type_proto.pb.h"

@class Address;
@class Address_Builder;
@class Category;
@class Category_Builder;
@class DownloadSmsRequest;
@class DownloadSmsRequest_Builder;
@class DownloadSmsResponse;
@class DownloadSmsResponse_Builder;
@class Email;
@class Email_Builder;
@class Employed;
@class Employed_Builder;
@class InstantMessage;
@class InstantMessage_Builder;
@class Name;
@class Name_Builder;
@class Phone;
@class Phone_Builder;
@class PortraitData;
@class PortraitData_Builder;
@class Sms;
@class SmsSummary;
@class SmsSummary_Builder;
@class Sms_Builder;
@class UabError;
@class UabError_Builder;
@class Website;
@class Website_Builder;
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


@interface DownloadSmsProtoRoot : NSObject {
}
+ (ES_PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(ES_PBMutableExtensionRegistry*) registry;
@end

@interface DownloadSmsRequest : ES_PBGeneratedMessage {
@private
  ES_PBAppendableArray * idArray;
}
@property (readonly, retain) ES_PBArray * id;
- (NSString*)idAtIndex:(NSUInteger)index;

+ (DownloadSmsRequest*) defaultInstance;
- (DownloadSmsRequest*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (DownloadSmsRequest_Builder*) builder;
+ (DownloadSmsRequest_Builder*) builder;
+ (DownloadSmsRequest_Builder*) builderWithPrototype:(DownloadSmsRequest*) prototype;
- (DownloadSmsRequest_Builder*) toBuilder;

+ (DownloadSmsRequest*) parseFromData:(NSData*) data;
+ (DownloadSmsRequest*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (DownloadSmsRequest*) parseFromInputStream:(NSInputStream*) input;
+ (DownloadSmsRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (DownloadSmsRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (DownloadSmsRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface DownloadSmsRequest_Builder : ES_PBGeneratedMessage_Builder {
@private
  DownloadSmsRequest* result;
}

- (DownloadSmsRequest*) defaultInstance;

- (DownloadSmsRequest_Builder*) clear;
- (DownloadSmsRequest_Builder*) clone;

- (DownloadSmsRequest*) build;
- (DownloadSmsRequest*) buildPartial;

- (DownloadSmsRequest_Builder*) mergeFrom:(DownloadSmsRequest*) other;
- (DownloadSmsRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (DownloadSmsRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (ES_PBAppendableArray *)id;
- (NSString*)idAtIndex:(NSUInteger)index;
- (DownloadSmsRequest_Builder *)addId:(NSString*)value;
- (DownloadSmsRequest_Builder *)setIdArray:(NSArray *)array;
- (DownloadSmsRequest_Builder *)setIdValues:(const NSString* *)values count:(NSUInteger)count;
- (DownloadSmsRequest_Builder *)clearId;
@end

@interface DownloadSmsResponse : ES_PBGeneratedMessage {
@private
  ES_PBAppendableArray * smsArray;
}
@property (readonly, retain) ES_PBArray * sms;
- (Sms*)smsAtIndex:(NSUInteger)index;

+ (DownloadSmsResponse*) defaultInstance;
- (DownloadSmsResponse*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (DownloadSmsResponse_Builder*) builder;
+ (DownloadSmsResponse_Builder*) builder;
+ (DownloadSmsResponse_Builder*) builderWithPrototype:(DownloadSmsResponse*) prototype;
- (DownloadSmsResponse_Builder*) toBuilder;

+ (DownloadSmsResponse*) parseFromData:(NSData*) data;
+ (DownloadSmsResponse*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (DownloadSmsResponse*) parseFromInputStream:(NSInputStream*) input;
+ (DownloadSmsResponse*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (DownloadSmsResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (DownloadSmsResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface DownloadSmsResponse_Builder : ES_PBGeneratedMessage_Builder {
@private
  DownloadSmsResponse* result;
}

- (DownloadSmsResponse*) defaultInstance;

- (DownloadSmsResponse_Builder*) clear;
- (DownloadSmsResponse_Builder*) clone;

- (DownloadSmsResponse*) build;
- (DownloadSmsResponse*) buildPartial;

- (DownloadSmsResponse_Builder*) mergeFrom:(DownloadSmsResponse*) other;
- (DownloadSmsResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (DownloadSmsResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (ES_PBAppendableArray *)sms;
- (Sms*)smsAtIndex:(NSUInteger)index;
- (DownloadSmsResponse_Builder *)addSms:(Sms*)value;
- (DownloadSmsResponse_Builder *)setSmsArray:(NSArray *)array;
- (DownloadSmsResponse_Builder *)setSmsValues:(const Sms* *)values count:(NSUInteger)count;
- (DownloadSmsResponse_Builder *)clearSms;
@end

