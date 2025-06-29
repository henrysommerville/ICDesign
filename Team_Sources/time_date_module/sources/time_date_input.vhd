----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2025 09:48:38 PM
-- Design Name: 
-- Module Name: time_date_input - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_date_input is
    PORT(
        de_set : in  STD_LOGIC;
        de_dow : in  STD_LOGIC_VECTOR (2 downto 0);
        de_day : in  STD_LOGIC_VECTOR (5 downto 0);
        de_month : in  STD_LOGIC_VECTOR (4 downto 0);
        de_year : in  STD_LOGIC_VECTOR (7 downto 0);
        de_hour : in  STD_LOGIC_VECTOR (5 downto 0);
        de_min : in  STD_LOGIC_VECTOR (6 downto 0);
        reset : in  STD_LOGIC;
        clk_10K : in STD_LOGIC;
        reset_counter : out STD_LOGIC;
        dow : out  STD_LOGIC_VECTOR (2 downto 0);
        day : out STD_LOGIC_VECTOR (5 downto 0);
        month : out  STD_LOGIC_VECTOR (4 downto 0);
        year : out  STD_LOGIC_VECTOR (7 downto 0);
        hour : out  STD_LOGIC_VECTOR (5 downto 0);
        min : out  STD_LOGIC_VECTOR (6 downto 0);
        synch_td : out STD_LOGIC;
        reset_td : out STD_LOGIC
    );
end time_date_input;

architecture Behavioral of time_date_input is
begin
    
process(de_set, reset)
    begin
        if rising_edge(reset) then
            dow <= "000";
            day <= "000001";
            month <= "00001";
            year <= "00000001";
            hour <= "000000";
            min <= "0000000";
        elsif rising_edge(de_set) then
            dow <= de_dow;
            day <= de_day;
            month <= de_month;
            year <= de_year;
            hour <= de_hour;
            min <= de_min;
        end if;
end process;

process(de_set, reset)
    begin
  
        if rising_edge(reset) then
            reset_counter <= '1';
            reset_td <= '1';   
        elsif rising_edge(de_set) then
            reset_counter <= '1';
            synch_td <= '1';
        elsif falling_edge(reset) or falling_edge(de_set) then
            reset_counter <= '0';   
            reset_td <= '0';
            synch_td <= '0';  
        end if;
        

end process;

end Behavioral;
