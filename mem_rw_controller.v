module mem_rw_controller(
i_clk,
i_reset,

// write channel
i_wr_req,
i_wr_data,
i_wr_valid,
o_wr_done,

// read channel
i_rd_req,
o_rd_data,
o_rd_valid,
i_rd_done,

// R/W share signals
i_addr,
o_ack,
i_num_b
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

// parameters
parameter	ST_IDLE = 3'd0;
parameter	ST_WRST = 3'd1;
parameter	ST_WRCT = 3'd2;
parameter	ST_RDST = 3'd3;
parameter	ST_RDCT = 3'd4;

// reg
reg	[3:0]	r_num_b;
reg	[3:0]	r_rw_b;
reg	[1:0]	r_rd_ptr;
reg	[1:0]	r_wr_ptr;
reg	[2:0]	r_state;
reg	[2:0]	w_nxt_state;

// mem
reg	[7:0]	mem	[5:0];

// wire
wire		w_st_idle = r_state == ST_IDLE;
wire		w_st_wrst = r_state == ST_WRST;
wire		w_st_wrct = r_state == ST_WRCT;
wire		w_st_rdst = r_state == ST_RDST;
wire		w_st_rdct = r_state == ST_RDCT;

wire		w_rw_comp = (r_rw_b == r_num_b - 1) & (w_st_wrct | w_st_rdct);

// ---------------------------
// next state logic
// ---------------------------

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
		if(~w_rw_comp)
			w_nxt_state = ST_WRCT;
		else if(i_wr_req)
			w_nxt_state = ST_WRST;
		else if(i_rd_req)
			w_nxt_state = ST_RDST;
		else
			w_nxt_state = ST_IDLE;
	else if(w_st_rdst)
		w_nxt_state = ST_RDCT;
	else if(w_st_rdct)
		if(~w_rw_comp)
			w_nxt_state = ST_RDCT;
		else if(i_wr_req)
			w_nxt_state = ST_WRST;
		else if(i_rd_req)
			w_nxt_state = ST_RDST;
		else
			w_nxt_state = ST_IDLE;
	else
		w_nxt_state = ST_IDLE;	
end

// ---------------------------
// read write byte count logic
// ---------------------------

wire		w_rd_step = o_rd_valid & i_rd_done & ~(r_rw_b == r_num_b);
wire		w_wr_step = i_wr_valid & o_wr_done & ~(r_rw_b == r_num_b);

always@(posedge i_clk or negedge i_reset) begin
	if(~i_reset)
		r_rw_b <= 4'b0;
	else if(w_rd_step | w_wr_step)
		r_rw_b <= r_rw_b + 1;
	else if(w_st_rdct | w_st_wrct)
		r_rw_b <= r_rw_b;
	else
		r_rw_b <= 4'b0;
end

always@(posedge i_clk or negedge i_reset) begin
	if(~i_reset)
		r_num_b <= 4'b0;
	else if(w_st_rdst | w_st_wrst)
		r_num_b <= i_num_b;
	else
		r_num_b <= r_num_b;
end

// ---------------------------
// state machine
// ---------------------------

always@(posedge i_clk) begin
	r_state <= w_nxt_state;
end

// ---------------------------
// Memory R/W logic
// ---------------------------

always@(posedge i_clk) begin
	if(i_wr_valid & w_st_wrct & ~w_rw_comp)
		mem[i_addr] <= i_wr_data;
end	
// ---------------------------
// Output logic
// ---------------------------

assign o_rd_data = mem[i_addr];

reg		o_rd_valid;

always@(posedge i_clk or negedge i_reset) begin
	if(~i_reset)
		o_rd_valid <= 1'd0;
	else if(w_st_rdct)
		o_rd_valid <= 1'd1;
	else
		o_rd_valid <= 1'd0;
end

reg		o_wr_done;

always@(posedge i_clk or negedge i_reset) begin
	if(~i_reset)
		o_wr_done <= 1'd0;
	else if(i_wr_valid & (w_st_wrct) & ~w_rw_comp)
		o_wr_done <= 1'd1;
	else
		o_wr_done <= 1'd0;
end

reg		o_ack;

always@(posedge i_clk or negedge i_reset) begin
	if(~i_reset)
		o_ack <= 1'd0;
	else if(w_st_wrst | w_st_rdst)
		o_ack <= 1'd1;
	else
		o_ack <= 1'd0;
end

endmodule
