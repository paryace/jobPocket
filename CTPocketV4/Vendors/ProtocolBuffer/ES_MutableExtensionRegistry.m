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

#import "ES_MutableExtensionRegistry.h"

#import "ES_ExtensionField.h"

@interface ES_PBMutableExtensionRegistry()
@property (retain) NSMutableDictionary* mutableClassMap;
@end

@implementation ES_PBMutableExtensionRegistry

@synthesize mutableClassMap;

- (void) dealloc {
  self.mutableClassMap = nil;
  [super dealloc];
}


- (id) initWithClassMap:(NSMutableDictionary*) mutableClassMap_ {
  if ((self = [super initWithClassMap:mutableClassMap_])) {
    self.mutableClassMap = mutableClassMap_;
  }

  return self;
}


+ (ES_PBMutableExtensionRegistry*) registry {
  return [[[ES_PBMutableExtensionRegistry alloc] initWithClassMap:[NSMutableDictionary dictionary]] autorelease];
}


- (void) addExtension:(id<ES_PBExtensionField>) extension {
  if (extension == nil) {
    return;
  }

  Class extendedClass = [extension extendedClass];
  id key = [self keyForClass:extendedClass];

  NSMutableDictionary* extensionMap = [classMap objectForKey:key];
  if (extensionMap == nil) {
    extensionMap = [NSMutableDictionary dictionary];
    [mutableClassMap setObject:extensionMap forKey:key];
  }

  [extensionMap setObject:extension
                   forKey:[NSNumber numberWithInteger:[extension fieldNumber]]];
}


@end
