NAME := 453.povray
SRC := povray atmosph  bbox  bcyl  bezier  blob  boxes   bsphere  camera  chi2  colour  colutils  cones   csg  \
	   defaultplatformbase  defaultrenderfrontend  discs   express  fileinputoutput  fncode  fnintern  \
	   fnpovfpu   fnsyntax  fpmetric  fractal  function  hcmplx  hfield   histogra  iff  image  interior  \
	   isosurf  lathe   lbuffer  lightgrp  lighting  mathutil  matrices   media  mesh  messageoutput  normal  \
	   objects  octree   optout  parse  parsestr  parstxtr  pattern  pgm   photons  pigment  planes  point  poly  \
	   polygon   polysolv  pov_mem  pov_util  povms  povmscpp   povmsend  povmsrec  ppm  prism   processoptions  \
	   processrenderoptions  quadrics  quatern   rad_data  radiosit  ray  rendctrl  render   renderfrontend  renderio  \
	   sor  specrand  spec_qsort   spheres  sphsweep  splines  statspov  stringutilities   super  targa  textstream  \
	   textstreambuffer  texture   tokenize  torus  triangle  truetype  txttest   userdisp  userio  vbuffer  vlbuffer  warps
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CXXFLAGS  += -Wno-multichar -Wno-write-strings
LDFLAGS += -lstdc++ -lm

all: $(BUILD_DIR)/$(NAME)
