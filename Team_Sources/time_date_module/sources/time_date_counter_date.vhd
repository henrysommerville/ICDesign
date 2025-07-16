----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/17/2025 11:41:50 PM
-- Design Name: 
-- Module Name: time_date_counter_date - Behavioral
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity time_date_counter_date is
    PORT(
        mode: in STD_LOGIC_VECTOR(2 downto 0);
        clk_10K : in STD_LOGIC;
        reset : in STD_LOGIC;
        td_date_status: out STD_LOGIC
    );
end time_date_counter_date;

architecture Behavioral of time_date_counter_date is


signal internal_date_counter : unsigned(14 downto 0) := to_unsigned(1,15);
signal internal_date_counter_active : STD_LOGIC := '0';
signal reset_prev : std_logic := '0';

begin
    
    td_date_status <= internal_date_counter_active;
    process(clk_10k)
    begin
        if rising_edge(clk_10k) then
            if reset = '1' and reset_prev = '0' then
                internal_date_counter_active <= '0';
                internal_date_counter <= to_unsigned(1,internal_date_counter'length);
            elsif internal_date_counter_active = '1' then
                if internal_date_counter = to_unsigned(30000,internal_date_counter'length) then
                    internal_date_counter <= to_unsigned(1,internal_date_counter'length);
                    internal_date_counter_active <= '0';
                else
                    internal_date_counter <= internal_date_counter + 1;
                end if;
                
            elsif mode = "001" and internal_date_counter_active = '0' then
                internal_date_counter_active <= '1';
            end if;
            reset_prev <= reset;
        end if;
        

   end process;
   
end Behavioral;
