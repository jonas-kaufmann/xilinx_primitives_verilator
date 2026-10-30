`ifdef verilator3
`else
`timescale 1 ps / 1 ps
`endif
//
// URAM288 primitive for Xilinx FPGAs
// Compatible with Verilator tool (www.veripool.org)
// Copyright (c) 2026 Jonas Kaufmann
// License : BSD
//

/* verilator coverage_off */
/* verilator tracing_off */
module URAM288
#(
`ifdef XIL_TIMING
    parameter         LOC                      = "UNPLACED",
`endif
    parameter integer AUTO_SLEEP_LATENCY       = 8,
    parameter integer AVG_CONS_INACTIVE_CYCLES = 10,
    parameter         BWE_MODE_A               = "PARITY_INTERLEAVED",
    parameter         BWE_MODE_B               = "PARITY_INTERLEAVED",
    parameter         CASCADE_ORDER_A          = "NONE",
    parameter         CASCADE_ORDER_B          = "NONE",
    parameter         EN_AUTO_SLEEP_MODE       = "FALSE",
    parameter         EN_ECC_RD_A              = "FALSE",
    parameter         EN_ECC_RD_B              = "FALSE",
    parameter         EN_ECC_WR_A              = "FALSE",
    parameter         EN_ECC_WR_B              = "FALSE",
    parameter         IREG_PRE_A               = "FALSE",
    parameter         IREG_PRE_B               = "FALSE",
    parameter   [0:0] IS_CLK_INVERTED          = 1'b0,
    parameter   [0:0] IS_EN_A_INVERTED         = 1'b0,
    parameter   [0:0] IS_EN_B_INVERTED         = 1'b0,
    parameter   [0:0] IS_RDB_WR_A_INVERTED     = 1'b0,
    parameter   [0:0] IS_RDB_WR_B_INVERTED     = 1'b0,
    parameter   [0:0] IS_RST_A_INVERTED        = 1'b0,
    parameter   [0:0] IS_RST_B_INVERTED        = 1'b0,
    parameter         MATRIX_ID                = "NONE",
    parameter integer NUM_UNIQUE_SELF_ADDR_A   = 1,
    parameter integer NUM_UNIQUE_SELF_ADDR_B   = 1,
    parameter integer NUM_URAM_IN_MATRIX       = 1,
    parameter         OREG_A                   = "FALSE",
    parameter         OREG_B                   = "FALSE",
    parameter         OREG_ECC_A               = "FALSE",
    parameter         OREG_ECC_B               = "FALSE",
    parameter         REG_CAS_A                = "FALSE",
    parameter         REG_CAS_B                = "FALSE",
    parameter         RST_MODE_A               = "SYNC",
    parameter         RST_MODE_B               = "SYNC",
    parameter  [10:0] SELF_ADDR_A              = 11'h000,
    parameter  [10:0] SELF_ADDR_B              = 11'h000,
    parameter  [10:0] SELF_MASK_A              = 11'h7FF,
    parameter  [10:0] SELF_MASK_B              = 11'h7FF,
    parameter         USE_EXT_CE_A             = "FALSE",
    parameter         USE_EXT_CE_B             = "FALSE"
)
(
    output [22:0] CAS_OUT_ADDR_A,
    output [22:0] CAS_OUT_ADDR_B,
    output  [8:0] CAS_OUT_BWE_A,
    output  [8:0] CAS_OUT_BWE_B,
    output        CAS_OUT_DBITERR_A,
    output        CAS_OUT_DBITERR_B,
    output [71:0] CAS_OUT_DIN_A,
    output [71:0] CAS_OUT_DIN_B,
    output [71:0] CAS_OUT_DOUT_A,
    output [71:0] CAS_OUT_DOUT_B,
    output        CAS_OUT_EN_A,
    output        CAS_OUT_EN_B,
    output        CAS_OUT_RDACCESS_A,
    output        CAS_OUT_RDACCESS_B,
    output        CAS_OUT_RDB_WR_A,
    output        CAS_OUT_RDB_WR_B,
    output        CAS_OUT_SBITERR_A,
    output        CAS_OUT_SBITERR_B,
    output        DBITERR_A,
    output        DBITERR_B,
    output [71:0] DOUT_A,
    output [71:0] DOUT_B,
    output        RDACCESS_A,
    output        RDACCESS_B,
    output        SBITERR_A,
    output        SBITERR_B,

    input  [22:0] ADDR_A,
    input  [22:0] ADDR_B,
    input   [8:0] BWE_A,
    input   [8:0] BWE_B,
    input  [22:0] CAS_IN_ADDR_A,
    input  [22:0] CAS_IN_ADDR_B,
    input   [8:0] CAS_IN_BWE_A,
    input   [8:0] CAS_IN_BWE_B,
    input         CAS_IN_DBITERR_A,
    input         CAS_IN_DBITERR_B,
    input  [71:0] CAS_IN_DIN_A,
    input  [71:0] CAS_IN_DIN_B,
    input  [71:0] CAS_IN_DOUT_A,
    input  [71:0] CAS_IN_DOUT_B,
    input         CAS_IN_EN_A,
    input         CAS_IN_EN_B,
    input         CAS_IN_RDACCESS_A,
    input         CAS_IN_RDACCESS_B,
    input         CAS_IN_RDB_WR_A,
    input         CAS_IN_RDB_WR_B,
    input         CAS_IN_SBITERR_A,
    input         CAS_IN_SBITERR_B,
    input         CLK,
    input  [71:0] DIN_A,
    input  [71:0] DIN_B,
    input         EN_A,
    input         EN_B,
    input         INJECT_DBITERR_A,
    input         INJECT_DBITERR_B,
    input         INJECT_SBITERR_A,
    input         INJECT_SBITERR_B,
    input         OREG_CE_A,
    input         OREG_CE_B,
    input         OREG_ECC_CE_A,
    input         OREG_ECC_CE_B,
    input         RDB_WR_A,
    input         RDB_WR_B,
    input         RST_A,
    input         RST_B,
    input         SLEEP
);

    reg [71:0] mem [0:4095];
    integer init_addr;
    initial begin
        for (init_addr = 0; init_addr < 4096; init_addr = init_addr + 1)
            mem[init_addr] = 72'b0;
        if (EN_AUTO_SLEEP_MODE != "FALSE" || EN_ECC_RD_A != "FALSE" ||
                EN_ECC_RD_B != "FALSE" || EN_ECC_WR_A != "FALSE" ||
                EN_ECC_WR_B != "FALSE" || OREG_ECC_A != "FALSE" || OREG_ECC_B != "FALSE")
            $fatal(1, "%m: sleep and ECC configurations are unsupported");
        if ({IS_CLK_INVERTED, IS_EN_A_INVERTED, IS_EN_B_INVERTED,
                  IS_RDB_WR_A_INVERTED, IS_RDB_WR_B_INVERTED,
                  IS_RST_A_INVERTED, IS_RST_B_INVERTED} !== 7'b0)
            $fatal(1, "%m: inverted controls are unsupported");
        if (RST_MODE_A != "SYNC" || RST_MODE_B != "SYNC")
            $fatal(1, "%m: only synchronous reset is supported");
`ifdef XIL_TIMING
        $fatal(1, "%m: timing simulation is unsupported");
`endif
    end

    function [71:0] write_mask;
        input [8:0] bwe;
        input independent;
        integer lane;
        begin
            for (lane = 0; lane < 8; lane = lane + 1)
                write_mask[lane * 8 +: 8] = {8{bwe[lane]}};
            write_mask[71:64] = independent ? {8{bwe[8]}} : bwe[7:0];
        end
    endfunction

    localparam CAS_IN_A = CASCADE_ORDER_A == "MIDDLE" || CASCADE_ORDER_A == "LAST";
    localparam CAS_OUT_A = CASCADE_ORDER_A == "FIRST" || CASCADE_ORDER_A == "MIDDLE";
    localparam INPUT_REG_A = CAS_IN_A ? REG_CAS_A == "TRUE" : IREG_PRE_A == "TRUE";
    initial begin
        if (CASCADE_ORDER_A != "NONE" && CASCADE_ORDER_A != "FIRST" &&
                CASCADE_ORDER_A != "MIDDLE" && CASCADE_ORDER_A != "LAST")
            $fatal(1, "%m: unsupported CASCADE_ORDER_A");
        if ((IREG_PRE_A != "FALSE" && IREG_PRE_A != "TRUE") ||
                (OREG_A != "FALSE" && OREG_A != "TRUE") ||
                (REG_CAS_A != "FALSE" && REG_CAS_A != "TRUE") ||
                (USE_EXT_CE_A != "FALSE" && USE_EXT_CE_A != "TRUE"))
            $fatal(1, "%m: invalid pipeline configuration on port A");
        if (BWE_MODE_A != "PARITY_INDEPENDENT" && BWE_MODE_A != "PARITY_INTERLEAVED")
            $fatal(1, "%m: unsupported BWE_MODE_A");
    end

    wire [22:0] addr_A_src = CAS_IN_A ? CAS_IN_ADDR_A : ADDR_A;
    wire [8:0] bwe_A_src = CAS_IN_A ? CAS_IN_BWE_A : BWE_A;
    wire [71:0] din_A_src = CAS_IN_A ? CAS_IN_DIN_A : DIN_A;
    wire en_A_src = CAS_IN_A ? CAS_IN_EN_A : EN_A;
    wire wr_A_src = CAS_IN_A ? CAS_IN_RDB_WR_A : RDB_WR_A;
    reg [22:0] addr_A_reg = 0;
    reg [8:0] bwe_A_reg = 0;
    reg [71:0] din_A_reg = 0;
    reg en_A_reg = 0, wr_A_reg = 0;
    wire [22:0] addr_A = INPUT_REG_A ? addr_A_reg : addr_A_src;
    wire [8:0] bwe_A = INPUT_REG_A ? bwe_A_reg : bwe_A_src;
    wire [71:0] din_A = INPUT_REG_A ? din_A_reg : din_A_src;
    wire en_A = INPUT_REG_A ? en_A_reg : en_A_src;
    wire wr_A = INPUT_REG_A ? wr_A_reg : wr_A_src;
    wire selected_A = en_A && (((addr_A[22:12] ^ SELF_ADDR_A) & ~SELF_MASK_A) == 0);
    wire read_A = selected_A && !wr_A;
    wire [71:0] mask_A = write_mask(bwe_A, BWE_MODE_A == "PARITY_INDEPENDENT");
    reg [71:0] data_A_lat = 0, data_A_reg = 0;
    reg valid_A_lat = 0, valid_A_reg = 0;
    reg data_A_enable = 0, rst_A_sync = 0;
    reg [71:0] cas_data_A_reg = 0;
    reg cas_valid_A_reg = 0;
    reg local_selected_A_reg = 0;
    wire [71:0] cas_data_A = REG_CAS_A == "TRUE" ? cas_data_A_reg : CAS_IN_DOUT_A;
    wire cas_valid_A = REG_CAS_A == "TRUE" ? cas_valid_A_reg : CAS_IN_RDACCESS_A;
    wire local_valid_A = OREG_A == "TRUE" ? valid_A_reg : valid_A_lat;
    wire local_selected_A = (cas_valid_A || local_valid_A) ? local_valid_A : local_selected_A_reg;
    wire [71:0] local_data_A = !data_A_enable ? 72'b0 :
            (OREG_A == "TRUE" ? data_A_reg : data_A_lat);
    assign DOUT_A = rst_A_sync ? 72'b0 :
            (CAS_IN_A && !local_selected_A ? cas_data_A : local_data_A);
    assign RDACCESS_A = !rst_A_sync &&
            (CAS_IN_A && !local_selected_A ? cas_valid_A : local_valid_A);
    assign CAS_OUT_DOUT_A = DOUT_A;
    assign CAS_OUT_RDACCESS_A = RDACCESS_A;
    assign SBITERR_A = 1'b0;
    assign DBITERR_A = 1'b0;
    assign CAS_OUT_SBITERR_A = 1'b0;
    assign CAS_OUT_DBITERR_A = 1'b0;
    assign CAS_OUT_ADDR_A = CAS_OUT_A ? addr_A : 23'b0;
    assign CAS_OUT_BWE_A = CAS_OUT_A ? bwe_A : 9'b0;
    assign CAS_OUT_DIN_A = CAS_OUT_A ? din_A : 72'b0;
    assign CAS_OUT_EN_A = CAS_OUT_A && en_A;
    assign CAS_OUT_RDB_WR_A = CAS_OUT_A && wr_A;

    always @(posedge CLK) begin
        en_A_reg <= en_A_src;
        if (en_A_src) begin
            addr_A_reg <= addr_A_src;
            bwe_A_reg <= bwe_A_src;
            din_A_reg <= din_A_src;
            wr_A_reg <= wr_A_src;
        end
        rst_A_sync <= RST_A;
        if (RST_A)
            begin
            data_A_reg <= 0;
            valid_A_lat <= 0;
            valid_A_reg <= 0;
            data_A_enable <= 0;
            cas_data_A_reg <= 0;
            cas_valid_A_reg <= 0;
            local_selected_A_reg <= 0;
        end else begin
            valid_A_lat <= read_A;
            valid_A_reg <= valid_A_lat && (USE_EXT_CE_A == "FALSE" || OREG_CE_A);
            if ((OREG_A == "TRUE" ? valid_A_lat : read_A))
                data_A_enable <= 1;
            if (OREG_A == "TRUE" &&
                    (USE_EXT_CE_A == "TRUE" ? OREG_CE_A : (selected_A || valid_A_lat)))
                data_A_reg <= data_A_lat;
            if (CAS_IN_A && REG_CAS_A == "TRUE") begin
                cas_valid_A_reg <= CAS_IN_RDACCESS_A;
                if (CAS_IN_RDACCESS_A)
                    cas_data_A_reg <= CAS_IN_DOUT_A;
            end
            local_selected_A_reg <= local_selected_A;
        end
    end

    localparam CAS_IN_B = CASCADE_ORDER_B == "MIDDLE" || CASCADE_ORDER_B == "LAST";
    localparam CAS_OUT_B = CASCADE_ORDER_B == "FIRST" || CASCADE_ORDER_B == "MIDDLE";
    localparam INPUT_REG_B = CAS_IN_B ? REG_CAS_B == "TRUE" : IREG_PRE_B == "TRUE";
    initial begin
        if (CASCADE_ORDER_B != "NONE" && CASCADE_ORDER_B != "FIRST" &&
                CASCADE_ORDER_B != "MIDDLE" && CASCADE_ORDER_B != "LAST")
            $fatal(1, "%m: unsupported CASCADE_ORDER_B");
        if ((IREG_PRE_B != "FALSE" && IREG_PRE_B != "TRUE") ||
                (OREG_B != "FALSE" && OREG_B != "TRUE") ||
                (REG_CAS_B != "FALSE" && REG_CAS_B != "TRUE") ||
                (USE_EXT_CE_B != "FALSE" && USE_EXT_CE_B != "TRUE"))
            $fatal(1, "%m: invalid pipeline configuration on port B");
        if (BWE_MODE_B != "PARITY_INDEPENDENT" && BWE_MODE_B != "PARITY_INTERLEAVED")
            $fatal(1, "%m: unsupported BWE_MODE_B");
    end

    wire [22:0] addr_B_src = CAS_IN_B ? CAS_IN_ADDR_B : ADDR_B;
    wire [8:0] bwe_B_src = CAS_IN_B ? CAS_IN_BWE_B : BWE_B;
    wire [71:0] din_B_src = CAS_IN_B ? CAS_IN_DIN_B : DIN_B;
    wire en_B_src = CAS_IN_B ? CAS_IN_EN_B : EN_B;
    wire wr_B_src = CAS_IN_B ? CAS_IN_RDB_WR_B : RDB_WR_B;
    reg [22:0] addr_B_reg = 0;
    reg [8:0] bwe_B_reg = 0;
    reg [71:0] din_B_reg = 0;
    reg en_B_reg = 0, wr_B_reg = 0;
    wire [22:0] addr_B = INPUT_REG_B ? addr_B_reg : addr_B_src;
    wire [8:0] bwe_B = INPUT_REG_B ? bwe_B_reg : bwe_B_src;
    wire [71:0] din_B = INPUT_REG_B ? din_B_reg : din_B_src;
    wire en_B = INPUT_REG_B ? en_B_reg : en_B_src;
    wire wr_B = INPUT_REG_B ? wr_B_reg : wr_B_src;
    wire selected_B = en_B && (((addr_B[22:12] ^ SELF_ADDR_B) & ~SELF_MASK_B) == 0);
    wire read_B = selected_B && !wr_B;
    wire [71:0] mask_B = write_mask(bwe_B, BWE_MODE_B == "PARITY_INDEPENDENT");
    reg [71:0] data_B_lat = 0, data_B_reg = 0;
    reg valid_B_lat = 0, valid_B_reg = 0;
    reg data_B_enable = 0, rst_B_sync = 0;
    reg [71:0] cas_data_B_reg = 0;
    reg cas_valid_B_reg = 0;
    reg local_selected_B_reg = 0;
    wire [71:0] cas_data_B = REG_CAS_B == "TRUE" ? cas_data_B_reg : CAS_IN_DOUT_B;
    wire cas_valid_B = REG_CAS_B == "TRUE" ? cas_valid_B_reg : CAS_IN_RDACCESS_B;
    wire local_valid_B = OREG_B == "TRUE" ? valid_B_reg : valid_B_lat;
    wire local_selected_B = (cas_valid_B || local_valid_B) ? local_valid_B : local_selected_B_reg;
    wire [71:0] local_data_B = !data_B_enable ? 72'b0 :
            (OREG_B == "TRUE" ? data_B_reg : data_B_lat);
    assign DOUT_B = rst_B_sync ? 72'b0 :
            (CAS_IN_B && !local_selected_B ? cas_data_B : local_data_B);
    assign RDACCESS_B = !rst_B_sync &&
            (CAS_IN_B && !local_selected_B ? cas_valid_B : local_valid_B);
    assign CAS_OUT_DOUT_B = DOUT_B;
    assign CAS_OUT_RDACCESS_B = RDACCESS_B;
    assign SBITERR_B = 1'b0;
    assign DBITERR_B = 1'b0;
    assign CAS_OUT_SBITERR_B = 1'b0;
    assign CAS_OUT_DBITERR_B = 1'b0;
    assign CAS_OUT_ADDR_B = CAS_OUT_B ? addr_B : 23'b0;
    assign CAS_OUT_BWE_B = CAS_OUT_B ? bwe_B : 9'b0;
    assign CAS_OUT_DIN_B = CAS_OUT_B ? din_B : 72'b0;
    assign CAS_OUT_EN_B = CAS_OUT_B && en_B;
    assign CAS_OUT_RDB_WR_B = CAS_OUT_B && wr_B;

    always @(posedge CLK) begin
        en_B_reg <= en_B_src;
        if (en_B_src) begin
            addr_B_reg <= addr_B_src;
            bwe_B_reg <= bwe_B_src;
            din_B_reg <= din_B_src;
            wr_B_reg <= wr_B_src;
        end
        rst_B_sync <= RST_B;
        if (RST_B)
            begin
            data_B_reg <= 0;
            valid_B_lat <= 0;
            valid_B_reg <= 0;
            data_B_enable <= 0;
            cas_data_B_reg <= 0;
            cas_valid_B_reg <= 0;
            local_selected_B_reg <= 0;
        end else begin
            valid_B_lat <= read_B;
            valid_B_reg <= valid_B_lat && (USE_EXT_CE_B == "FALSE" || OREG_CE_B);
            if ((OREG_B == "TRUE" ? valid_B_lat : read_B))
                data_B_enable <= 1;
            if (OREG_B == "TRUE" &&
                    (USE_EXT_CE_B == "TRUE" ? OREG_CE_B : (selected_B || valid_B_lat)))
                data_B_reg <= data_B_lat;
            if (CAS_IN_B && REG_CAS_B == "TRUE") begin
                cas_valid_B_reg <= CAS_IN_RDACCESS_B;
                if (CAS_IN_RDACCESS_B)
                    cas_data_B_reg <= CAS_IN_DOUT_B;
            end
            local_selected_B_reg <= local_selected_B;
        end
    end

    always @(posedge CLK) begin
        if (SLEEP === 1'b1 || INJECT_SBITERR_A === 1'b1 || INJECT_SBITERR_B === 1'b1 ||
                INJECT_DBITERR_A === 1'b1 || INJECT_DBITERR_B === 1'b1)
            $fatal(1, "%m: sleep and error injection controls are unsupported");
        if ((CAS_IN_A && (CAS_IN_SBITERR_A === 1'b1 || CAS_IN_DBITERR_A === 1'b1)) ||
                (CAS_IN_B && (CAS_IN_SBITERR_B === 1'b1 || CAS_IN_DBITERR_B === 1'b1)))
            $fatal(1, "%m: cascade ECC error controls are unsupported");
        if (selected_A && wr_A)
            mem[addr_A[11:0]] = (mem[addr_A[11:0]] & ~mask_A) | (din_A & mask_A);
        if (RST_A)
            data_A_lat <= 0;
        else if (read_A)
            data_A_lat <= mem[addr_A[11:0]];
        if (selected_B && wr_B)
            mem[addr_B[11:0]] = (mem[addr_B[11:0]] & ~mask_B) | (din_B & mask_B);
        if (RST_B)
            data_B_lat <= 0;
        else if (read_B)
            data_B_lat <= mem[addr_B[11:0]];
    end
endmodule
