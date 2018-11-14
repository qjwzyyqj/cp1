module mem_rw_controller(
i_clk,
i_reset,

// write channel
i_wr_req,
o_wr_ack,
i_wr_addr,
i_wr_data,
i_wr_num_b,
i_wr_valid,
o_wr_done,

// read channel
i_rd_req,
o_rd_ack,
i_rd_addr,
i_rd_num_b,
o_rd_data,
o_rd_valid,
i_rd_done,

// error report
o_err,
o_err_code,
i_err_ack

);

// input/output
input 		i_clk;
input 		i_reset;

// write channel
input 		i_wr_req;
input 	[7:0]	i_wr_data;
input 		i_wr_valid;
output 		o_wr_done;

// read channel
input 		i_rd_req;
output 	[7:0]	o_rd_data;
output 		o_rd_valid;
input 		i_rd_done;

// R/W share signal
input	[5:0]	i_addr;
output		o_ack;
input 	[3:0]	i_num_b;

// error report
output 		o_err;
output 	[2:0]	o_err_code;
input 		i_err_ack;

// parameters
parameter	ST_IDLE = 3'd1;
parameter	ST_WRST = 3'd2;
parameter	ST_WRCT = 3'd3;
parameter	ST_RDST = 3'd4;
parameter	ST_RDCT = 3'd5;
parameter	ST_ERPT = 3'd6;

// reg
reg	[3:0]	r_num_b;
reg	[3:0]	r_rw_b;
reg	[1:0]	r_rd_ptr;
reg	[1:0]	r_wr_ptr;
reg	[4:0]	r_timer;
reg	[4:0]	r_max_time;
reg	[2:0]	r_state;

// mem
reg	[7:0]	mem	[5:0];

// wire
wire	[2:0]	w_nxt_state;
wire		w_st_idle = r_state == ST_IDLE;
wire		w_st_wrst = r_state == ST_WRST;
wire		w_st_wrct = r_state == ST_WRCT;
wire		w_st_rdst = r_state == ST_RDST;
wire		w_st_rdct = r_state == ST_RDCT;
wire		w_st_erpt = r_state == ST_ERPT;

always@(*) begin
	if(~i_reset)
		w_nxt_state = ST_IDLE;
	else if(w_st_idle)
		if(i_wr_req)
			w_nxt_state = ST_WRST;
		else if(i_rd_req)
			w_nxt_state = ST_RDST;
	      	else
			w_nxt_state = ST_IDLE;	
	else if(w_st_wrst)
		if(i_wr_valid)
			w_nxt_state = ST_WRCT;
		else
			w_nxt_state = ST_WRST;
	else if(w_st_wrct)
	
	else
		w_nxt_state = ST_IDLE;	
end


endmodule
