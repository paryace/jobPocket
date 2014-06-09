// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "Query_mobile_no_proto.pb.h"

@implementation QueryMobileNoProtoRoot
static ES_PBExtensionRegistry* extensionRegistry = nil;
+ (ES_PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [QueryMobileNoProtoRoot class]) {
    ES_PBMutableExtensionRegistry* registry = [ES_PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    extensionRegistry = [registry retain];
  }
}
+ (void) registerAllExtensions:(ES_PBMutableExtensionRegistry*) registry {
}
@end

@interface QueryMobileNoRequest ()
@property (retain) NSString* imsi;
@end

@implementation QueryMobileNoRequest

- (BOOL) hasImsi {
  return !!hasImsi_;
}
- (void) setHasImsi:(BOOL) value_ {
  hasImsi_ = !!value_;
}
@synthesize imsi;
- (void) dealloc {
  self.imsi = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.imsi = @"";
  }
  return self;
}
static QueryMobileNoRequest* defaultQueryMobileNoRequestInstance = nil;
+ (void) initialize {
  if (self == [QueryMobileNoRequest class]) {
    defaultQueryMobileNoRequestInstance = [[QueryMobileNoRequest alloc] init];
  }
}
+ (QueryMobileNoRequest*) defaultInstance {
  return defaultQueryMobileNoRequestInstance;
}
- (QueryMobileNoRequest*) defaultInstance {
  return defaultQueryMobileNoRequestInstance;
}
- (BOOL) isInitialized {
  if (!self.hasImsi) {
    return NO;
  }
  return YES;
}
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output {
  if (self.hasImsi) {
    [output writeString:1 value:self.imsi];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasImsi) {
    size_ += ES_computeStringSize(1, self.imsi);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (QueryMobileNoRequest*) parseFromData:(NSData*) data {
  return (QueryMobileNoRequest*)[[[QueryMobileNoRequest builder] mergeFromData:data] build];
}
+ (QueryMobileNoRequest*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (QueryMobileNoRequest*)[[[QueryMobileNoRequest builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (QueryMobileNoRequest*) parseFromInputStream:(NSInputStream*) input {
  return (QueryMobileNoRequest*)[[[QueryMobileNoRequest builder] mergeFromInputStream:input] build];
}
+ (QueryMobileNoRequest*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (QueryMobileNoRequest*)[[[QueryMobileNoRequest builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (QueryMobileNoRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return (QueryMobileNoRequest*)[[[QueryMobileNoRequest builder] mergeFromCodedInputStream:input] build];
}
+ (QueryMobileNoRequest*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (QueryMobileNoRequest*)[[[QueryMobileNoRequest builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (QueryMobileNoRequest_Builder*) builder {
  return [[[QueryMobileNoRequest_Builder alloc] init] autorelease];
}
+ (QueryMobileNoRequest_Builder*) builderWithPrototype:(QueryMobileNoRequest*) prototype {
  return [[QueryMobileNoRequest builder] mergeFrom:prototype];
}
- (QueryMobileNoRequest_Builder*) builder {
  return [QueryMobileNoRequest builder];
}
- (QueryMobileNoRequest_Builder*) toBuilder {
  return [QueryMobileNoRequest builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasImsi) {
    [output appendFormat:@"%@%@: %@\n", indent, @"imsi", self.imsi];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[QueryMobileNoRequest class]]) {
    return NO;
  }
  QueryMobileNoRequest *otherMessage = other;
  return
      self.hasImsi == otherMessage.hasImsi &&
      (!self.hasImsi || [self.imsi isEqual:otherMessage.imsi]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  NSUInteger hashCode = 7;
  if (self.hasImsi) {
    hashCode = hashCode * 31 + [self.imsi hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface QueryMobileNoRequest_Builder()
@property (retain) QueryMobileNoRequest* result;
@end

@implementation QueryMobileNoRequest_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[[QueryMobileNoRequest alloc] init] autorelease];
  }
  return self;
}
- (ES_PBGeneratedMessage*) internalGetResult {
  return result;
}
- (QueryMobileNoRequest_Builder*) clear {
  self.result = [[[QueryMobileNoRequest alloc] init] autorelease];
  return self;
}
- (QueryMobileNoRequest_Builder*) clone {
  return [QueryMobileNoRequest builderWithPrototype:result];
}
- (QueryMobileNoRequest*) defaultInstance {
  return [QueryMobileNoRequest defaultInstance];
}
- (QueryMobileNoRequest*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (QueryMobileNoRequest*) buildPartial {
  QueryMobileNoRequest* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (QueryMobileNoRequest_Builder*) mergeFrom:(QueryMobileNoRequest*) other {
  if (other == [QueryMobileNoRequest defaultInstance]) {
    return self;
  }
  if (other.hasImsi) {
    [self setImsi:other.imsi];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (QueryMobileNoRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[ES_PBExtensionRegistry emptyRegistry]];
}
- (QueryMobileNoRequest_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
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
        [self setImsi:[input readString]];
        break;
      }
    }
  }
}
- (BOOL) hasImsi {
  return result.hasImsi;
}
- (NSString*) imsi {
  return result.imsi;
}
- (QueryMobileNoRequest_Builder*) setImsi:(NSString*) value {
  result.hasImsi = YES;
  result.imsi = value;
  return self;
}
- (QueryMobileNoRequest_Builder*) clearImsi {
  result.hasImsi = NO;
  result.imsi = @"";
  return self;
}
@end

@interface QueryMobileNoResponse ()
@property (retain) NSString* mobileNum;
@property (retain) NSString* alias;
@end

@implementation QueryMobileNoResponse

- (BOOL) hasMobileNum {
  return !!hasMobileNum_;
}
- (void) setHasMobileNum:(BOOL) value_ {
  hasMobileNum_ = !!value_;
}
@synthesize mobileNum;
- (BOOL) hasAlias {
  return !!hasAlias_;
}
- (void) setHasAlias:(BOOL) value_ {
  hasAlias_ = !!value_;
}
@synthesize alias;
- (void) dealloc {
  self.mobileNum = nil;
  self.alias = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.mobileNum = @"";
    self.alias = @"";
  }
  return self;
}
static QueryMobileNoResponse* defaultQueryMobileNoResponseInstance = nil;
+ (void) initialize {
  if (self == [QueryMobileNoResponse class]) {
    defaultQueryMobileNoResponseInstance = [[QueryMobileNoResponse alloc] init];
  }
}
+ (QueryMobileNoResponse*) defaultInstance {
  return defaultQueryMobileNoResponseInstance;
}
- (QueryMobileNoResponse*) defaultInstance {
  return defaultQueryMobileNoResponseInstance;
}
- (BOOL) isInitialized {
  if (!self.hasMobileNum) {
    return NO;
  }
  return YES;
}
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output {
  if (self.hasMobileNum) {
    [output writeString:1 value:self.mobileNum];
  }
  if (self.hasAlias) {
    [output writeString:2 value:self.alias];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasMobileNum) {
    size_ += ES_computeStringSize(1, self.mobileNum);
  }
  if (self.hasAlias) {
    size_ += ES_computeStringSize(2, self.alias);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (QueryMobileNoResponse*) parseFromData:(NSData*) data {
  return (QueryMobileNoResponse*)[[[QueryMobileNoResponse builder] mergeFromData:data] build];
}
+ (QueryMobileNoResponse*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (QueryMobileNoResponse*)[[[QueryMobileNoResponse builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (QueryMobileNoResponse*) parseFromInputStream:(NSInputStream*) input {
  return (QueryMobileNoResponse*)[[[QueryMobileNoResponse builder] mergeFromInputStream:input] build];
}
+ (QueryMobileNoResponse*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (QueryMobileNoResponse*)[[[QueryMobileNoResponse builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (QueryMobileNoResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return (QueryMobileNoResponse*)[[[QueryMobileNoResponse builder] mergeFromCodedInputStream:input] build];
}
+ (QueryMobileNoResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (QueryMobileNoResponse*)[[[QueryMobileNoResponse builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (QueryMobileNoResponse_Builder*) builder {
  return [[[QueryMobileNoResponse_Builder alloc] init] autorelease];
}
+ (QueryMobileNoResponse_Builder*) builderWithPrototype:(QueryMobileNoResponse*) prototype {
  return [[QueryMobileNoResponse builder] mergeFrom:prototype];
}
- (QueryMobileNoResponse_Builder*) builder {
  return [QueryMobileNoResponse builder];
}
- (QueryMobileNoResponse_Builder*) toBuilder {
  return [QueryMobileNoResponse builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasMobileNum) {
    [output appendFormat:@"%@%@: %@\n", indent, @"mobileNum", self.mobileNum];
  }
  if (self.hasAlias) {
    [output appendFormat:@"%@%@: %@\n", indent, @"alias", self.alias];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[QueryMobileNoResponse class]]) {
    return NO;
  }
  QueryMobileNoResponse *otherMessage = other;
  return
      self.hasMobileNum == otherMessage.hasMobileNum &&
      (!self.hasMobileNum || [self.mobileNum isEqual:otherMessage.mobileNum]) &&
      self.hasAlias == otherMessage.hasAlias &&
      (!self.hasAlias || [self.alias isEqual:otherMessage.alias]) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  NSUInteger hashCode = 7;
  if (self.hasMobileNum) {
    hashCode = hashCode * 31 + [self.mobileNum hash];
  }
  if (self.hasAlias) {
    hashCode = hashCode * 31 + [self.alias hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface QueryMobileNoResponse_Builder()
@property (retain) QueryMobileNoResponse* result;
@end

@implementation QueryMobileNoResponse_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[[QueryMobileNoResponse alloc] init] autorelease];
  }
  return self;
}
- (ES_PBGeneratedMessage*) internalGetResult {
  return result;
}
- (QueryMobileNoResponse_Builder*) clear {
  self.result = [[[QueryMobileNoResponse alloc] init] autorelease];
  return self;
}
- (QueryMobileNoResponse_Builder*) clone {
  return [QueryMobileNoResponse builderWithPrototype:result];
}
- (QueryMobileNoResponse*) defaultInstance {
  return [QueryMobileNoResponse defaultInstance];
}
- (QueryMobileNoResponse*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (QueryMobileNoResponse*) buildPartial {
  QueryMobileNoResponse* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (QueryMobileNoResponse_Builder*) mergeFrom:(QueryMobileNoResponse*) other {
  if (other == [QueryMobileNoResponse defaultInstance]) {
    return self;
  }
  if (other.hasMobileNum) {
    [self setMobileNum:other.mobileNum];
  }
  if (other.hasAlias) {
    [self setAlias:other.alias];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (QueryMobileNoResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[ES_PBExtensionRegistry emptyRegistry]];
}
- (QueryMobileNoResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
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
        [self setMobileNum:[input readString]];
        break;
      }
      case 18: {
        [self setAlias:[input readString]];
        break;
      }
    }
  }
}
- (BOOL) hasMobileNum {
  return result.hasMobileNum;
}
- (NSString*) mobileNum {
  return result.mobileNum;
}
- (QueryMobileNoResponse_Builder*) setMobileNum:(NSString*) value {
  result.hasMobileNum = YES;
  result.mobileNum = value;
  return self;
}
- (QueryMobileNoResponse_Builder*) clearMobileNum {
  result.hasMobileNum = NO;
  result.mobileNum = @"";
  return self;
}
- (BOOL) hasAlias {
  return result.hasAlias;
}
- (NSString*) alias {
  return result.alias;
}
- (QueryMobileNoResponse_Builder*) setAlias:(NSString*) value {
  result.hasAlias = YES;
  result.alias = value;
  return self;
}
- (QueryMobileNoResponse_Builder*) clearAlias {
  result.hasAlias = NO;
  result.alias = @"";
  return self;
}
@end
