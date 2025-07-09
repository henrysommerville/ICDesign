----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name: testbench_fsm - Behavioral
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

entity stopwatch_fsm_tb is
end stopwatch_fsm_tb;

architecture Behavioral of stopwatch_fsm_tb is

    -- Component under test
    component stopwatch_fsm is 
        Port (
            clk             : in STD_LOGIC;
            reset           : in STD_LOGIC;
    
            i_sw_enable     : in STD_LOGIC;
            i_sw_lap_toggle : in STD_LOGIC;
            i_sw_reset      : in STD_LOGIC;
            
            o_counter_active : out STD_LOGIC;
            o_sw_reset       : out STD_LOGIC;
            o_lap_toggle     : out STD_LOGIC
         );
    end component;

    -- Testbench signals
    signal clk : STD_LOGIC;
    signal reset           :  STD_LOGIC := '0';

    signal i_sw_enable     :  STD_LOGIC := '0';
    signal i_sw_lap_toggle :  STD_LOGIC := '0';
    signal i_sw_reset      :  STD_LOGIC := '0';
    
    signal o_counter_active :  STD_LOGIC := '0';
    signal o_sw_reset       :  STD_LOGIC := '0';
    signal o_lap_toggle     :  STD_LOGIC := '0';


    -- Clock period definition
    constant c_CLK_PERIOD : time := 100000 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: stopwatch_fsm
        port map (
            clk         => clk,
            reset       => reset,
            
            i_sw_enable        => i_sw_enable,
            i_sw_lap_toggle => i_sw_lap_toggle,
            i_sw_reset => i_sw_reset,
            
            o_counter_active => o_counter_active,
            o_sw_reset => o_sw_reset,
            o_lap_toggle => o_lap_toggle
            
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
        
        wait for 5 * c_CLK_PERIOD;
        i_sw_enable         <= '1';
        i_sw_lap_toggle     <= '0';
        i_sw_reset          <= '0';
        
        wait for 2 * c_CLK_PERIOD;
        
        i_sw_enable         <= '0';
        i_sw_lap_toggle     <= '0';
        i_sw_reset          <= '0';

        -- Change input again to simulate new snapshot

        wait for 2 * c_CLK_PERIOD;
        
        i_sw_enable         <= '0';
        i_sw_lap_toggle     <= '1';
        i_sw_reset          <= '0';


        wait for 2 * c_CLK_PERIOD;
        i_sw_enable         <= '1';
        i_sw_lap_toggle     <= '0';
        i_sw_reset          <= '0';
        
        wait for 2 * c_CLK_PERIOD;
        i_sw_enable         <= '1';
        i_sw_lap_toggle     <= '1';
        i_sw_reset          <= '0';
        
        
        wait for 2 * c_CLK_PERIOD;
        i_sw_enable         <= '1';
        i_sw_lap_toggle     <= '0';
        i_sw_reset          <= '0';
        
        wait for 2 * c_CLK_PERIOD;
        i_sw_enable         <= '0';
        i_sw_lap_toggle     <= '0';
        i_sw_reset          <= '1';
        

        wait for 2 * c_CLK_PERIOD;

        -- Stop simulation
        wait;
    end process;

end Behavioral;
