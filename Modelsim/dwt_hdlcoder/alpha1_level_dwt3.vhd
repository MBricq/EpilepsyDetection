-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\hdlcoder_dwt\alpha1_level_dwt3.vhd
-- Created: 2023-05-02 15:37:17
-- 
-- Generated by MATLAB 9.11 and HDL Coder 3.19
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: alpha1_level_dwt3
-- Source Path: hdlcoder_dwt/4_level_dwt/1_level_dwt3
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.alpha4_level_dwt_pkg.ALL;

ENTITY alpha1_level_dwt3 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb_1_8_0                         :   IN    std_logic;
        enb_1_16_0                        :   IN    std_logic;
        enb_1_16_1                        :   IN    std_logic;
        s_in                              :   IN    std_logic_vector(88 DOWNTO 0);  -- sfix89_En12
        enable                            :   IN    std_logic;
        D                                 :   OUT   std_logic_vector(107 DOWNTO 0);  -- sfix108_En12
        A                                 :   OUT   std_logic_vector(107 DOWNTO 0)  -- sfix108_En12
        );
END alpha1_level_dwt3;


ARCHITECTURE rtl OF alpha1_level_dwt3 IS

  -- Component Declarations
  COMPONENT Discrete_FIR_Filter_block2
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb_1_8_0                       :   IN    std_logic;
          Discrete_FIR_Filter_in          :   IN    std_logic_vector(88 DOWNTO 0);  -- sfix89_En12
          Discrete_FIR_Filter_coeff       :   IN    vector_of_std_logic_vector16(0 TO 7);  -- int16 [8]
          Discrete_FIR_Filter_out         :   OUT   std_logic_vector(107 DOWNTO 0)  -- sfix108_En12
          );
  END COMPONENT;

  COMPONENT Discrete_FIR_Filter1_block2
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb_1_8_0                       :   IN    std_logic;
          Discrete_FIR_Filter1_in         :   IN    std_logic_vector(88 DOWNTO 0);  -- sfix89_En12
          Discrete_FIR_Filter1_coeff      :   IN    vector_of_std_logic_vector16(0 TO 7);  -- int16 [8]
          Discrete_FIR_Filter1_out        :   OUT   std_logic_vector(107 DOWNTO 0)  -- sfix108_En12
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : Discrete_FIR_Filter_block2
    USE ENTITY work.Discrete_FIR_Filter_block2(rtl);

  FOR ALL : Discrete_FIR_Filter1_block2
    USE ENTITY work.Discrete_FIR_Filter1_block2(rtl);

  -- Signals
  SIGNAL RT2_bypass_reg                   : std_logic;  -- ufix1
  SIGNAL RT2_out1                         : std_logic;
  SIGNAL switch_compare_1                 : std_logic;
  SIGNAL Constant_out1                    : signed(107 DOWNTO 0);  -- sfix108_En12
  SIGNAL db4_wavelet_out1                 : vector_of_signed16(0 TO 7);  -- int16 [8]
  SIGNAL db4_wavelet_out1_1               : vector_of_std_logic_vector16(0 TO 7);  -- ufix16 [8]
  SIGNAL Discrete_FIR_Filter_out1         : std_logic_vector(107 DOWNTO 0);  -- ufix108
  SIGNAL Discrete_FIR_Filter_out1_signed  : signed(107 DOWNTO 0);  -- sfix108_En12
  SIGNAL Downsample_out1                  : signed(107 DOWNTO 0);  -- sfix108_En12
  SIGNAL Switch_out1                      : signed(107 DOWNTO 0);  -- sfix108_En12
  SIGNAL switch_compare_1_1               : std_logic;
  SIGNAL db4_scaling_out1                 : vector_of_signed16(0 TO 7);  -- int16 [8]
  SIGNAL db4_scaling_out1_1               : vector_of_std_logic_vector16(0 TO 7);  -- ufix16 [8]
  SIGNAL Discrete_FIR_Filter1_out1        : std_logic_vector(107 DOWNTO 0);  -- ufix108
  SIGNAL Discrete_FIR_Filter1_out1_signed : signed(107 DOWNTO 0);  -- sfix108_En12
  SIGNAL Downsample1_out1                 : signed(107 DOWNTO 0);  -- sfix108_En12
  SIGNAL Switch1_out1                     : signed(107 DOWNTO 0);  -- sfix108_En12

BEGIN
  u_Discrete_FIR_Filter : Discrete_FIR_Filter_block2
    PORT MAP( clk => clk,
              reset => reset,
              enb_1_8_0 => enb_1_8_0,
              Discrete_FIR_Filter_in => s_in,  -- sfix89_En12
              Discrete_FIR_Filter_coeff => db4_wavelet_out1_1,  -- int16 [8]
              Discrete_FIR_Filter_out => Discrete_FIR_Filter_out1  -- sfix108_En12
              );

  u_Discrete_FIR_Filter1 : Discrete_FIR_Filter1_block2
    PORT MAP( clk => clk,
              reset => reset,
              enb_1_8_0 => enb_1_8_0,
              Discrete_FIR_Filter1_in => s_in,  -- sfix89_En12
              Discrete_FIR_Filter1_coeff => db4_scaling_out1_1,  -- int16 [8]
              Discrete_FIR_Filter1_out => Discrete_FIR_Filter1_out1  -- sfix108_En12
              );

  RT2_bypass_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      RT2_bypass_reg <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb_1_16_1 = '1' THEN
        RT2_bypass_reg <= enable;
      END IF;
    END IF;
  END PROCESS RT2_bypass_process;

  
  RT2_out1 <= enable WHEN enb_1_16_1 = '1' ELSE
      RT2_bypass_reg;

  
  switch_compare_1 <= '1' WHEN RT2_out1 > '0' ELSE
      '0';

  Constant_out1 <= to_signed(0, 108);

  db4_wavelet_out1(0) <= to_signed(16#0000#, 16);
  db4_wavelet_out1(1) <= to_signed(16#0001#, 16);
  db4_wavelet_out1(2) <= to_signed(-16#0001#, 16);
  db4_wavelet_out1(3) <= to_signed(16#0000#, 16);
  db4_wavelet_out1(4) <= to_signed(16#0000#, 16);
  db4_wavelet_out1(5) <= to_signed(16#0000#, 16);
  db4_wavelet_out1(6) <= to_signed(16#0000#, 16);
  db4_wavelet_out1(7) <= to_signed(16#0000#, 16);

  outputgen1: FOR k IN 0 TO 7 GENERATE
    db4_wavelet_out1_1(k) <= std_logic_vector(db4_wavelet_out1(k));
  END GENERATE;

  Discrete_FIR_Filter_out1_signed <= signed(Discrete_FIR_Filter_out1);

  -- Downsample output register
  Downsample_output_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Downsample_out1 <= to_signed(0, 108);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb_1_16_0 = '1' THEN
        Downsample_out1 <= Discrete_FIR_Filter_out1_signed;
      END IF;
    END IF;
  END PROCESS Downsample_output_process;


  
  Switch_out1 <= Constant_out1 WHEN switch_compare_1 = '0' ELSE
      Downsample_out1;

  D <= std_logic_vector(Switch_out1);

  
  switch_compare_1_1 <= '1' WHEN RT2_out1 > '0' ELSE
      '0';

  db4_scaling_out1(0) <= to_signed(16#0000#, 16);
  db4_scaling_out1(1) <= to_signed(16#0000#, 16);
  db4_scaling_out1(2) <= to_signed(16#0000#, 16);
  db4_scaling_out1(3) <= to_signed(16#0000#, 16);
  db4_scaling_out1(4) <= to_signed(16#0000#, 16);
  db4_scaling_out1(5) <= to_signed(16#0001#, 16);
  db4_scaling_out1(6) <= to_signed(16#0001#, 16);
  db4_scaling_out1(7) <= to_signed(16#0000#, 16);

  outputgen: FOR k IN 0 TO 7 GENERATE
    db4_scaling_out1_1(k) <= std_logic_vector(db4_scaling_out1(k));
  END GENERATE;

  Discrete_FIR_Filter1_out1_signed <= signed(Discrete_FIR_Filter1_out1);

  -- Downsample output register
  Downsample1_output_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Downsample1_out1 <= to_signed(0, 108);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb_1_16_0 = '1' THEN
        Downsample1_out1 <= Discrete_FIR_Filter1_out1_signed;
      END IF;
    END IF;
  END PROCESS Downsample1_output_process;


  
  Switch1_out1 <= Constant_out1 WHEN switch_compare_1_1 = '0' ELSE
      Downsample1_out1;

  A <= std_logic_vector(Switch1_out1);

END rtl;

