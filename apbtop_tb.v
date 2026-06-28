module apbtop_tb();
reg PCLK;
reg PRESETn;
reg PWRITE;
reg PSEL;
reg PENABLE;
reg miso;
reg [2:0] PADDR;
reg [7:0] PWDATA;
wire [7:0] PRDATA;
wire PREADY, PSLVERR, sclk, ss, mosi, spi_interrupt_request;
integer i;

apbtop DUT(PCLK, PRESETn, PSEL, PENABLE, PWRITE, miso, PADDR, PWDATA, PRDATA, PREADY, PSLVERR, sclk, ss, mosi, spi_interrupt_request);

initial
PCLK = 1'b0;
always
#5 PCLK = ~PCLK;

task reset;
begin
PRESETn = 11'b0;
#15;
PRESETn = 1'b1;
end
endtask

task miso_bits_lsb(input [7:0]miso_data);
begin
wait(~ss)
for(i = 0; i < 8; i = i + 1)
begin
@(posedge sclk)
miso = miso_data[i];
end
end
endtask

task miso_bits_msb(input [7:0]miso_data);
begin
wait(~ss)
for(i = 7; i > 0; i = i - 1)
begin
@(posedge sclk)
miso = miso_data[i];
end
end
endtask

task spi_config_reg(input [7:0]data, input [3:0]addr);
begin
@(posedge PCLK);
PADDR = addr;
PWDATA = data;
PSEL = 1'b1;
PENABLE = 1'b0;
PWRITE = 1'b1;
@(posedge PCLK);
PENABLE = 1'b1;
wait(!PREADY)
@(posedge PCLK);
PSEL = 1'b0;
PENABLE = 1'b0;
@(posedge PCLK);
end
endtask

task spi_config_SR(input [3:0] addr);
begin
@(negedge PCLK);
PADDR = addr;
PSEL = 1'b1;
PWRITE = 1'b0;
@(negedge PCLK);
PENABLE = 1'b1;
wait(!PREADY)
@(negedge PCLK);
PSEL = 1'b0;
PENABLE = 1'b0;
@(negedge PCLK);
end
endtask

/*
task write_registers(input[7:0] contr1_data, input [7:0] contr2_data, input [7:0] baudrate
begin
@(posedge PCLK)
PADDR = 3'b0; //Control Register
PWRITE = 1'b1; 
PSEL = 1'b1;
PENABLE = 1'b0;
PWDATA = contr1_data;

@(posedge PCLK)
PADDR = 3'b0;
PWRITE = 1'b1;
PSEL = 1'b1;
PENABLE = 1'b1;
PWDATA = contr1_data;

@(posedge PCLK)
wait(PREADY);
PENABLE = 1'b0;

@(posedge PCLK)
wait(PREADY);
PENABLE = 1'b0;

@(posedge PCLK)
PADDR = 3'b1; //Control register 2
PWRITE = 1'b1;
PSEL = 1'b1;
PENABLE = 1'b1;
PWDATA = contr1_data;

@(posedge PCLK)
PADDR = 3'b010; //Baud Rate Register
PWRITE = 1'b1;
PSEL = 1'b1;
PENABLE = 1'b1;
PWDATA = baud_data;

@(posedge PCLK)
wait(PREADY);
PENABLE = 1'b0;

end
endtask

//Write the value to the data register task_write_data_register(input [7:0] write_data);
begin
@(posedge PCLK)
PADDR = 3'b101;
PWRITE = 1'b1;
PSEL = 1'b1;
PWDATA = write_data;
@(posedge PCLK)
wait(PREADY);
PADDR = 3'b101;
PWRITE = 1'b0;
PSEL = 1'b0;
PENABLE = 1'b0;
PWDATA = write_data;
end
endtask

initial
begin
miso = 0;
reset;
//Write COntrol Register with Cphase 1, Cpol0, lsbfe 1-checked
//Write_registers(8'b1111_0101, 8'b1100_0001, 8'b0000_0001);
//Write Control Register with Cphase 1, Cpol0, lsbfe 0-checked
write registers(8'b1011_0000, 8_b1100_0001, 8'b0000_0001);
write_registers(8'b1011_0000, 8'b1100_0011, 8'b0000_0001);
write_registers(8'b1111_0000, 8'b1100_0001, 8'b0000_0001);
write_data_register(8'b10101010);
miso bits lsb(8'b10101010);
//miso_bitsmsb(8'b10101010);
end
*/

initial
begin
reset;
spi_config_reg(8'b1111_1110, 4'd0); //CR1
//spi_config_SR(4'b0011);
spi_config_reg(8'b0001_0000, 4'd1); //CR2
spi_config_reg(8'b0000_0001, 4'd2); //BR-4
//spi_config_SR(3'd3); //SR
//spi_config_reg(8'd68, 4'd5); //DR
//miso_bits_msb(8'b10010011);
spi_config_reg(8'hF0,4'd5);
miso_bits_msb(8'hA5);
end

initial
#2000 $finish;
endmodule


