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

#import "ES_GeneratedMessage.h"

#import "ES_UnknownFieldSet.h"

@interface ES_PBGeneratedMessage ()
@property (retain) ES_PBUnknownFieldSet* unknownFields;
@end


@implementation ES_PBGeneratedMessage

@synthesize unknownFields;

- (void) dealloc {
  self.unknownFields = nil;
  [super dealloc];
}


- (id) init {
  if ((self = [super init])) {
    self.unknownFields = [ES_PBUnknownFieldSet defaultInstance];
    memoizedSerializedSize = -1;
  }

  return self;
}

@end
