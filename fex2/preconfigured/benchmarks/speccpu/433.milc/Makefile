NAME := 433.milc
SRC := control f_meas gauge_info setup update update_h update_u layout_hyper check_unitarity d_plaq4 gaugefix2 \
	   io_helpers io_lat4 make_lattice path_product ploop3 ranmom ranstuff reunitarize2 gauge_stuff grsource_imp \
	   mat_invert quark_stuff rephase cmplx addmat addvec clear_mat clearvec m_amatvec m_mat_an m_mat_na m_mat_nn \
	   m_matvec make_ahmat rand_ahmat realtr s_m_a_mat s_m_a_vec s_m_s_mat s_m_vec s_m_mat su3_adjoint su3_dot \
	   su3_rdot su3_proj su3mat_copy submat subvec trace_su3 uncmp_ahmat msq_su3vec sub4vecs m_amv_4dir m_amv_4vec \
	   m_mv_s_4dir m_su2_mat_vec_n l_su2_hit_n r_su2_hit_a m_su2_mat_vec_a gaussrand byterevn m_mat_hwvec m_amat_hwvec \
	   dslash_fn2 d_congrad5_fn com_vanilla io_nonansi
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CFLAGS += -DFN -DFAST -DCONGRAD_TMP_VECTORS -DDSLASH_TMP_LINKS -Wno-int-to-pointer-cast -Isrc
LDFLAGS += -lm

all: $(BUILD_DIR)/$(NAME)
