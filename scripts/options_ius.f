+incdir+${PROJECT_DIR}/sv/ 
+incdir+${PROJECT_DIR}/ve/sv/ 
+incdir+${PROJECT_DIR}/tests/ 
+incdir+${UVMC_HOME}/src/connect/sv/
-I${SYSTEMC_HOME}/include/tlm2/tlm_utils/
-I${UVMC_HOME}/src/connect/sc/
-I${PROJECT_DIR}/sc/
-I${PROJECT_DIR}/ve/sc/
-${ARCH_BITS}bit
-defineall UVMC_MAX_WORDS=${UVMC_MAX_WORDS}
-defineall UVM_MAX_STREAMBITS=${UVM_MAX_STREAMBITS}
-g 
-sysc
-uvm
-access rw
-sv
+UVM_NO_RELNOTES 
-DSC_INCLUDE_DYNAMIC_PROCESSES 
-sv_lib ${IUS_HOME}/tools.lnx86/methodology/UVM/CDNS-1.1d/additions/sv/lib/64bit/libuvmdpi.so
+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR
+UVM_VERBOSITY=UVM_LOW
${UVMC_HOME}/src/connect/sc/uvmc.cpp 
-sc_main 
-dpi
${PROJECT_DIR}/ve/sc/${TOP_MODULE_NAME}.cpp 
${TOP_FILE_PATH} 
-timescale 1ns/1ps 
