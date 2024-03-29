-- Implements a simple Nios II system for the DE2-115 board.
-- Inputs: SW7-0 are parallel port inputs to the Nios II system
-- CLOCK_50 is the system clock
-- KEY0 is the active-low system reset
-- Outputs: LEDG7−0 are parallel port outputs from the Nios II system
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

ENTITY top_level IS
PORT (
    KEY : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    CLOCK_50 : IN STD_LOGIC;
    LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
    );
END top_level;

ARCHITECTURE Structure OF top_level IS

component system is
    port (
        clk_clk                                   : in  std_logic                     := 'X'; -- clk
        reset_reset_n                             : in  std_logic                     := 'X'; -- reset_n
        parallelport_0_external_connection_export : out std_logic_vector(17 downto 0)         -- export
    );
end component system;

BEGIN

-- Instantiate the Nios II system entity generated by the SOPC Builder
-- Nios II: nios_system PORT MAP (CLOCK_50, KEY(0), LEDG, SW);
u0 : component system
    port map (
        clk_clk                           => CLOCK_50,                           --                        clk.clk
        reset_reset_n                     => KEY(0),                     --                      reset.reset_n
        parallelport_0_external_connection_export => LEDR  -- parallelport_0_conduit_end.export
    );

END Structure;