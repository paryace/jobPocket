// Protocol Buffers for Objective C
//
// Copyright 2010 Booyah Inc.
// Copyright 2008 Cyrus Najmabadi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "ES_AbstractMessage.h"

#import "ES_CodedOutputStream.h"

@implementation ES_PBAbstractMessage

- (id) init {
  if ((self = [super init])) {
  }

  return self;
}


- (NSData*) data {
  NSMutableData* data = [NSMutableData dataWithLength:self.serializedSize];
  ES_PBCodedOutputStream* stream = [ES_PBCodedOutputStream streamWithData:data];
  [self writeToCodedOutputStream:stream];
  return data;
}


- (BOOL) isInitialized {
  @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (int32_t) serializedSize {
  @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (void) writeToCodedOutputStream:(ES_PBCodedOutputStream*) output {
  @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (void) writeToOutputStream:(NSOutputStream*) output {
  ES_PBCodedOutputStream* codedOutput = [ES_PBCodedOutputStream streamWithOutputStream:output];
  [self writeToCodedOutputStream:codedOutput];
  [codedOutput flush];
}


- (id<ES_PBMessage>) defaultInstance {
  @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (ES_PBUnknownFieldSet*) unknownFields {
  @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (id<ES_PBMessage_Builder>) builder {
  @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (id<ES_PBMessage_Builder>) toBuilder {
  @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (void) writeDescriptionTo:(NSMutableString*) output
                 withIndent:(NSString*) indent {
  @throw [NSException exceptionWithName:@"ImproperSubclassing" reason:@"" userInfo:nil];
}


- (NSString*) description {
  NSMutableString* output = [NSMutableString string];
  [self writeDescriptionTo:output withIndent:@""];
  return output;
}


@end
