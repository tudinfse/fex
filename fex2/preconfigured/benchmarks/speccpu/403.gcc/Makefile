NAME := 403.gcc
SRC := alloca asprintf vasprintf c-parse c-lang attribs c-errors c-lex c-pragma c-decl c-typeck c-convert c-aux-info \
       c-common c-format c-semantics c-objc-common  cpplib cpplex cppmacro cppexp cppfiles cpphash cpperror cppinit \
       cppdefault line-map mkdeps prefix version mbchar alias bb-reorder bitmap builtins caller-save calls cfg cfganal \
       cfgbuild cfgcleanup cfglayout cfgloop cfgrtl combine conflict convert cse cselib dbxout debug dependence df \
       diagnostic doloop dominance dwarf2asm dwarf2out dwarfout emit-rtl except explow expmed expr final flow \
       fold-const function gcse genrtl ggc-common global graph haifa-sched hash hashtable hooks ifcvt insn-attrtab \
       insn-emit insn-extract insn-opinit insn-output insn-peep insn-recog integrate intl jump langhooks lcm lists \
       local-alloc loop obstack optabs params predict print-rtl print-tree profile real recog reg-stack regclass \
       regmove regrename reload reload1 reorg resource rtl rtlanal rtl-error sbitmap sched-deps sched-ebb sched-rgn \
       sched-vis sdbout sibcall simplify-rtx ssa ssa-ccp ssa-dce stmt stor-layout stringpool timevar toplev tree \
       tree-dump tree-inline unroll varasm varray vmsdbgout xcoffout ggc-page i386 xmalloc xexit hashtab safe-ctype \
       splay-tree xstrdup md5 fibheap xstrerror concat partition hex lbasename getpwd ucbqsort main
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -Isrc

all: $(BUILD_DIR)/$(NAME)
