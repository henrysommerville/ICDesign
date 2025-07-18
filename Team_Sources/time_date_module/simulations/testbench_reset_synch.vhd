----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name: testbench_reset_synch - Behavioral
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
library MFclock;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use MFclock.bcd_package.ALL;


entity testbench_reset_synch is
--  Port ( );
end testbench_reset_synch;

architecture Behavioral of testbench_reset_synch is

signal de_set:STD_LOGIC := '0';
signal reset:STD_Logic := '0';
signal de_dow :STD_LOGIC_VECTOR (2 downto 0) := "001";
signal de_day :STD_LOGIC_VECTOR (5 downto 0):= "000010";
signal de_month : STD_LOGIC_VECTOR (4 downto 0):= "00011";
signal de_year : STD_LOGIC_VECTOR (7 downto 0):= "00000011";
signal de_hour :  STD_LOGIC_VECTOR (5 downto 0):= "000010";
signal de_min :  STD_LOGIC_VECTOR (6 downto 0):= "0000111";
signal mode: STD_LOGIC_VECTOR (2 downto 0) := "000";
signal clk_10K : STD_LOGIC := '0';
signal td_dcf_show: STD_LOGIC;
signal td_dow : STD_LOGIC_VECTOR (7 downto 0);
signal td_day :  STD_LOGIC_VECTOR (7 downto 0);
signal td_month : STD_LOGIC_VECTOR (7 downto 0);
signal td_year : STD_LOGIC_VECTOR (7 downto 0);
signal td_hour : STD_LOGIC_VECTOR (7 downto 0);
signal td_min : STD_LOGIC_VECTOR (7 downto 0);
signal td_sec : STD_LOGIC_VECTOR (7 downto 0);
signal td_date_status : STD_LOGIC;

begin

dut : entity MFclock.time_date_module
    PORT MAP(
            de_dow => de_dow,
            de_day => de_day,
            de_month => de_month,
            de_year => de_year,
            de_hour => de_hour,
            de_min  => de_min,
            de_set => de_set,
            clk_10K => clk_10K,
            td_dcf_show => td_dcf_show,
            td_dow  => td_dow,
            td_day => td_day,
            td_month => td_month,
            td_year => td_year,
            td_hour => td_hour,
            td_min => td_min,
            td_sec => td_sec,
            td_date_status => td_date_status,
            mode => mode,
            reset => reset
            );


clk : process
    begin
        wait for 50 us;
        clk_10k <= '1';
        wait for 50 us;
        clk_10k <= '0';  
    end process;
stim : process
    begin
        wait until rising_edge(clk_10k);
        reset <= '1';
        wait until rising_edge(clk_10k);
        reset <= '0';
        wait for 200us;
        wait until rising_edge(clk_10k);
        de_set <= '1';
        wait until rising_edge(clk_10k);
        de_set <= '0';
        wait for 200us;
        wait until rising_edge(clk_10k);
        de_set <= '1';
        reset <= '1';
        wait until rising_edge(clk_10k);
        de_set <= '0';
        reset <= '0';
        wait for 10 sec;
    end process;
check : process
    begin
        wait until rising_edge(clk_10k);
        wait until rising_edge(clk_10k);
        assert td_dow = bcd_0 and
                td_day = bcd_1 and
                td_month = bcd_1 and
                td_year = bcd_1 and
                td_hour = bcd_0 and
                td_min = bcd_0
            report "default time values invalid" 
            severity error;
            
        wait until rising_edge(reset);
        wait until rising_edge(clk_10k);
        wait until rising_edge(clk_10k);
        assert td_dow = bcd_0 and
                td_day = bcd_1 and
                td_month = bcd_1 and
                td_year = bcd_1 and
                td_hour = bcd_0 and
                td_min = bcd_0
            report "reset not sucessfull" 
            severity error;
            
        wait until rising_edge(de_set);
        wait until rising_edge(clk_10k);
        wait until rising_edge(clk_10k);
        assert td_dow(2 downto 0) = de_dow and
                td_day(5 downto 0) = de_day and
                td_month(4 downto 0) = de_month and
                td_year(7 downto 0) = de_year and
                td_hour(5 downto 0) = de_hour and
                td_min(6 downto 0) = de_min
            report "synch not sucessfull" 
            severity error;
        
        wait until rising_edge(reset) and rising_edge(de_set);
        wait until rising_edge(clk_10k);
        wait until rising_edge(clk_10k);
        assert td_dow = bcd_0 and
                td_day = bcd_1 and
                td_month = bcd_1 and
                td_year = bcd_1 and
                td_hour = bcd_0 and
                td_min = bcd_0
            report "reset with synch not sucessfull" 
            severity error;

        wait until rising_edge(clk_10k);
        assert false report "Simulation finished successfully." severity failure;
end process;


end Behavioral;