----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2025 10:34:41 PM
-- Design Name: 
-- Module Name: testbench_count - Behavioral
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

entity testbench_count is
--  Port ( );
end testbench_count;

architecture Behavioral of testbench_count is


signal reset : STD_LOGIC:= '0';
signal clk_10K : STD_LOGIC:= '0';
signal td_sec : STD_LOGIC_VECTOR (6 downto 0);
signal min_finished : STD_LOGIC;

begin

dut : entity work.time_date_counter
    PORT MAP(
            reset => reset,
            clk_10K => clk_10K,
            td_sec => td_sec,
            min_finished => min_finished
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
        wait for 50 us;
        wait for 5 sec;
        reset <= '1';
        wait for 100 us;
        reset <= '1';
        wait for 100 us;
        reset<= '0';
        wait for 60sec;
        reset <= '1';
        wait for 100 us;
        reset <= '0';        
        

end process;
end Behavioral;
