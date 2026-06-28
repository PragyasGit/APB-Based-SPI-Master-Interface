module shiftreg(input PCLK, 
input PRESET_n, 
input ss_i, 
input send_data_i, //transfer data from data_reg to shift_reg
input lsbfe_i, 
input cpha_i, 
input cpol_i, 
input miso_receive_sclk_i, //Posedge miso sclk
input miso_receive_sclk0_i, //negedge miso sclk
input mosi_send_sclk_i, //Posedge mosi sclk
input mosi_send_sclk0_i, //negedge mosi sclk
input [7:0] data_mosi_i, //MOSI data from data_reg to shift_Reg
input miso_i,
input receive_data_i, //MISO data from shift_reg to data_reg

output reg mosi_o,
output [7:0] data_miso_o); //MISO data from shift_reg

//Internal Register
reg [7:0] shift_reg; //holds outgoing 8bit data to shift on MOSI
reg [7:0] temp_reg; //collects incoming 8 bit data from MISO
reg [2:0] count, count1; //counters for MOSI shifting (LSB first/MSB first)
reg [2:0] count2, count3; //counter for MISO shifting (LSB first/MSB first)

//Updating DATA_MISO
assign data_miso_o = receive_data_i ? temp_reg : 8'h00;

//Updating shift register signal
always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
shift_reg <= 8'h00;
else if(send_data_i)
shift_reg <= data_mosi_i;
else
shift_reg <= shift_reg;
end

//Updating MOSI signal in count and count1 wrt mosi_send_sclk(Positive edge) and mosi_send_sclk0_i(Negedge Edge)

always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
begin
mosi_o <= 1'b0;
count <= 3'd0;
count1 <= 3'd7;
end
else
begin
if(!ss_i)
begin
if((!cpha_i && cpol_i) || (cpha_i && !cpol_i)) //Negedge
begin
if(lsbfe_i) //count increment wrt mosi_send_sclk from 0 to 7
begin
if(count <= 3'd7)
begin
if(mosi_send_sclk0_i)
begin
mosi_o <= shift_reg[count];
count <= count + 1'b1;
end
end
else
count <= 3'd0;
end
else //count1 decrement wrt mosi_send_sclk0_i
begin
if(count1 >= 3'd0)
begin
if(mosi_send_sclk0_i)
begin
mosi_o <= shift_reg[count1];
count1 <= count1 - 1'b1;
end
end
else
count1 <= 3'd7;
end
end

else //posedge clock
begin
if(lsbfe_i) //count increment wrt mosi_send_sclk
begin
if(count <= 3'd7)
begin
if(mosi_send_sclk_i)
begin
mosi_o <= shift_reg[count];
count <= count + 1'b1;
end
end
else
count <= 3'd0;
end
else //count1 decrement wrt mosi_send_sclk
begin
if(count1 >= 3'd0)
begin
if(mosi_send_sclk_i)
begin
mosi_o <= shift_reg[count1];
count1 <= count1 - 1'b1;
end
end
else
count1 <= 3'd7;
end
end
end
end
end

//Updating MISO signal in count2 and count3 wrt mosi_receive_sclk(Positive Edge) and mosi_receive_sclk0(Negative Edge)

always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
begin
temp_reg <= 8'b0;
count2 <= 3'd0;
count3 <= 3'd7;
end
else
begin
if(!ss_i)
begin
if((!cpha_i & cpol_i) || (cpha_i && !cpol_i)) //Negedge
begin
if(lsbfe_i) //count2 increment wrt miso_receive_sclk0_i from 0 to 7
begin
if(count2 <= 3'd7)
begin
if(miso_receive_sclk0_i)
begin
temp_reg[count2] <= miso_i;
count2 <= count2 + 1'b1;
end
end
else
count2 <= 3'd0;
end
else //count3 decrement wrt miso_receive_sclk0_i from 7 to 0
begin
if(count3 >= 3'd0)
begin
if(miso_receive_sclk0_i) 
begin
temp_reg[count3] <= miso_i;
count3 <= count3 - 1'b1;
end
end
else
count3 <= 3'd7;
end
end
else //posedge clock
begin
if(lsbfe_i)
begin
if(count2 <= 3'd7)
begin
if(miso_receive_sclk_i)
begin
temp_reg[count2] <= miso_i;
count2 <= count2 + 1'b1;
end
end
else
count2 <= 3'd0;
end
else //count1 decrement wrt mosi_send_sclk
begin
if(count3 >= 3'd0)
begin
if(miso_receive_sclk_i)
begin
temp_reg[count3] <= miso_i;
count3 <= count3 - 1'b1;
end
end
else
count3 <= 3'd7;
end
end
end
end
end
endmodule
