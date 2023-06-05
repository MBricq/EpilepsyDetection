-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\hdlcoder_dwt\Discrete_FIR_Filter1.vhd
-- Created: 2023-05-02 15:37:17
-- 
-- Generated by MATLAB 9.11 and HDL Coder 3.19
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: Discrete_FIR_Filter1
-- Source Path: hdlcoder_dwt/4_level_dwt/1_level_dwt/Discrete FIR Filter1
-- Hierarchy Level: 2
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.alpha4_level_dwt_pkg.ALL;

ENTITY Discrete_FIR_Filter1 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        Discrete_FIR_Filter1_in           :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En12
        Discrete_FIR_Filter1_coeff        :   IN    vector_of_std_logic_vector16(0 TO 7);  -- int16 [8]
        Discrete_FIR_Filter1_out          :   OUT   std_logic_vector(50 DOWNTO 0)  -- sfix51_En12
        );
END Discrete_FIR_Filter1;


ARCHITECTURE rtl OF Discrete_FIR_Filter1 IS

  -- Signals
  SIGNAL Discrete_FIR_Filter1_in_signed   : signed(31 DOWNTO 0);  -- sfix32_En12
  SIGNAL Discrete_FIR_Filter1_coeff_0     : signed(15 DOWNTO 0);  -- int16
  SIGNAL delay_pipeline_1                 : vector_of_signed32(0 TO 6);  -- sfix32_En12 [7]
  SIGNAL product1                         : signed(47 DOWNTO 0);  -- sfix48_En12
  SIGNAL delay_pipeline_0                 : signed(31 DOWNTO 0);  -- sfix32_En12
  SIGNAL Discrete_FIR_Filter1_coeff_1     : signed(15 DOWNTO 0);  -- int16
  SIGNAL product2                         : signed(47 DOWNTO 0);  -- sfix48_En12
  SIGNAL adder_add_cast                   : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL adder_add_cast_1                 : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL sum1                             : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL delay_pipeline_1_1               : signed(31 DOWNTO 0);  -- sfix32_En12
  SIGNAL Discrete_FIR_Filter1_coeff_2     : signed(15 DOWNTO 0);  -- int16
  SIGNAL product3                         : signed(47 DOWNTO 0);  -- sfix48_En12
  SIGNAL adder_add_cast_2                 : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL sum2                             : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL delay_pipeline_2                 : signed(31 DOWNTO 0);  -- sfix32_En12
  SIGNAL Discrete_FIR_Filter1_coeff_3     : signed(15 DOWNTO 0);  -- int16
  SIGNAL product4                         : signed(47 DOWNTO 0);  -- sfix48_En12
  SIGNAL adder_add_cast_3                 : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL sum3                             : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL delay_pipeline_3                 : signed(31 DOWNTO 0);  -- sfix32_En12
  SIGNAL Discrete_FIR_Filter1_coeff_4     : signed(15 DOWNTO 0);  -- int16
  SIGNAL product5                         : signed(47 DOWNTO 0);  -- sfix48_En12
  SIGNAL adder_add_cast_4                 : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL sum4                             : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL delay_pipeline_4                 : signed(31 DOWNTO 0);  -- sfix32_En12
  SIGNAL Discrete_FIR_Filter1_coeff_5     : signed(15 DOWNTO 0);  -- int16
  SIGNAL product6                         : signed(47 DOWNTO 0);  -- sfix48_En12
  SIGNAL adder_add_cast_5                 : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL sum5                             : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL delay_pipeline_5                 : signed(31 DOWNTO 0);  -- sfix32_En12
  SIGNAL Discrete_FIR_Filter1_coeff_6     : signed(15 DOWNTO 0);  -- int16
  SIGNAL product7                         : signed(47 DOWNTO 0);  -- sfix48_En12
  SIGNAL adder_add_cast_6                 : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL sum6                             : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL delay_pipeline_6                 : signed(31 DOWNTO 0);  -- sfix32_En12
  SIGNAL Discrete_FIR_Filter1_coeff_7     : signed(15 DOWNTO 0);  -- int16
  SIGNAL product8                         : signed(47 DOWNTO 0);  -- sfix48_En12
  SIGNAL adder_add_cast_7                 : signed(50 DOWNTO 0);  -- sfix51_En12
  SIGNAL sum7                             : signed(50 DOWNTO 0);  -- sfix51_En12

BEGIN
  Discrete_FIR_Filter1_in_signed <= signed(Discrete_FIR_Filter1_in);

  Discrete_FIR_Filter1_coeff_0 <= signed(Discrete_FIR_Filter1_coeff(0));

  Delay_Pipeline_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      delay_pipeline_1 <= (OTHERS => to_signed(0, 32));
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        delay_pipeline_1(0) <= Discrete_FIR_Filter1_in_signed;
        delay_pipeline_1(1 TO 6) <= delay_pipeline_1(0 TO 5);
      END IF;
    END IF;
  END PROCESS Delay_Pipeline_process;


  product1 <= Discrete_FIR_Filter1_in_signed * Discrete_FIR_Filter1_coeff_0;

  delay_pipeline_0 <= delay_pipeline_1(0);

  Discrete_FIR_Filter1_coeff_1 <= signed(Discrete_FIR_Filter1_coeff(1));

  product2 <= delay_pipeline_0 * Discrete_FIR_Filter1_coeff_1;

  adder_add_cast <= resize(product1, 51);
  adder_add_cast_1 <= resize(product2, 51);
  sum1 <= adder_add_cast + adder_add_cast_1;

  delay_pipeline_1_1 <= delay_pipeline_1(1);

  Discrete_FIR_Filter1_coeff_2 <= signed(Discrete_FIR_Filter1_coeff(2));

  product3 <= delay_pipeline_1_1 * Discrete_FIR_Filter1_coeff_2;

  adder_add_cast_2 <= resize(product3, 51);
  sum2 <= sum1 + adder_add_cast_2;

  delay_pipeline_2 <= delay_pipeline_1(2);

  Discrete_FIR_Filter1_coeff_3 <= signed(Discrete_FIR_Filter1_coeff(3));

  product4 <= delay_pipeline_2 * Discrete_FIR_Filter1_coeff_3;

  adder_add_cast_3 <= resize(product4, 51);
  sum3 <= sum2 + adder_add_cast_3;

  delay_pipeline_3 <= delay_pipeline_1(3);

  Discrete_FIR_Filter1_coeff_4 <= signed(Discrete_FIR_Filter1_coeff(4));

  product5 <= delay_pipeline_3 * Discrete_FIR_Filter1_coeff_4;

  adder_add_cast_4 <= resize(product5, 51);
  sum4 <= sum3 + adder_add_cast_4;

  delay_pipeline_4 <= delay_pipeline_1(4);

  Discrete_FIR_Filter1_coeff_5 <= signed(Discrete_FIR_Filter1_coeff(5));

  product6 <= delay_pipeline_4 * Discrete_FIR_Filter1_coeff_5;

  adder_add_cast_5 <= resize(product6, 51);
  sum5 <= sum4 + adder_add_cast_5;

  delay_pipeline_5 <= delay_pipeline_1(5);

  Discrete_FIR_Filter1_coeff_6 <= signed(Discrete_FIR_Filter1_coeff(6));

  product7 <= delay_pipeline_5 * Discrete_FIR_Filter1_coeff_6;

  adder_add_cast_6 <= resize(product7, 51);
  sum6 <= sum5 + adder_add_cast_6;

  delay_pipeline_6 <= delay_pipeline_1(6);

  Discrete_FIR_Filter1_coeff_7 <= signed(Discrete_FIR_Filter1_coeff(7));

  product8 <= delay_pipeline_6 * Discrete_FIR_Filter1_coeff_7;

  adder_add_cast_7 <= resize(product8, 51);
  sum7 <= sum6 + adder_add_cast_7;

  Discrete_FIR_Filter1_out <= std_logic_vector(sum7);

END rtl;

