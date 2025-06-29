----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2025 09:50:40 PM
-- Design Name: 
-- Module Name: time_date_counter - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_date_counter is
    PORT(
        de_set: in STD_LOGIC;
        reset: in STD_LOGIC;
        clk_10K : in STD_LOGIC;
        td_sec: out STD_LOGIC_VECTOR(6 downto 0);
        min_finished: out STD_LOGIC
    );
end time_date_counter;

architecture Behavioral of time_date_counter is

signal internal_clock_counter : unsigned(13 downto 0) := to_unsigned(1,14);
signal internal_second_counter : STD_LOGIC_VECTOR(7 downto 0) := bcd_0;

begin
    td_sec <= internal_second_counter(6 downto 0);
    
    process(clk_10k, reset, de_set)
    begin
        if rising_edge(reset) or rising_edge(de_set) then
            internal_clock_counter <= to_unsigned(1,internal_clock_counter'length);
            internal_second_counter <= bcd_0;
        elsif rising_edge(clk_10k) then       
            
            if internal_clock_counter =  to_unsigned(10000,internal_clock_counter'length) then
                if internal_second_counter = bcd_59 then
                    internal_clock_counter <= to_unsigned(1,internal_clock_counter'length);
                    internal_second_counter <= bcd_0;
                    min_finished <= '1';
                else
                    internal_second_counter <= increment_bcd(internal_second_counter);
                    internal_clock_counter <= to_unsigned(1,internal_clock_counter'length);
                end if;
            else
                min_finished <= '0';
                internal_clock_counter <= internal_clock_counter + 1;        
            end if;
                
        end if;
            
   end process;

end Behavioral;
