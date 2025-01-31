// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "Download_portrait_proto.pb.h"

@implementation DownloadPortraitProtoRoot
static ES_PBExtensionRegistry* extensionRegistry = nil;
+ (ES_PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [DownloadPortraitProtoRoot class]) {
    ES_PBMutableExtensionRegistry* registry = [ES_PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [BaseTypeProtoRoot registerAllExtensions:registry];
    extensionRegistry = [registry retain];
  }
}
+ (void) registerAllExtensions:(ES_PBMutableExtensionRegistry*) registry {
}
@end

@interface DownloadPortraitRequest ()
@property (retain) ES_PBAppendableArray * sidArray;
@property BOOL isRequestBusinessCardPortrait;
@end

@implementation DownloadPortraitRequest

@synthesize sidArray;
@dynamic sid;
- (BOOL) hasIsRequestBusinessCardPortrait {
  return !!hasIsRequestBusinessCardPortrait_;
}
- (void) setHasIsRequestBusinessCardPortrait:(BOOL) value_ {
  hasIsRequestBusinessCardPortrait_ = !!value_;
}
- (BOOL) isRequestBusinessCardPortrait {
  return !!isRequestBusinessCardPortrait_;
}
- (void) setIsRequestBusinessCardPortrait:(BOOL) value_ {
  isRequestBusinessCardPortrait_ = !!value_;
}
- (void) dealloc {
  self.sidArray = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.isRequestBusinessCardPortrait = NO;
  }
  return self;
}
static DownloadPortraitRequest* defaultDownloadPortraitRequestInstance = nil;
+ (void) initialize {
  if (self == [DownloadPortraitRequest class]) {
    defaultDownloadPortraitRequestInstance = [[DownloadPortraitRequest alloc] init];
  }
}
+ (DownloadPortraitRequest*) defaultInstance {
  return defaultDownloadPortraitRequestInstance;
}
- (DownloadPortraitRequest*) defaultInstance {
  return defaultDownloadPortraitRequestInstance;
}
- (ES_PBArray *)sid {
  return sidArray;
}
- (int32_t)sidAtIndex:(NSUInteger)index {
  return [sidArray int32AtIndex:index];
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output {
  const NSUInteger sidArrayCount = self.sidArray.count;
  if (sidArrayCount > 0) {
    const int32_t *values = (const int32_t *)self.sidArray.data;
    [output writeRawVarint32:10];
    [output writeRawVarint32:sidMemoizedSerializedSize];
    for (NSUInteger i = 0; i < sidArrayCount; ++i) {
      [output writeInt32NoTag:values[i]];
    }
  }
  if (self.hasIsRequestBusinessCardPortrait) {
    [output writeBool:2 value:self.isRequestBusinessCardPortrait];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  {
    int32_t dataSize = 0;
    const NSUInteger count = self.sidArray.count;
    const int32_t *values = (const int32_t *)self.sidArray.data;
    for (NSUInteger i = 0; i < count; ++i) {
      dataSize += ES_computeInt32SizeNoTag(values[i]);
    }
    size_ += dataSize;
    if (count > 0) {
      size_ += 1;
      size_ += ES_computeInt32SizeNoTag(dataSize);
    }
    sidMemoizedSerializedSize = dataSize;
  }
  if (self.hasIsRequestBusinessCardPortrait) {
    size_ += ES_computeBoolSize(2, self.isRequestBusinessCardPortrait);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (DownloadPortraitRequest*) parseFromData:(NSData*) data {
  return (DownloadPortraitRequest*)[[[DownloadPortraitRequest builder] mergeFromData:data] build];
}
+ (DownloadPortraitRequest*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitRequest*)[[[DownloadPortraitRequest builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitRequest*) parseFromInputStream:(NSInputStream*) input {
  return (DownloadPortraitRequest*)[[[DownloadPortraitRequest builder] mergeFromInputStream:input] build];
}
+ (DownloadPortraitRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitRequest*)[[[DownloadPortraitRequest builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return (DownloadPortraitRequest*)[[[DownloadPortraitRequest builder] mergeFromCodedInputStream:input] build];
}
+ (DownloadPortraitRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitRequest*)[[[DownloadPortraitRequest builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitRequest_Builder*) builder {
  return [[[DownloadPortraitRequest_Builder alloc] init] autorelease];
}
+ (DownloadPortraitRequest_Builder*) builderWithPrototype:(DownloadPortraitRequest*) prototype {
  return [[DownloadPortraitRequest builder] mergeFrom:prototype];
}
- (DownloadPortraitRequest_Builder*) builder {
  return [DownloadPortraitRequest builder];
}
- (DownloadPortraitRequest_Builder*) toBuilder {
  return [DownloadPortraitRequest builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  for (NSNumber* value in self.sidArray) {
    [output appendFormat:@"%@%@: %@\n", indent, @"sid", value];
  }
  if (self.hasIsRequestBusinessCardPortrait) {
    [output appendFormat:@"%@%@: %@\n", indent, @"isRequestBusinessCardPortrait", [NSNumber numberWithBool:self.isRequestBusinessCardPortrait]];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[DownloadPortraitRequest class]]) {
    return NO;
  }
  DownloadPortraitRequest *otherMessage = other;
  return
      [self.sidArray isEqualToArray:otherMessage.sidArray] &&
      self.hasIsRequestBusinessCardPortrait == otherMessage.hasIsRequestBusinessCardPortrait &&
      (!self.hasIsRequestBusinessCardPortrait || self.isRequestBusinessCardPortrait == otherMessage.isRequestBusinessCardPortrait) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  NSUInteger hashCode = 7;
  for (NSNumber* value in self.sidArray) {
    hashCode = hashCode * 31 + [value intValue];
  }
  if (self.hasIsRequestBusinessCardPortrait) {
    hashCode = hashCode * 31 + [[NSNumber numberWithBool:self.isRequestBusinessCardPortrait] hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface DownloadPortraitRequest_Builder()
@property (retain) DownloadPortraitRequest* result;
@end

@implementation DownloadPortraitRequest_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[[DownloadPortraitRequest alloc] init] autorelease];
  }
  return self;
}
- (ES_PBGeneratedMessage*) internalGetResult {
  return result;
}
- (DownloadPortraitRequest_Builder*) clear {
  self.result = [[[DownloadPortraitRequest alloc] init] autorelease];
  return self;
}
- (DownloadPortraitRequest_Builder*) clone {
  return [DownloadPortraitRequest builderWithPrototype:result];
}
- (DownloadPortraitRequest*) defaultInstance {
  return [DownloadPortraitRequest defaultInstance];
}
- (DownloadPortraitRequest*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (DownloadPortraitRequest*) buildPartial {
  DownloadPortraitRequest* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (DownloadPortraitRequest_Builder*) mergeFrom:(DownloadPortraitRequest*) other {
  if (other == [DownloadPortraitRequest defaultInstance]) {
    return self;
  }
  if (other.sidArray.count > 0) {
    if (result.sidArray == nil) {
      result.sidArray = [[other.sidArray copyWithZone:[other.sidArray zone]] autorelease];
    } else {
      [result.sidArray appendArray:other.sidArray];
    }
  }
  if (other.hasIsRequestBusinessCardPortrait) {
    [self setIsRequestBusinessCardPortrait:other.isRequestBusinessCardPortrait];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (DownloadPortraitRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[ES_PBExtensionRegistry emptyRegistry]];
}
- (DownloadPortraitRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  ES_PBUnknownFieldSet_Builder* unknownFields = [ES_PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    int32_t tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 10: {
        int32_t length = [input readRawVarint32];
        int32_t limit = [input pushLimit:length];
        if (result.sidArray == nil) {
          result.sidArray = [ES_PBAppendableArray arrayWithValueType:ES_PBArrayValueTypeInt32];
        }
        while (input.bytesUntilLimit > 0) {
          [result.sidArray addInt32:[input readInt32]];
        }
        [input popLimit:limit];
        break;
      }
      case 16: {
        [self setIsRequestBusinessCardPortrait:[input readBool]];
        break;
      }
    }
  }
}
- (ES_PBAppendableArray *)sid {
  return result.sidArray;
}
- (int32_t)sidAtIndex:(NSUInteger)index {
  return [result sidAtIndex:index];
}
- (DownloadPortraitRequest_Builder *)addSid:(int32_t)value {
  if (result.sidArray == nil) {
    result.sidArray = [ES_PBAppendableArray arrayWithValueType:ES_PBArrayValueTypeInt32];
  }
  [result.sidArray addInt32:value];
  return self;
}
- (DownloadPortraitRequest_Builder *)setSidArray:(NSArray *)array {
  result.sidArray = [ES_PBAppendableArray arrayWithArray:array valueType:ES_PBArrayValueTypeInt32];
  return self;
}
- (DownloadPortraitRequest_Builder *)setSidValues:(const int32_t *)values count:(NSUInteger)count {
  result.sidArray = [ES_PBAppendableArray arrayWithValues:values count:count valueType:ES_PBArrayValueTypeInt32];
  return self;
}
- (DownloadPortraitRequest_Builder *)clearSid {
  result.sidArray = nil;
  return self;
}
- (BOOL) hasIsRequestBusinessCardPortrait {
  return result.hasIsRequestBusinessCardPortrait;
}
- (BOOL) isRequestBusinessCardPortrait {
  return result.isRequestBusinessCardPortrait;
}
- (DownloadPortraitRequest_Builder*) setIsRequestBusinessCardPortrait:(BOOL) value {
  result.hasIsRequestBusinessCardPortrait = YES;
  result.isRequestBusinessCardPortrait = value;
  return self;
}
- (DownloadPortraitRequest_Builder*) clearIsRequestBusinessCardPortrait {
  result.hasIsRequestBusinessCardPortrait = NO;
  result.isRequestBusinessCardPortrait = NO;
  return self;
}
@end

@interface DownloadPortraitData ()
@property (retain) PortraitData* portraitData;
@property int32_t portraitVersion;
@end

@implementation DownloadPortraitData

- (BOOL) hasPortraitData {
  return !!hasPortraitData_;
}
- (void) setHasPortraitData:(BOOL) value_ {
  hasPortraitData_ = !!value_;
}
@synthesize portraitData;
- (BOOL) hasPortraitVersion {
  return !!hasPortraitVersion_;
}
- (void) setHasPortraitVersion:(BOOL) value_ {
  hasPortraitVersion_ = !!value_;
}
@synthesize portraitVersion;
- (void) dealloc {
  self.portraitData = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.portraitData = [PortraitData defaultInstance];
    self.portraitVersion = 0;
  }
  return self;
}
static DownloadPortraitData* defaultDownloadPortraitDataInstance = nil;
+ (void) initialize {
  if (self == [DownloadPortraitData class]) {
    defaultDownloadPortraitDataInstance = [[DownloadPortraitData alloc] init];
  }
}
+ (DownloadPortraitData*) defaultInstance {
  return defaultDownloadPortraitDataInstance;
}
- (DownloadPortraitData*) defaultInstance {
  return defaultDownloadPortraitDataInstance;
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output {
  if (self.hasPortraitData) {
    [output writeMessage:1 value:self.portraitData];
  }
  if (self.hasPortraitVersion) {
    [output writeInt32:2 value:self.portraitVersion];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasPortraitData) {
    size_ += ES_computeMessageSize(1, self.portraitData);
  }
  if (self.hasPortraitVersion) {
    size_ += ES_computeInt32Size(2, self.portraitVersion);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (DownloadPortraitData*) parseFromData:(NSData*) data {
  return (DownloadPortraitData*)[[[DownloadPortraitData builder] mergeFromData:data] build];
}
+ (DownloadPortraitData*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitData*)[[[DownloadPortraitData builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitData*) parseFromInputStream:(NSInputStream*) input {
  return (DownloadPortraitData*)[[[DownloadPortraitData builder] mergeFromInputStream:input] build];
}
+ (DownloadPortraitData*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitData*)[[[DownloadPortraitData builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitData*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return (DownloadPortraitData*)[[[DownloadPortraitData builder] mergeFromCodedInputStream:input] build];
}
+ (DownloadPortraitData*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitData*)[[[DownloadPortraitData builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitData_Builder*) builder {
  return [[[DownloadPortraitData_Builder alloc] init] autorelease];
}
+ (DownloadPortraitData_Builder*) builderWithPrototype:(DownloadPortraitData*) prototype {
  return [[DownloadPortraitData builder] mergeFrom:prototype];
}
- (DownloadPortraitData_Builder*) builder {
  return [DownloadPortraitData builder];
}
- (DownloadPortraitData_Builder*) toBuilder {
  return [DownloadPortraitData builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasPortraitData) {
    [output appendFormat:@"%@%@ {\n", indent, @"portraitData"];
    [self.portraitData writeDescriptionTo:output
                         withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  if (self.hasPortraitVersion) {
    [output appendFormat:@"%@%@: %@\n", indent, @"portraitVersion", [NSNumber numberWithInt:self.portraitVersion]];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[DownloadPortraitData class]]) {
    return NO;
  }
  DownloadPortraitData *otherMessage = other;
  return
      self.hasPortraitData == otherMessage.hasPortraitData &&
      (!self.hasPortraitData || [self.portraitData isEqual:otherMessage.portraitData]) &&
      self.hasPortraitVersion == otherMessage.hasPortraitVersion &&
      (!self.hasPortraitVersion || self.portraitVersion == otherMessage.portraitVersion) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  NSUInteger hashCode = 7;
  if (self.hasPortraitData) {
    hashCode = hashCode * 31 + [self.portraitData hash];
  }
  if (self.hasPortraitVersion) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInt:self.portraitVersion] hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface DownloadPortraitData_Builder()
@property (retain) DownloadPortraitData* result;
@end

@implementation DownloadPortraitData_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[[DownloadPortraitData alloc] init] autorelease];
  }
  return self;
}
- (ES_PBGeneratedMessage*) internalGetResult {
  return result;
}
- (DownloadPortraitData_Builder*) clear {
  self.result = [[[DownloadPortraitData alloc] init] autorelease];
  return self;
}
- (DownloadPortraitData_Builder*) clone {
  return [DownloadPortraitData builderWithPrototype:result];
}
- (DownloadPortraitData*) defaultInstance {
  return [DownloadPortraitData defaultInstance];
}
- (DownloadPortraitData*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (DownloadPortraitData*) buildPartial {
  DownloadPortraitData* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (DownloadPortraitData_Builder*) mergeFrom:(DownloadPortraitData*) other {
  if (other == [DownloadPortraitData defaultInstance]) {
    return self;
  }
  if (other.hasPortraitData) {
    [self mergePortraitData:other.portraitData];
  }
  if (other.hasPortraitVersion) {
    [self setPortraitVersion:other.portraitVersion];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (DownloadPortraitData_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[ES_PBExtensionRegistry emptyRegistry]];
}
- (DownloadPortraitData_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  ES_PBUnknownFieldSet_Builder* unknownFields = [ES_PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    int32_t tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 10: {
        PortraitData_Builder* subBuilder = [PortraitData builder];
        if (self.hasPortraitData) {
          [subBuilder mergeFrom:self.portraitData];
        }
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self setPortraitData:[subBuilder buildPartial]];
        break;
      }
      case 16: {
        [self setPortraitVersion:[input readInt32]];
        break;
      }
    }
  }
}
- (BOOL) hasPortraitData {
  return result.hasPortraitData;
}
- (PortraitData*) portraitData {
  return result.portraitData;
}
- (DownloadPortraitData_Builder*) setPortraitData:(PortraitData*) value {
  result.hasPortraitData = YES;
  result.portraitData = value;
  return self;
}
- (DownloadPortraitData_Builder*) setPortraitDataBuilder:(PortraitData_Builder*) builderForValue {
  return [self setPortraitData:[builderForValue build]];
}
- (DownloadPortraitData_Builder*) mergePortraitData:(PortraitData*) value {
  if (result.hasPortraitData &&
      result.portraitData != [PortraitData defaultInstance]) {
    result.portraitData =
      [[[PortraitData builderWithPrototype:result.portraitData] mergeFrom:value] buildPartial];
  } else {
    result.portraitData = value;
  }
  result.hasPortraitData = YES;
  return self;
}
- (DownloadPortraitData_Builder*) clearPortraitData {
  result.hasPortraitData = NO;
  result.portraitData = [PortraitData defaultInstance];
  return self;
}
- (BOOL) hasPortraitVersion {
  return result.hasPortraitVersion;
}
- (int32_t) portraitVersion {
  return result.portraitVersion;
}
- (DownloadPortraitData_Builder*) setPortraitVersion:(int32_t) value {
  result.hasPortraitVersion = YES;
  result.portraitVersion = value;
  return self;
}
- (DownloadPortraitData_Builder*) clearPortraitVersion {
  result.hasPortraitVersion = NO;
  result.portraitVersion = 0;
  return self;
}
@end

@interface DownloadPortraitResponse ()
@property (retain) ES_PBAppendableArray * portraitArray;
@property (retain) DownloadPortraitData* businessCardPortrait;
@end

@implementation DownloadPortraitResponse

@synthesize portraitArray;
@dynamic portrait;
- (BOOL) hasBusinessCardPortrait {
  return !!hasBusinessCardPortrait_;
}
- (void) setHasBusinessCardPortrait:(BOOL) value_ {
  hasBusinessCardPortrait_ = !!value_;
}
@synthesize businessCardPortrait;
- (void) dealloc {
  self.portraitArray = nil;
  self.businessCardPortrait = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.businessCardPortrait = [DownloadPortraitData defaultInstance];
  }
  return self;
}
static DownloadPortraitResponse* defaultDownloadPortraitResponseInstance = nil;
+ (void) initialize {
  if (self == [DownloadPortraitResponse class]) {
    defaultDownloadPortraitResponseInstance = [[DownloadPortraitResponse alloc] init];
  }
}
+ (DownloadPortraitResponse*) defaultInstance {
  return defaultDownloadPortraitResponseInstance;
}
- (DownloadPortraitResponse*) defaultInstance {
  return defaultDownloadPortraitResponseInstance;
}
- (ES_PBArray *)portrait {
  return portraitArray;
}
- (DownloadPortraitData*)portraitAtIndex:(NSUInteger)index {
  return [portraitArray objectAtIndex:index];
}
- (BOOL) isInitialized {
  return YES;
}
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output {
  for (DownloadPortraitData *element in self.portraitArray) {
    [output writeMessage:1 value:element];
  }
  if (self.hasBusinessCardPortrait) {
    [output writeMessage:2 value:self.businessCardPortrait];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  for (DownloadPortraitData *element in self.portraitArray) {
    size_ += ES_computeMessageSize(1, element);
  }
  if (self.hasBusinessCardPortrait) {
    size_ += ES_computeMessageSize(2, self.businessCardPortrait);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (DownloadPortraitResponse*) parseFromData:(NSData*) data {
  return (DownloadPortraitResponse*)[[[DownloadPortraitResponse builder] mergeFromData:data] build];
}
+ (DownloadPortraitResponse*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitResponse*)[[[DownloadPortraitResponse builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitResponse*) parseFromInputStream:(NSInputStream*) input {
  return (DownloadPortraitResponse*)[[[DownloadPortraitResponse builder] mergeFromInputStream:input] build];
}
+ (DownloadPortraitResponse*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitResponse*)[[[DownloadPortraitResponse builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return (DownloadPortraitResponse*)[[[DownloadPortraitResponse builder] mergeFromCodedInputStream:input] build];
}
+ (DownloadPortraitResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (DownloadPortraitResponse*)[[[DownloadPortraitResponse builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (DownloadPortraitResponse_Builder*) builder {
  return [[[DownloadPortraitResponse_Builder alloc] init] autorelease];
}
+ (DownloadPortraitResponse_Builder*) builderWithPrototype:(DownloadPortraitResponse*) prototype {
  return [[DownloadPortraitResponse builder] mergeFrom:prototype];
}
- (DownloadPortraitResponse_Builder*) builder {
  return [DownloadPortraitResponse builder];
}
- (DownloadPortraitResponse_Builder*) toBuilder {
  return [DownloadPortraitResponse builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  for (DownloadPortraitData* element in self.portraitArray) {
    [output appendFormat:@"%@%@ {\n", indent, @"portrait"];
    [element writeDescriptionTo:output
                     withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  if (self.hasBusinessCardPortrait) {
    [output appendFormat:@"%@%@ {\n", indent, @"businessCardPortrait"];
    [self.businessCardPortrait writeDescriptionTo:output
                         withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[DownloadPortraitResponse class]]) {
    return NO;
  }
  DownloadPortraitResponse *otherMessage = other;
  return
      [self.portraitArray isEqualToArray:otherMessage.portraitArray] &&
      self.hasBusinessCardPortrait == otherMessage.hasBusinessCardPortrait &&
      (!self.hasBusinessCardPortrait || [self.businessCardPortrait isEqual:otherMessage.businessCardPortrait]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  NSUInteger hashCode = 7;
  for (DownloadPortraitData* element in self.portraitArray) {
    hashCode = hashCode * 31 + [element hash];
  }
  if (self.hasBusinessCardPortrait) {
    hashCode = hashCode * 31 + [self.businessCardPortrait hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface DownloadPortraitResponse_Builder()
@property (retain) DownloadPortraitResponse* result;
@end

@implementation DownloadPortraitResponse_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[[DownloadPortraitResponse alloc] init] autorelease];
  }
  return self;
}
- (ES_PBGeneratedMessage*) internalGetResult {
  return result;
}
- (DownloadPortraitResponse_Builder*) clear {
  self.result = [[[DownloadPortraitResponse alloc] init] autorelease];
  return self;
}
- (DownloadPortraitResponse_Builder*) clone {
  return [DownloadPortraitResponse builderWithPrototype:result];
}
- (DownloadPortraitResponse*) defaultInstance {
  return [DownloadPortraitResponse defaultInstance];
}
- (DownloadPortraitResponse*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (DownloadPortraitResponse*) buildPartial {
  DownloadPortraitResponse* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (DownloadPortraitResponse_Builder*) mergeFrom:(DownloadPortraitResponse*) other {
  if (other == [DownloadPortraitResponse defaultInstance]) {
    return self;
  }
  if (other.portraitArray.count > 0) {
    if (result.portraitArray == nil) {
      result.portraitArray = [[other.portraitArray copyWithZone:[other.portraitArray zone]] autorelease];
    } else {
      [result.portraitArray appendArray:other.portraitArray];
    }
  }
  if (other.hasBusinessCardPortrait) {
    [self mergeBusinessCardPortrait:other.businessCardPortrait];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (DownloadPortraitResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[ES_PBExtensionRegistry emptyRegistry]];
}
- (DownloadPortraitResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  ES_PBUnknownFieldSet_Builder* unknownFields = [ES_PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    int32_t tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 10: {
        DownloadPortraitData_Builder* subBuilder = [DownloadPortraitData builder];
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self addPortrait:[subBuilder buildPartial]];
        break;
      }
      case 18: {
        DownloadPortraitData_Builder* subBuilder = [DownloadPortraitData builder];
        if (self.hasBusinessCardPortrait) {
          [subBuilder mergeFrom:self.businessCardPortrait];
        }
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self setBusinessCardPortrait:[subBuilder buildPartial]];
        break;
      }
    }
  }
}
- (ES_PBAppendableArray *)portrait {
  return result.portraitArray;
}
- (DownloadPortraitData*)portraitAtIndex:(NSUInteger)index {
  return [result portraitAtIndex:index];
}
- (DownloadPortraitResponse_Builder *)addPortrait:(DownloadPortraitData*)value {
  if (result.portraitArray == nil) {
    result.portraitArray = [ES_PBAppendableArray arrayWithValueType:ES_PBArrayValueTypeObject];
  }
  [result.portraitArray addObject:value];
  return self;
}
- (DownloadPortraitResponse_Builder *)setPortraitArray:(NSArray *)array {
  result.portraitArray = [ES_PBAppendableArray arrayWithArray:array valueType:ES_PBArrayValueTypeObject];
  return self;
}
- (DownloadPortraitResponse_Builder *)setPortraitValues:(const DownloadPortraitData* *)values count:(NSUInteger)count {
  result.portraitArray = [ES_PBAppendableArray arrayWithValues:values count:count valueType:ES_PBArrayValueTypeObject];
  return self;
}
- (DownloadPortraitResponse_Builder *)clearPortrait {
  result.portraitArray = nil;
  return self;
}
- (BOOL) hasBusinessCardPortrait {
  return result.hasBusinessCardPortrait;
}
- (DownloadPortraitData*) businessCardPortrait {
  return result.businessCardPortrait;
}
- (DownloadPortraitResponse_Builder*) setBusinessCardPortrait:(DownloadPortraitData*) value {
  result.hasBusinessCardPortrait = YES;
  result.businessCardPortrait = value;
  return self;
}
- (DownloadPortraitResponse_Builder*) setBusinessCardPortraitBuilder:(DownloadPortraitData_Builder*) builderForValue {
  return [self setBusinessCardPortrait:[builderForValue build]];
}
- (DownloadPortraitResponse_Builder*) mergeBusinessCardPortrait:(DownloadPortraitData*) value {
  if (result.hasBusinessCardPortrait &&
      result.businessCardPortrait != [DownloadPortraitData defaultInstance]) {
    result.businessCardPortrait =
      [[[DownloadPortraitData builderWithPrototype:result.businessCardPortrait] mergeFrom:value] buildPartial];
  } else {
    result.businessCardPortrait = value;
  }
  result.hasBusinessCardPortrait = YES;
  return self;
}
- (DownloadPortraitResponse_Builder*) clearBusinessCardPortrait {
  result.hasBusinessCardPortrait = NO;
  result.businessCardPortrait = [DownloadPortraitData defaultInstance];
  return self;
}
@end

