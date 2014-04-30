// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ES_ProtocolBuffers.h"

#import "Contact_proto.pb.h"

@class Address;
@class Address_Builder;
@class Category;
@class Category_Builder;
@class Contact;
@class Contact_Builder;
@class Email;
@class Email_Builder;
@class Employed;
@class Employed_Builder;
@class Group;
@class Group_Builder;
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
@class SyncMappingInfo;
@class SyncMappingInfo_Builder;
@class SyncSummary;
@class SyncSummary_Builder;
@class SyncUploadContactRequest;
@class SyncUploadContactRequest_Builder;
@class SyncUploadContactResponse;
@class SyncUploadContactResponse_Builder;
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


@interface SyncUploadContactProtoRoot : NSObject {
}
+ (ES_PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(ES_PBMutableExtensionRegistry*) registry;
@end

@interface SyncUploadContactRequest : ES_PBGeneratedMessage {
@private
  BOOL hasBusinessCardVersion_:1;
  BOOL hasBusinessCard_:1;
  int32_t businessCardVersion;
  Contact* businessCard;
  ES_PBAppendableArray * contactDelArray;
  int32_t contactDelMemoizedSerializedSize;
  ES_PBAppendableArray * groupDelArray;
  int32_t groupDelMemoizedSerializedSize;
  ES_PBAppendableArray * contactAddArray;
  ES_PBAppendableArray * contactUpdArray;
  ES_PBAppendableArray * contactSyncSummaryArray;
  ES_PBAppendableArray * groupAddArray;
  ES_PBAppendableArray * groupUpdArray;
  ES_PBAppendableArray * groupSyncSummaryArray;
}
- (BOOL) hasBusinessCard;
- (BOOL) hasBusinessCardVersion;
@property (readonly, retain) ES_PBArray * contactAdd;
@property (readonly, retain) ES_PBArray * contactUpd;
@property (readonly, retain) ES_PBArray * contactDel;
@property (readonly, retain) ES_PBArray * contactSyncSummary;
@property (readonly, retain) ES_PBArray * groupAdd;
@property (readonly, retain) ES_PBArray * groupUpd;
@property (readonly, retain) ES_PBArray * groupDel;
@property (readonly, retain) ES_PBArray * groupSyncSummary;
@property (readonly, retain) Contact* businessCard;
@property (readonly) int32_t businessCardVersion;
- (Contact*)contactAddAtIndex:(NSUInteger)index;
- (Contact*)contactUpdAtIndex:(NSUInteger)index;
- (int32_t)contactDelAtIndex:(NSUInteger)index;
- (SyncSummary*)contactSyncSummaryAtIndex:(NSUInteger)index;
- (Group*)groupAddAtIndex:(NSUInteger)index;
- (Group*)groupUpdAtIndex:(NSUInteger)index;
- (int32_t)groupDelAtIndex:(NSUInteger)index;
- (SyncSummary*)groupSyncSummaryAtIndex:(NSUInteger)index;

+ (SyncUploadContactRequest*) defaultInstance;
- (SyncUploadContactRequest*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (SyncUploadContactRequest_Builder*) builder;
+ (SyncUploadContactRequest_Builder*) builder;
+ (SyncUploadContactRequest_Builder*) builderWithPrototype:(SyncUploadContactRequest*) prototype;
- (SyncUploadContactRequest_Builder*) toBuilder;

+ (SyncUploadContactRequest*) parseFromData:(NSData*) data;
+ (SyncUploadContactRequest*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncUploadContactRequest*) parseFromInputStream:(NSInputStream*) input;
+ (SyncUploadContactRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncUploadContactRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (SyncUploadContactRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncUploadContactRequest_Builder : ES_PBGeneratedMessage_Builder {
@private
  SyncUploadContactRequest* result;
}

- (SyncUploadContactRequest*) defaultInstance;

- (SyncUploadContactRequest_Builder*) clear;
- (SyncUploadContactRequest_Builder*) clone;

- (SyncUploadContactRequest*) build;
- (SyncUploadContactRequest*) buildPartial;

- (SyncUploadContactRequest_Builder*) mergeFrom:(SyncUploadContactRequest*) other;
- (SyncUploadContactRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (SyncUploadContactRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (ES_PBAppendableArray *)contactAdd;
- (Contact*)contactAddAtIndex:(NSUInteger)index;
- (SyncUploadContactRequest_Builder *)addContactAdd:(Contact*)value;
- (SyncUploadContactRequest_Builder *)setContactAddArray:(NSArray *)array;
- (SyncUploadContactRequest_Builder *)setContactAddValues:(const Contact* *)values count:(NSUInteger)count;
- (SyncUploadContactRequest_Builder *)clearContactAdd;

- (ES_PBAppendableArray *)contactUpd;
- (Contact*)contactUpdAtIndex:(NSUInteger)index;
- (SyncUploadContactRequest_Builder *)addContactUpd:(Contact*)value;
- (SyncUploadContactRequest_Builder *)setContactUpdArray:(NSArray *)array;
- (SyncUploadContactRequest_Builder *)setContactUpdValues:(const Contact* *)values count:(NSUInteger)count;
- (SyncUploadContactRequest_Builder *)clearContactUpd;

- (ES_PBAppendableArray *)contactDel;
- (int32_t)contactDelAtIndex:(NSUInteger)index;
- (SyncUploadContactRequest_Builder *)addContactDel:(int32_t)value;
- (SyncUploadContactRequest_Builder *)setContactDelArray:(NSArray *)array;
- (SyncUploadContactRequest_Builder *)setContactDelValues:(const int32_t *)values count:(NSUInteger)count;
- (SyncUploadContactRequest_Builder *)clearContactDel;

- (ES_PBAppendableArray *)contactSyncSummary;
- (SyncSummary*)contactSyncSummaryAtIndex:(NSUInteger)index;
- (SyncUploadContactRequest_Builder *)addContactSyncSummary:(SyncSummary*)value;
- (SyncUploadContactRequest_Builder *)setContactSyncSummaryArray:(NSArray *)array;
- (SyncUploadContactRequest_Builder *)setContactSyncSummaryValues:(const SyncSummary* *)values count:(NSUInteger)count;
- (SyncUploadContactRequest_Builder *)clearContactSyncSummary;

- (ES_PBAppendableArray *)groupAdd;
- (Group*)groupAddAtIndex:(NSUInteger)index;
- (SyncUploadContactRequest_Builder *)addGroupAdd:(Group*)value;
- (SyncUploadContactRequest_Builder *)setGroupAddArray:(NSArray *)array;
- (SyncUploadContactRequest_Builder *)setGroupAddValues:(const Group* *)values count:(NSUInteger)count;
- (SyncUploadContactRequest_Builder *)clearGroupAdd;

- (ES_PBAppendableArray *)groupUpd;
- (Group*)groupUpdAtIndex:(NSUInteger)index;
- (SyncUploadContactRequest_Builder *)addGroupUpd:(Group*)value;
- (SyncUploadContactRequest_Builder *)setGroupUpdArray:(NSArray *)array;
- (SyncUploadContactRequest_Builder *)setGroupUpdValues:(const Group* *)values count:(NSUInteger)count;
- (SyncUploadContactRequest_Builder *)clearGroupUpd;

- (ES_PBAppendableArray *)groupDel;
- (int32_t)groupDelAtIndex:(NSUInteger)index;
- (SyncUploadContactRequest_Builder *)addGroupDel:(int32_t)value;
- (SyncUploadContactRequest_Builder *)setGroupDelArray:(NSArray *)array;
- (SyncUploadContactRequest_Builder *)setGroupDelValues:(const int32_t *)values count:(NSUInteger)count;
- (SyncUploadContactRequest_Builder *)clearGroupDel;

- (ES_PBAppendableArray *)groupSyncSummary;
- (SyncSummary*)groupSyncSummaryAtIndex:(NSUInteger)index;
- (SyncUploadContactRequest_Builder *)addGroupSyncSummary:(SyncSummary*)value;
- (SyncUploadContactRequest_Builder *)setGroupSyncSummaryArray:(NSArray *)array;
- (SyncUploadContactRequest_Builder *)setGroupSyncSummaryValues:(const SyncSummary* *)values count:(NSUInteger)count;
- (SyncUploadContactRequest_Builder *)clearGroupSyncSummary;

- (BOOL) hasBusinessCard;
- (Contact*) businessCard;
- (SyncUploadContactRequest_Builder*) setBusinessCard:(Contact*) value;
- (SyncUploadContactRequest_Builder*) setBusinessCardBuilder:(Contact_Builder*) builderForValue;
- (SyncUploadContactRequest_Builder*) mergeBusinessCard:(Contact*) value;
- (SyncUploadContactRequest_Builder*) clearBusinessCard;

- (BOOL) hasBusinessCardVersion;
- (int32_t) businessCardVersion;
- (SyncUploadContactRequest_Builder*) setBusinessCardVersion:(int32_t) value;
- (SyncUploadContactRequest_Builder*) clearBusinessCardVersion;
@end

@interface SyncUploadContactResponse : ES_PBGeneratedMessage {
@private
  BOOL hasContactListVersion_:1;
  BOOL hasBusinessCardVersion_:1;
  BOOL hasSessionId_:1;
  int32_t contactListVersion;
  int32_t businessCardVersion;
  NSString* sessionId;
  ES_PBAppendableArray * deletedContactIdArray;
  int32_t deletedContactIdMemoizedSerializedSize;
  ES_PBAppendableArray * updatedContactIdArray;
  int32_t updatedContactIdMemoizedSerializedSize;
  ES_PBAppendableArray * deletedGroupIdArray;
  int32_t deletedGroupIdMemoizedSerializedSize;
  ES_PBAppendableArray * updatedGroupIdArray;
  int32_t updatedGroupIdMemoizedSerializedSize;
  ES_PBAppendableArray * contactMappingInfoArray;
  ES_PBAppendableArray * groupMappingInfoArray;
}
- (BOOL) hasContactListVersion;
- (BOOL) hasSessionId;
- (BOOL) hasBusinessCardVersion;
@property (readonly) int32_t contactListVersion;
@property (readonly, retain) NSString* sessionId;
@property (readonly, retain) ES_PBArray * contactMappingInfo;
@property (readonly, retain) ES_PBArray * deletedContactId;
@property (readonly, retain) ES_PBArray * updatedContactId;
@property (readonly, retain) ES_PBArray * groupMappingInfo;
@property (readonly, retain) ES_PBArray * deletedGroupId;
@property (readonly, retain) ES_PBArray * updatedGroupId;
@property (readonly) int32_t businessCardVersion;
- (SyncMappingInfo*)contactMappingInfoAtIndex:(NSUInteger)index;
- (int32_t)deletedContactIdAtIndex:(NSUInteger)index;
- (int32_t)updatedContactIdAtIndex:(NSUInteger)index;
- (SyncMappingInfo*)groupMappingInfoAtIndex:(NSUInteger)index;
- (int32_t)deletedGroupIdAtIndex:(NSUInteger)index;
- (int32_t)updatedGroupIdAtIndex:(NSUInteger)index;

+ (SyncUploadContactResponse*) defaultInstance;
- (SyncUploadContactResponse*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (SyncUploadContactResponse_Builder*) builder;
+ (SyncUploadContactResponse_Builder*) builder;
+ (SyncUploadContactResponse_Builder*) builderWithPrototype:(SyncUploadContactResponse*) prototype;
- (SyncUploadContactResponse_Builder*) toBuilder;

+ (SyncUploadContactResponse*) parseFromData:(NSData*) data;
+ (SyncUploadContactResponse*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncUploadContactResponse*) parseFromInputStream:(NSInputStream*) input;
+ (SyncUploadContactResponse*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncUploadContactResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (SyncUploadContactResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncUploadContactResponse_Builder : ES_PBGeneratedMessage_Builder {
@private
  SyncUploadContactResponse* result;
}

- (SyncUploadContactResponse*) defaultInstance;

- (SyncUploadContactResponse_Builder*) clear;
- (SyncUploadContactResponse_Builder*) clone;

- (SyncUploadContactResponse*) build;
- (SyncUploadContactResponse*) buildPartial;

- (SyncUploadContactResponse_Builder*) mergeFrom:(SyncUploadContactResponse*) other;
- (SyncUploadContactResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (SyncUploadContactResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasContactListVersion;
- (int32_t) contactListVersion;
- (SyncUploadContactResponse_Builder*) setContactListVersion:(int32_t) value;
- (SyncUploadContactResponse_Builder*) clearContactListVersion;

- (BOOL) hasSessionId;
- (NSString*) sessionId;
- (SyncUploadContactResponse_Builder*) setSessionId:(NSString*) value;
- (SyncUploadContactResponse_Builder*) clearSessionId;

- (ES_PBAppendableArray *)contactMappingInfo;
- (SyncMappingInfo*)contactMappingInfoAtIndex:(NSUInteger)index;
- (SyncUploadContactResponse_Builder *)addContactMappingInfo:(SyncMappingInfo*)value;
- (SyncUploadContactResponse_Builder *)setContactMappingInfoArray:(NSArray *)array;
- (SyncUploadContactResponse_Builder *)setContactMappingInfoValues:(const SyncMappingInfo* *)values count:(NSUInteger)count;
- (SyncUploadContactResponse_Builder *)clearContactMappingInfo;

- (ES_PBAppendableArray *)deletedContactId;
- (int32_t)deletedContactIdAtIndex:(NSUInteger)index;
- (SyncUploadContactResponse_Builder *)addDeletedContactId:(int32_t)value;
- (SyncUploadContactResponse_Builder *)setDeletedContactIdArray:(NSArray *)array;
- (SyncUploadContactResponse_Builder *)setDeletedContactIdValues:(const int32_t *)values count:(NSUInteger)count;
- (SyncUploadContactResponse_Builder *)clearDeletedContactId;

- (ES_PBAppendableArray *)updatedContactId;
- (int32_t)updatedContactIdAtIndex:(NSUInteger)index;
- (SyncUploadContactResponse_Builder *)addUpdatedContactId:(int32_t)value;
- (SyncUploadContactResponse_Builder *)setUpdatedContactIdArray:(NSArray *)array;
- (SyncUploadContactResponse_Builder *)setUpdatedContactIdValues:(const int32_t *)values count:(NSUInteger)count;
- (SyncUploadContactResponse_Builder *)clearUpdatedContactId;

- (ES_PBAppendableArray *)groupMappingInfo;
- (SyncMappingInfo*)groupMappingInfoAtIndex:(NSUInteger)index;
- (SyncUploadContactResponse_Builder *)addGroupMappingInfo:(SyncMappingInfo*)value;
- (SyncUploadContactResponse_Builder *)setGroupMappingInfoArray:(NSArray *)array;
- (SyncUploadContactResponse_Builder *)setGroupMappingInfoValues:(const SyncMappingInfo* *)values count:(NSUInteger)count;
- (SyncUploadContactResponse_Builder *)clearGroupMappingInfo;

- (ES_PBAppendableArray *)deletedGroupId;
- (int32_t)deletedGroupIdAtIndex:(NSUInteger)index;
- (SyncUploadContactResponse_Builder *)addDeletedGroupId:(int32_t)value;
- (SyncUploadContactResponse_Builder *)setDeletedGroupIdArray:(NSArray *)array;
- (SyncUploadContactResponse_Builder *)setDeletedGroupIdValues:(const int32_t *)values count:(NSUInteger)count;
- (SyncUploadContactResponse_Builder *)clearDeletedGroupId;

- (ES_PBAppendableArray *)updatedGroupId;
- (int32_t)updatedGroupIdAtIndex:(NSUInteger)index;
- (SyncUploadContactResponse_Builder *)addUpdatedGroupId:(int32_t)value;
- (SyncUploadContactResponse_Builder *)setUpdatedGroupIdArray:(NSArray *)array;
- (SyncUploadContactResponse_Builder *)setUpdatedGroupIdValues:(const int32_t *)values count:(NSUInteger)count;
- (SyncUploadContactResponse_Builder *)clearUpdatedGroupId;

- (BOOL) hasBusinessCardVersion;
- (int32_t) businessCardVersion;
- (SyncUploadContactResponse_Builder*) setBusinessCardVersion:(int32_t) value;
- (SyncUploadContactResponse_Builder*) clearBusinessCardVersion;
@end

@interface SyncMappingInfo : ES_PBGeneratedMessage {
@private
  BOOL hasTempServerId_:1;
  BOOL hasServerId_:1;
  BOOL hasVersion_:1;
  int32_t tempServerId;
  int32_t serverId;
  int32_t version;
}
- (BOOL) hasTempServerId;
- (BOOL) hasServerId;
- (BOOL) hasVersion;
@property (readonly) int32_t tempServerId;
@property (readonly) int32_t serverId;
@property (readonly) int32_t version;

+ (SyncMappingInfo*) defaultInstance;
- (SyncMappingInfo*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (SyncMappingInfo_Builder*) builder;
+ (SyncMappingInfo_Builder*) builder;
+ (SyncMappingInfo_Builder*) builderWithPrototype:(SyncMappingInfo*) prototype;
- (SyncMappingInfo_Builder*) toBuilder;

+ (SyncMappingInfo*) parseFromData:(NSData*) data;
+ (SyncMappingInfo*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncMappingInfo*) parseFromInputStream:(NSInputStream*) input;
+ (SyncMappingInfo*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncMappingInfo*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (SyncMappingInfo*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncMappingInfo_Builder : ES_PBGeneratedMessage_Builder {
@private
  SyncMappingInfo* result;
}

- (SyncMappingInfo*) defaultInstance;

- (SyncMappingInfo_Builder*) clear;
- (SyncMappingInfo_Builder*) clone;

- (SyncMappingInfo*) build;
- (SyncMappingInfo*) buildPartial;

- (SyncMappingInfo_Builder*) mergeFrom:(SyncMappingInfo*) other;
- (SyncMappingInfo_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (SyncMappingInfo_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasTempServerId;
- (int32_t) tempServerId;
- (SyncMappingInfo_Builder*) setTempServerId:(int32_t) value;
- (SyncMappingInfo_Builder*) clearTempServerId;

- (BOOL) hasServerId;
- (int32_t) serverId;
- (SyncMappingInfo_Builder*) setServerId:(int32_t) value;
- (SyncMappingInfo_Builder*) clearServerId;

- (BOOL) hasVersion;
- (int32_t) version;
- (SyncMappingInfo_Builder*) setVersion:(int32_t) value;
- (SyncMappingInfo_Builder*) clearVersion;
@end

@interface SyncSummary : ES_PBGeneratedMessage {
@private
  BOOL hasId_:1;
  BOOL hasVersion_:1;
  int32_t id;
  int32_t version;
}
- (BOOL) hasId;
- (BOOL) hasVersion;
@property (readonly) int32_t id;
@property (readonly) int32_t version;

+ (SyncSummary*) defaultInstance;
- (SyncSummary*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output;
- (SyncSummary_Builder*) builder;
+ (SyncSummary_Builder*) builder;
+ (SyncSummary_Builder*) builderWithPrototype:(SyncSummary*) prototype;
- (SyncSummary_Builder*) toBuilder;

+ (SyncSummary*) parseFromData:(NSData*) data;
+ (SyncSummary*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncSummary*) parseFromInputStream:(NSInputStream*) input;
+ (SyncSummary*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
+ (SyncSummary*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input;
+ (SyncSummary*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;
@end

@interface SyncSummary_Builder : ES_PBGeneratedMessage_Builder {
@private
  SyncSummary* result;
}

- (SyncSummary*) defaultInstance;

- (SyncSummary_Builder*) clear;
- (SyncSummary_Builder*) clone;

- (SyncSummary*) build;
- (SyncSummary*) buildPartial;

- (SyncSummary_Builder*) mergeFrom:(SyncSummary*) other;
- (SyncSummary_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input;
- (SyncSummary_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasId;
- (int32_t) id;
- (SyncSummary_Builder*) setId:(int32_t) value;
- (SyncSummary_Builder*) clearId;

- (BOOL) hasVersion;
- (int32_t) version;
- (SyncSummary_Builder*) setVersion:(int32_t) value;
- (SyncSummary_Builder*) clearVersion;
@end
