----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2025 09:04:05 PM
-- Design Name: 
-- Module Name: testbench_module - Behavioral
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

entity testbench_module is
--  Port ( );
end testbench_module;

architecture Behavioral of testbench_module is

COMPONENT time_date_module
    PORT(  
        de_set : in  STD_LOGIC;
        de_dow : in  STD_LOGIC_VECTOR (2 downto 0);
        de_day : in  STD_LOGIC_VECTOR (5 downto 0);
        de_month : in  STD_LOGIC_VECTOR (4 downto 0);
        de_year : in  STD_LOGIC_VECTOR (7 downto 0);
         de_hour : in  STD_LOGIC_VECTOR (5 downto 0);
        de_min : in  STD_LOGIC_VECTOR (6 downto 0);
        mode_date : in STD_LOGIC;
        reset : in  STD_LOGIC;
        clk_10K : in STD_LOGIC;
        td_dcf_show: out STD_LOGIC;
        td_dow : out  STD_LOGIC_VECTOR (2 downto 0);
        td_day : out  STD_LOGIC_VECTOR (5 downto 0);
        td_month : out  STD_LOGIC_VECTOR (4 downto 0);
        td_year : out  STD_LOGIC_VECTOR (7 downto 0);
        td_hour : out  STD_LOGIC_VECTOR (5 downto 0);
        td_min : out  STD_LOGIC_VECTOR (6 downto 0);
        td_sec : out  STD_LOGIC_VECTOR (6 downto 0);
        td_date_done : out STD_LOGIC
        );
end component;


signal de_set :  STD_LOGIC;
signal de_dow :  STD_LOGIC_VECTOR (2 downto 0);
signal de_day : STD_LOGIC_VECTOR (5 downto 0);
signal de_month : STD_LOGIC_VECTOR (4 downto 0);
signal de_year : STD_LOGIC_VECTOR (7 downto 0);
signal de_hour : STD_LOGIC_VECTOR (5 downto 0);
signal de_min : STD_LOGIC_VECTOR (6 downto 0);
signal mode_date : STD_LOGIC;
signal reset : STD_LOGIC;
signal clk_10K : STD_LOGIC;
signal td_dcf_show: STD_LOGIC;
signal td_dow : STD_LOGIC_VECTOR (2 downto 0);
signal td_day : STD_LOGIC_VECTOR (5 downto 0);
signal td_month : STD_LOGIC_VECTOR (4 downto 0);
signal td_year : STD_LOGIC_VECTOR (7 downto 0);
signal td_hour : STD_LOGIC_VECTOR (5 downto 0);
signal td_min : STD_LOGIC_VECTOR (6 downto 0);
signal td_sec : STD_LOGIC_VECTOR (6 downto 0);
signal td_date_done : STD_LOGIC;

begin

dut : time_date_module
    PORT MAP(
            de_set => de_set,
            de_dow => de_dow,
            de_day => de_day,
            de_month => de_month,
            de_year => de_year,
            de_hour => de_hour,
            de_min => de_min,
            mode_date => mode_date,
            reset => reset,
            clk_10K => clk_10K,
            td_dcf_show => td_dcf_show,
            td_dow => td_dow,
            td_day => td_day,
            td_month => td_month,
            td_year => td_year,
            td_hour => td_hour,
            td_min => td_min,
            td_sec => td_sec,
            td_date_done => td_date_done
            );

stim : process
begin 


end process;

end Behavioral;
