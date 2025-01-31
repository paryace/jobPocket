// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ES_ProtocolBuffers.h"

#import "Base_type_proto.pb.h"

@class Address;
@class Address_Builder;
@class Category;
@class Category_Builder;
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
@class SyncSmsRequest;
@class SyncSmsRequest_Builder;
@class SyncSmsResponse;
@class SyncSmsResponse_Builder;
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

typedef enum {
  SyncSmsRequestTypeBackup = 1,
  SyncSmsRequestTypeRecover = 2,
} SyncSmsRequestType;

BOOL SyncSmsRequestTypeIsValidValue(SyncSmsRequestType value);


@interface SyncSmsProtoRoot : NSObject {
}
+ (ES_PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(ES_PBMutableExtensionRegistry*) registry;
@end

@interface SyncSmsRequest : ES_PBGeneratedMessage {
@private
  BOOL hasType_:1;
  SyncSmsRequestType type;
  ES_PBAppendableArray * smsSummaryArray;
}
- (BOOL) hasType;
@property (readonly, retain) ES_PBArray * smsSummary;
@property (readonly) SyncSmsRequestType type;
- (SmsSummary*)smsSummaryAtIndex:(NSUInteger)index;

+ (SyncSmsRequest*) defaultInstance;
- (SyncSmsRequest*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (SyncSmsRequest_Builder*) builder;
+ (SyncSmsRequest_Builder*) builder;
+ (SyncSmsRequest_Builder*) builderWithPrototype:(SyncSmsRequest*) prototype;
- (SyncSmsRequest_Builder*) toBuilder;

+ (SyncSmsRequest*) parseFromData:(NSData*) data;
+ (SyncSmsRequest*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncSmsRequest*) parseFromInputStream:(NSInputStream*) input;
+ (SyncSmsRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncSmsRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (SyncSmsRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncSmsRequest_Builder : ES_PBGeneratedMessage_Builder {
@private
  SyncSmsRequest* result;
}

- (SyncSmsRequest*) defaultInstance;

- (SyncSmsRequest_Builder*) clear;
- (SyncSmsRequest_Builder*) clone;

- (SyncSmsRequest*) build;
- (SyncSmsRequest*) buildPartial;

- (SyncSmsRequest_Builder*) mergeFrom:(SyncSmsRequest*) other;
- (SyncSmsRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (SyncSmsRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (ES_PBAppendableArray *)smsSummary;
- (SmsSummary*)smsSummaryAtIndex:(NSUInteger)index;
- (SyncSmsRequest_Builder *)addSmsSummary:(SmsSummary*)value;
- (SyncSmsRequest_Builder *)setSmsSummaryArray:(NSArray *)array;
- (SyncSmsRequest_Builder *)setSmsSummaryValues:(const SmsSummary* *)values count:(NSUInteger)count;
- (SyncSmsRequest_Builder *)clearSmsSummary;

- (BOOL) hasType;
- (SyncSmsRequestType) type;
- (SyncSmsRequest_Builder*) setType:(SyncSmsRequestType) value;
- (SyncSmsRequest_Builder*) clearType;
@end

@interface SyncSmsResponse : ES_PBGeneratedMessage {
@private
  ES_PBAppendableArray * uploadIdArray;
  ES_PBAppendableArray * downloadIdArray;
  ES_PBAppendableArray * deleteIdArray;
  ES_PBAppendableArray * updateFavouriteArray;
}
@property (readonly, retain) ES_PBArray * uploadId;
@property (readonly, retain) ES_PBArray * downloadId;
@property (readonly, retain) ES_PBArray * deleteId;
@property (readonly, retain) ES_PBArray * updateFavourite;
- (NSString*)uploadIdAtIndex:(NSUInteger)index;
- (NSString*)downloadIdAtIndex:(NSUInteger)index;
- (NSString*)deleteIdAtIndex:(NSUInteger)index;
- (SmsSummary*)updateFavouriteAtIndex:(NSUInteger)index;

+ (SyncSmsResponse*) defaultInstance;
- (SyncSmsResponse*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (SyncSmsResponse_Builder*) builder;
+ (SyncSmsResponse_Builder*) builder;
+ (SyncSmsResponse_Builder*) builderWithPrototype:(SyncSmsResponse*) prototype;
- (SyncSmsResponse_Builder*) toBuilder;

+ (SyncSmsResponse*) parseFromData:(NSData*) data;
+ (SyncSmsResponse*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncSmsResponse*) parseFromInputStream:(NSInputStream*) input;
+ (SyncSmsResponse*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncSmsResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (SyncSmsResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncSmsResponse_Builder : ES_PBGeneratedMessage_Builder {
@private
  SyncSmsResponse* result;
}

- (SyncSmsResponse*) defaultInstance;

- (SyncSmsResponse_Builder*) clear;
- (SyncSmsResponse_Builder*) clone;

- (SyncSmsResponse*) build;
- (SyncSmsResponse*) buildPartial;

- (SyncSmsResponse_Builder*) mergeFrom:(SyncSmsResponse*) other;
- (SyncSmsResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (SyncSmsResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (ES_PBAppendableArray *)uploadId;
- (NSString*)uploadIdAtIndex:(NSUInteger)index;
- (SyncSmsResponse_Builder *)addUploadId:(NSString*)value;
- (SyncSmsResponse_Builder *)setUploadIdArray:(NSArray *)array;
- (SyncSmsResponse_Builder *)setUploadIdValues:(const NSString* *)values count:(NSUInteger)count;
- (SyncSmsResponse_Builder *)clearUploadId;

- (ES_PBAppendableArray *)downloadId;
- (NSString*)downloadIdAtIndex:(NSUInteger)index;
- (SyncSmsResponse_Builder *)addDownloadId:(NSString*)value;
- (SyncSmsResponse_Builder *)setDownloadIdArray:(NSArray *)array;
- (SyncSmsResponse_Builder *)setDownloadIdValues:(const NSString* *)values count:(NSUInteger)count;
- (SyncSmsResponse_Builder *)clearDownloadId;

- (ES_PBAppendableArray *)deleteId;
- (NSString*)deleteIdAtIndex:(NSUInteger)index;
- (SyncSmsResponse_Builder *)addDeleteId:(NSString*)value;
- (SyncSmsResponse_Builder *)setDeleteIdArray:(NSArray *)array;
- (SyncSmsResponse_Builder *)setDeleteIdValues:(const NSString* *)values count:(NSUInteger)count;
- (SyncSmsResponse_Builder *)clearDeleteId;

- (ES_PBAppendableArray *)updateFavourite;
- (SmsSummary*)updateFavouriteAtIndex:(NSUInteger)index;
- (SyncSmsResponse_Builder *)addUpdateFavourite:(SmsSummary*)value;
- (SyncSmsResponse_Builder *)setUpdateFavouriteArray:(NSArray *)array;
- (SyncSmsResponse_Builder *)setUpdateFavouriteValues:(const SmsSummary* *)values count:(NSUInteger)count;
- (SyncSmsResponse_Builder *)clearUpdateFavourite;
@end

