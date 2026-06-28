module apbslaveinterface_tb();
reg PCLK, PRESET_n, PWRITE_i, PSEL_i, PENABLE_i, ss_i, receive_data_i, tip_i;
reg[2:0] PADDR_i;
reg[7:0] PWDATA_i;
reg [7:0] miso_data_i;

wire mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o;
wire send_data_o, spi_interrupt_request_o, PREADY_o, PSLVERR_o;
wire [7:0] PRDATA_o;
wire [2:0] sppr_o;
wire [2:0] spr_o;
wire [7:0] mosi_data_o;
wire [1:0] spi_mode_o;

//DUT Instantiation
apbslaveinterface DUT(PCLK, PRESET_n, PADDR_i, PWRITE_i, PSEL_i, PENABLE_i, PWDATA_i, ss_i, miso_data_i, receive_data_i, tip_i, PRDATA_o, mstr_o, cpol_o, cpha_o, lsbfe_o, spiswai_o, sppr_o, spr_o, spi_interrupt_request_o, PREADY_o, send_data_o, mosi_data_o, spi_mode_o);

//Clock Generation
initial PCLK = 0;
always #5 PCLK = ~PCLK;

//Reset Task
task reset;
begin
PRESET_n = 0;
#10;
PRESET_n = 1;
end
endtask

task initialize;
begin
@(negedge PCLK);
PADDR_i = 3'b000;
PWRITE_i = 0;
PSEL_i = 1;
PENABLE_i = 0;
ss_i = 0;
miso_data_i = 8'h00;
tip_i = 1'b0;
PWDATA_i = 8'h00;
end
endtask

task spi_cr1_write;
begin
@(posedge PCLK);
PADDR_i = 3'b000; //Address for SPI_CR1
PWRITE_i = 1'b1; //Write Operation
PSEL_i = 1'b1; //Select
PENABLE_i = 1'b0; //Not enable yet
PWDATA_i = 8'b01010110; //Write ddata to SPI_CR1
@(posedge PCLK);
PENABLE_i = 1'b1; //Enable
@(posedge PCLK);
PENABLE_i = 1'b0;
PSEL_i = 0; //Deselect
end
endtask

task spi_cr2_write;
begin
@(posedge PCLK);
PADDR_i = 3'b001; //Address for SPI_CR2
PWRITE_i = 1'b1; //Write Operation
PSEL_i = 1'b1; //Select
PENABLE_i = 1'b0; //Not enabled yet
PWDATA_i = 8'b1101_0001; //Write data to SPI_CR2
@(posedge PCLK);
PENABLE_i = 1'b1; //Enable
@(posedge PCLK);
PENABLE_i = 1'b0;
PSEL_i = 0; //Deselect
end
endtask

task spi_cr1_read;
begin
@(posedge PCLK);
PADDR_i = 3'b000; //Address for SPI_CR1
PWRITE_i = 1'b0;
PSEL_i = 1'b1;
PENABLE_i = 1'b0;
@(posedge PCLK);
PENABLE_i = 1'b1;
@(posedge PCLK);
PENABLE_i = 1'b0;
@(posedge PCLK);
PSEL_i = 0;
end
endtask

task spi_dr_write;
begin
@(posedge PCLK);
PADDR_i = 3'b101; //Address for SPI_DR
PWRITE_i = 1'b1; //Write Operation
PSEL_i = 1'b1; //Select
PENABLE_i = 1'b0; //Not enable yet
PWDATA_i = 8'h55; //Write data to SPI_DR
@(posedge PCLK);
PENABLE_i = 1'b1; //Enable
tip_i = 1; //to generate slave error
@(posedge PCLK);
PENABLE_i = 1'b0;
PSEL_i = 0; //Deselect
end
endtask

task spi_sr_read;
begin
@(posedge PCLK);
PADDR_i = 3'b011; //Address for SPI_CR1
PWRITE_i = 1'b0;
PSEL_i = 1'b1; //Select
PENABLE_i = 1'b0; //Mot enabled yet
@(posedge PCLK);
PENABLE_i = 1'b1; //Enable
@(posedge PCLK);
PENABLE_i = 1'b0;
@(posedge PCLK);
PSEL_i = 0;
end
endtask

task spi_br_write;
begin
@(posedge PCLK);
PADDR_i = 3'b010; //Address for SIP_BR
PWRITE_i = 1'b1; //Write operation
PSEL_i = 1'b1; //Select
PENABLE_i = 1'b0; //Not enable yet
PWDATA_i = 8'h1; //Write data to SPI_BR
@(posedge PCLK);
PENABLE_i = 1'b1; //Enable
@(posedge PCLK);
PENABLE_i = 1'b0;
PSEL_i = 0; //Deselect
end
endtask

task interrupt;
begin
//spiswai = 1'b1; //Enable SPI software interrupt
//#10;
receive_data_i = 1'b1;
miso_data_i = 8'hAB;
ss_i = 0;
#10;
//receive_data = 1'b0;
end
endtask

task spi_dr_read;
begin
@(posedge PCLK);
PADDR_i = 3'b101; //Address for SPI_CR1
PWRITE_i = 1'b0;
PSEL_i = 1'b1; //Select
PENABLE_i = 1'b0; //Not enable yet
@(posedge PCLK);
PENABLE_i = 1'b1; //Enable
@(posedge PCLK);
PENABLE_i = 1'b0;
@(posedge PCLK);
PSEL_i = 0;
end
endtask

task spi_br_read;
begin
@(posedge PCLK);
PADDR_i = 3'b010; //Address for SPI_CR1
PWRITE_i = 1'b0;
PSEL_i = 1'b1; //Select
PENABLE_i = 1'b0; //Not enable yet
@(posedge PCLK);
PENABLE_i = 1'b1; //Enable
@(posedge PCLK)
PENABLE_i = 1'b0;
@(posedge PCLK);
PSEL_i = 0;
end
endtask

initial
begin
initialize;
reset;
//spi_cr1_write;
//spi_cr2_write;
//spi_br_write;
spi_dr_write;
//spi_cr1_read;
/*spi_dr_read;
spi_cr1_read;
spi_sr_read;
interrupt; */
end

initial
begin
#1000 $finish;
end

endmodule
