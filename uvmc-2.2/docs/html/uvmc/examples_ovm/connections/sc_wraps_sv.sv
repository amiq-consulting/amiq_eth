//
//------------------------------------------------------------//
//   Copyright 2009-2012 Mentor Graphics Corporation          //
//   All Rights Reserved Worldwid                             //
//                                                            //
//   Licensed under the Apache License, Version 2.0 (the      //
//   "License"); you may not use this file except in          //
//   compliance with the License.  You may obtain a copy of   //
//   the License at                                           //
//                                                            //
//       http://www.apache.org/licenses/LICENSE-2.0           //
//                                                            //
//   Unless required by applicable law or agreed to in        //
//   writing, software distributed under the License is       //
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR   //
//   CONDITIONS OF ANY KIND, either express or implied.  See  //
//   the License for the specific language governing          //
//   permissions and limitations under the License.           //
//------------------------------------------------------------//

//-----------------------------------------------------------------------------
// Title: UVMC Connection Example - Hierarchical Connection, SV side
//
// This example illustrates how to make hierarchical connections, i.e. promoting
// a ~port~, ~export~, ~imp~, or ~socket~ from a child component to its parent.
// See <UVMC Connection Example - Hierarchical Connection, SC side> to see 
// the SC portion of the example.
//
// (see UVMC_Connections_SCwrapsSV.png)
//
// Note: This example is derived from the UVM Connect examples, so the diagram 
// depicts components with TLM2 sockets. TLM2 is not available in OVM, so this OVM
// components use TLM1 blocking put ports. Whether sockets or ports/exports, the
// connection syntax is the same.
//
// In this case, we are creating a SV producer that will serve as the 
// implementation of a producer in SC. SC users won't be aware of this because all
// they will see is a standard SC producer. This is in keeping with the principle
// of encapsulation and designing to interfaces. The implementation of something
// can change as long as the interface and semantic doesn't change. Standard
// TLM interfaces enable the application of this principle for design and
// verification components alike.
//
// The ~sv_main~ top-level module below implements the SV portion of this
// example. It does the following:
//
// - Creates an instance of a ~producer~ component
//
// - Registers the producer's ~out~ port with UVMC using the string "sv_out".
//   During elaboration, UVMC will connect this port with something registered
//   with the same lookup string. In this example, the match will occur with the
//   SC producer's ~out~ port. This effectively promotes this SV producer port
//   to the port in its producer "wrapper" in SC.
//
// - Calls ~run_test~ to start UVM SV simulation
//
//-----------------------------------------------------------------------------

// (inline source)
`include "ovm_macros.svh"
import ovm_pkg::*; 

`include "producer.sv"

module sv_main;

  import ovmc_pkg::*;

  producer prod = new("prod");

  initial begin
    uvmc_tlm1 #(packet)::connect(prod.out,"sv_out");
    run_test();
  end

endmodule
