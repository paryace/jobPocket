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

#import "ES_ExtensionField.h"

/**
 * Generated message classes for message types that contain extension ranges
 * subclass this.
 *
 * <p>This class implements type-safe accessors for extensions.  They
 * implement all the same operations that you can do with normal fields --
 * e.g. "has", "get", and "getCount" -- but for extensions.  The extensions
 * are identified using instances of the class {@link GeneratedExtension};
 * the protocol compiler generates a static instance of this class for every
 * extension in its input.  Through the magic of generics, all is made
 * type-safe.
 *
 * <p>For example, imagine you have the {@code .proto} file:
 *
 * <pre>
 * option java_class = "MyProto";
 *
 * message Foo {
 *   extensions 1000 to max;
 * }
 *
 * extend Foo {
 *   optional int32 bar;
 * }
 * </pre>
 *
 * <p>Then you might write code like:
 *
 * <pre>
 * MyProto.Foo foo = getFoo();
 * int i = foo.getExtension(MyProto.bar);
 * </pre>
 *
 * <p>See also {@link ExtendableBuilder}.
 */
@interface ES_PBExtendableMessage : ES_PBGeneratedMessage {
@private
  NSMutableDictionary* extensionMap;
  NSMutableDictionary* extensionRegistry;
}

@property (retain) NSMutableDictionary* extensionMap;
@property (retain) NSMutableDictionary* extensionRegistry;

- (BOOL) hasExtension:(id<ES_PBExtensionField>) extension;
- (id) getExtension:(id<ES_PBExtensionField>) extension;

//@protected
- (BOOL) extensionsAreInitialized;
- (int32_t) extensionsSerializedSize;
- (void) writeExtensionsToCodedOutputStream:(ES_PBCodedOutputStream*) output
                                       from:(int32_t) startInclusive
                                         to:(int32_t) endExclusive;
- (void) writeExtensionDescriptionToMutableString:(NSMutableString*) output
                                             from:(int32_t) startInclusive
                                               to:(int32_t) endExclusive
                                       withIndent:(NSString*) indent;
- (BOOL) isEqualExtensionsInOther:(ES_PBExtendableMessage*)otherMessage
                             from:(int32_t) startInclusive
                               to:(int32_t) endExclusive;
- (NSUInteger) hashExtensionsFrom:(int32_t) startInclusive
                               to:(int32_t) endExclusive;



/* @internal */
- (void) ensureExtensionIsRegistered:(id<ES_PBExtensionField>) extension;

@end
