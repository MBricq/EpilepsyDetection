library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Segment7 is
    port(
        clk : in std_logic;

        enable : in std_logic;
        display : in std_logic_vector(3 downto 0);

        -- External interface (i.e. conduit).
        out_disp : out std_logic_vector(6 downto 0)
    );
end Segment7;

architecture comp of Segment7 is

begin

    -- Output value.
    process(enable, display)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                out_disp(0) <= not (display(3) or display(1) or (display(2) and display(0)) or (not display(2) and not display(0)));
                out_disp(1) <= not ((not display(2)) or (not display(1) and not display(0)) or (display(1) and display(0)));
                out_disp(2) <= not (display(2) or (not display(1)) or display(0));
                out_disp(3) <= not ((not display(2) and not display(0)) or (display(1) and not display(0)) or (display(2) and not display(1) and display(0)) or (not display(2) and display(1)) or display(3));
                out_disp(4) <= not ((not display(2) and not display(0)) or (display(1) and not display(0)));
                out_disp(5) <= not (display(3) or (not display(1) and not display(0)) or (display(2) and not display(1)) or (display(2) and not display(0)));
                out_disp(6) <= not (display(3) or (display(2) and not display(1)) or (not display(2) and display(1)) or (display(1) and not display(0)));
            else
                out_disp <= (others => '1');
            end if;
        end if;
    end process;

end comp;