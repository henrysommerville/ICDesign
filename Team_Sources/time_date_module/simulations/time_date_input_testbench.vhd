----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2025 10:34:41 PM
-- Design Name: 
-- Module Name: testbench_input - Behavioral
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

entity testbench_input is
--  Port ( );
end testbench_input;

architecture Behavioral of testbench_input is

COMPONENT time_date_input is
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
        update_status : in STD_LOGIC;
        counter_active : out STD_LOGIC;
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
end component;

signal de_set : STD_LOGIC := '0';
signal de_dow : STD_LOGIC_VECTOR (2 downto 0):= "001";
signal de_day : STD_LOGIC_VECTOR (5 downto 0):="100001";
signal de_month : STD_LOGIC_VECTOR (4 downto 0):="00101";
signal de_year : STD_LOGIC_VECTOR (7 downto 0):="00000010";
signal de_hour : STD_LOGIC_VECTOR (5 downto 0):="010100";
signal de_min : STD_LOGIC_VECTOR (6 downto 0):="0110000";
signal reset : STD_LOGIC := '0';
signal clk_10K : STD_LOGIC:= '0';
signal update_status : STD_LOGIC:= '0';
signal counter_active : STD_LOGIC;
signal reset_counter : STD_LOGIC;
signal dow : STD_LOGIC_VECTOR (2 downto 0);
signal day : STD_LOGIC_VECTOR (5 downto 0);
signal month : STD_LOGIC_VECTOR (4 downto 0);
signal year : STD_LOGIC_VECTOR (7 downto 0);
signal hour : STD_LOGIC_VECTOR (5 downto 0);
signal min : STD_LOGIC_VECTOR (6 downto 0);
signal synch_td : STD_LOGIC;
signal reset_td : STD_LOGIC;

begin

dut : time_date_input
    PORT MAP(
            de_set => de_set,
            de_dow => de_dow,
            de_day => de_day,
            de_month => de_month,
            de_year => de_year,
            de_hour => de_hour,
            de_min => de_min,
            reset => reset,
            clk_10K => clk_10K,
            update_status => update_status,
            counter_active => counter_active,
            reset_counter => reset_counter,
            day => day,
            dow => dow,
            month => month,
            year => year,
            hour => hour,
            min => min,
            synch_td => synch_td,
            reset_td => reset_td
            );


stim : process
    begin
        wait for 1 ns;
        de_set <= '1';
                
        wait for 1 ns;
        
        de_set <= '0';

        wait for 5 ns;
        
        update_status <= '1';
        wait for 1 ns;
        update_status <= '0';
        
        wait for 10 ns;
        
        reset <= '1';
        
        wait for 1 ns;
        
        reset <= '0';
        
        wait for 5 ns;
        
        update_status <= '1';
        
        wait for 1 ns;
        
        update_status <= '0';
        
        wait for 1 ns;
    end process;

end Behavioral;
