library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity predictor_interface is
    port (
        clk : in std_logic;
        nReset : in std_logic;

        -- Avalon slave interface
        -- Address can go from 0 to 526, 10 bits
        address : in std_logic_vector(9 downto 0);
        write : in std_logic;
        writedata : in std_logic_vector(31 downto 0);
        read : in std_logic;
        readdata : out std_logic_vector(31 downto 0)
    );
end entity predictor_interface;

architecture rtl of predictor_interface is

    -- Internal signals
    -- Define a FSM with following states: WAIT_STATE, SEND_DATA, WAIT_DONE, FINISH_STATE, RESET
    type state_type is (WAIT_STATE, SEND_DATA, WAIT_DONE, FINISH_STATE, RESET);
    signal state : state_type := WAIT_STATE;

    -- Array to contain all 512 samples, each 16bits
    type sample_array is array (0 to 511) of std_logic_vector(15 downto 0);
    signal samples : sample_array := (others => (others => '0'));
    -- Counter to keep track of the current sample
    signal sample_counter : unsigned(9 downto 0) := (others => '0');
    -- Sample currently sent to the predictor
    signal current_sample : std_logic_vector(15 downto 0) := (others => '0');

    -- All values of the linear SVM, each values is 42 bits (signed + 12 decimal bits)
    signal bias : std_logic_vector(41 downto 0) := (others => '0');
    signal scale : std_logic_vector(41 downto 0) := (others => '0');

    -- THIS PART SHOULD BE CHANGED FOR EACH PATIENT
    -- Depending on the patient, the number of features changes, thus the number of betas_cur_d1, mus_cur_d1 and sigmas_cur_d1 changes
    -- Patient 3: one feature with beta, mu and sigma being 42 bits
    signal betas_cur_d1 : std_logic_vector(41 downto 0) := (others => '0');
    signal mus_cur_d1 : std_logic_vector(41 downto 0) := (others => '0');
    signal sigmas_cur_d1 : std_logic_vector(41 downto 0) := (others => '0');
    -- --------------------------------------------

    -- The result of the SVM is a 43 bits signed number
    signal result : std_logic_vector(42 downto 0) := (others => '0');

    -- Control signals for the FSM
    signal start : std_logic := '0';    -- Value written by CPU to start sending data
    signal stop : std_logic := '0';     -- Value written by CPU to stop prediction
    signal finished : std_logic := '0'; -- Value polled by CPU to know if prediction is finished
    signal enable : std_logic := '0';   -- Controlled by the FSM, enable the predictor

    -- Done signal read from the predictor
    signal done : std_logic := '0';
    -- Output of the predictor on 43 bits
    signal prediction : std_logic_vector(42 downto 0) := (others => '0');

    -- THIS PART SHOULD BE CHANGED FOR EACH PATIENT
    -- Needs to correspond to the actual 'full_system' entity (see full_system.vhd)
    -- Instantiate the predictor
    component full_system IS
    PORT( clk                               :   IN    std_logic;
            reset                             :   IN    std_logic;
            clk_enable                        :   IN    std_logic;
            signal_in                         :   IN    std_logic_vector(15 DOWNTO 0);  -- sfix16_En4
            enable                            :   IN    std_logic;
            scale                             :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
            cur_mu_D1                         :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
            cur_sig_D1                        :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
            cur_beta_D1                       :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
            bias                              :   IN    std_logic_vector(41 DOWNTO 0);  -- sfix42_En12
            ce_out                            :   OUT   std_logic;
            svm_out                           :   OUT   std_logic_vector(42 DOWNTO 0);  -- sfix43_En12
            done                              :   OUT   std_logic
            );
    END component full_system;
    -- --------------------------------------------

begin

    -- Avalon slave interface
    process(clk, nReset)
    begin

        if nReset = '0' then
            start <= '0';
            stop <= '0';
            samples <= (others => (others => '0'));
            bias <= (others => '0');
            scale <= (others => '0');
            betas_cur_d1 <= (others => '0');
            mus_cur_d1 <= (others => '0');
            sigmas_cur_d1 <= (others => '0');
        elsif rising_edge(clk) then
            if read = '1' then
                readdata <= (others => '0');
                -- Address of readable registers :
                -- 514: finished
                -- 515 to 516: result (525: 0 to 31, 526: 32 to 42)
                if address = "1000000010" then
                    readdata(0) <= finished;
                elsif address = "1000000011" then
                    readdata <= result(31 downto 0);
                elsif address = "1000000100" then
                    readdata(10 downto 0) <= result(42 downto 32);
                end if;
            elsif write = '1' then
                -- NEEDS TO BE CHANGED FOR EACH PATIENT

                -- Add at the end the addresses for each extra feature

                -- Address of writable registers :
                -- 0 to 511: samples
                -- 512: start
                -- 513: stop
                -- 514 to 516: reserved (read only)
                -- For bias, scale, betas_cur_d1, mus_cur_d1 and sigmas_cur_d1: they are 42 bits long, so we need to write 2 registers (low address = LSB)
                -- 517 to 518: bias
                -- 519 to 520: scale
                -- 521 to 522: betas_cur_d1 
                -- 523 to 524: mus_cur_d1
                -- 525 to 526: sigmas_cur_d1
                if address < "1000000000" then
                    -- Write samples
                    samples(to_integer(unsigned(address))) <= writedata(15 downto 0);
                elsif address = "1000000000" then
                    -- Start
                    start <= writedata(0);
                elsif address = "1000000001" then
                    -- Stop
                    stop <= writedata(0);
                elsif address = "1000000101" then
                    -- LSB of bias
                    bias(31 downto 0) <= writedata;
                elsif address = "1000000110" then
                    -- MSB of bias
                    bias(41 downto 32) <= writedata(9 downto 0);
                elsif address = "1000000111" then
                    -- LSB of scale
                    scale(31 downto 0) <= writedata;
                elsif address = "1000001000" then
                    -- MSB of scale
                    scale(41 downto 32) <= writedata(9 downto 0);
                elsif address = "1000001001" then
                    -- LSB of betas_cur_d1
                    betas_cur_d1(31 downto 0) <= writedata;
                elsif address = "1000001010" then
                    -- MSB of betas_cur_d1
                    betas_cur_d1(41 downto 32) <= writedata(9 downto 0);
                elsif address = "1000001011" then
                    -- LSB of mus_cur_d1
                    mus_cur_d1(31 downto 0) <= writedata;
                elsif address = "1000001100" then
                    -- MSB of mus_cur_d1
                    mus_cur_d1(41 downto 32) <= writedata(9 downto 0);
                elsif address = "1000001101" then
                    -- LSB of sigmas_cur_d1
                    sigmas_cur_d1(31 downto 0) <= writedata;
                elsif address = "1000001110" then
                    -- MSB of sigmas_cur_d1
                    sigmas_cur_d1(41 downto 32) <= writedata(9 downto 0);
            end if;
        end if;

    end process;
    

    -- FSM
    process(clk, nReset)
    begin

        if nReset = '0' then
            state <= WAIT_STATE;
            sample_counter <= (others => '0');
            result <= (others => '0');
            finished <= '0';
            enable <= '0';
            current_sample <= (others => '0');
        elsif rising_edge(clk) then
            -- If stop always go to RESET
            case state is
                when WAIT_STATE =>
                    -- WAIT_STATE for start or stop
                    if stop = '1' then
                        enable <= '0';
                        state <= RESET;
                    elsif start = '1' then
                        sample_counter <= (others => '0');
                        finished <= '0';
                        state <= SEND_DATA;
                    else
                        enable <= '0';
                        finished <= '0';
                        state <= WAIT_STATE;
                    end if;
                when SEND_DATA =>
                    -- Send data to the SVM, there are 512 samples
                    if stop = '1' then
                        enable <= '0';
                        state <= RESET;
                    else
                        enable <= '1';
                        if sample_counter = 512 then
                            current_sample <= (others => '0');
                            state <= WAIT_DONE;
                        else
                            current_sample <= samples(to_integer(sample_counter));
                            sample_counter <= sample_counter + 1;
                            state <= SEND_DATA;
                        end if;
                    end if;
                when WAIT_DONE =>
                -- Wait for the result of the SVM
                    if stop = '1' then
                        enable <= '0';
                        state <= RESET;
                    elsif done = '1' then
                        -- Save prediction in the result register and indicate that the SVM is finished
                        result <= prediction;
                        finished <= '1';
                        state <= FINISH_STATE;
                    else
                        -- Just wait, keep finished to '0' until done
                        finished <= '0';
                        state <= WAIT_DONE;
                    end if;
                when FINISH_STATE =>
                    -- Wait for stop
                    if stop = '1' then
                        enable <= '0';
                        state <= RESET;
                    else
                        -- Keep finished to '1' until stop
                        finished <= '1';
                        -- Stops the predictor
                        enable <= '0';
                        state <= FINISH_STATE;
                    end if;
                when RESET =>
                    -- Reset all FSM variables
                    sample_counter <= (others => '0');
                    result <= (others => '0');
                    current_sample <= (others => '0');
                    enable <= '0';
                    finished <= '0';

                    if stop = '0' then
                        state <= WAIT_STATE;
                    else
                        state <= RESET;
                    end if;
                when others =>
                    enable <= '0';
                    finished <= '0';
                    state <= RESET;
            end case;
        end if;

    end process;
    
    -- Connect the predictor using its instantiation, the port needs to be adapted to the component
    predictor : component full_system
       port map (
        clk                               => clk,
        reset                             => not nReset,
        clk_enable                        => '1',
        signal_in                         => current_sample,
        enable                            => enable,
        scale                             => scale,
        cur_mu_D1                         => mus_cur_d1,
        cur_sig_D1                        => sigmas_cur_d1,
        cur_beta_D1                       => betas_cur_d1,
        bias                              => bias,
        ce_out                            => open,
        svm_out                           => prediction,
        done                              => done
       ); 
    
end architecture rtl;