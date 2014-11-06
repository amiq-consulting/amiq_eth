#!/bin/sh -e

#UVMC define for maximum number of words
export UVMC_MAX_WORDS=9200

#UVM maximum number of streaming bits
export UVM_MAX_STREAMBITS=294400

export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

#the default values of the user controlled options
default_tool=ius
default_seed=1;
default_test="amiq_eth_ve_test_ipv4_packets"
default_arch_bits=64
default_livestream=no

tool=${default_tool}
seed=${default_seed}
test=${default_test}
ARCH_BITS=${default_arch_bits}
livestream=${default_livestream}

export TOP_MODULE_NAME=amiq_eth_ve_top
export TOP_FILE_NAME=${TOP_MODULE_NAME}.v
export TOP_FILE_PATH=${PROJECT_DIR}/ve/sv/${TOP_FILE_NAME}

wireshark_file=wireshark
wireshark_options=""

help() {
	echo ""
	echo "Possible options for this script:"
	echo "	-seed <SEED>           --> specify a particular seed for the simulation (default: ${default_seed})"
	echo "	-test <TEST_NAME>      --> specify a particular test to run (default: ${default_test})"
	echo "	-tool [ius|questa|vcs] --> specify what simulator to use (default: ${default_tool})"
	echo "	-bit[32|64]            --> specify what architecture to use: 32 or 64 bits (default: ${default_arch_bits} bits)"
	echo "	-livestream            --> triggers live streaming using Wireshark"
	echo "	-help                  --> print this message"
	echo ""
}

setup_wireshark_for_pipe() {
	rm -rf ${wireshark_file}.pcap ${wireshark_file}.fifo; 
	mkfifo ${wireshark_file}.fifo; touch ${wireshark_file}.pcap; 
	tail -f ${wireshark_file}.pcap >> ${wireshark_file}.fifo &
	wireshark -k -i ${wireshark_file}.fifo &
}

run_with_ius_test() {
	if [ "$livestream" = "yes" ]; then
		setup_wireshark_for_pipe;
		wireshark_options=" +define+AMIQ_ETH_WIRESHARK_FILE=\"${wireshark_file}\" "
	fi
	
	irun ${wireshark_options} -f ${PROJECT_DIR}/scripts/options_ius.f -svseed ${seed} +UVM_TESTNAME=${test}
}

run_with_vcs_test() {
	echo "Script is not currently supporting VCS simmulator!"
	exit 1
}

run_with_questa_test() {
	if [ "$livestream" = "yes" ]; then
		setup_wireshark_for_pipe;
		wireshark_options=" +define+AMIQ_ETH_WIRESHARK_FILE=\"${wireshark_file}\" "
	fi
	
	rm -rf work
	vlib work
	vlog ${wireshark_options} -f ${PROJECT_DIR}/scripts/options_vlog.f
	sccom -f ${PROJECT_DIR}/scripts/options_sccom.f
    sccom -link
    vsim -${ARCH_BITS} -L work -c -do "run -all; quit -f" -t 1ps -sv_seed ${seed} +UVM_TESTNAME=${test} sc_main ${TOP_MODULE_NAME}
}

while [ $# -gt 0 ]; do
	case `echo $1 | tr "[A-Z]" "[a-z]"` in
		-seed)
			seed=$2
      	;;
      	-tool)
      		tool=$2
      	;;
      	-test)
      		test=$2
      	;;
      	-bit32)
      		ARCH_BITS=32
      	;;
      	-bit64)
      		ARCH_BITS=64
      	;;
        -livestream)
      	    livestream=yes
      	;;
      	-help)
      		help
      		exit 0
      	;;
    esac
    shift       
done

if [[ -z "${UVM_HOME}" ]]; then
	echo "You did not set system variable UVM_HOME - please make sure that you have set this variable to the location of your UVM instalation!"
	exit 1
fi

if [[ -z "${UVMC_HOME}" ]]; then
	export UVMC_HOME=${PROJECT_DIR}/uvmc-2.2
	echo "You did not set system variable UVMC_HOME - the default value will be used: ${UVMC_HOME}"
fi

export ARCH_BITS=${ARCH_BITS}

case $tool in
	ius)
		echo "Selected tool: IUS..."
	;;
	vcs)
		echo "Selected tool: VCS..."
	;;
	questa)
		echo "Selected tool: Questa..."
	;;
	*)
		echo "Illegal option for tool: $tool"
		exit 1;
	;;
esac

sim_dir=`pwd`/amiq_eth_work
echo "Start running ${test} test in ${sim_dir}";
rm -rf ${sim_dir};
mkdir ${sim_dir};
cd ${sim_dir};
run_with_${tool}_test
cd -
