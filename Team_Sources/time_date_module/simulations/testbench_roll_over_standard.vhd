----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name: testbench_roll_over_standard - Behavioral
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
use work.bcd_package.ALL;
use ieee.std_logic_textio.all;  -- optional for textio
use std.textio.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench_roll_over_standard is
--  Port ( );
end testbench_roll_over_standard;

architecture Behavioral of testbench_roll_over_standard is

signal de_set:STD_LOGIC := '0';
signal reset:STD_Logic := '0';
signal de_dow :STD_LOGIC_VECTOR (2 downto 0) := "000";
signal de_day :STD_LOGIC_VECTOR (5 downto 0):= "000010";
signal de_month : STD_LOGIC_VECTOR (4 downto 0):= "00011";
signal de_year : STD_LOGIC_VECTOR (7 downto 0):= "00000011";
signal de_hour :  STD_LOGIC_VECTOR (5 downto 0):= "000010";
signal de_min :  STD_LOGIC_VECTOR (6 downto 0):= "0000111";
signal mode_date: STD_LOGIC := '0';
signal clk_10K : STD_LOGIC := '0';
signal td_dcf_show: STD_LOGIC;
signal td_dow : STD_LOGIC_VECTOR (2 downto 0);
signal td_day :  STD_LOGIC_VECTOR (5 downto 0);
signal td_month : STD_LOGIC_VECTOR (4 downto 0);
signal td_year : STD_LOGIC_VECTOR (7 downto 0);
signal td_hour : STD_LOGIC_VECTOR (5 downto 0);
signal td_min : STD_LOGIC_VECTOR (6 downto 0);
signal td_sec : STD_LOGIC_VECTOR (6 downto 0);
signal td_date_status : STD_LOGIC;

signal temp_bcd : STD_LOGIC_VECTOR (7 downto 0);

begin

dut : entity work.time_date_module
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
            mode_date => mode_date,
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
        --minute
        wait until rising_edge(clk_10k);
        de_day <= bcd_1(5 downto 0);
        de_month <=bcd_1(4 downto 0);
        de_year <= bcd_1(7 downto 0);
        de_hour <= bcd_0(5 downto 0);
        de_min <= bcd_0(6 downto 0);
        de_set<= '1';
        wait until rising_edge(clk_10k);
        de_set<= '0';
        wait for 61 sec;
        
        --hour
        wait until rising_edge(clk_10k);
        de_day <= bcd_1(5 downto 0);
        de_month <=bcd_1(4 downto 0);
        de_year <= bcd_1(7 downto 0);
        de_hour <= bcd_0(5 downto 0);
        de_min <= bcd_59(6 downto 0);
        de_set<= '1';
        wait until rising_edge(clk_10k);
        de_set<= '0';
        wait for 61 sec;
        
        --day
        wait until rising_edge(clk_10k);
        de_day <= bcd_1(5 downto 0);
        de_month <=bcd_1(4 downto 0);
        de_year <= bcd_1(7 downto 0);
        de_hour <= bcd_23(5 downto 0);
        de_min <= bcd_59(6 downto 0);
        de_set<= '1';
        wait until rising_edge(clk_10k);
        de_set<= '0';
        wait for 61 sec;
        
        --dow
        wait until rising_edge(clk_10k);
        de_day <= bcd_1(5 downto 0);
        de_month <=bcd_1(4 downto 0);
        de_year <= bcd_1(7 downto 0);
        de_hour <= bcd_23(5 downto 0);
        de_min <= bcd_59(6 downto 0);
        de_set<= '1';
        wait until rising_edge(clk_10k);
        de_set<= '0';
        wait for 61 sec;
        
        --month
        wait until rising_edge(clk_10k);
        de_day <= bcd_31(5 downto 0);
        de_month <=bcd_1(4 downto 0);
        de_year <= bcd_1(7 downto 0);
        de_hour <= bcd_23(5 downto 0);
        de_min <= bcd_59(6 downto 0);
        de_set<= '1';
        wait until rising_edge(clk_10k);
        de_set<= '0';
        wait for 61 sec;
        
        --year
        wait until rising_edge(clk_10k);
        de_day <= bcd_31(5 downto 0);
        de_month <=bcd_12(4 downto 0);
        de_year <= bcd_1(7 downto 0);
        de_hour <= bcd_23(5 downto 0);
        de_min <= bcd_59(6 downto 0);
        de_set<= '1';
        wait until rising_edge(clk_10k);
        de_set<= '0';
        wait for 61 sec;
        
        --century
        wait until rising_edge(clk_10k);
        de_day <= bcd_31(5 downto 0);
        de_month <=bcd_12(4 downto 0);
        de_year <= bcd_99(7 downto 0);
        de_hour <= bcd_23(5 downto 0);
        de_min <= bcd_59(6 downto 0);
        de_set<= '1';
        wait until rising_edge(clk_10k);
        de_set<= '0';
        wait for 61 sec;
            
    end process;
check : process
    begin
        -- min
        wait until falling_edge(de_set);
        wait until falling_edge(clk_10k);
        temp_bcd(6 downto 0) <= td_min;
        wait until td_sec = bcd_59(6 downto 0);
        assert temp_bcd(6 downto 0) = td_min
            report "min to early"
            severity error;
        wait for 1 sec;
        temp_bcd <= increment_bcd(temp_bcd);
        wait until falling_edge(clk_10k);
        assert temp_bcd(6 downto 0) = td_min and td_sec = bcd_0(6 downto 0)
            report "min to late" 
            severity error;
            
        -- hour
        wait until falling_edge(de_set);
        wait until falling_edge(clk_10k);
        temp_bcd(5 downto 0) <= td_hour;
        wait until td_sec = bcd_59(6 downto 0);
        assert temp_bcd(5 downto 0) = td_hour 
            report "hour to early" 
            severity error;
        wait for 1 sec;
        temp_bcd <= increment_bcd(temp_bcd);
        wait until falling_edge(clk_10k);
        assert temp_bcd(5 downto 0) = td_hour and td_min = bcd_0(6 downto 0)
            report "hour to late" 
            severity error;
            
        -- dow
        wait until falling_edge(de_set);
        wait until falling_edge(clk_10k);
        temp_bcd(2 downto 0) <= td_dow;
        wait until td_sec = bcd_59(6 downto 0);
        assert temp_bcd(2 downto 0) = td_dow
            report "dow to early" 
            severity error;
        wait for 1 sec;
        temp_bcd <= increment_bcd(temp_bcd);
        wait until falling_edge(clk_10k);
        assert temp_bcd(2 downto 0) = td_dow and td_hour = bcd_0(5 downto 0)
            report "dow to late" 
            severity error;
            
        -- day
        wait until falling_edge(de_set);
        wait until falling_edge(clk_10k);
        temp_bcd(5 downto 0) <= td_day;
        wait until td_sec = bcd_59(6 downto 0);
        assert temp_bcd(5 downto 0) = td_day
            report "day to early" 
            severity error;
        wait for 1 sec;
        temp_bcd <= increment_bcd(temp_bcd);
        wait until falling_edge(clk_10k);
        assert temp_bcd(5 downto 0) = td_day and td_hour = bcd_0(5 downto 0)
            report "day to late" 
            severity error;
            

        -- month
        wait until falling_edge(de_set);
        wait until falling_edge(clk_10k);
        temp_bcd(4 downto 0) <= td_month;
        wait until td_sec = bcd_59(6 downto 0);
        assert temp_bcd(4 downto 0) = td_month
            report "month to early" 
            severity error;
        wait for 1 sec;
        temp_bcd <= increment_bcd(temp_bcd);
        wait until falling_edge(clk_10k);
        assert temp_bcd(4 downto 0) = td_month and td_day = bcd_1(5 downto 0) 
            report "month to late" 
            severity error;
            
        -- year
        wait until falling_edge(de_set);
        wait until falling_edge(clk_10k);
        temp_bcd(7 downto 0) <= td_year;
        wait until td_sec = bcd_59(6 downto 0);
        assert temp_bcd(7 downto 0) = td_year
            report "year to early" 
            severity error;
        wait for 1 sec;
        temp_bcd <= increment_bcd(temp_bcd);
        wait until falling_edge(clk_10k);
        assert temp_bcd(7 downto 0) = td_year and td_month = bcd_1(4 downto 0) 
            report "year to late" 
            severity error;
            
        -- century
        wait until falling_edge(de_set);
        wait until falling_edge(clk_10k);
        temp_bcd(7 downto 0) <= td_year;
        wait until td_sec = bcd_59(6 downto 0);
        assert temp_bcd(7 downto 0) = td_year
            report "century to early" 
            severity error;
        wait for 1 sec;
        temp_bcd <= increment_bcd(temp_bcd);
        wait until falling_edge(clk_10k);
        assert bcd_1(7 downto 0)  = td_year and td_month = bcd_1(4 downto 0) 
            report "century to late" 
            severity error;
       
        wait until rising_edge(clk_10k);
        assert false report "Simulation finished successfully." severity failure;
end process;


end Behavioral;
