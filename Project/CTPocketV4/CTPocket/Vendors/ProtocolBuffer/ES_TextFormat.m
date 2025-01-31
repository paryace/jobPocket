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

#import "ES_TextFormat.h"

#import "ES_Utilities.h"

@implementation ES_PBTextFormat


BOOL ES_allZeroes(NSString* string) {
  for (int i = 0; i < string.length; i++) {
    if ([string characterAtIndex:i] != '0') {
      return NO;
    }
  }

  return YES;
}


/** Is this an octal digit? */
BOOL ES_isOctal(unichar c) {
  return '0' <= c && c <= '7';
}


/** Is this an octal digit? */
BOOL ES_isDecimal(unichar c) {
  return '0' <= c && c <= '9';
}

/** Is this a hex digit? */
BOOL ES_isHex(unichar c) {
  return
  ES_isDecimal(c) ||
  ('a' <= c && c <= 'f') ||
  ('A' <= c && c <= 'F');
}


+ (int64_t) parseInteger:(NSString*) text
                isSigned:(BOOL) isSigned
                  isLong:(BOOL) isLong {
  if (text.length == 0) {
    @throw [NSException exceptionWithName:@"NumberFormat" reason:@"Number was blank" userInfo:nil];
  }

  if (isblank([text characterAtIndex:0])) {
    @throw [NSException exceptionWithName:@"NumberFormat" reason:@"Invalid character" userInfo:nil];
  }

  if ([text hasPrefix:@"-"]) {
    if (!isSigned) {
      @throw [NSException exceptionWithName:@"NumberFormat" reason:@"Number must be positive" userInfo:nil];
    }
  }

  // now call into the appropriate conversion utilities.
  int64_t result;
  const char* in_string = text.UTF8String;
  char* out_string = NULL;
  errno = 0;
  if (isLong) {
    if (isSigned) {
      result = strtoll(in_string, &out_string, 0);
    } else {
      result = ES_convertUInt64ToInt64(strtoull(in_string, &out_string, 0));
    }
  } else {
    if (isSigned) {
      result = strtol(in_string, &out_string, 0);
    } else {
      result = ES_convertUInt32ToInt32(strtoul(in_string, &out_string, 0));
    }
  }

  // from the man pages:
  // (Thus, i* tr is not `\0' but **endptr is `\0' on return, the entire
  // string was valid.)
  if (*in_string == 0 || *out_string != 0) {
    @throw [NSException exceptionWithName:@"NumberFormat" reason:@"IllegalNumber" userInfo:nil];
  }

  if (errno == ERANGE) {
    @throw [NSException exceptionWithName:@"NumberFormat" reason:@"Number out of range" userInfo:nil];
  }

  return result;
}


/**
 * Parse a 32-bit signed integer from the text.  This function recognizes
 * the prefixes "0x" and "0" to signify hexidecimal and octal numbers,
 * respectively.
 */
+ (int32_t) parseInt32:(NSString*) text {
  return (int32_t)[self parseInteger:text isSigned:YES isLong:NO];
}


/**
 * Parse a 32-bit unsigned integer from the text.  This function recognizes
 * the prefixes "0x" and "0" to signify hexidecimal and octal numbers,
 * respectively.  The result is coerced to a (signed) {@code int} when returned.
 */
+ (int32_t) parseUInt32:(NSString*) text {
  return (int32_t)[self parseInteger:text isSigned:NO isLong:NO];
}


/**
 * Parse a 64-bit signed integer from the text.  This function recognizes
 * the prefixes "0x" and "0" to signify hexidecimal and octal numbers,
 * respectively.
 */
+ (int64_t) parseInt64:(NSString*) text {
  return [self parseInteger:text isSigned:YES isLong:YES];
}


/**
 * Parse a 64-bit unsigned integer from the text.  This function recognizes
 * the prefixes "0x" and "0" to signify hexidecimal and octal numbers,
 * respectively.  The result is coerced to a (signed) {@code long} when
 * returned.
 */
+ (int64_t) parseUInt64:(NSString*) text {
  return [self parseInteger:text isSigned:NO isLong:YES];
}

/**
 * Interpret a character as a digit (in any base up to 36) and return the
 * numeric value.  This is like {@code Character.digit()} but we don't accept
 * non-ASCII digits.
 */
int32_t ES_digitValue(unichar c) {
  if ('0' <= c && c <= '9') {
    return c - '0';
  } else if ('a' <= c && c <= 'z') {
    return c - 'a' + 10;
  } else {
    return c - 'A' + 10;
  }
}


/**
 * Un-escape a byte sequence as escaped using
 * {@link #escapeBytes(ByteString)}.  Two-digit hex escapes (starting with
 * "\x") are also recognized.
 */
+ (NSData*) unescapeBytes:(NSString*) input {
  NSMutableData* result = [NSMutableData dataWithLength:input.length];

  int32_t pos = 0;
  for (int32_t i = 0; i < input.length; i++) {
    unichar c = [input characterAtIndex:i];
    if (c == '\\') {
      if (i + 1 < input.length) {
        ++i;
        c = [input characterAtIndex:i];
        if (ES_isOctal(c)) {
          // Octal escape.
          int32_t code = ES_digitValue(c);
          if (i + 1 < input.length && ES_isOctal([input characterAtIndex:(i + 1)])) {
            ++i;
            code = code * 8 + ES_digitValue([input characterAtIndex:i]);
          }
          if (i + 1 < input.length && ES_isOctal([input characterAtIndex:(i + 1)])) {
            ++i;
            code = code * 8 + ES_digitValue([input characterAtIndex:i]);
          }
          ((int8_t*)result.mutableBytes)[pos++] = (int8_t)code;
        } else {
          switch (c) {
            case 'a' : ((int8_t*)result.mutableBytes)[pos++] = 0x07; break;
            case 'b' : ((int8_t*)result.mutableBytes)[pos++] = '\b'; break;
            case 'f' : ((int8_t*)result.mutableBytes)[pos++] = '\f'; break;
            case 'n' : ((int8_t*)result.mutableBytes)[pos++] = '\n'; break;
            case 'r' : ((int8_t*)result.mutableBytes)[pos++] = '\r'; break;
            case 't' : ((int8_t*)result.mutableBytes)[pos++] = '\t'; break;
            case 'v' : ((int8_t*)result.mutableBytes)[pos++] = 0x0b; break;
            case '\\': ((int8_t*)result.mutableBytes)[pos++] = '\\'; break;
            case '\'': ((int8_t*)result.mutableBytes)[pos++] = '\''; break;
            case '"' : ((int8_t*)result.mutableBytes)[pos++] = '\"'; break;

            case 'x': // hex escape
            {
              int32_t code = 0;
              if (i + 1 < input.length && ES_isHex([input characterAtIndex:(i + 1)])) {
                ++i;
                code = ES_digitValue([input characterAtIndex:i]);
              } else {
                @throw [NSException exceptionWithName:@"InvalidEscape" reason:@"Invalid escape sequence: '\\x' with no digits" userInfo:nil];
              }
              if (i + 1 < input.length && ES_isHex([input characterAtIndex:(i + 1)])) {
                ++i;
                code = code * 16 + ES_digitValue([input characterAtIndex:i]);
              }
              ((int8_t*)result.mutableBytes)[pos++] = (int8_t)code;
              break;
            }

            default:
              @throw [NSException exceptionWithName:@"InvalidEscape" reason:@"Invalid escape sequence" userInfo:nil];
          }
        }
      } else {
        @throw [NSException exceptionWithName:@"InvalidEscape" reason:@"Invalid escape sequence: '\\' at end of string" userInfo:nil];
      }
    } else {
      ((int8_t*)result.mutableBytes)[pos++] = (int8_t)c;
    }
  }

  [result setLength:pos];
  return result;
}

@end
