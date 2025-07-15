----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/19/2025 09:18:21 PM
-- Design Name: 
-- Module Name: bcd_package - Behavioral
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

package bcd_package is
    constant bcd_0 : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    constant bcd_1 : STD_LOGIC_VECTOR(7 downto 0) := "00000001";
    constant bcd_2 : STD_LOGIC_VECTOR(7 downto 0) := "00000010";
    constant bcd_3 : STD_LOGIC_VECTOR(7 downto 0) := "00000011";
    constant bcd_4 : STD_LOGIC_VECTOR(7 downto 0) := "00000100";
    constant bcd_6 : STD_LOGIC_VECTOR(7 downto 0) := "00000110";
    constant bcd_8 : STD_LOGIC_VECTOR(7 downto 0) := "00001000";
    constant bcd_9 : STD_LOGIC_VECTOR(7 downto 0) := "00001001";
    constant bcd_10 : STD_LOGIC_VECTOR(7 downto 0) := "00010000";
    constant bcd_12 : STD_LOGIC_VECTOR(7 downto 0) := "00010010";
    constant bcd_13 : STD_LOGIC_VECTOR(7 downto 0) := "00010011";
    constant bcd_23 : STD_LOGIC_VECTOR(7 downto 0) := "00100011";
    constant bcd_28 : STD_LOGIC_VECTOR(7 downto 0) := "00101000";
    constant bcd_29 : STD_LOGIC_VECTOR(7 downto 0) := "00101001";
    constant bcd_30 : STD_LOGIC_VECTOR(7 downto 0) := "00110000";
    constant bcd_31 : STD_LOGIC_VECTOR(7 downto 0) := "00110001";
    constant bcd_59 : STD_LOGIC_VECTOR(7 downto 0) := "01011001";
    constant bcd_99 : STD_LOGIC_VECTOR(7 downto 0) := "10011001";
    function increment_bcd(bcd_in : STD_LOGIC_VECTOR(7 downto 0))return STD_LOGIC_VECTOR;
end package bcd_package;

package body bcd_package is
    function increment_bcd ( bcd_in : in STD_LOGIC_VECTOR(7 downto 0))
        return STD_LOGIC_VECTOR is 
        variable first_digit : unsigned(3 downto 0);
        variable second_digit : unsigned(3 downto 0);
        
        begin
            first_digit := unsigned(bcd_in(7 downto 4));
            second_digit := unsigned(bcd_in(3 downto 0));
            
            second_digit:= second_digit + 1;
            
            if second_digit = 10 then
                first_digit := first_digit + 1;
                second_digit := "0000";
            end if;
           
        return (std_logic_vector(first_digit) & std_logic_vector(second_digit));
    end increment_bcd;
end package body;