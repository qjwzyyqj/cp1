`timescale 1ns/1ps
module tb;

reg		t_clk;
reg		t_reset;

reg		t_wr_req;
reg	[7:0]	t_wr_data;
reg		t_wr_valid;
wire		t_wr_done;

reg		t_rd_req;
wire	[7:0]	t_rd_data;
wire 		t_rd_valid;
reg 		t_rd_done;

// R/W share signal
reg	[5:0]	t_addr;
wire		t_ack;
reg 	[3:0]	t_num_b;

mem_rw_controller dut(
	.i_clk(t_clk),
	.i_reset(t_reset),
	.i_wr_req(t_wr_req),
	.i_wr_data(t_wr_data),
	.i_wr_valid(t_wr_valid),
	.o_wr_done(t_wr_done),
	.i_rd_req(t_rd_req),
	.o_rd_data(t_rd_data),
	.o_rd_valid(t_rd_valid),
	.i_rd_done(t_rd_done),
	.i_addr(t_addr),
	.o_ack(t_ack),
	.i_num_b(t_num_b)
);
reg	[4:0]	i;
initial begin
	t_clk = 1'b0;
	t_reset = 1'b0;
	#100;
	t_reset = 1'b1;
	// write sequence
	t_wr_req = 1'b0;
	#40;
	@(posedge t_clk);
	$display("TB: write req start");
	t_wr_valid = 1'b0;
	t_wr_req = 1'b1;
	t_num_b = 4'd3;
	t_addr = 6'd0;
	t_wr_data = 8'd0;
	@(posedge t_ack);
	$display("TB: receive write ack");
	t_wr_data = 8'd3;
	t_wr_req = 1'b0;
	$display("TB: start write bytes");
	@(posedge t_clk);
	t_wr_valid = 1'b1;
	i = 1;
	while(i < 4) begin
		@(posedge t_clk);
		if(t_wr_done == 1) begin 
			$display("TB: Write %d Byte Done.", i);	
			t_wr_data = t_wr_data + 1;
			i = i + 1;
		end
		else begin
			$display("TB: Wait write done");
		end
		#5;
	end
	#5;
	t_wr_valid = 1'b0;
	@(posedge t_clk);
	#30;
	$finish;
end

always
	#5 t_clk = ~t_clk;

initial begin
	$dumpfile("test.vcd");
	$dumpvars(0,tb);
end

endmodule
