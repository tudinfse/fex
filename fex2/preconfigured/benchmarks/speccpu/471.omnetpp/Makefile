NAME := 471.omnetpp
SRC := omnetapp EtherAppCli EtherAppCli_n EtherAppSrv EtherAppSrv_n EtherApp_m \
	EtherBus EtherBus_n EtherCtrl_m EtherEncap EtherEncap_n EtherFrame_m \
	EtherHost_n EtherHub EtherHub_n EtherLLC EtherLLC_n EtherMAC EtherMAC_n \
	EtherSwitch_n LargeNet_n MACAddress MACAddress_m MACRelayUnitBase \
	MACRelayUnitNP MACRelayUnitNP_n MACRelayUnitPP MACRelayUnitPP_n \
	MACRelayUnit_n Networks_n eth-index_n utils cmdenv enumstr heap \
	akoutvectormgr args cenvir cinifile filemgrs main patmatch platdep seeds \
	slaveapp speedmtr carray cexception cmessage cpar ctypes task cchannel cfsm \
	cmodule cpsquare cvarhist util ccoroutine cgate cmsgheap cqueue cwatch \
	cdensity chead cnetmod csimul distrib cdetect chist cobject cstat errmsg \
	cdispstr cksplit coutvect cstruct onstartup cenum cllist cpacket ctopo \
	random netpack spec_qsort
VPATH := src:src/libs/cmdenv/:src/libs/envir/:src/libs/sim/:src/libs/sim/std/:src/libs/spec/

include $(BUILD_TYPE).mk
include ../spec_common.mk

CXXFLAGS += -Isrc -Isrc/omnet_include -Isrc/libs/envir/
CXXFLAGS += -Wno-write-strings
LDFLAGS += -lstdc++ -lm

all: $(BUILD_DIR)/$(NAME)
