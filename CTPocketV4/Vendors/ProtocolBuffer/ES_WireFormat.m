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

#import "ES_WireFormat.h"

#import "ES_Utilities.h"

int32_t ES_PBWireFormatMakeTag(int32_t fieldNumber, int32_t wireType) {
  return (fieldNumber << ES_PBWireFormatTagTypeBits) | wireType;
}


int32_t ES_PBWireFormatGetTagWireType(int32_t tag) {
  return tag & ES_PBWireFormatTagTypeMask;
}


int32_t ES_PBWireFormatGetTagFieldNumber(int32_t tag) {
  return ES_logicalRightShift32(tag, ES_PBWireFormatTagTypeBits);
}
