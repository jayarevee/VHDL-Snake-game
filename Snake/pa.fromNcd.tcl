
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name lab4 -dir "Z:/Documents/448/Lab4/lab4/planAhead_run_1" -part xc6slx16csg324-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "Z:/Documents/448/Lab4/lab4/top_dat.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {Z:/Documents/448/Lab4/lab4} }
set_property target_constrs_file "lab4_exercise1_nexys3.ucf" [current_fileset -constrset]
add_files [list {lab4_exercise1_nexys3.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "Z:/Documents/448/Lab4/lab4/top_dat.ncd"
if {[catch {read_twx -name results_1 -file "Z:/Documents/448/Lab4/lab4/top_dat.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"Z:/Documents/448/Lab4/lab4/top_dat.twx\": $eInfo"
}
