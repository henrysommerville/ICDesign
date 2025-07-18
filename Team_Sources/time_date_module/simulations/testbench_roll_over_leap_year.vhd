----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name: testbench_roll_over_leap_year - Behavioral
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
use ieee.std_logic_textio.all;
use std.textio.all;


entity testbench_roll_over_leap_year is
--  Port ( );
end testbench_roll_over_leap_year;

architecture Behavioral of testbench_roll_over_leap_year is

signal de_set:STD_LOGIC := '0';
signal reset:STD_Logic := '0';
signal de_dow :STD_LOGIC_VECTOR (2 downto 0) := "000";
signal de_day :STD_LOGIC_VECTOR (5 downto 0):= "000001";
signal de_month : STD_LOGIC_VECTOR (4 downto 0):= "00001";
signal de_year : STD_LOGIC_VECTOR (7 downto 0):= "00000001";
signal de_hour :  STD_LOGIC_VECTOR (5 downto 0):= "000001";
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

signal current_year: integer := 0; 

function int_to_bcd(i : integer) return std_logic_vector is
    variable tens    : integer;
    variable ones    : integer;
    variable bcd     : std_logic_vector(7 downto 0);
begin
    tens := i / 10;
    ones := i mod 10;
    bcd(7 downto 4) := std_logic_vector(to_unsigned(tens, 4));
    bcd(3 downto 0) := std_logic_vector(to_unsigned(ones, 4));
    return bcd;
end function;

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
        for ii in 0 to 20 loop
            current_year <= ii;
            
            wait until rising_edge(clk_10k);
            de_day <= bcd_28(5 downto 0);
            de_month <= bcd_2(4 downto 0);
            de_year <= int_to_bcd(ii)(7 downto 0);
            de_hour <= bcd_23(5 downto 0);
            de_min <= bcd_59(6 downto 0);
            de_set<= '1';
            wait until rising_edge(clk_10k);
            de_set<= '0';
            wait for 119 sec;
        end loop;
        
       
        assert false report "Simulation finished successfully." severity failure;
    end process;

check : process
    begin
        for ii in 0 to 20 loop
            -- year
            wait until falling_edge(de_set);
            wait until falling_edge(clk_10k);
            wait until td_sec = bcd_59(6 downto 0);
            wait for 1 sec;
            wait until falling_edge(clk_10k);
            if current_year mod 4 = 0 then
                assert td_month = bcd_2 and td_day = bcd_29
                    report "wrong roll over for leap year: "  & integer'image(current_year)
                    severity error;
            else
                assert td_month = bcd_3 and td_day = bcd_1
                    report "wrong roll over for normal year: "  & integer'image(current_year)
                    severity error;
            end if;
        end loop;
       
        
       
        assert false report "Simulation finished successfully." severity failure;
    end process;

end Behavioral;