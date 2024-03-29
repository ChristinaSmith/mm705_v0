// MLDefs.bsv - Message Level Definitions
// Copyright (c) 2012 Atomic Rules LLC - ALL RIGHTS RESERVED

package MLDefs;

import GetPut  ::*;
import Vector  ::*;
import DefaultValue ::*;

typedef struct {
  UInt#(32) length;   // Message Length in Bytes
  Bit#(8)   opcode;   // Message Opcode
} MLMeta deriving (Bits, Eq);

typedef struct {
  UInt#(32)   length;
  Bit#(8)     opcode;
  Bit#(8)     portID;
  Bit#(15)    reserved;
  Bit#(1)     alwaysOne;
} RDMAMeta deriving (Bits, Eq);

instance DefaultValue#(RDMAMeta);
defaultValue = 
  RDMAMeta {
  length:    0,
  opcode:    0,
  portID:    0,
  reserved:  0,
  alwaysOne: 1
};
endinstance

typedef enum {
  Constant = 0,
  Incremental = 1,
  Random = 2
} LengthMode deriving (Bits, Eq);

typedef enum {
  ZeroOrigin = 0,
  IncrementalOrigin = 1,
  RollingCount = 2
} DataMode deriving (Bits, Eq);

typedef Vector#(16,Bit#(8)) HexByte;

typedef union tagged {
  MLMeta Meta;
  HexByte Data;
} MLMesg deriving (Bits, Eq);

typedef struct {
  HexByte data;     // 16B of data, little endian packed
  UInt#(5) nbVal;   // Number of Bytes 0-16 that are valid
  Bool isEOP;       // True if this is the end of packet
} HexBDG deriving (Bits, Eq);


interface MLProducer;
  interface GetS#(MLMeta) meta;    // GetS splits the "first" and "deq" methods so we can observe
  interface Get#(HexByte) data;    // Our message data
endinterface

interface PutAck#(type t);
  method Action offer(t val);      // A way to observe the first element
  method Bool   ack();             // And signal for the next
endinterface

interface MLConsumer;
  interface PutAck#(MLMeta) meta;  // Our metadata
  interface Put#(HexByte)   data;  // Our message data
endinterface

endpackage
