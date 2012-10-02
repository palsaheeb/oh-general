---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Vectored Interrupt Controller (VIC)
---------------------------------------------------------------------------------------
-- File           : wb_slave_vic.vhd
-- Author         : auto-generated by wbgen2 from wb_slave_vic.wb
-- Created        : Thu Sep 27 16:06:58 2012
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wb_slave_vic.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wbgen2_pkg.all;

entity wb_slave_vic is
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(5 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
-- Port for BIT field: 'VIC Enable' in reg: 'VIC Control Register'
    vic_ctl_enable_o                         : out    std_logic;
-- Port for BIT field: 'VIC output polarity' in reg: 'VIC Control Register'
    vic_ctl_pol_o                            : out    std_logic;
-- Port for BIT field: 'Emulate Edge sensitive output' in reg: 'VIC Control Register'
    vic_ctl_emu_edge_o                       : out    std_logic;
-- Port for std_logic_vector field: 'Emulated Edge pulse timer' in reg: 'VIC Control Register'
    vic_ctl_emu_len_o                        : out    std_logic_vector(15 downto 0);
-- Port for std_logic_vector field: 'Raw interrupt status' in reg: 'Raw Interrupt Status Register'
    vic_risr_i                               : in     std_logic_vector(31 downto 0);
-- Ports for PASS_THROUGH field: 'Enable IRQ' in reg: 'Interrupt Enable Register'
    vic_ier_o                                : out    std_logic_vector(31 downto 0);
    vic_ier_wr_o                             : out    std_logic;
-- Ports for PASS_THROUGH field: 'Disable IRQ' in reg: 'Interrupt Disable Register'
    vic_idr_o                                : out    std_logic_vector(31 downto 0);
    vic_idr_wr_o                             : out    std_logic;
-- Port for std_logic_vector field: 'IRQ disabled/enabled' in reg: 'Interrupt Mask Register'
    vic_imr_i                                : in     std_logic_vector(31 downto 0);
-- Port for std_logic_vector field: 'Vector Address' in reg: 'Vector Address Register'
    vic_var_i                                : in     std_logic_vector(31 downto 0);
-- Ports for PASS_THROUGH field: 'SWI interrupt mask' in reg: 'Software Interrupt Register'
    vic_swir_o                               : out    std_logic_vector(31 downto 0);
    vic_swir_wr_o                            : out    std_logic;
-- Ports for PASS_THROUGH field: 'End of Interrupt' in reg: 'End Of Interrupt Acknowledge Register'
    vic_eoir_o                               : out    std_logic_vector(31 downto 0);
    vic_eoir_wr_o                            : out    std_logic;
-- Ports for RAM: Interrupt Vector Table
    vic_ivt_ram_addr_i                       : in     std_logic_vector(4 downto 0);
-- Read data output
    vic_ivt_ram_data_o                       : out    std_logic_vector(31 downto 0);
-- Read strobe input (active high)
    vic_ivt_ram_rd_i                         : in     std_logic
  );
end wb_slave_vic;

architecture syn of wb_slave_vic is

signal vic_ctl_enable_int                       : std_logic      ;
signal vic_ctl_pol_int                          : std_logic      ;
signal vic_ctl_emu_edge_int                     : std_logic      ;
signal vic_ctl_emu_len_int                      : std_logic_vector(15 downto 0);
signal vic_ivt_ram_rddata_int                   : std_logic_vector(31 downto 0);
signal vic_ivt_ram_rd_int                       : std_logic      ;
signal vic_ivt_ram_wr_int                       : std_logic      ;
signal ack_sreg                                 : std_logic_vector(9 downto 0);
signal rddata_reg                               : std_logic_vector(31 downto 0);
signal wrdata_reg                               : std_logic_vector(31 downto 0);
signal bwsel_reg                                : std_logic_vector(3 downto 0);
signal rwaddr_reg                               : std_logic_vector(5 downto 0);
signal ack_in_progress                          : std_logic      ;
signal wr_int                                   : std_logic      ;
signal rd_int                                   : std_logic      ;
signal allones                                  : std_logic_vector(31 downto 0);
signal allzeros                                 : std_logic_vector(31 downto 0);

begin
-- Some internal signals assignments. For (foreseen) compatibility with other bus standards.
  wrdata_reg <= wb_dat_i;
  bwsel_reg <= wb_sel_i;
  rd_int <= wb_cyc_i and (wb_stb_i and (not wb_we_i));
  wr_int <= wb_cyc_i and (wb_stb_i and wb_we_i);
  allones <= (others => '1');
  allzeros <= (others => '0');
-- 
-- Main register bank access process.
  process (clk_sys_i, rst_n_i)
  begin
    if (rst_n_i = '0') then 
      ack_sreg <= "0000000000";
      ack_in_progress <= '0';
      rddata_reg <= "00000000000000000000000000000000";
      vic_ctl_enable_int <= '0';
      vic_ctl_pol_int <= '0';
      vic_ctl_emu_edge_int <= '0';
      vic_ctl_emu_len_int <= "0000000000000000";
      vic_ier_wr_o <= '0';
      vic_idr_wr_o <= '0';
      vic_swir_wr_o <= '0';
      vic_eoir_wr_o <= '0';
    elsif rising_edge(clk_sys_i) then
-- advance the ACK generator shift register
      ack_sreg(8 downto 0) <= ack_sreg(9 downto 1);
      ack_sreg(9) <= '0';
      if (ack_in_progress = '1') then
        if (ack_sreg(0) = '1') then
          vic_ier_wr_o <= '0';
          vic_idr_wr_o <= '0';
          vic_swir_wr_o <= '0';
          vic_eoir_wr_o <= '0';
          ack_in_progress <= '0';
        else
          vic_ier_wr_o <= '0';
          vic_idr_wr_o <= '0';
          vic_swir_wr_o <= '0';
          vic_eoir_wr_o <= '0';
        end if;
      else
        if ((wb_cyc_i = '1') and (wb_stb_i = '1')) then
          case rwaddr_reg(5) is
          when '0' => 
            case rwaddr_reg(2 downto 0) is
            when "000" => 
              if (wb_we_i = '1') then
                vic_ctl_enable_int <= wrdata_reg(0);
                vic_ctl_pol_int <= wrdata_reg(1);
                vic_ctl_emu_edge_int <= wrdata_reg(2);
                vic_ctl_emu_len_int <= wrdata_reg(18 downto 3);
              end if;
              rddata_reg(0) <= vic_ctl_enable_int;
              rddata_reg(1) <= vic_ctl_pol_int;
              rddata_reg(2) <= vic_ctl_emu_edge_int;
              rddata_reg(18 downto 3) <= vic_ctl_emu_len_int;
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
              ack_sreg(0) <= '1';
              ack_in_progress <= '1';
            when "001" => 
              if (wb_we_i = '1') then
              end if;
              rddata_reg(31 downto 0) <= vic_risr_i;
              ack_sreg(0) <= '1';
              ack_in_progress <= '1';
            when "010" => 
              if (wb_we_i = '1') then
                vic_ier_wr_o <= '1';
              end if;
              rddata_reg(0) <= 'X';
              rddata_reg(1) <= 'X';
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(8) <= 'X';
              rddata_reg(9) <= 'X';
              rddata_reg(10) <= 'X';
              rddata_reg(11) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= 'X';
              rddata_reg(18) <= 'X';
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
              ack_sreg(0) <= '1';
              ack_in_progress <= '1';
            when "011" => 
              if (wb_we_i = '1') then
                vic_idr_wr_o <= '1';
              end if;
              rddata_reg(0) <= 'X';
              rddata_reg(1) <= 'X';
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(8) <= 'X';
              rddata_reg(9) <= 'X';
              rddata_reg(10) <= 'X';
              rddata_reg(11) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= 'X';
              rddata_reg(18) <= 'X';
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
              ack_sreg(0) <= '1';
              ack_in_progress <= '1';
            when "100" => 
              if (wb_we_i = '1') then
              end if;
              rddata_reg(31 downto 0) <= vic_imr_i;
              ack_sreg(0) <= '1';
              ack_in_progress <= '1';
            when "101" => 
              if (wb_we_i = '1') then
              end if;
              rddata_reg(31 downto 0) <= vic_var_i;
              ack_sreg(0) <= '1';
              ack_in_progress <= '1';
            when "110" => 
              if (wb_we_i = '1') then
                vic_swir_wr_o <= '1';
              end if;
              rddata_reg(0) <= 'X';
              rddata_reg(1) <= 'X';
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(8) <= 'X';
              rddata_reg(9) <= 'X';
              rddata_reg(10) <= 'X';
              rddata_reg(11) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= 'X';
              rddata_reg(18) <= 'X';
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
              ack_sreg(0) <= '1';
              ack_in_progress <= '1';
            when "111" => 
              if (wb_we_i = '1') then
                vic_eoir_wr_o <= '1';
              end if;
              rddata_reg(0) <= 'X';
              rddata_reg(1) <= 'X';
              rddata_reg(2) <= 'X';
              rddata_reg(3) <= 'X';
              rddata_reg(4) <= 'X';
              rddata_reg(5) <= 'X';
              rddata_reg(6) <= 'X';
              rddata_reg(7) <= 'X';
              rddata_reg(8) <= 'X';
              rddata_reg(9) <= 'X';
              rddata_reg(10) <= 'X';
              rddata_reg(11) <= 'X';
              rddata_reg(12) <= 'X';
              rddata_reg(13) <= 'X';
              rddata_reg(14) <= 'X';
              rddata_reg(15) <= 'X';
              rddata_reg(16) <= 'X';
              rddata_reg(17) <= 'X';
              rddata_reg(18) <= 'X';
              rddata_reg(19) <= 'X';
              rddata_reg(20) <= 'X';
              rddata_reg(21) <= 'X';
              rddata_reg(22) <= 'X';
              rddata_reg(23) <= 'X';
              rddata_reg(24) <= 'X';
              rddata_reg(25) <= 'X';
              rddata_reg(26) <= 'X';
              rddata_reg(27) <= 'X';
              rddata_reg(28) <= 'X';
              rddata_reg(29) <= 'X';
              rddata_reg(30) <= 'X';
              rddata_reg(31) <= 'X';
              ack_sreg(0) <= '1';
              ack_in_progress <= '1';
            when others =>
-- prevent the slave from hanging the bus on invalid address
              ack_in_progress <= '1';
              ack_sreg(0) <= '1';
            end case;
          when '1' => 
            if (rd_int = '1') then
              ack_sreg(0) <= '1';
            else
              ack_sreg(0) <= '1';
            end if;
            ack_in_progress <= '1';
          when others =>
-- prevent the slave from hanging the bus on invalid address
            ack_in_progress <= '1';
            ack_sreg(0) <= '1';
          end case;
        end if;
      end if;
    end if;
  end process;
  
  
-- Data output multiplexer process
  process (rddata_reg, rwaddr_reg, vic_ivt_ram_rddata_int, wb_adr_i  )
  begin
    case rwaddr_reg(5) is
    when '1' => 
      wb_dat_o(31 downto 0) <= vic_ivt_ram_rddata_int;
    when others =>
      wb_dat_o <= rddata_reg;
    end case;
  end process;
  
  
-- Read & write lines decoder for RAMs
  process (wb_adr_i, rd_int, wr_int  )
  begin
    if (wb_adr_i(5) = '1') then
      vic_ivt_ram_rd_int <= rd_int;
      vic_ivt_ram_wr_int <= wr_int;
    else
      vic_ivt_ram_wr_int <= '0';
      vic_ivt_ram_rd_int <= '0';
    end if;
  end process;
  
  
-- VIC Enable
  vic_ctl_enable_o <= vic_ctl_enable_int;
-- VIC output polarity
  vic_ctl_pol_o <= vic_ctl_pol_int;
-- Emulate Edge sensitive output
  vic_ctl_emu_edge_o <= vic_ctl_emu_edge_int;
-- Emulated Edge pulse timer
  vic_ctl_emu_len_o <= vic_ctl_emu_len_int;
-- Raw interrupt status
-- Enable IRQ
-- pass-through field: Enable IRQ in register: Interrupt Enable Register
  vic_ier_o <= wrdata_reg(31 downto 0);
-- Disable IRQ
-- pass-through field: Disable IRQ in register: Interrupt Disable Register
  vic_idr_o <= wrdata_reg(31 downto 0);
-- IRQ disabled/enabled
-- Vector Address
-- SWI interrupt mask
-- pass-through field: SWI interrupt mask in register: Software Interrupt Register
  vic_swir_o <= wrdata_reg(31 downto 0);
-- End of Interrupt
-- pass-through field: End of Interrupt in register: End Of Interrupt Acknowledge Register
  vic_eoir_o <= wrdata_reg(31 downto 0);
-- extra code for reg/fifo/mem: Interrupt Vector Table
-- RAM block instantiation for memory: Interrupt Vector Table
  vic_ivt_ram_raminst : wbgen2_dpssram
    generic map (
      g_data_width         => 32,
      g_size               => 32,
      g_addr_width         => 5,
      g_dual_clock         => false,
      g_use_bwsel          => false
    )
    port map (
      clk_a_i              => clk_sys_i,
      clk_b_i              => clk_sys_i,
      addr_b_i             => vic_ivt_ram_addr_i,
      addr_a_i             => rwaddr_reg(4 downto 0),
      data_b_o             => vic_ivt_ram_data_o,
      rd_b_i               => vic_ivt_ram_rd_i,
      bwsel_b_i            => allones(3 downto 0),
      data_b_i             => allzeros(31 downto 0),
      wr_b_i               => allzeros(0),
      data_a_o             => vic_ivt_ram_rddata_int(31 downto 0),
      rd_a_i               => vic_ivt_ram_rd_int,
      data_a_i             => wrdata_reg(31 downto 0),
      wr_a_i               => vic_ivt_ram_wr_int,
      bwsel_a_i            => allones(3 downto 0)
    );
  
  rwaddr_reg <= wb_adr_i;
  wb_stall_o <= (not ack_sreg(0)) and (wb_stb_i and wb_cyc_i);
-- ACK signal generation. Just pass the LSB of ACK counter.
  wb_ack_o <= ack_sreg(0);
end syn;
