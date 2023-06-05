-- -------------------------------------------------------------
-- 
-- File Name: hdlsrc\full_system_nios_id2\predictor10.vhd
-- Created: 2023-05-25 08:56:43
-- 
-- Generated by MATLAB 9.11 and HDL Coder 3.19
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: predictor10
-- Source Path: full_system_nios_id2/full_system/predictor10
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY predictor10 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        variable_rsvd                     :   IN    std_logic_vector(37 DOWNTO 0);  -- sfix38_En8
        trigger                           :   IN    std_logic;
        mu                                :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
        sigma                             :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
        scale                             :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
        beta                              :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
        predicted                         :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En12
        );
END predictor10;


ARCHITECTURE rtl OF predictor10 IS

  ATTRIBUTE multstyle : string;

  -- Signals
  SIGNAL beta_signed                      : signed(41 DOWNTO 0);  -- sfix42_En12
  SIGNAL trigger_1                        : std_logic;
  SIGNAL variable_signed                  : signed(37 DOWNTO 0);  -- sfix38_En8
  SIGNAL stateControl_1                   : std_logic;
  SIGNAL stateControl_2                   : std_logic;
  SIGNAL enb_gated                        : std_logic;
  SIGNAL Delay2_out1                      : signed(37 DOWNTO 0);  -- sfix38_En8
  SIGNAL Switch1_out1                     : signed(37 DOWNTO 0);  -- sfix38_En8
  SIGNAL mu_signed                        : signed(41 DOWNTO 0);  -- sfix42_En12
  SIGNAL mu_1                             : signed(41 DOWNTO 0);  -- sfix42_En12
  SIGNAL Subtract_sub_cast                : signed(42 DOWNTO 0);  -- sfix43_En12
  SIGNAL Subtract_sub_cast_1              : signed(42 DOWNTO 0);  -- sfix43_En12
  SIGNAL with_mu                          : signed(42 DOWNTO 0);  -- sfix43_En12
  SIGNAL Data_Type_Conversion1_out1       : signed(54 DOWNTO 0);  -- sfix55_En24
  SIGNAL Data_Type_Conversion1_out1_dtc   : signed(55 DOWNTO 0);  -- sfix56_En24
  SIGNAL sigma_signed                     : signed(41 DOWNTO 0);  -- sfix42_En12
  SIGNAL scale_signed                     : signed(41 DOWNTO 0);  -- sfix42_En12
  SIGNAL Product_out1                     : signed(83 DOWNTO 0);  -- sfix84_En24
  SIGNAL Data_Type_Conversion2_out1       : signed(62 DOWNTO 0);  -- sfix63_En12
  SIGNAL beta_1                           : signed(41 DOWNTO 0);  -- sfix42_En12
  SIGNAL Data_Type_Conversion2_out1_1     : signed(62 DOWNTO 0);  -- sfix63_En12
  SIGNAL after_div                        : signed(41 DOWNTO 0);  -- sfix42_En12
  SIGNAL Product1_mul_temp                : signed(83 DOWNTO 0);  -- sfix84_En24
  SIGNAL after_beta                       : signed(31 DOWNTO 0);  -- sfix32_En12

BEGIN
  beta_signed <= signed(beta);

  delayMatch_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      trigger_1 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        trigger_1 <= trigger;
      END IF;
    END IF;
  END PROCESS delayMatch_process;


  variable_signed <= signed(variable_rsvd);

  stateControl_1 <= '1';

  delayMatch1_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      stateControl_2 <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        stateControl_2 <= stateControl_1;
      END IF;
    END IF;
  END PROCESS delayMatch1_process;


  enb_gated <= stateControl_2 AND enb;

  
  Switch1_out1 <= Delay2_out1 WHEN trigger_1 = '0' ELSE
      variable_signed;

  Delay2_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Delay2_out1 <= to_signed(0, 38);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb_gated = '1' THEN
        Delay2_out1 <= Switch1_out1;
      END IF;
    END IF;
  END PROCESS Delay2_process;


  mu_signed <= signed(mu);

  delayMatch2_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      mu_1 <= to_signed(0, 42);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        mu_1 <= mu_signed;
      END IF;
    END IF;
  END PROCESS delayMatch2_process;


  Subtract_sub_cast <= resize(Delay2_out1 & '0' & '0' & '0' & '0', 43);
  Subtract_sub_cast_1 <= resize(mu_1, 43);
  with_mu <= Subtract_sub_cast - Subtract_sub_cast_1;

  Data_Type_Conversion1_out1 <= with_mu & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0';

  Data_Type_Conversion1_out1_dtc <= resize(Data_Type_Conversion1_out1, 56);

  sigma_signed <= signed(sigma);

  scale_signed <= signed(scale);

  Product_out1 <= sigma_signed * scale_signed;

  Data_Type_Conversion2_out1 <= Product_out1(74 DOWNTO 12);

  delayMatch4_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      beta_1 <= to_signed(0, 42);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        beta_1 <= beta_signed;
      END IF;
    END IF;
  END PROCESS delayMatch4_process;


  delayMatch3_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      Data_Type_Conversion2_out1_1 <= to_signed(0, 63);
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        Data_Type_Conversion2_out1_1 <= Data_Type_Conversion2_out1;
      END IF;
    END IF;
  END PROCESS delayMatch3_process;


  Divide_output : PROCESS (Data_Type_Conversion1_out1_dtc, Data_Type_Conversion2_out1_1)
    VARIABLE c : signed(62 DOWNTO 0);
    VARIABLE div_temp : signed(62 DOWNTO 0);
  BEGIN
    div_temp := to_signed(0, 63);
    IF Data_Type_Conversion2_out1_1 = to_signed(0, 63) THEN 
      IF Data_Type_Conversion1_out1_dtc < to_signed(0, 56) THEN 
        c := signed'("100000000000000000000000000000000000000000000000000000000000000");
      ELSE 
        c := signed'("011111111111111111111111111111111111111111111111111111111111111");
      END IF;
    ELSE 
      div_temp := resize(Data_Type_Conversion1_out1_dtc, 63) / Data_Type_Conversion2_out1_1;
      c := div_temp;
    END IF;
    IF (c(62) = '0') AND (c(61 DOWNTO 41) /= "000000000000000000000") THEN 
      after_div <= "011111111111111111111111111111111111111111";
    ELSIF (c(62) = '1') AND (c(61 DOWNTO 41) /= "111111111111111111111") THEN 
      after_div <= "100000000000000000000000000000000000000000";
    ELSE 
      after_div <= c(41 DOWNTO 0);
    END IF;
  END PROCESS Divide_output;


  Product1_mul_temp <= beta_1 * after_div;
  after_beta <= Product1_mul_temp(43 DOWNTO 12);

  predicted <= std_logic_vector(after_beta);

END rtl;

