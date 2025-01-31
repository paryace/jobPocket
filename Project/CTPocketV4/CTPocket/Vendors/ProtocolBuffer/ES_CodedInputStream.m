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

#import "ES_CodedInputStream.h"

#import "ES_Message_Builder.h"
#import "ES_Utilities.h"
#import "ES_WireFormat.h"


@interface ES_PBCodedInputStream ()
@property (retain) NSMutableData* buffer;
@property (retain) NSInputStream* input;
@end


@implementation ES_PBCodedInputStream

const int32_t ES_DEFAULT_RECURSION_LIMIT = 64;
const int32_t ES_DEFAULT_SIZE_LIMIT = 64 << 20;  // 64MB
const int32_t ES_BUFFER_SIZE = 4096;

@synthesize buffer;
@synthesize input;

- (void) dealloc {
  [input close];
  self.buffer = nil;
  self.input = nil;

  [super dealloc];
}


- (void) commonInit {
  currentLimit = INT_MAX;
  recursionLimit = ES_DEFAULT_RECURSION_LIMIT;
  sizeLimit = ES_DEFAULT_SIZE_LIMIT;
}


- (id) initWithData:(NSData*) data {
  if ((self = [super init])) {
    self.buffer = [NSMutableData dataWithData:data];
    bufferSize = buffer.length;
    self.input = nil;
    [self commonInit];
  }

  return self;
}


- (id) initWithInputStream:(NSInputStream*) input_ {
  if ((self = [super init])) {
    self.buffer = [NSMutableData dataWithLength:ES_BUFFER_SIZE];
    bufferSize = 0;
    self.input = input_;
    [input open];
    [self commonInit];
  }

  return self;
}


+ (ES_PBCodedInputStream*) streamWithData:(NSData*) data {
  return [[[ES_PBCodedInputStream alloc] initWithData:data] autorelease];
}


+ (ES_PBCodedInputStream*) streamWithInputStream:(NSInputStream*) input {
  return [[[ES_PBCodedInputStream alloc] initWithInputStream:input] autorelease];
}


/**
 * Attempt to read a field tag, returning zero if we have reached EOF.
 * Protocol message parsers use this to read tags, since a protocol message
 * may legally end wherever a tag occurs, and zero is not a valid tag number.
 */
- (int32_t) readTag {
  if (self.isAtEnd) {
    lastTag = 0;
    return 0;
  }

  lastTag = [self readRawVarint32];
  if (lastTag == 0) {
    // If we actually read zero, that's not a valid tag.
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"Invalid Tag" userInfo:nil];
  }
  return lastTag;
}

/**
 * Verifies that the last call to readTag() returned the given tag value.
 * This is used to verify that a nested group ended with the correct
 * end tag.
 *
 * @throws InvalidProtocolBufferException {@code value} does not match the
 *                                        last tag.
 */
- (void) checkLastTagWas:(int32_t) value {
  if (lastTag != value) {
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"Invalid End Tag" userInfo:nil];
  }
}

/**
 * Reads and discards a single field, given its tag value.
 *
 * @return {@code NO} if the tag is an endgroup tag, in which case
 *         nothing is skipped.  Otherwise, returns {@code YES}.
 */
- (BOOL) skipField:(int32_t) tag {
  switch (ES_PBWireFormatGetTagWireType(tag)) {
    case ES_PBWireFormatVarint:
      [self readInt32];
      return YES;
    case ES_PBWireFormatFixed64:
      [self readRawLittleEndian64];
      return YES;
    case ES_PBWireFormatLengthDelimited:
      [self skipRawData:[self readRawVarint32]];
      return YES;
    case ES_PBWireFormatStartGroup:
      [self skipMessage];
      [self checkLastTagWas:
       ES_PBWireFormatMakeTag(ES_PBWireFormatGetTagFieldNumber(tag),
                           ES_PBWireFormatEndGroup)];
      return YES;
    case ES_PBWireFormatEndGroup:
      return NO;
    case ES_PBWireFormatFixed32:
      [self readRawLittleEndian32];
      return YES;
    default:
      @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"Invalid Wire Type" userInfo:nil];
  }
}


/**
 * Reads and discards an entire message.  This will read either until EOF
 * or until an endgroup tag, whichever comes first.
 */
- (void) skipMessage {
  while (YES) {
    int32_t tag = [self readTag];
    if (tag == 0 || ![self skipField:tag]) {
      return;
    }
  }
}


/** Read a {@code double} field value from the stream. */
- (Float64) readDouble {
  return ES_convertInt64ToFloat64([self readRawLittleEndian64]);
}


/** Read a {@code float} field value from the stream. */
- (Float32) readFloat {
  return ES_convertInt32ToFloat32([self readRawLittleEndian32]);
}


/** Read a {@code uint64} field value from the stream. */
- (int64_t) readUInt64 {
  return [self readRawVarint64];
}


/** Read an {@code int64} field value from the stream. */
- (int64_t) readInt64 {
  return [self readRawVarint64];
}


/** Read an {@code int32} field value from the stream. */
- (int32_t) readInt32 {
  return [self readRawVarint32];
}


/** Read a {@code fixed64} field value from the stream. */
- (int64_t) readFixed64 {
  return [self readRawLittleEndian64];
}


/** Read a {@code fixed32} field value from the stream. */
- (int32_t) readFixed32 {
  return [self readRawLittleEndian32];
}


/** Read a {@code bool} field value from the stream. */
- (BOOL) readBool {
  return [self readRawVarint32] != 0;
}


/** Read a {@code string} field value from the stream. */
- (NSString*) readString {
  int32_t size = [self readRawVarint32];
  if (size <= (bufferSize - bufferPos) && size > 0) {
    // Fast path:  We already have the bytes in a contiguous buffer, so
    //   just copy directly from it.
    //  new String(buffer, bufferPos, size, "UTF-8");
    NSString* result = [[[NSString alloc] initWithBytes:(((uint8_t*) buffer.bytes) + bufferPos)
                                                 length:size
                                               encoding:NSUTF8StringEncoding] autorelease];
    bufferPos += size;
    return result;
  } else {
    // Slow path:  Build a byte array first then copy it.
    NSData* data = [self readRawData:size];
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
  }
}


/** Read a {@code group} field value from the stream. */
- (void)      readGroup:(int32_t) fieldNumber
                builder:(id<ES_PBMessage_Builder>) builder
      extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  if (recursionDepth >= recursionLimit) {
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"Recursion Limit Exceeded" userInfo:nil];
  }
  ++recursionDepth;
  [builder mergeFromCodedInputStream:self extensionRegistry:extensionRegistry];
  [self checkLastTagWas:ES_PBWireFormatMakeTag(fieldNumber, ES_PBWireFormatEndGroup)];
  --recursionDepth;
}


/**
 * Reads a {@code group} field value from the stream and merges it into the
 * given {@link ES_PBUnknownFieldSet}.
 */
- (void) readUnknownGroup:(int32_t) fieldNumber
                  builder:(ES_PBUnknownFieldSet_Builder*) builder {
  if (recursionDepth >= recursionLimit) {
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"Recursion Limit Exceeded" userInfo:nil];
  }
  ++recursionDepth;
  [builder mergeFromCodedInputStream:self];
  [self checkLastTagWas:ES_PBWireFormatMakeTag(fieldNumber, ES_PBWireFormatEndGroup)];
  --recursionDepth;
}


/** Read an embedded message field value from the stream. */
- (void) readMessage:(id<ES_PBMessage_Builder>) builder
   extensionRegistry:(ES_PBExtensionRegistry*) extensionRegistry {
  int32_t length = [self readRawVarint32];
  if (recursionDepth >= recursionLimit) {
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"Recursion Limit Exceeded" userInfo:nil];
  }
  int32_t oldLimit = [self pushLimit:length];
  ++recursionDepth;
  [builder mergeFromCodedInputStream:self extensionRegistry:extensionRegistry];
  [self checkLastTagWas:0];
  --recursionDepth;
  [self popLimit:oldLimit];
}


/** Read a {@code bytes} field value from the stream. */
- (NSData*) readData {
  int32_t size = [self readRawVarint32];
  if (size < bufferSize - bufferPos && size > 0) {
    // Fast path:  We already have the bytes in a contiguous buffer, so
    //   just copy directly from it.
    NSData* result = [NSData dataWithBytes:(((uint8_t*) buffer.bytes) + bufferPos) length:size];
    bufferPos += size;
    return result;
  } else {
    // Slow path:  Build a byte array first then copy it.
    return [self readRawData:size];
  }
}


/** Read a {@code uint32} field value from the stream. */
- (int32_t) readUInt32 {
  return [self readRawVarint32];
}


/**
 * Read an enum field value from the stream.  Caller is responsible
 * for converting the numeric value to an actual enum.
 */
- (int32_t) readEnum {
  return [self readRawVarint32];
}


/** Read an {@code sfixed32} field value from the stream. */
- (int32_t) readSFixed32 {
  return [self readRawLittleEndian32];
}


/** Read an {@code sfixed64} field value from the stream. */
- (int64_t) readSFixed64 {
  return [self readRawLittleEndian64];
}


/** Read an {@code sint32} field value from the stream. */
- (int32_t) readSInt32 {
  return ES_decodeZigZag32([self readRawVarint32]);
}


/** Read an {@code sint64} field value from the stream. */
- (int64_t) readSInt64 {
  return ES_decodeZigZag64([self readRawVarint64]);
}


// =================================================================

/**
 * Read a raw Varint from the stream.  If larger than 32 bits, discard the
 * upper bits.
 */
- (int32_t) readRawVarint32 {
  int8_t tmp = [self readRawByte];
  if (tmp >= 0) {
    return tmp;
  }
  int32_t result = tmp & 0x7f;
  if ((tmp = [self readRawByte]) >= 0) {
    result |= tmp << 7;
  } else {
    result |= (tmp & 0x7f) << 7;
    if ((tmp = [self readRawByte]) >= 0) {
      result |= tmp << 14;
    } else {
      result |= (tmp & 0x7f) << 14;
      if ((tmp = [self readRawByte]) >= 0) {
        result |= tmp << 21;
      } else {
        result |= (tmp & 0x7f) << 21;
        result |= (tmp = [self readRawByte]) << 28;
        if (tmp < 0) {
          // Discard upper 32 bits.
          for (int i = 0; i < 5; i++) {
            if ([self readRawByte] >= 0) {
              return result;
            }
          }
          @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"malformedVarint" userInfo:nil];
        }
      }
    }
  }
  return result;
}


/** Read a raw Varint from the stream. */
- (int64_t) readRawVarint64 {
  int32_t shift = 0;
  int64_t result = 0;
  while (shift < 64) {
    int8_t b = [self readRawByte];
    result |= (int64_t)(b & 0x7F) << shift;
    if ((b & 0x80) == 0) {
      return result;
    }
    shift += 7;
  }
  @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"malformedVarint" userInfo:nil];
}


/** Read a 32-bit little-endian integer from the stream. */
- (int32_t) readRawLittleEndian32 {
  int8_t b1 = [self readRawByte];
  int8_t b2 = [self readRawByte];
  int8_t b3 = [self readRawByte];
  int8_t b4 = [self readRawByte];
  return
  (((int32_t)b1 & 0xff)      ) |
  (((int32_t)b2 & 0xff) <<  8) |
  (((int32_t)b3 & 0xff) << 16) |
  (((int32_t)b4 & 0xff) << 24);
}


/** Read a 64-bit little-endian integer from the stream. */
- (int64_t) readRawLittleEndian64 {
  int8_t b1 = [self readRawByte];
  int8_t b2 = [self readRawByte];
  int8_t b3 = [self readRawByte];
  int8_t b4 = [self readRawByte];
  int8_t b5 = [self readRawByte];
  int8_t b6 = [self readRawByte];
  int8_t b7 = [self readRawByte];
  int8_t b8 = [self readRawByte];
  return
  (((int64_t)b1 & 0xff)      ) |
  (((int64_t)b2 & 0xff) <<  8) |
  (((int64_t)b3 & 0xff) << 16) |
  (((int64_t)b4 & 0xff) << 24) |
  (((int64_t)b5 & 0xff) << 32) |
  (((int64_t)b6 & 0xff) << 40) |
  (((int64_t)b7 & 0xff) << 48) |
  (((int64_t)b8 & 0xff) << 56);
}


/**
 * Set the maximum message recursion depth.  In order to prevent malicious
 * messages from causing stack overflows, {@code ES_PBCodedInputStream} limits
 * how deeply messages may be nested.  The default limit is 64.
 *
 * @return the old limit.
 */
- (int32_t) setRecursionLimit:(int32_t) limit {
  if (limit < 0) {
    @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"Recursion limit cannot be negative" userInfo:nil];
  }
  int32_t oldLimit = recursionLimit;
  recursionLimit = limit;
  return oldLimit;
}


/**
 * Set the maximum message size.  In order to prevent malicious
 * messages from exhausting memory or causing integer overflows,
 * {@code ES_PBCodedInputStream} limits how large a message may be.
 * The default limit is 64MB.  You should set this limit as small
 * as you can without harming your app's functionality.  Note that
 * size limits only apply when reading from an {@code InputStream}, not
 * when constructed around a raw byte array.
 *
 * @return the old limit.
 */
- (int32_t) setSizeLimit:(int32_t) limit {
  if (limit < 0) {
    @throw [NSException exceptionWithName:@"IllegalArgument" reason:@"Size limit cannot be negative:" userInfo:nil];
  }
  int32_t oldLimit = sizeLimit;
  sizeLimit = limit;
  return oldLimit;
}


/**
 * Resets the current size counter to zero (see {@link #setSizeLimit(int)}).
 */
- (void) resetSizeCounter {
  totalBytesRetired = 0;
}


/**
 * Sets {@code currentLimit} to (current position) + {@code byteLimit}.  This
 * is called when descending into a length-delimited embedded message.
 *
 * @return the old limit.
 */
- (int32_t) pushLimit:(int32_t) byteLimit {
  if (byteLimit < 0) {
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"negativeSize" userInfo:nil];
  }
  byteLimit += totalBytesRetired + bufferPos;
  int32_t oldLimit = currentLimit;
  if (byteLimit > oldLimit) {
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"truncatedMessage" userInfo:nil];
  }
  currentLimit = byteLimit;

  [self recomputeBufferSizeAfterLimit];

  return oldLimit;
}


- (void) recomputeBufferSizeAfterLimit {
  bufferSize += bufferSizeAfterLimit;
  int32_t bufferEnd = totalBytesRetired + bufferSize;
  if (bufferEnd > currentLimit) {
    // Limit is in current buffer.
    bufferSizeAfterLimit = bufferEnd - currentLimit;
    bufferSize -= bufferSizeAfterLimit;
  } else {
    bufferSizeAfterLimit = 0;
  }
}


/**
 * Discards the current limit, returning to the previous limit.
 *
 * @param oldLimit The old limit, as returned by {@code pushLimit}.
 */
- (void) popLimit:(int32_t) oldLimit {
  currentLimit = oldLimit;
  [self recomputeBufferSizeAfterLimit];
}


/**
 * Returns the number of bytes to be read before the current limit.
 * If no limit is set, returns -1.
 */
- (int32_t) bytesUntilLimit {
  if (currentLimit == INT_MAX) {
    return -1;
  }

  int32_t currentAbsolutePosition = totalBytesRetired + bufferPos;
  return currentLimit - currentAbsolutePosition;
}

/**
 * Returns true if the stream has reached the end of the input.  This is the
 * case if either the end of the underlying input source has been reached or
 * if the stream has reached a limit created using {@link #pushLimit(int)}.
 */
- (BOOL) isAtEnd {
  return bufferPos == bufferSize && ![self refillBuffer:NO];
}


/**
 * Called with {@code this.buffer} is empty to read more bytes from the
 * input.  If {@code mustSucceed} is YES, refillBuffer() gurantees that
 * either there will be at least one byte in the buffer when it returns
 * or it will throw an exception.  If {@code mustSucceed} is NO,
 * refillBuffer() returns NO if no more bytes were available.
 */
- (BOOL) refillBuffer:(BOOL) mustSucceed {
  if (bufferPos < bufferSize) {
    @throw [NSException exceptionWithName:@"IllegalState" reason:@"refillBuffer called when buffer wasn't empty." userInfo:nil];
  }

  if (totalBytesRetired + bufferSize == currentLimit) {
    // Oops, we hit a limit.
    if (mustSucceed) {
      @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"truncatedMessage" userInfo:nil];
    } else {
      return NO;
    }
  }

  totalBytesRetired += bufferSize;

  // TODO(cyrusn): does NSInputStream behave the same as java.io.InputStream
  // when there is no more data?
  bufferPos = 0;
  bufferSize = 0;
  if (input != nil) {
    bufferSize = [input read:buffer.mutableBytes maxLength:buffer.length];
  }

  if (bufferSize <= 0) {
    bufferSize = 0;
    if (mustSucceed) {
      @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"truncatedMessage" userInfo:nil];
    } else {
      return NO;
    }
  } else {
    [self recomputeBufferSizeAfterLimit];
    int32_t totalBytesRead = totalBytesRetired + bufferSize + bufferSizeAfterLimit;
    if (totalBytesRead > sizeLimit || totalBytesRead < 0) {
      @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"sizeLimitExceeded" userInfo:nil];
    }
    return YES;
  }
}


/**
 * Read one byte from the input.
 *
 * @throws InvalidProtocolBufferException The end of the stream or the current
 *                                        limit was reached.
 */
- (int8_t) readRawByte {
  if (bufferPos == bufferSize) {
    [self refillBuffer:YES];
  }
  int8_t* bytes = (int8_t*)buffer.bytes;
  return bytes[bufferPos++];
}


/**
 * Read a fixed size of bytes from the input.
 *
 * @throws InvalidProtocolBufferException The end of the stream or the current
 *                                        limit was reached.
 */
- (NSData*) readRawData:(int32_t) size {
  if (size < 0) {
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"negativeSize" userInfo:nil];
  }

  if (totalBytesRetired + bufferPos + size > currentLimit) {
    // Read to the end of the stream anyway.
    [self skipRawData:currentLimit - totalBytesRetired - bufferPos];
    // Then fail.
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"truncatedMessage" userInfo:nil];
  }

  if (size <= bufferSize - bufferPos) {
    // We have all the bytes we need already.
    NSData* data = [NSData dataWithBytes:(((int8_t*) buffer.bytes) + bufferPos) length:size];
    bufferPos += size;
    return data;
  } else if (size < ES_BUFFER_SIZE) {
    // Reading more bytes than are in the buffer, but not an excessive number
    // of bytes.  We can safely allocate the resulting array ahead of time.

    // First copy what we have.
    NSMutableData* bytes = [NSMutableData dataWithLength:size];
    int32_t pos = bufferSize - bufferPos;
    memcpy(bytes.mutableBytes, ((int8_t*)buffer.bytes) + bufferPos, pos);
    bufferPos = bufferSize;

    // We want to use refillBuffer() and then copy from the buffer into our
    // byte array rather than reading directly into our byte array because
    // the input may be unbuffered.
    [self refillBuffer:YES];

    while (size - pos > bufferSize) {
      memcpy(((int8_t*)bytes.mutableBytes) + pos, buffer.bytes, bufferSize);
      pos += bufferSize;
      bufferPos = bufferSize;
      [self refillBuffer:YES];
    }

    memcpy(((int8_t*)bytes.mutableBytes) + pos, buffer.bytes, size - pos);
    bufferPos = size - pos;

    return bytes;
  } else {
    // The size is very large.  For security reasons, we can't allocate the
    // entire byte array yet.  The size comes directly from the input, so a
    // maliciously-crafted message could provide a bogus very large size in
    // order to trick the app into allocating a lot of memory.  We avoid this
    // by allocating and reading only a small chunk at a time, so that the
    // malicious message must actuall* e* extremely large to cause
    // problems.  Meanwhile, we limit the allowed size of a message elsewhere.

    // Remember the buffer markers since we'll have to copy the bytes out of
    // it later.
    int32_t originalBufferPos = bufferPos;
    int32_t originalBufferSize = bufferSize;

    // Mark the current buffer consumed.
    totalBytesRetired += bufferSize;
    bufferPos = 0;
    bufferSize = 0;

    // Read all the rest of the bytes we need.
    int32_t sizeLeft = size - (originalBufferSize - originalBufferPos);
    NSMutableArray* chunks = [NSMutableArray array];

    while (sizeLeft > 0) {
      NSMutableData* chunk = [NSMutableData dataWithLength:MIN(sizeLeft, ES_BUFFER_SIZE)];

      int32_t pos = 0;
      while (pos < chunk.length) {
        int32_t n = 0;
        if (input != nil) {
          n = [input read:(((uint8_t*) chunk.mutableBytes) + pos) maxLength:chunk.length - pos];
        }
        if (n <= 0) {
          @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"truncatedMessage" userInfo:nil];
        }
        totalBytesRetired += n;
        pos += n;
      }
      sizeLeft -= chunk.length;
      [chunks addObject:chunk];
    }

    // OK, got everything.  Now concatenate it all into one buffer.
    NSMutableData* bytes = [NSMutableData dataWithLength:size];

    // Start by copying the leftover bytes from this.buffer.
    int32_t pos = originalBufferSize - originalBufferPos;
    memcpy(bytes.mutableBytes, ((int8_t*)buffer.bytes) + originalBufferPos, pos);

    // And now all the chunks.
    for (NSData* chunk in chunks) {
      memcpy(((int8_t*)bytes.mutableBytes) + pos, chunk.bytes, chunk.length);
      pos += chunk.length;
    }

    // Done.
    return bytes;
  }
}


/**
 * Reads and discards {@code size} bytes.
 *
 * @throws InvalidProtocolBufferException The end of the stream or the current
 *                                        limit was reached.
 */
- (void) skipRawData:(int32_t) size {
  if (size < 0) {
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"negativeSize" userInfo:nil];
  }

  if (totalBytesRetired + bufferPos + size > currentLimit) {
    // Read to the end of the stream anyway.
    [self skipRawData:currentLimit - totalBytesRetired - bufferPos];
    // Then fail.
    @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"truncatedMessage" userInfo:nil];
  }

  if (size <= (bufferSize - bufferPos)) {
    // We have all the bytes we need already.
    bufferPos += size;
  } else {
    // Skipping more bytes than are in the buffer.  First skip what we have.
    int32_t pos = bufferSize - bufferPos;
    totalBytesRetired += pos;
    bufferPos = 0;
    bufferSize = 0;

    // Then skip directly from the InputStream for the rest.
    while (pos < size) {
      NSMutableData* data = [NSMutableData dataWithLength:(size - pos)];
      int32_t n = (input == nil) ? -1 : (int32_t)[input read:data.mutableBytes maxLength:(size - pos)];
      if (n <= 0) {
        @throw [NSException exceptionWithName:@"InvalidProtocolBuffer" reason:@"truncatedMessage" userInfo:nil];
      }
      pos += n;
      totalBytesRetired += n;
    }
  }
}



@end
