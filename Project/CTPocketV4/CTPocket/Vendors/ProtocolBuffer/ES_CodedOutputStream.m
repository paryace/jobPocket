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

#import "ES_CodedOutputStream.h"
#import "ES_RingBuffer.h"
#import "ES_Message.h"
#import "ES_Utilities.h"
#import "ES_WireFormat.h"


@implementation ES_PBCodedOutputStream

const int32_t ES_DEFAULT_BUFFER_SIZE = 4 * 1024;


- (id)initWithOutputStream:(NSOutputStream*)_output data:(NSMutableData*)data {
	if ( (self = [super init]) ) {
		output = [_output retain];
		buffer = [[ES_RingBuffer alloc] initWithData:data];
	}
	return self;
}


- (void)dealloc {
	[output release];
	[buffer release];
	[super dealloc];
}


+ (ES_PBCodedOutputStream*)streamWithOutputStream:(NSOutputStream*)output bufferSize:(int32_t)bufferSize {
	NSMutableData *data = [NSMutableData dataWithLength:bufferSize];
	return [[[ES_PBCodedOutputStream alloc] initWithOutputStream:output data:data] autorelease];
}


+ (ES_PBCodedOutputStream*)streamWithOutputStream:(NSOutputStream*)output {
	return [ES_PBCodedOutputStream streamWithOutputStream:output bufferSize:ES_DEFAULT_BUFFER_SIZE];
}


+ (ES_PBCodedOutputStream*)streamWithData:(NSMutableData*)data {
	return [[[ES_PBCodedOutputStream alloc] initWithOutputStream:nil data:data] autorelease];
}


- (void)flush {
	if (output == nil) {
		// We're writing to a single buffer.
		@throw [NSException exceptionWithName:@"OutOfSpace" reason:@"" userInfo:nil];
	}
	
	[buffer flushToOutputStream:output];
}


- (void)writeRawByte:(uint8_t)value {
	while (![buffer appendByte:value]) {
        [self flush];
	}
}


- (void)writeRawData:(const NSData*)data {
	[self writeRawData:data offset:0 length:data.length];
}


- (void)writeRawData:(const NSData*)value offset:(int32_t)offset length:(int32_t)length {
	while (length > 0) {
		int32_t written = [buffer appendData:value offset:offset length:length];
		offset += written;
		length -= written;
		if (!written || length > 0) {
            [self flush];
		}
	}
}


- (void)writeDoubleNoTag:(Float64)value {
	[self writeRawLittleEndian64:ES_convertFloat64ToInt64(value)];
}


/** Write a {@code double} field, including tag, to the stream. */
- (void)writeDouble:(int32_t)fieldNumber value:(Float64)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatFixed64];
	[self writeDoubleNoTag:value];
}


- (void)writeFloatNoTag:(Float32)value {
	[self writeRawLittleEndian32:ES_convertFloat32ToInt32(value)];
}


/** Write a {@code float} field, including tag, to the stream. */
- (void)writeFloat:(int32_t)fieldNumber value:(Float32)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatFixed32];
	[self writeFloatNoTag:value];
}


- (void)writeUInt64NoTag:(int64_t)value {
	[self writeRawVarint64:value];
}


/** Write a {@code uint64} field, including tag, to the stream. */
- (void)writeUInt64:(int32_t)fieldNumber value:(int64_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatVarint];
	[self writeUInt64NoTag:value];
}


- (void)writeInt64NoTag:(int64_t)value {
	[self writeRawVarint64:value];
}


/** Write an {@code int64} field, including tag, to the stream. */
- (void)writeInt64:(int32_t)fieldNumber value:(int64_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatVarint];
	[self writeInt64NoTag:value];
}


- (void)writeInt32NoTag:(int32_t)value {
	if (value >= 0) {
		[self writeRawVarint32:value];
	} else {
		// Must sign-extend
		[self writeRawVarint64:value];
	}
}


/** Write an {@code int32} field, including tag, to the stream. */
- (void)writeInt32:(int32_t)fieldNumber value:(int32_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatVarint];
	[self writeInt32NoTag:value];
}


- (void)writeFixed64NoTag:(int64_t)value {
	[self writeRawLittleEndian64:value];
}


/** Write a {@code fixed64} field, including tag, to the stream. */
- (void)writeFixed64:(int32_t)fieldNumber value:(int64_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatFixed64];
	[self writeFixed64NoTag:value];
}


- (void)writeFixed32NoTag:(int32_t)value {
	[self writeRawLittleEndian32:value];
}


/** Write a {@code fixed32} field, including tag, to the stream. */
- (void)writeFixed32:(int32_t)fieldNumber value:(int32_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatFixed32];
	[self writeFixed32NoTag:value];
}


- (void)writeBoolNoTag:(BOOL)value {
	[self writeRawByte:(value ? 1 : 0)];
}


/** Write a {@code bool} field, including tag, to the stream. */
- (void)writeBool:(int32_t)fieldNumber value:(BOOL)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatVarint];
	[self writeBoolNoTag:value];
}


- (void)writeStringNoTag:(const NSString*)value {
	NSData* data = [value dataUsingEncoding:NSUTF8StringEncoding];
	[self writeRawVarint32:data.length];
	[self writeRawData:data];
}


/** Write a {@code string} field, including tag, to the stream. */
- (void)writeString:(int32_t)fieldNumber value:(const NSString*)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatLengthDelimited];
	[self writeStringNoTag:value];
}


- (void)writeGroupNoTag:(int32_t)fieldNumber value:(const id<ES_PBMessage>)value {
	[value writeToCodedOutputStream:self];
	[self writeTag:fieldNumber format:ES_PBWireFormatEndGroup];
}


/** Write a {@code group} field, including tag, to the stream. */
- (void)writeGroup:(int32_t)fieldNumber value:(const id<ES_PBMessage>)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatStartGroup];
	[self writeGroupNoTag:fieldNumber value:value];
}


- (void)writeUnknownGroupNoTag:(int32_t)fieldNumber value:(const ES_PBUnknownFieldSet*)value {
	[value writeToCodedOutputStream:self];
	[self writeTag:fieldNumber format:ES_PBWireFormatEndGroup];
}


/** Write a group represented by an {@link ES_PBUnknownFieldSet}. */
- (void)writeUnknownGroup:(int32_t)fieldNumber value:(const ES_PBUnknownFieldSet*)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatStartGroup];
	[self writeUnknownGroupNoTag:fieldNumber value:value];
}


- (void)writeMessageNoTag:(const id<ES_PBMessage>)value {
	[self writeRawVarint32:[value serializedSize]];
	[value writeToCodedOutputStream:self];
}


/** Write an embedded message field, including tag, to the stream. */
- (void)writeMessage:(int32_t)fieldNumber value:(const id<ES_PBMessage>)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatLengthDelimited];
	[self writeMessageNoTag:value];
}


- (void)writeDataNoTag:(const NSData*)value {
	[self writeRawVarint32:value.length];
	[self writeRawData:value];
}


/** Write a {@code bytes} field, including tag, to the stream. */
- (void)writeData:(int32_t)fieldNumber value:(const NSData*)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatLengthDelimited];
	[self writeDataNoTag:value];
}


- (void)writeUInt32NoTag:(int32_t)value {
	[self writeRawVarint32:value];
}


/** Write a {@code uint32} field, including tag, to the stream. */
- (void)writeUInt32:(int32_t)fieldNumber value:(int32_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatVarint];
	[self writeUInt32NoTag:value];
}


- (void)writeEnumNoTag:(int32_t)value {
	[self writeRawVarint32:value];
}


- (void)writeEnum:(int32_t)fieldNumber value:(int32_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatVarint];
	[self writeEnumNoTag:value];
}


- (void)writeSFixed32NoTag:(int32_t)value {
	[self writeRawLittleEndian32:value];
}


/** Write an {@code sfixed32} field, including tag, to the stream. */
- (void)writeSFixed32:(int32_t)fieldNumber value:(int32_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatFixed32];
	[self writeSFixed32NoTag:value];
}


- (void)writeSFixed64NoTag:(int64_t)value {
	[self writeRawLittleEndian64:value];
}


/** Write an {@code sfixed64} field, including tag, to the stream. */
- (void)writeSFixed64:(int32_t)fieldNumber value:(int64_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatFixed64];
	[self writeSFixed64NoTag:value];
}


- (void)writeSInt32NoTag:(int32_t)value {
	[self writeRawVarint32:ES_encodeZigZag32(value)];
}


/** Write an {@code sint32} field, including tag, to the stream. */
- (void)writeSInt32:(int32_t)fieldNumber value:(int32_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatVarint];
	[self writeSInt32NoTag:value];
}


- (void)writeSInt64NoTag:(int64_t)value {
	[self writeRawVarint64:ES_encodeZigZag64(value)];
}


/** Write an {@code sint64} field, including tag, to the stream. */
- (void)writeSInt64:(int32_t)fieldNumber value:(int64_t)value {
	[self writeTag:fieldNumber format:ES_PBWireFormatVarint];
	[self writeSInt64NoTag:value];
}


/**
 * Write a MessageSet extension field to the stream.  For historical reasons,
 * the wire format differs from normal fields.
 */
- (void)writeMessageSetExtension:(int32_t)fieldNumber value:(const id<ES_PBMessage>)value {
	[self writeTag:ES_PBWireFormatMessageSetItem format:ES_PBWireFormatStartGroup];
	[self writeUInt32:ES_PBWireFormatMessageSetTypeId value:fieldNumber];
	[self writeMessage:ES_PBWireFormatMessageSetMessage value:value];
	[self writeTag:ES_PBWireFormatMessageSetItem format:ES_PBWireFormatEndGroup];
}


/**
 * Write an unparsed MessageSet extension field to the stream.  For
 * historical reasons, the wire format differs from normal fields.
 */
- (void)writeRawMessageSetExtension:(int32_t)fieldNumber value:(const NSData*)value {
	[self writeTag:ES_PBWireFormatMessageSetItem format:ES_PBWireFormatStartGroup];
	[self writeUInt32:ES_PBWireFormatMessageSetTypeId value:fieldNumber];
	[self writeData:ES_PBWireFormatMessageSetMessage value:value];
	[self writeTag:ES_PBWireFormatMessageSetItem format:ES_PBWireFormatEndGroup];
}


- (void)writeTag:(int32_t)fieldNumber format:(int32_t)format {
	[self writeRawVarint32:ES_PBWireFormatMakeTag(fieldNumber, format)];
}


- (void)writeRawVarint32:(int32_t)value {
	while (YES) {
		if ((value & ~0x7F) == 0) {
			[self writeRawByte:value];
			return;
		} else {
			[self writeRawByte:((value & 0x7F) | 0x80)];
			value = ES_logicalRightShift32(value, 7);
		}
	}
}


- (void)writeRawVarint64:(int64_t)value {
	while (YES) {
		if ((value & ~0x7FL) == 0) {
			[self writeRawByte:((int32_t)value)];
			return;
		} else {
			[self writeRawByte:(((int32_t)value & 0x7F) | 0x80)];
			value = ES_logicalRightShift64(value, 7);
		}
	}
}


- (void)writeRawLittleEndian32:(int32_t)value {
	[self writeRawByte:((value      ) & 0xFF)];
	[self writeRawByte:((value >>  8) & 0xFF)];
	[self writeRawByte:((value >> 16) & 0xFF)];
	[self writeRawByte:((value >> 24) & 0xFF)];
}


- (void)writeRawLittleEndian64:(int64_t)value {
	[self writeRawByte:((int32_t)(value      ) & 0xFF)];
	[self writeRawByte:((int32_t)(value >>  8) & 0xFF)];
	[self writeRawByte:((int32_t)(value >> 16) & 0xFF)];
	[self writeRawByte:((int32_t)(value >> 24) & 0xFF)];
	[self writeRawByte:((int32_t)(value >> 32) & 0xFF)];
	[self writeRawByte:((int32_t)(value >> 40) & 0xFF)];
	[self writeRawByte:((int32_t)(value >> 48) & 0xFF)];
	[self writeRawByte:((int32_t)(value >> 56) & 0xFF)];
}

@end
