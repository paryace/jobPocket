// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "Recover_calllog_proto.pb.h"

@implementation RecoverCalllogProtoRoot
static ES_PBExtensionRegistry* extensionRegistry = nil;
+ (ES_PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [RecoverCalllogProtoRoot class]) {
    ES_PBMutableExtensionRegistry* registry = [ES_PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    [BaseTypeProtoRoot registerAllExtensions:registry];
    extensionRegistry = [registry retain];
  }
}
+ (void) registerAllExtensions:(ES_PBMutableExtensionRegistry*) registry {
}
@end

@interface RecoverCallLogResponse ()
@property (retain) ES_PBAppendableArray * callLogArray;
@end

@implementation RecoverCallLogResponse

@synthesize callLogArray;
@dynamic callLog;
- (void) dealloc {
  self.callLogArray = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
  }
  return self;
}
static RecoverCallLogResponse* defaultRecoverCallLogResponseInstance = nil;
+ (void) initialize {
  if (self == [RecoverCallLogResponse class]) {
    defaultRecoverCallLogResponseInstance = [[RecoverCallLogResponse alloc] init];
  }
}
+ (RecoverCallLogResponse*) defaultInstance {
  return defaultRecoverCallLogResponseInstance;
}
- (RecoverCallLogResponse*) defaultInstance {
  return defaultRecoverCallLogResponseInstance;
}
- (ES_PBArray *)callLog {
  return callLogArray;
}
- (CallLog*)callLogAtIndex:(NSUInteger)index {
  return [callLogArray objectAtIndex:index];
}
- (BOOL) isInitialized {
  for (CallLog* element in self.callLog) {
    if (!element.isInitialized) {
      return NO;
    }
  }
  return YES;
}
- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output {
  for (CallLog *element in self.callLogArray) {
    [output writeMessage:1 value:element];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (int32_t) serializedSize {
  int32_t size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  for (CallLog *element in self.callLogArray) {
    size_ += ES_computeMessageSize(1, element);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (RecoverCallLogResponse*) parseFromData:(NSData*) data {
  return (RecoverCallLogResponse*)[[[RecoverCallLogResponse builder] mergeFromData:data] build];
}
+ (RecoverCallLogResponse*) parseFromData:(NSData*) data extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (RecoverCallLogResponse*)[[[RecoverCallLogResponse builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (RecoverCallLogResponse*) parseFromInputStream:(NSInputStream*) input {
  return (RecoverCallLogResponse*)[[[RecoverCallLogResponse builder] mergeFromInputStream:input] build];
}
+ (RecoverCallLogResponse*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (RecoverCallLogResponse*)[[[RecoverCallLogResponse builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (RecoverCallLogResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return (RecoverCallLogResponse*)[[[RecoverCallLogResponse builder] mergeFromCodedInputStream:input] build];
}
+ (RecoverCallLogResponse*) parseFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  return (RecoverCallLogResponse*)[[[RecoverCallLogResponse builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (RecoverCallLogResponse_Builder*) builder {
  return [[[RecoverCallLogResponse_Builder alloc] init] autorelease];
}
+ (RecoverCallLogResponse_Builder*) builderWithPrototype:(RecoverCallLogResponse*) prototype {
  return [[RecoverCallLogResponse builder] mergeFrom:prototype];
}
- (RecoverCallLogResponse_Builder*) builder {
  return [RecoverCallLogResponse builder];
}
- (RecoverCallLogResponse_Builder*) toBuilder {
  return [RecoverCallLogResponse builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  for (CallLog* element in self.callLogArray) {
    [output appendFormat:@"%@%@ {\n", indent, @"callLog"];
    [element writeDescriptionTo:output
                     withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[RecoverCallLogResponse class]]) {
    return NO;
  }
  RecoverCallLogResponse *otherMessage = other;
  return
      [self.callLogArray isEqualToArray:otherMessage.callLogArray] &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  NSUInteger hashCode = 7;
  for (CallLog* element in self.callLogArray) {
    hashCode = hashCode * 31 + [element hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

@interface RecoverCallLogResponse_Builder()
@property (retain) RecoverCallLogResponse* result;
@end

@implementation RecoverCallLogResponse_Builder
@synthesize result;
- (void) dealloc {
  self.result = nil;
  [super dealloc];
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[[RecoverCallLogResponse alloc] init] autorelease];
  }
  return self;
}
- (ES_PBGeneratedMessage*) internalGetResult {
  return result;
}
- (RecoverCallLogResponse_Builder*) clear {
  self.result = [[[RecoverCallLogResponse alloc] init] autorelease];
  return self;
}
- (RecoverCallLogResponse_Builder*) clone {
  return [RecoverCallLogResponse builderWithPrototype:result];
}
- (RecoverCallLogResponse*) defaultInstance {
  return [RecoverCallLogResponse defaultInstance];
}
- (RecoverCallLogResponse*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (RecoverCallLogResponse*) buildPartial {
  RecoverCallLogResponse* returnMe = [[result retain] autorelease];
  self.result = nil;
  return returnMe;
}
- (RecoverCallLogResponse_Builder*) mergeFrom:(RecoverCallLogResponse*) other {
  if (other == [RecoverCallLogResponse defaultInstance]) {
    return self;
  }
  if (other.callLogArray.count > 0) {
    if (result.callLogArray == nil) {
      result.callLogArray = [[other.callLogArray copyWithZone:[other.callLogArray zone]] autorelease];
    } else {
      [result.callLogArray appendArray:other.callLogArray];
    }
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (RecoverCallLogResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[ES_PBExtensionRegistry emptyRegistry]];
}
- (RecoverCallLogResponse_Builder*) mergeFromCodedInputStream:(ES_PBCodedInputStream*) input extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
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
        CallLog_Builder* subBuilder = [CallLog builder];
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self addCallLog:[subBuilder buildPartial]];
        break;
      }
    }
  }
}
- (ES_PBAppendableArray *)callLog {
  return result.callLogArray;
}
- (CallLog*)callLogAtIndex:(NSUInteger)index {
  return [result callLogAtIndex:index];
}
- (RecoverCallLogResponse_Builder *)addCallLog:(CallLog*)value {
  if (result.callLogArray == nil) {
    result.callLogArray = [ES_PBAppendableArray arrayWithValueType:ES_PBArrayValueTypeObject];
  }
  [result.callLogArray addObject:value];
  return self;
}
- (RecoverCallLogResponse_Builder *)setCallLogArray:(NSArray *)array {
  result.callLogArray = [ES_PBAppendableArray arrayWithArray:array valueType:ES_PBArrayValueTypeObject];
  return self;
}
- (RecoverCallLogResponse_Builder *)setCallLogValues:(const CallLog* *)values count:(NSUInteger)count {
  result.callLogArray = [ES_PBAppendableArray arrayWithValues:values count:count valueType:ES_PBArrayValueTypeObject];
  return self;
}
- (RecoverCallLogResponse_Builder *)clearCallLog {
  result.callLogArray = nil;
  return self;
}
@end
