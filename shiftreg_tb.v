module shiftreg_tb();
reg PCLK;
reg PRESET_n;
reg ss_i;
reg send_data_i;
reg lsbfe_i;
reg cpha_i;
reg cpol_i;
reg miso_receive_sclk_i;
reg miso_receive_sclk0_i;
reg mosi_send_sclk_i;
reg mosi_send_sclk0_i;
reg [7:0] data_mosi_i;
reg miso_i;
reg receive_data_i;

wire mosi_o;
wire [7:0] data_miso_o;
integer i;

//Instantiate the baud generation
reg sclk_i, spiswai_i;
reg [2:0] sppr_i;
reg [2:0] spr_i;

wire [11:0] baudratedivisor_o;
wire pre_sclk_s;
reg [11:0] count_s;
reg[1:0] spi_mode_i;

//Instatiate the DUT generation
shiftreg DUT (PCLK,
PRESET_n, 
ss_i,
send_data_i,
lsbfe_i,
cpha_i,
cpol_i,
miso_receive_sclk_i,
miso_receive_sclk0_i,
mosi_send_sclk_i,
mosi_send_sclk0_i,
data_mosi_i,
miso_i,
receive_data_i,
mosi_o,
data_miso_o);

assign baudratedivisor_o = ((sppr_i + 1) * (2 ** (spr_i + 1)));
assign pre_sclk_s = cpol_i ? 1'b1 : 1'b0;

//Count logic and scslk logic 
always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
begin
count_s <= 12'b0;
sclk_i <= pre_sclk_s;
end
else if(!ss_i && !spiswai_i && (spi_mode_i == 2'b00 ||spi_mode_i == 2'b01))
begin
if(count_s == (baudratedivisor_o/2 - 1'b1))
begin
count_s <= 12'b0;
sclk_i <= ~sclk_i;
end
else
begin
sclk_i <= sclk_i;
count_s <= count_s + 1'b1;
end
end
else
begin
sclk_i <= pre_sclk_s;
count_s <= 12'b0;
end
end

//Generating MISO receive flag for both negedge_clk and posedge_clk respectvely
always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
begin
miso_receive_sclk0_i <= 1'b0;
miso_receive_sclk_i <= 1'b0;
end
else
begin
if((!cpha_i && cpol_i) || (cpha_i && !cpol_i))
begin
if(sclk_i)
begin
if(count_s == (baudratedivisor_o /2 - 1'b1))
miso_receive_sclk0_i <= 1'b1;
else
miso_receive_sclk0_i <= 1'b0;
end
else
miso_receive_sclk0_i <= 1'b0;
end
else if((!cpha_i && !cpol_i) || (cpha_i && cpol_i))
begin
if(!sclk_i)
begin
if(count_s == baudratedivisor_o/2 - 1'b1)
miso_receive_sclk_i <= 1'b1;
else
miso_receive_sclk_i <= 1'b0;
end
end
end
end

//Generating MOSI_send flag for both negedge_clk and posedge_clk respectively
always@(posedge PCLK or negedge PRESET_n)
begin
if(!PRESET_n)
begin
mosi_send_sclk0_i <= 1'b0;
mosi_send_sclk_i <= 1'b0;
end
else
begin
if((!cpha_i && cpol_i ) || (cpha_i && !cpol_i))
begin
if(sclk_i)
begin
if(count_s == (baudratedivisor_o/2 - 2'b10))
mosi_send_sclk0_i <= 1'b1;
else
mosi_send_sclk0_i <= 1'b0;
end
else
mosi_send_sclk0_i <= 1'b0;
end
else if((!cpha_i && !cpol_i) || (cpha_i && cpol_i)) 
begin
if(!sclk_i)
begin
if(count_s == baudratedivisor_o/2 - 2'b10)
mosi_send_sclk_i <= 1'b1;
else
mosi_send_sclk_i <= 1'b0;
end
else
mosi_send_sclk_i <= 1'b0;
end
end
end

//Clock generation
always
begin
#5;
PCLK = 0;
#5;
PCLK = ~PCLK;
end

//Task to initialize signals
task initialize;
begin
@(negedge PCLK)
//PCLK = 0;
PRESET_n = 0;
sppr_i = 1;
spr_i = 0;
ss_i = 1;
spiswai_i = 0;
spi_mode_i = 0;
send_data_i = 0;
lsbfe_i = 0;
cpha_i = 0;
cpol_i = 0;
miso_receive_sclk_i = 0;
miso_receive_sclk0_i = 0;
mosi_send_sclk_i = 0;
mosi_send_sclk0_i = 0;
miso_i = 0;
receive_data_i = 0;
data_mosi_i = 8'b0;
end
endtask

//Task to reset the DUT
task reset_DUT;
begin
#10;
PRESET_n = 0;
#10;
PRESET_n = 1;
end
endtask

//Task to send dat
task send_spi_data(input [7:0] spi_data, input lsb_first);
begin
send_data_i = 1;
data_mosi_i = spi_data;
lsbfe_i = lsb_first;
#10;
send_data_i = 0;
end
endtask

task send_miso_task;
begin
for(i = 0; i < 7; i = i + 1)
begin
@(negedge sclk_i)
miso_i = ~miso_i;
end
end
endtask

//Task to simulate SPI transfer
task spi_transfer(input ss_active, input mosi_ss_v_i, input mosi_ss0_v_i, input miso_rs_v_i, input miso_rs0_v_i);
begin
ss_i = ss_active;
mosi_send_sclk_i = mosi_ss_v_i;
mosi_send_sclk0_i = mosi_ss0_v_i;
miso_receive_sclk_i = miso_rs_v_i;
miso_receive_sclk0_i = miso_rs0_v_i;
#1000; //simulate for a period of time
ss_i = 1; //Deactivate slave select
end
endtask


initial
begin
//Initialize signals
initialize;

//Apply reset
reset_DUT;
fork
/*Test Case 1: normal data transfer with specific flag settings 
$display($time, "Starting Test Case 1");
send_spi_data(8'b00001010, 1); //Send 00001010 with LSB first
receive_data_i = 0;
send_miso_task;
cpol_i = 1'b0;
cpha_i = 1'b1;
spi_transfer(0, 1, 0, 1, 0);
receive_data_i = 1;
join

 //Test Case 2: Different flag settings
$display($time, "Starting Test Case 2");
send_spi_data(8'h3c, 0); //Send 0z3c with MSBfirst
spi_transfer(0, 0, 1, 0, 1);
cpol_i = 1'b0;
cpha_i = 1'b0;
join

//Test Case 3: Edge case with all flags high 
$display($time, "Starting with Test Case 3");
send_spi_data(8'hFF, 1); //Send 0xFF with LSB first 
spi_transfer(0, 1, 1, 1, 1);
cpol_i = 1'b1;
cpha_i = 1'b0;
join
*/

//Test Case 4: Edge case with all flags low
$display($time, "Starting Test Case 4");
send_spi_data(8'h00, 0); //Send 0x00 with MSB first
spi_transfer(0, 0, 0, 0, 0); 
cpol_i = 1;
cpha_i = 1;
lsbfe_i = 0;
join

//End simulation
$display($time, "All test cases completed");
end

initial
#5000 $finish;

endmodule
