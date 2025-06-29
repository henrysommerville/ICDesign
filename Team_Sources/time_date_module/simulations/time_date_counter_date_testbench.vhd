----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name: testbench_counter_date - Behavioral
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

entity testbench_counter_date is
--  Port ( );
end testbench_counter_date;

architecture Behavioral of testbench_counter_date is


signal mode_date : STD_LOGIC := '0';
signal clk_10K : STD_LOGIC := '0';
signal td_date_status : STD_LOGIC;

begin

dut : entity work.time_date_counter_date
    PORT MAP(
            mode_date => mode_date,
            clk_10K => clk_10K,
            td_date_status => td_date_status
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
        wait for 650 us;
        mode_date <= '1';
        wait for 50 us;
        mode_date <= '0';
    end process;


end Behavioral;
