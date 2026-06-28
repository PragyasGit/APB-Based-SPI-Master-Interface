module apbtop(input PCLK, 
input PRESETn,
input PSEL, 
input PENABLE,
input PWRITE,
input miso,
input [2:0] PADDR,
input [7:0] PWDATA,
output [7:0] PRDATA,
output PREADY, PSLVERR, sclk, ss, mosi, spi_interrupt_request);

wire [2:0] spr, sppr;
wire [1:0] spi_mode;
wire [11:0] baudratedivisor;
wire [7:0] data_mosi, data_miso;
wire cpol, cpha, tip, mstr_o;
wire spiswai, send_data, receive_data, lsbfe;
wire miso_receive_sclk, miso_receive_sclk0, mosi_send_sclk, mosi_send_sclk0;

baudrategen A1(.PCLK(PCLK), .PRESET_n(PRESETn), .spiswai_i(spiswai), .cpol_i(cpol), .cpha_i(cpha), .ss_i(ss), .sppr_i(spr), .spr_i(sppr), .spi_mode_i(spi_mode), .sclk_o(sclk), .miso_receive_sclk_o(miso_receive_sclk), .miso_receive_sclk0_o(miso_receive_sclk0), .mosi_send_sclk_o(mosi_send_sclk), .mosi_send_sclk0_o(mosi_send_sclk0), .baudratedivisor_o(baudratedivisor));

slaveselect B1(.PCLK(PCLK), .PRESET_n(PRESETn), .send_data_i(send_data), .mstr_i(mstr_o), .spiswai_i(spiswai), .spi_mode_i(spi_mode), .baudratedivisor_i(baudratedivisor), .receive_data_o(receive_data), .ss_o(ss), .tip_o(tip));

shiftreg C1(.PCLK(PCLK), .PRESET_n(PRESETn), .ss_i(ss), .send_data_i(send_data), .lsbfe_i(lsbfe), .cpha_i(cpha), .cpol_i(cpol), .miso_receive_sclk_i(miso_receive_sclk), .miso_receive_sclk0_i(miso_receive_sclk0), .mosi_send_sclk_i(mosi_send_sclk), .mosi_send_sclk0_i(mosi_send_sclk0), .data_mosi_i(data_mosi), .miso_i(miso), .receive_data_i(receive_data), .mosi_o(mosi), .data_miso_o(data_miso));

apbslaveinterface D1(.PCLK(PCLK), .PRESET_n(PRESETn), .PADDR_i(PADDR), .PWRITE_i(PWRITE), .PSEL_i(PSEL), .PENABLE_i(PENABLE), .PWDATA_i(PWDATA), .ss_i(ss), .miso_data_i(data_miso), .receive_data_i(receive_data), .tip_i(tip), .PRDATA_o(PRDATA), .mstr_o(mstr_o), .cpol_o(cpol), .cpha_o(cpha), .lsbfe_o(lsbfe), .spiswai_o(spiswai), .sppr_o(sppr), .spr_o(spr), .spi_interrupt_request_o(spi_interrupt_request), .PREADY_o(PREADY), .PSLVERR_o(PSLVERR), .send_data_o(send_data), .mosi_data_o(data_mosi), .spi_mode_o(spi_mode));

endmodule
