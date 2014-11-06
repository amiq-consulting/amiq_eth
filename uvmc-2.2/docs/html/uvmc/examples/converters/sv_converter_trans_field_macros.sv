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

//------------------------------------------------------------------------------
// Title: UVMC Converter Example - SV In-Transaction via Field Macros
//
// This example shows a UVM-style transaction that uses the `uvm_field macros
// to implement the required conversion functionality. 
//
// (see UVMC_Converters_SV_InTransMacros.png)
//
// UVMC's default converter for SV works for these types of transactions.
// Direct implementation of the ~do_pack~ and ~do_unpack~ methods are preferred
// over using the ~`uvm_field~ macros because of the performance impact and low
// debug support associated with these macros. See "Are UVM Macros Evil? A Cost
// Beneifit Analysis" white paper for detailed analysis of the ~`uvm_field~
// and other UVM macros.
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Group: User Library
//
// This section defines a transaction class, ~packet~, that indirectly extends
// ~uvm_object~. It also defines a generic producer model via an `include. All
// transactions and components in the  user library should be written to be
// independent of context, i.e. not assume a UVMC or any other outside connetion.
//
// The ~`uvm_field~ macros expand into hundreds of lines of code, perhaps
// thousands depending on the number and type of fields in your transaction.
// See the example showing direct implementation of ~do_pack~ and ~do_unpack~
// for a better solution.
//------------------------------------------------------------------------------

// (begin inline source)
package user_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  class packet_base extends uvm_sequence_item;

    typedef enum { WRITE, READ, NOOP } cmd_t;

    rand cmd_t cmd;
    rand int   addr;
    rand byte  data[$];

    function new(string name="");
      super.new(name);
    endfunction

    constraint c_data_size { data.size() inside { [1:10] }; }

    `uvm_object_utils_begin(packet_base)
      `uvm_field_enum(cmd_t,cmd,UVM_ALL_ON)
      `uvm_field_int(addr,UVM_ALL_ON)
      `uvm_field_queue_int(data,UVM_ALL_ON)
    `uvm_object_utils_end
    
    virtual function string convert2string();
      return $sformatf("cmd:%s addr:%h data:%p",cmd,addr,data);
    endfunction

  endclass


  class packet extends packet_base;

    rand int extra_int;

    function new(string name="");
      super.new(name);
    endfunction

    `uvm_object_utils_begin(packet)
      `uvm_field_int(extra_int,UVM_ALL_ON)
    `uvm_object_utils_end

    virtual function string convert2string();
      return $sformatf("%s extra_int:%h",super.convert2string(),extra_int);
    endfunction

  endclass

  `include "producer.sv"

endpackage : user_pkg
// (end inline source)



//------------------------------------------------------------------------------
// Group: Conversion code
//
// This section is empty because our conversion functionality is built into the
// transaction type proper.
//------------------------------------------------------------------------------

// (begin inline source)


   /***  No external conversion code needed  ***/


// (end inline source)



//------------------------------------------------------------------------------
// Group: Testbench code
//
// This section defines our testbench environment. In the env's ~build~ function,
// we instantiate the generic producer model. In the ~connect~ method, we
// register the producer's ~out~ port for UVMC connection using the lookup string
// 'stimulus'. The SC-side will register its consumer's ~in~ port with the same
// lookup string. UVMC will match these two strings and complete the cross-
// language connection, i.e. the SV producer's ~out~ port will be bound to the
// SC consumer's ~in~ export.
//
// Because our ~packet~ class implements the requisite ~do_pack~ and ~do_unpack~
// methods, we can leverage UVMC's default converter, which delegates to these
// methods. When making the uvmc_tlm::connect call, we do not need to specify
// a custom converter type--only the transaction type.
//------------------------------------------------------------------------------


// (begin inline source)
module sv_main;

  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import uvmc_pkg::*;
  import user_pkg::*;

  // Define env with connection specifying custom converter 

  class sv_env extends uvm_env;

    producer #(packet) prod;

    `uvm_component_utils(sv_env)
   
    function new(string name, uvm_component parent=null);
       super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
       prod = new("prod", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      uvmc_tlm #(packet)::connect(prod.out, "stimulus");
    endfunction

  endclass


  sv_env env;

  initial begin
    env = new("env");
    run_test();
  end

endmodule
// (end inline source)

