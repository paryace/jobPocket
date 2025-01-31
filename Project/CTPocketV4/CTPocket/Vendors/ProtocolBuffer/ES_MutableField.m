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

#import "ES_MutableField.h"

#import "ES_Field.h"
#import "ES_PBArray.h"

@implementation ES_PBMutableField

- (void)dealloc {
	[super dealloc];
}

+ (ES_PBMutableField *)field {
	return [[[ES_PBMutableField alloc] init] autorelease];
}

- (ES_PBMutableField *)clear {
	[_varintArray release];		_varintArray = nil;
	[_fixed32Array release];	_fixed32Array = nil;
	[_fixed64Array release];	_fixed64Array = nil;
	[_lengthDelimitedArray release];	_lengthDelimitedArray = nil;
	[_groupArray release];		_groupArray = nil;

	return self;
}

- (ES_PBMutableField *)mergeFromField:(ES_PBField *)other {
	if (other.varintArray.count > 0) {
		if (_varintArray == nil) {
			_varintArray = [other.varintArray copy];
		} else {
			[_varintArray appendArray:other.varintArray];
		}
	}

	if (other.fixed32Array.count > 0) {
		if (_fixed32Array == nil) {
			_fixed32Array = [other.fixed32Array copy];
		} else {
			[_fixed32Array appendArray:other.fixed32Array];
		}
	}

	if (other.fixed64Array.count > 0) {
		if (_fixed64Array == nil) {
			_fixed64Array = [other.fixed64Array copy];
		} else {
			[_fixed64Array appendArray:other.fixed64Array];
		}
	}

	if (other.lengthDelimitedArray.count > 0) {
		if (_lengthDelimitedArray == nil) {
			_lengthDelimitedArray = [other.lengthDelimitedArray copy];
		} else {
			[_lengthDelimitedArray appendArray:other.lengthDelimitedArray];
		}
	}

	if (other.groupArray.count > 0) {
		if (_groupArray == nil) {
			_groupArray = [other.groupArray copy];
		} else {
			[_groupArray appendArray:other.groupArray];
		}
	}

	return self;
}

- (ES_PBMutableField *)addVarint:(int64_t)value {
	if (_varintArray == nil) {
		_varintArray = [[ES_PBAppendableArray alloc] initWithValueType:ES_PBArrayValueTypeInt64];
	}
	[_varintArray addInt64:value];

	return self;
}

- (ES_PBMutableField *)addFixed32:(int32_t)value {
	if (_fixed32Array == nil) {
		_fixed32Array = [[ES_PBAppendableArray alloc] initWithValueType:ES_PBArrayValueTypeInt32];
	}
	[_fixed32Array addInt32:value];

	return self;
}

- (ES_PBMutableField *)addFixed64:(int64_t)value {
	if (_fixed64Array == nil) {
		_fixed64Array = [[ES_PBAppendableArray alloc] initWithValueType:ES_PBArrayValueTypeInt64];
	}
	[_fixed64Array addInt64:value];

	return self;
}

- (ES_PBMutableField *)addLengthDelimited:(NSData *)value {
	if (_lengthDelimitedArray == nil) {
		_lengthDelimitedArray = [[ES_PBAppendableArray alloc] initWithValueType:ES_PBArrayValueTypeObject];
	}
	[_lengthDelimitedArray addObject:value];

	return self;
}

- (ES_PBMutableField *)addGroup:(ES_PBUnknownFieldSet *)value {
	if (_groupArray == nil) {
		_groupArray = [[ES_PBAppendableArray alloc] initWithValueType:ES_PBArrayValueTypeObject];
	}
	[_groupArray addObject:value];

	return self;
}

@end