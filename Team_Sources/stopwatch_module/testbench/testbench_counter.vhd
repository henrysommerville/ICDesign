library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sw_counter_tb is
end sw_counter_tb;

architecture Behavioral of sw_counter_tb is

    -- Component Declaration
    component stopwatch_counter is
        port (
            clk       : in  STD_LOGIC;
            i_enable  : in  STD_LOGIC;
            i_reset   : in  STD_LOGIC;
            o_hs      : out STD_LOGIC_VECTOR(7 downto 0);
            o_s       : out STD_LOGIC_VECTOR(7 downto 0);
            o_min     : out STD_LOGIC_VECTOR(7 downto 0);
            o_h       : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Testbench signals
    signal clk       : STD_LOGIC := '0';
    signal i_enable  : STD_LOGIC := '0';
    signal i_reset   : STD_LOGIC := '0';
    signal o_hs      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_s       : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_min     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_h       : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    constant sec_wait : time := 1 sec;

begin

    -- Instantiate the DUT (Device Under Test)
    uut: stopwatch_counter
        port map (
            clk      => clk,
            i_enable => i_enable,
            i_reset  => i_reset,
            o_hs     => o_hs,
            o_s      => o_s,
            o_min    => o_min,
            o_h      => o_h
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            wait for 50 us;
            clk <= '1';
            wait for 50 us;
            clk <= '0';
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        i_reset <= '1';
        i_enable <= '0';
        wait for 2 * sec_wait;

        -- Release reset
        i_reset <= '0';
        wait for 1 * sec_wait;

        -- Enable counting
        i_enable <= '1';
        wait for 90 * 60 * sec_wait; -- Let it run for a bit

        -- Disable counting
        i_enable <= '0';
        wait for 5 * sec_wait;

        i_enable <= '1';
        wait for 5 * 60 * sec_wait; -- Let it run for a bit


        -- Reset again, while running
        i_reset <= '1';
        wait for 2 * sec_wait;
        i_reset <= '0';

        -- Observe outputs for a while
        wait for 20 * sec_wait;

        -- Stop simulation
        wait;
    end process;

end Behavioral;
