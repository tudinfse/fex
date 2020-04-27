NAME := 447.dealII
SRC := auto_derivative_function block_sparse_matrix block_sparse_matrix_ez block_sparsity_pattern block_vector \
	   compressed_sparsity_pattern data_out data_out_base data_out_faces data_out_rotation data_out_stack  \
	   derivative_approximation dof_accessor dof_constraints dof_handler dof_levels dof_renumbering dof_tools \
	   error_estimator exceptions fe fe_data fe_dgp fe_dgp_1d fe_dgp_2d fe_dgp_3d fe_dgp_nonparametric fe_dgq \
	   fe_dgq_1d fe_dgq_2d fe_dgq_3d fe_nedelec fe_nedelec_1d fe_nedelec_2d fe_nedelec_3d fe_q fe_q_1d fe_q_2d fe_q_3d \
	   fe_q_hierarchical fe_raviart_thomas fe_system fe_tools fe_values filtered_matrix full_matrix.double \
	   full_matrix.float function function_derivative function_lib function_lib_cutoff function_time geometry_info \
	   grid_generator grid_in grid_out.all_dimensions grid_out grid_refinement grid_reordering histogram intergrid_map \
	   job_identifier log mapping mapping_c1 mapping_cartesian mapping_q mapping_q1 mapping_q1_eulerian \
	   matrices.all_dimensions matrices matrix_lib matrix_out memory_consumption mg_base mg_dof_accessor mg_dof_handler \
	   mg_dof_tools mg_smoother mg_transfer_block mg_transfer_prebuilt mg_transfer_block.all_dimensions \
	   multigrid.all_dimensions multithread_info parameter_handler persistent_tria polynomial polynomial_space \
	   programid quadrature quadrature_lib solution_transfer solver_control sparse_matrix.double sparse_matrix.float \
	   sparse_matrix_ez.double sparse_matrix_ez.float sparsity_pattern step-14 subscriptor swappable_vector tensor \
	   tensor_product_polynomials tria.all_dimensions tria tria_accessor tria_boundary tria_boundary_lib vector \
	   vector.long_double vectors.all_dimensions fe_dgp_monomial fe_poly polynomials_bdm polynomials_p vectors
VPATH := src

include $(BUILD_TYPE).mk
include ../spec_common.mk

CXXFLAGS += -Isrc/include
CXXFLAGS += -DBOOST_DISABLE_THREADS -DBOOST_DISABLE_THREADS
CXXFLAGS += -Ddeal_II_dimension=3 -include cstddef -include cstdlib -include cstring
CXXFLAGS += -Wno-deprecated-declarations -Wno-deprecated -fpermissive
LDFLAGS += -lstdc++ -lm

all: $(BUILD_DIR)/$(NAME)
