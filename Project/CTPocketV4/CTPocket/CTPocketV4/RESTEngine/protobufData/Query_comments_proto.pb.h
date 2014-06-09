// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ES_ProtocolBuffers.h"

@class CommentInfoRequest;
@class CommentInfoRequest_Builder;
@class CommentInfoResponse;
@class CommentInfoResponse_Builder;
@class QComment;
@class QComment_Builder;
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


@interface QueryCommentsProtoRoot : NSObject {
}
+ (ES_PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(ES_PBMutableExtensionRegistry*) registry;
@end

@interface QComment : ES_PBGeneratedMessage {
@private
  BOOL hasMark1_:1;
  BOOL hasMark2_:1;
  BOOL hasMark3_:1;
  BOOL hasMark4_:1;
  BOOL hasMark5_:1;
  BOOL hasUserName_:1;
  BOOL hasPortraitUrl_:1;
  BOOL hasContent_:1;
  BOOL hasCommentTime_:1;
  int32_t mark1;
  int32_t mark2;
  int32_t mark3;
  int32_t mark4;
  int32_t mark5;
  NSString* userName;
  NSString* portraitUrl;
  NSString* content;
  NSString* commentTime;
}
- (BOOL) hasUserName;
- (BOOL) hasPortraitUrl;
- (BOOL) hasContent;
- (BOOL) hasMark1;
- (BOOL) hasMark2;
- (BOOL) hasMark3;
- (BOOL) hasMark4;
- (BOOL) hasMark5;
- (BOOL) hasCommentTime;
@property (readonly, retain) NSString* userName;
@property (readonly, retain) NSString* portraitUrl;
@property (readonly, retain) NSString* content;
@property (readonly) int32_t mark1;
@property (readonly) int32_t mark2;
@property (readonly) int32_t mark3;
@property (readonly) int32_t mark4;
@property (readonly) int32_t mark5;
@property (readonly, retain) NSString* commentTime;

+ (QComment*) defaultInstance;
- (QComment*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (QComment_Builder*) builder;
+ (QComment_Builder*) builder;
+ (QComment_Builder*) builderWithPrototype:(QComment*) prototype;
- (QComment_Builder*) toBuilder;

+ (QComment*) parseFromData:(NSData*) data;
+ (QComment*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (QComment*) parseFromInputStream:(NSInputStream*) input;
+ (QComment*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (QComment*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (QComment*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface QComment_Builder : ES_PBGeneratedMessage_Builder {
@private
  QComment* result;
}

- (QComment*) defaultInstance;

- (QComment_Builder*) clear;
- (QComment_Builder*) clone;

- (QComment*) build;
- (QComment*) buildPartial;

- (QComment_Builder*) mergeFrom:(QComment*) other;
- (QComment_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (QComment_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasUserName;
- (NSString*) userName;
- (QComment_Builder*) setUserName:(NSString*) value;
- (QComment_Builder*) clearUserName;

- (BOOL) hasPortraitUrl;
- (NSString*) portraitUrl;
- (QComment_Builder*) setPortraitUrl:(NSString*) value;
- (QComment_Builder*) clearPortraitUrl;

- (BOOL) hasContent;
- (NSString*) content;
- (QComment_Builder*) setContent:(NSString*) value;
- (QComment_Builder*) clearContent;

- (BOOL) hasMark1;
- (int32_t) mark1;
- (QComment_Builder*) setMark1:(int32_t) value;
- (QComment_Builder*) clearMark1;

- (BOOL) hasMark2;
- (int32_t) mark2;
- (QComment_Builder*) setMark2:(int32_t) value;
- (QComment_Builder*) clearMark2;

- (BOOL) hasMark3;
- (int32_t) mark3;
- (QComment_Builder*) setMark3:(int32_t) value;
- (QComment_Builder*) clearMark3;

- (BOOL) hasMark4;
- (int32_t) mark4;
- (QComment_Builder*) setMark4:(int32_t) value;
- (QComment_Builder*) clearMark4;

- (BOOL) hasMark5;
- (int32_t) mark5;
- (QComment_Builder*) setMark5:(int32_t) value;
- (QComment_Builder*) clearMark5;

- (BOOL) hasCommentTime;
- (NSString*) commentTime;
- (QComment_Builder*) setCommentTime:(NSString*) value;
- (QComment_Builder*) clearCommentTime;
@end

@interface CommentInfoRequest : ES_PBGeneratedMessage {
@private
  BOOL hasMark1_:1;
  BOOL hasMark2_:1;
  BOOL hasMark3_:1;
  BOOL hasMark4_:1;
  BOOL hasMark5_:1;
  BOOL hasStart_:1;
  BOOL hasRows_:1;
  BOOL hasCompanyId_:1;
  BOOL hasContent_:1;
  BOOL hasIPaddress_:1;
  int32_t mark1;
  int32_t mark2;
  int32_t mark3;
  int32_t mark4;
  int32_t mark5;
  int32_t start;
  int32_t rows;
  NSString* companyId;
  NSString* content;
  NSString* iPaddress;
}
- (BOOL) hasCompanyId;
- (BOOL) hasContent;
- (BOOL) hasMark1;
- (BOOL) hasMark2;
- (BOOL) hasMark3;
- (BOOL) hasMark4;
- (BOOL) hasMark5;
- (BOOL) hasIPaddress;
- (BOOL) hasStart;
- (BOOL) hasRows;
@property (readonly, retain) NSString* companyId;
@property (readonly, retain) NSString* content;
@property (readonly) int32_t mark1;
@property (readonly) int32_t mark2;
@property (readonly) int32_t mark3;
@property (readonly) int32_t mark4;
@property (readonly) int32_t mark5;
@property (readonly, retain) NSString* iPaddress;
@property (readonly) int32_t start;
@property (readonly) int32_t rows;

+ (CommentInfoRequest*) defaultInstance;
- (CommentInfoRequest*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (CommentInfoRequest_Builder*) builder;
+ (CommentInfoRequest_Builder*) builder;
+ (CommentInfoRequest_Builder*) builderWithPrototype:(CommentInfoRequest*) prototype;
- (CommentInfoRequest_Builder*) toBuilder;

+ (CommentInfoRequest*) parseFromData:(NSData*) data;
+ (CommentInfoRequest*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (CommentInfoRequest*) parseFromInputStream:(NSInputStream*) input;
+ (CommentInfoRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (CommentInfoRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (CommentInfoRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface CommentInfoRequest_Builder : ES_PBGeneratedMessage_Builder {
@private
  CommentInfoRequest* result;
}

- (CommentInfoRequest*) defaultInstance;

- (CommentInfoRequest_Builder*) clear;
- (CommentInfoRequest_Builder*) clone;

- (CommentInfoRequest*) build;
- (CommentInfoRequest*) buildPartial;

- (CommentInfoRequest_Builder*) mergeFrom:(CommentInfoRequest*) other;
- (CommentInfoRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (CommentInfoRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasCompanyId;
- (NSString*) companyId;
- (CommentInfoRequest_Builder*) setCompanyId:(NSString*) value;
- (CommentInfoRequest_Builder*) clearCompanyId;

- (BOOL) hasContent;
- (NSString*) content;
- (CommentInfoRequest_Builder*) setContent:(NSString*) value;
- (CommentInfoRequest_Builder*) clearContent;

- (BOOL) hasMark1;
- (int32_t) mark1;
- (CommentInfoRequest_Builder*) setMark1:(int32_t) value;
- (CommentInfoRequest_Builder*) clearMark1;

- (BOOL) hasMark2;
- (int32_t) mark2;
- (CommentInfoRequest_Builder*) setMark2:(int32_t) value;
- (CommentInfoRequest_Builder*) clearMark2;

- (BOOL) hasMark3;
- (int32_t) mark3;
- (CommentInfoRequest_Builder*) setMark3:(int32_t) value;
- (CommentInfoRequest_Builder*) clearMark3;

- (BOOL) hasMark4;
- (int32_t) mark4;
- (CommentInfoRequest_Builder*) setMark4:(int32_t) value;
- (CommentInfoRequest_Builder*) clearMark4;

- (BOOL) hasMark5;
- (int32_t) mark5;
- (CommentInfoRequest_Builder*) setMark5:(int32_t) value;
- (CommentInfoRequest_Builder*) clearMark5;

- (BOOL) hasIPaddress;
- (NSString*) iPaddress;
- (CommentInfoRequest_Builder*) setIPaddress:(NSString*) value;
- (CommentInfoRequest_Builder*) clearIPaddress;

- (BOOL) hasStart;
- (int32_t) start;
- (CommentInfoRequest_Builder*) setStart:(int32_t) value;
- (CommentInfoRequest_Builder*) clearStart;

- (BOOL) hasRows;
- (int32_t) rows;
- (CommentInfoRequest_Builder*) setRows:(int32_t) value;
- (CommentInfoRequest_Builder*) clearRows;
@end

@interface CommentInfoResponse : ES_PBGeneratedMessage {
@private
  BOOL hasNumFound_:1;
  BOOL hasStatus_:1;
  int64_t numFound;
  int32_t status;
  ES_PBAppendableArray * commentsArray;
}
- (BOOL) hasNumFound;
- (BOOL) hasStatus;
@property (readonly, retain) ES_PBArray * comments;
@property (readonly) int64_t numFound;
@property (readonly) int32_t status;
- (QComment*)commentsAtIndex:(NSUInteger)index;

+ (CommentInfoResponse*) defaultInstance;
- (CommentInfoResponse*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (CommentInfoResponse_Builder*) builder;
+ (CommentInfoResponse_Builder*) builder;
+ (CommentInfoResponse_Builder*) builderWithPrototype:(CommentInfoResponse*) prototype;
- (CommentInfoResponse_Builder*) toBuilder;

+ (CommentInfoResponse*) parseFromData:(NSData*) data;
+ (CommentInfoResponse*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (CommentInfoResponse*) parseFromInputStream:(NSInputStream*) input;
+ (CommentInfoResponse*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (CommentInfoResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (CommentInfoResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface CommentInfoResponse_Builder : ES_PBGeneratedMessage_Builder {
@private
  CommentInfoResponse* result;
}

- (CommentInfoResponse*) defaultInstance;

- (CommentInfoResponse_Builder*) clear;
- (CommentInfoResponse_Builder*) clone;

- (CommentInfoResponse*) build;
- (CommentInfoResponse*) buildPartial;

- (CommentInfoResponse_Builder*) mergeFrom:(CommentInfoResponse*) other;
- (CommentInfoResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (CommentInfoResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (ES_PBAppendableArray *)comments;
- (QComment*)commentsAtIndex:(NSUInteger)index;
- (CommentInfoResponse_Builder *)addComments:(QComment*)value;
- (CommentInfoResponse_Builder *)setCommentsArray:(NSArray *)array;
- (CommentInfoResponse_Builder *)setCommentsValues:(const QComment* *)values count:(NSUInteger)count;
- (CommentInfoResponse_Builder *)clearComments;

- (BOOL) hasNumFound;
- (int64_t) numFound;
- (CommentInfoResponse_Builder*) setNumFound:(int64_t) value;
- (CommentInfoResponse_Builder*) clearNumFound;

- (BOOL) hasStatus;
- (int32_t) status;
- (CommentInfoResponse_Builder*) setStatus:(int32_t) value;
- (CommentInfoResponse_Builder*) clearStatus;
@end
