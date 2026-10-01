vlib work
vlog uart_baud.v uart_tx.v uart_rx.v top_module.v tb.v
vsim -voptargs=+acc work.tb
add wave *
run -all
#quit -sim