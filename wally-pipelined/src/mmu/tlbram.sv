///////////////////////////////////////////
// tlbram.sv
//
// Written: jtorrey@hmc.edu & tfleming@hmc.edu 16 February 2021
// Modified:
//
// Purpose: Stores page table entries of cached address translations.
//          Outputs the physical page number and access bits of the current
//          virtual address on a TLB hit.
// 
// A component of the Wally configurable RISC-V project.
// 
// Copyright (C) 2021 Harvey Mudd College & Oklahoma State University
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT 
// OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///////////////////////////////////////////

`include "wally-config.vh"

module tlbram #(parameter TLB_ENTRIES = 8) (
  input  logic                      clk, reset,
  input  logic [`XLEN-1:0]          PTE,
  input  logic [TLB_ENTRIES-1:0]    Matches, WriteEnables,
  output logic [`PPN_BITS-1:0]      PPN,
  output logic [7:0]                PTEAccessBits,
  output logic [TLB_ENTRIES-1:0]    PTE_Gs
);

  logic [`PPN_BITS+9:0] RamRead[TLB_ENTRIES-1:0];
  logic [`PPN_BITS+9:0] PageTableEntry;

  // RAM implemented with array of flops and AND/OR read logic
  tlbramline #(`PPN_BITS+10) tlblineram[TLB_ENTRIES-1:0](clk, reset, Matches, WriteEnables, PTE[`PPN_BITS+9:0], RamRead, PTE_Gs);
  assign PageTableEntry = RamRead.or; // OR each column of RAM read to read PTE
  // Rename the bits read from the TLB RAM
  assign PTEAccessBits = PageTableEntry[7:0];
  assign PPN = PageTableEntry[`PPN_BITS+9:10];
endmodule
