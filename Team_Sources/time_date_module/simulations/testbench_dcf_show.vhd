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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench_dcf_show is
--  Port ( );
end testbench_dcf_show;

architecture Behavioral of testbench_dcf_show is

signal de_set:STD_LOGIC := '0';
signal reset:STD_Logic := '0';
signal de_dow :STD_LOGIC_VECTOR (2 downto 0) := "000";
signal de_day :STD_LOGIC_VECTOR (5 downto 0):= "000001";
signal de_month : STD_LOGIC_VECTOR (4 downto 0):= "00001";
signal de_year : STD_LOGIC_VECTOR (7 downto 0):= "00000001";
signal de_hour :  STD_LOGIC_VECTOR (5 downto 0):= "000000";
signal de_min :  STD_LOGIC_VECTOR (6 downto 0):= "0000000";
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

signal start_time: time;
signal stop_time:time;

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
        de_set <= '1';
        wait until rising_edge(clk_10k);
        de_set <= '0';
        wait for 1 sec;
        wait until rising_edge(clk_10k);
        reset <= '1';
        wait until rising_edge(clk_10k);
        de_set <= '1';
        wait until rising_edge(clk_10k);
        reset <= '0';
        de_set <= '0';
        wait for 61 sec;
        
    end process;
check : process
    begin
        wait until rising_edge(clk_10k);
            
        wait until rising_edge(de_set);
        wait until rising_edge(clk_10k);
        wait until rising_edge(clk_10k);
        assert td_dcf_show ='1'
            report "td_dcf_show invalid after synch" 
            severity error;
        
        wait until rising_edge(reset);
        wait until rising_edge(clk_10k);
        wait until rising_edge(clk_10k);
        assert td_dcf_show ='0'
            report "td_dcf_show invalid after reset" 
            severity error;
        
        wait until rising_edge(td_dcf_show);
        start_time <= now;
        wait until falling_edge(td_dcf_show);
        stop_time <= now;

        wait until rising_edge(clk_10k);  
        assert (stop_time-start_time) = 60 sec 
            report "td_dcf_show reset not on time"
            severity error;
        report "Delta Time: " & time'image(stop_time - start_time);
            
        wait until rising_edge(clk_10k);
        assert false report "Simulation finished successfully." severity failure;
end process;


end Behavioral;