#/*
# * Revision Control Information
# *
# * $Source: /vol/opua/opua2/sis/sis-1.1/common/src/sis/sis_lib/help/RCS/Makefile,v $
# * $Author: sis $
# * $Revision: 1.4 $
# * $Date: 1992/05/06 19:04:01 $
# *
# */
build: sis.1 make_fmt

sis.1:
	soelim sis.man | tbl | eqn > sis.1
#or try ditroff -eqn -tbl -man -Plps20a

install:
	cp sis.1 ../../man

clean:
	rm -f *.fmt sis.1

sis.doc:

print: sis.1
	ditroff -man -Plps20a sis.1
#	psroff -man -Plps20 sis.1

depend: $(SRC)
	sed '/^#--DONT TOUCH BELOW THIS LINE/,$$d' Makefile >mktemp
	echo '#--DONT TOUCH BELOW THIS LINE' >>mktemp
	ls *.1 | sed 's/\.1//' | grep -v sis | awk -f make.awk >>mktemp
	mv mktemp Makefile

#--DONT TOUCH BELOW THIS LINE
.SUFFIXES: .1 .fmt
.1.fmt:
	format $*.1 >$*.fmt
make_fmt: _astg_cycle.fmt _astg_flow.fmt _astg_hfrpdft.fmt _astg_irred.fmt  \
	_astg_mgc.fmt _astg_smc.fmt act_map.fmt add_inverter.fmt alias.fmt  \
	astg_add_state.fmt astg_contract.fmt astg_current.fmt  \
	astg_encode.fmt astg_lockgraph.fmt astg_marking.fmt  \
	astg_print_sg.fmt astg_print_stat.fmt astg_slow.fmt  \
	astg_state_min.fmt astg_stg_scr.fmt astg_syn.fmt astg_to_f.fmt  \
	astg_to_stg.fmt atpg.fmt bdsyn.fmt buffer_opt.fmt c_check.fmt  \
	c_opt.fmt chng_clock.fmt chng_name.fmt collapse.fmt  \
	constraints.fmt decomp.fmt echo.fmt eliminate.fmt env_seq_dc.fmt  \
	env_verify_fsm.fmt equiv_nets.fmt espresso.fmt extract_seq_dc.fmt  \
	factor.fmt fanout_alg.fmt fanout_param.fmt force_init_0.fmt  \
	free_dc.fmt full_simplify.fmt fx.fmt gcx.fmt gkx.fmt help.fmt  \
	history.fmt invert.fmt invert_io.fmt ite_map.fmt latch_output.fmt  \
	map.fmt one_hot.fmt phase.fmt plot_blif.fmt power_estimate.fmt  \
	power_free_info.fmt power_print.fmt print.fmt print_altname.fmt  \
	print_clock.fmt print_delay.fmt print_factor.fmt print_gate.fmt  \
	print_io.fmt print_kernel.fmt print_latch.fmt print_level.fmt  \
	print_library.fmt print_map_stats.fmt print_state.fmt  \
	print_stats.fmt print_value.fmt quit.fmt read_astg.fmt  \
	read_blif.fmt read_eqn.fmt read_kiss.fmt read_library.fmt  \
	read_oct.fmt read_pla.fmt read_slif.fmt red_removal.fmt  \
	reduce_depth.fmt remove_dep.fmt remove_latches.fmt replace.fmt  \
	reset_name.fmt resub.fmt retime.fmt save.fmt set.fmt set_delay.fmt  \
	set_state.fmt short_tests.fmt sim_verify.fmt simplify.fmt  \
	simulate.fmt source.fmt speed_up.fmt speedup_alg.fmt  \
	state_assign.fmt state_minimize.fmt stg_cover.fmt stg_extract.fmt  \
	stg_to_astg.fmt stg_to_network.fmt sweep.fmt tech_decomp.fmt  \
	time.fmt timeout.fmt unalias.fmt undo.fmt unset.fmt usage.fmt  \
	verify.fmt verify_fsm.fmt wd.fmt write_astg.fmt write_bdnet.fmt  \
	write_blif.fmt write_eqn.fmt write_kiss.fmt write_oct.fmt  \
	write_pds.fmt write_pla.fmt write_slif.fmt xilinx.fmt  \
	xl_absorb.fmt xl_ao.fmt xl_coll_ck.fmt xl_cover.fmt  \
	xl_decomp_two.fmt xl_imp.fmt xl_k_decomp.fmt xl_merge.fmt  \
	xl_part_coll.fmt xl_partition.fmt xl_rl.fmt xl_split.fmt 
_astg_cycle.fmt: _astg_cycle.1 header.me
_astg_flow.fmt: _astg_flow.1 header.me
_astg_hfrpdft.fmt: _astg_hfrpdft.1 header.me
_astg_irred.fmt: _astg_irred.1 header.me
_astg_mgc.fmt: _astg_mgc.1 header.me
_astg_smc.fmt: _astg_smc.1 header.me
act_map.fmt: act_map.1 header.me
add_inverter.fmt: add_inverter.1 header.me
alias.fmt: alias.1 header.me
astg_add_state.fmt: astg_add_state.1 header.me
astg_contract.fmt: astg_contract.1 header.me
astg_current.fmt: astg_current.1 header.me
astg_encode.fmt: astg_encode.1 header.me
astg_lockgraph.fmt: astg_lockgraph.1 header.me
astg_marking.fmt: astg_marking.1 header.me
astg_print_sg.fmt: astg_print_sg.1 header.me
astg_print_stat.fmt: astg_print_stat.1 header.me
astg_slow.fmt: astg_slow.1 header.me
astg_state_min.fmt: astg_state_min.1 header.me
astg_stg_scr.fmt: astg_stg_scr.1 header.me
astg_syn.fmt: astg_syn.1 header.me
astg_to_f.fmt: astg_to_f.1 header.me
astg_to_stg.fmt: astg_to_stg.1 header.me
atpg.fmt: atpg.1 header.me
bdsyn.fmt: bdsyn.1 header.me
buffer_opt.fmt: buffer_opt.1 header.me
c_check.fmt: c_check.1 header.me
c_opt.fmt: c_opt.1 header.me
chng_clock.fmt: chng_clock.1 header.me
chng_name.fmt: chng_name.1 header.me
collapse.fmt: collapse.1 header.me
constraints.fmt: constraints.1 header.me
decomp.fmt: decomp.1 header.me
echo.fmt: echo.1 header.me
eliminate.fmt: eliminate.1 header.me
env_seq_dc.fmt: env_seq_dc.1 header.me
env_verify_fsm.fmt: env_verify_fsm.1 header.me
equiv_nets.fmt: equiv_nets.1 header.me
espresso.fmt: espresso.1 header.me
extract_seq_dc.fmt: extract_seq_dc.1 header.me
factor.fmt: factor.1 header.me
fanout_alg.fmt: fanout_alg.1 header.me
fanout_param.fmt: fanout_param.1 header.me
force_init_0.fmt: force_init_0.1 header.me
free_dc.fmt: free_dc.1 header.me
full_simplify.fmt: full_simplify.1 header.me
fx.fmt: fx.1 header.me
gcx.fmt: gcx.1 header.me
gkx.fmt: gkx.1 header.me
help.fmt: help.1 header.me
history.fmt: history.1 header.me
invert.fmt: invert.1 header.me
invert_io.fmt: invert_io.1 header.me
ite_map.fmt: ite_map.1 header.me
latch_output.fmt: latch_output.1 header.me
map.fmt: map.1 header.me
one_hot.fmt: one_hot.1 header.me
phase.fmt: phase.1 header.me
plot_blif.fmt: plot_blif.1 header.me
power_estimate.fmt: power_estimate.1 header.me
power_free_info.fmt: power_free_info.1 header.me
power_print.fmt: power_print.1 header.me
print.fmt: print.1 header.me
print_altname.fmt: print_altname.1 header.me
print_clock.fmt: print_clock.1 header.me
print_delay.fmt: print_delay.1 header.me
print_factor.fmt: print_factor.1 header.me
print_gate.fmt: print_gate.1 header.me
print_io.fmt: print_io.1 header.me
print_kernel.fmt: print_kernel.1 header.me
print_latch.fmt: print_latch.1 header.me
print_level.fmt: print_level.1 header.me
print_library.fmt: print_library.1 header.me
print_map_stats.fmt: print_map_stats.1 header.me
print_state.fmt: print_state.1 header.me
print_stats.fmt: print_stats.1 header.me
print_value.fmt: print_value.1 header.me
quit.fmt: quit.1 header.me
read_astg.fmt: read_astg.1 header.me
read_blif.fmt: read_blif.1 header.me
read_eqn.fmt: read_eqn.1 header.me
read_kiss.fmt: read_kiss.1 header.me
read_library.fmt: read_library.1 header.me
read_oct.fmt: read_oct.1 header.me
read_pla.fmt: read_pla.1 header.me
read_slif.fmt: read_slif.1 header.me
red_removal.fmt: red_removal.1 header.me
reduce_depth.fmt: reduce_depth.1 header.me
remove_dep.fmt: remove_dep.1 header.me
remove_latches.fmt: remove_latches.1 header.me
replace.fmt: replace.1 header.me
reset_name.fmt: reset_name.1 header.me
resub.fmt: resub.1 header.me
retime.fmt: retime.1 header.me
save.fmt: save.1 header.me
set.fmt: set.1 header.me
set_delay.fmt: set_delay.1 header.me
set_state.fmt: set_state.1 header.me
short_tests.fmt: short_tests.1 header.me
sim_verify.fmt: sim_verify.1 header.me
simplify.fmt: simplify.1 header.me
simulate.fmt: simulate.1 header.me
source.fmt: source.1 header.me
speed_up.fmt: speed_up.1 header.me
speedup_alg.fmt: speedup_alg.1 header.me
state_assign.fmt: state_assign.1 header.me
state_minimize.fmt: state_minimize.1 header.me
stg_cover.fmt: stg_cover.1 header.me
stg_extract.fmt: stg_extract.1 header.me
stg_to_astg.fmt: stg_to_astg.1 header.me
stg_to_network.fmt: stg_to_network.1 header.me
sweep.fmt: sweep.1 header.me
tech_decomp.fmt: tech_decomp.1 header.me
time.fmt: time.1 header.me
timeout.fmt: timeout.1 header.me
unalias.fmt: unalias.1 header.me
undo.fmt: undo.1 header.me
unset.fmt: unset.1 header.me
usage.fmt: usage.1 header.me
verify.fmt: verify.1 header.me
verify_fsm.fmt: verify_fsm.1 header.me
wd.fmt: wd.1 header.me
write_astg.fmt: write_astg.1 header.me
write_bdnet.fmt: write_bdnet.1 header.me
write_blif.fmt: write_blif.1 header.me
write_eqn.fmt: write_eqn.1 header.me
write_kiss.fmt: write_kiss.1 header.me
write_oct.fmt: write_oct.1 header.me
write_pds.fmt: write_pds.1 header.me
write_pla.fmt: write_pla.1 header.me
write_slif.fmt: write_slif.1 header.me
xilinx.fmt: xilinx.1 header.me
xl_absorb.fmt: xl_absorb.1 header.me
xl_ao.fmt: xl_ao.1 header.me
xl_coll_ck.fmt: xl_coll_ck.1 header.me
xl_cover.fmt: xl_cover.1 header.me
xl_decomp_two.fmt: xl_decomp_two.1 header.me
xl_imp.fmt: xl_imp.1 header.me
xl_k_decomp.fmt: xl_k_decomp.1 header.me
xl_merge.fmt: xl_merge.1 header.me
xl_part_coll.fmt: xl_part_coll.1 header.me
xl_partition.fmt: xl_partition.1 header.me
xl_rl.fmt: xl_rl.1 header.me
xl_split.fmt: xl_split.1 header.me
sis.1: sis.man _astg_cycle.1 _astg_flow.1 _astg_hfrpdft.1 _astg_irred.1  \
	_astg_mgc.1 _astg_smc.1 act_map.1 add_inverter.1 alias.1  \
	astg_add_state.1 astg_contract.1 astg_current.1 astg_encode.1  \
	astg_lockgraph.1 astg_marking.1 astg_print_sg.1 astg_print_stat.1  \
	astg_slow.1 astg_state_min.1 astg_stg_scr.1 astg_syn.1 astg_to_f.1  \
	astg_to_stg.1 atpg.1 bdsyn.1 buffer_opt.1 c_check.1 c_opt.1  \
	chng_clock.1 chng_name.1 collapse.1 constraints.1 decomp.1 echo.1  \
	eliminate.1 env_seq_dc.1 env_verify_fsm.1 equiv_nets.1 espresso.1  \
	extract_seq_dc.1 factor.1 fanout_alg.1 fanout_param.1  \
	force_init_0.1 free_dc.1 full_simplify.1 fx.1 gcx.1 gkx.1 help.1  \
	history.1 invert.1 invert_io.1 ite_map.1 latch_output.1 map.1  \
	one_hot.1 phase.1 plot_blif.1 power_estimate.1 power_free_info.1  \
	power_print.1 print.1 print_altname.1 print_clock.1 print_delay.1  \
	print_factor.1 print_gate.1 print_io.1 print_kernel.1  \
	print_latch.1 print_level.1 print_library.1 print_map_stats.1  \
	print_state.1 print_stats.1 print_value.1 quit.1 read_astg.1  \
	read_blif.1 read_eqn.1 read_kiss.1 read_library.1 read_oct.1  \
	read_pla.1 read_slif.1 red_removal.1 reduce_depth.1 remove_dep.1  \
	remove_latches.1 replace.1 reset_name.1 resub.1 retime.1 save.1  \
	set.1 set_delay.1 set_state.1 short_tests.1 sim_verify.1  \
	simplify.1 simulate.1 source.1 speed_up.1 speedup_alg.1  \
	state_assign.1 state_minimize.1 stg_cover.1 stg_extract.1  \
	stg_to_astg.1 stg_to_network.1 sweep.1 tech_decomp.1 time.1  \
	timeout.1 unalias.1 undo.1 unset.1 usage.1 verify.1 verify_fsm.1  \
	wd.1 write_astg.1 write_bdnet.1 write_blif.1 write_eqn.1  \
	write_kiss.1 write_oct.1 write_pds.1 write_pla.1 write_slif.1  \
	xilinx.1 xl_absorb.1 xl_ao.1 xl_coll_ck.1 xl_cover.1  \
	xl_decomp_two.1 xl_imp.1 xl_k_decomp.1 xl_merge.1 xl_part_coll.1  \
	xl_partition.1 xl_rl.1 xl_split.1 
