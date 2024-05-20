////////////////////////////////////////////////////////////////////////////////////////////////////
// Block:sb_registers
//
// Author: Hager Walid
//
// Description: A set of registers that are used to link setup and configuration over the 
//                side band channel, sb_registrers is accessed by AT transactions and it's used when Other lane adapter requesting parameters.
//                our main register is REG12 "link Configuration" it's 3 bytes registers
//                it takes address from mem[80:78].it's also "Read only " register. At rst mem location is set to values of gen 4
//                when s_read is asserted we choose a certin s_address according to register we want to read on sb_register
//                when s_write is asserted we make sure that "read only " registers are not written at then write on specified address.
//
////////////////////////////////////////////////////////////////////////////////////////////////////


module sb_registers (
    input wire fsm_clk, rst, s_read, s_write,
    input wire [7:0] s_data, s_address,
    output reg [23:0] sb_read );
    
reg [7:0] mem [0:156];
integer i;

wire  [23:0] REG12; 
wire  [31:0] REG13,REG14,REG15,REG0,REG5,REG1,REG7,REG8,REG9;
wire  [511:0] REG18;
wire  [431:0] REG6;


assign REG0 = {mem[3],mem[2],mem[1],mem[0]};
assign REG1 = {mem[7],mem[6],mem[5],mem[4]};
assign REG5 = {mem[11],mem[10],mem[9],mem[8]};
assign REG7 = {mem[69],mem[68],mem[67],mem[66]};
assign REG8 = {mem[73],mem[72],mem[71],mem[70]};
assign REG9 =  {mem[77],mem[76],mem[75],mem[74]};
assign REG12 = {mem[80],mem[79],mem[78]};
assign REG13 = {mem[84],mem[83],mem[82],mem[81]};
assign REG14 = {mem[88],mem[87],mem[86],mem[85]};
assign REG15 =  {mem[92],mem[91],mem[90],mem[89]};
assign REG18 = mem[93];


    always @(posedge fsm_clk or negedge rst) begin
        if (!rst) begin
            mem[78] <= 8'b00000011; // reg 12
            mem[79] <= 8'b00110011; // 
            mem[80] <= 8'b00000101;
            mem[85] <= 8'b0;
            mem[86] <= 8'b0;
            mem[87] <= 8'b11000000;
            mem[88] <= 8'b11000000;
            sb_read <= 24'b0;
        end 
        else if (s_read && !s_write) begin 
            case(s_address)
                0  : sb_read <= REG0;
			          4  : sb_read <= REG1;
			          8 : sb_read <= REG5;
			          66 : sb_read <= REG7;
			          70 : sb_read <= REG8;
			          74 : sb_read <= REG9;	
                78 : sb_read <= REG12;
			         	81 : sb_read <= REG13;
                85 : sb_read <= REG14;
				        89 : sb_read <= REG15;
			          93 : sb_read <= REG18;
                default: sb_read <= 24'h000000;
            endcase
        end
        else if (s_write && !s_read) begin // write
            if (s_address == 78 | s_address == 79 | s_address ==80 | s_address ==81 | s_address == 82 | s_address ==89 | s_address ==90 | s_address ==91|s_address ==92| s_address ==0|s_address ==1|s_address ==2|s_address ==3|s_address ==4|s_address ==5|s_address ==6|s_address ==7) begin
                sb_read <= 24'b0;
			end	
			else begin
                mem[s_address] <= s_data;
                sb_read <= 24'b0;
			end	
        end
        else begin 
	        sb_read <= sb_read;
        end	
    end
endmodule

`default_nettype none
`resetall
