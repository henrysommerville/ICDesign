----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name: stopwatch_lap_reg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stopwatch_lap_reg_tb is
end stopwatch_lap_reg_tb;

architecture Behavioral of stopwatch_lap_reg_tb is

    -- Component under test
    component stopwatch_lap_reg is 
        Port (
            clk         : in STD_LOGIC;
            reset       : in STD_LOGIC;
            i_hs        : in STD_LOGIC_VECTOR(7 downto 0); 
            i_s         : in STD_LOGIC_VECTOR(7 downto 0);
            i_min       : in STD_LOGIC_VECTOR(7 downto 0);
            i_h         : in STD_LOGIC_VECTOR(7 downto 0);
            o_lap_hs    : out STD_LOGIC_VECTOR(7 downto 0); 
            o_lap_s     : out STD_LOGIC_VECTOR(7 downto 0);
            o_lap_min   : out STD_LOGIC_VECTOR(7 downto 0);
            o_lap_h     : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Testbench signals
    signal clk         : STD_LOGIC := '0';
    signal reset       : STD_LOGIC := '0';
    signal i_hs        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal i_s         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal i_min       : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal i_h         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_lap_hs    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_lap_s     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_lap_min   : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_lap_h     : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: stopwatch_lap_reg
        port map (
            clk         => clk,
            reset       => reset,
            i_hs        => i_hs,
            i_s         => i_s,
            i_min       => i_min,
            i_h         => i_h,
            o_lap_hs    => o_lap_hs,
            o_lap_s     => o_lap_s,
            o_lap_min   => o_lap_min,
            o_lap_h     => o_lap_h
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
        -- Reset the design
        reset <= '1';
        wait for 2 * c_CLK_PERIOD;
        reset <= '0';

        -- Load time into registers
        i_hs  <= x"09";
        i_s   <= x"59";
        i_min <= x"23";
        i_h   <= x"12";

        wait for 2 * c_CLK_PERIOD;

        -- Change input again to simulate new snapshot
        i_hs  <= x"10";
        i_s   <= x"00";
        i_min <= x"24";
        i_h   <= x"13";

        wait for 2 * c_CLK_PERIOD;

        -- Reset again
        reset <= '1';
        wait for 2 * c_CLK_PERIOD;
        reset <= '0';

        wait for 2 * c_CLK_PERIOD;

        -- Stop simulation
        wait;
    end process;

end Behavioral;
