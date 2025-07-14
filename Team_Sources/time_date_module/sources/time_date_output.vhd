----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2025 09:50:15 PM
-- Design Name: 
-- Module Name: time_date_output - Behavioral
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



entity time_date_output is
    PORT(
        de_dow : in  STD_LOGIC_VECTOR (2 downto 0);
        de_day : in STD_LOGIC_VECTOR (5 downto 0);
        de_month : in  STD_LOGIC_VECTOR (4 downto 0);
        de_year : in  STD_LOGIC_VECTOR (7 downto 0);
        de_hour : in  STD_LOGIC_VECTOR (5 downto 0);
        de_min : in  STD_LOGIC_VECTOR (6 downto 0);
        de_set : in STD_LOGIC;
        reset : in STD_LOGIC;
        clk_10K : in STD_LOGIC;
        td_dcf_show: out STD_LOGIC;
        td_dow : out  STD_LOGIC_VECTOR (7 downto 0);
        td_day : out  STD_LOGIC_VECTOR (7 downto 0);
        td_month : out  STD_LOGIC_VECTOR (7 downto 0);
        td_year : out  STD_LOGIC_VECTOR (7 downto 0);
        td_hour : out  STD_LOGIC_VECTOR (7 downto 0);
        td_min : out  STD_LOGIC_VECTOR (7 downto 0);
        td_sec : out  STD_LOGIC_VECTOR (7 downto 0)
    );
end time_date_output;


architecture Behavioral of time_date_output is

function check_leap_year ( year : in STD_LOGIC_VECTOR(7 downto 0))
    return boolean is 
    variable first_digit : STD_LOGIC_VECTOR(3 downto 0);
    variable second_digit : STD_LOGIC_VECTOR(3 downto 0);
    
    begin
    
       first_digit := year(7 downto 4);
       second_digit := year(3 downto 0);
       
       if 
           ((first_digit(0) = '0') and (second_digit = "1000" or second_digit = "0100" or second_digit = "0000")) or   
           ((first_digit(0) = '1') and (second_digit = "0010" or second_digit = "0110"))
       then
            return True;
       else
            return False;
       end if;
       
end check_leap_year;

signal internal_dow : STD_LOGIC_VECTOR(7 downto 0) := bcd_0;
signal internal_day : STD_LOGIC_VECTOR(7 downto 0) := bcd_1;
signal internal_month : STD_LOGIC_VECTOR(7 downto 0):= bcd_1;
signal internal_year : STD_LOGIC_VECTOR(7 downto 0):= bcd_1;
signal internal_hour : STD_LOGIC_VECTOR(7 downto 0):= bcd_0;
signal internal_min : STD_LOGIC_VECTOR(7 downto 0):= bcd_0;

signal internal_clock_counter : unsigned(13 downto 0) := to_unsigned(1,14);
signal internal_second_counter : STD_LOGIC_VECTOR(7 downto 0) := bcd_0;

signal leap_year : boolean;
signal even_month : boolean; 
signal below_august : boolean;
signal is_februar : boolean;

signal reset_prev : std_logic := '0';
signal de_set_prev : std_logic := '0';

begin

td_dow <= internal_dow;
td_day <= internal_day;
td_month <= internal_month;
td_year <= internal_year;
td_hour <= internal_hour;
td_min <= internal_min;
td_sec <= internal_second_counter;


process(clk_10k)
begin
    if rising_edge(clk_10K) then
        if reset = '1' and reset_prev = '0' then 
            td_dcf_show <= '0';
            
            internal_clock_counter <= to_unsigned(1,internal_clock_counter'length);
            internal_second_counter <= bcd_0;
            
            internal_dow <= bcd_0;
            internal_day <= bcd_1;
            internal_month <= bcd_1;
            internal_year <= bcd_1;
            internal_hour<= bcd_0;
            internal_min <= bcd_0;
        elsif de_set = '1' and de_set_prev = '0' then
            td_dcf_show <= '1';
            
            internal_clock_counter <= to_unsigned(1,internal_clock_counter'length);
            internal_second_counter <= bcd_0;
            
            internal_dow(2 downto 0) <= de_dow;
            internal_day(5 downto 0) <= de_day;
            internal_month(4 downto 0) <= de_month;
            internal_year(7 downto 0) <= de_year;
            internal_hour(5 downto 0) <= de_hour;
            internal_min(6 downto 0) <= de_min;
        else
            if internal_clock_counter =  to_unsigned(10000,internal_clock_counter'length) then
                        if internal_second_counter = bcd_59 then
                            internal_clock_counter <= to_unsigned(1,internal_clock_counter'length);
                            internal_second_counter <= bcd_0;
                            
                            td_dcf_show <= '0';
            
                           if internal_min = bcd_59 then
                                internal_min <= bcd_0;
                                if internal_hour = bcd_23 then
                                    internal_hour <= bcd_0;
                                    if internal_dow = bcd_6 then
                                        internal_dow <= bcd_0;
                                    else
                                        internal_dow <= increment_bcd(internal_dow);
                                    end if;
                                    
                                    leap_year <= check_leap_year(internal_year);
                                    even_month <= (internal_month(0) = '0');
                                    below_august <= (unsigned(internal_month(3 downto 0)) < to_unsigned(8, 4)) and (internal_month(7 downto 4) = "0000");
                                    is_februar  <= (internal_month = bcd_2);
                                                    
                                    if
                                        ((below_august and (not even_month) and (internal_day = bcd_31)) or
                                        ((not below_august) and even_month and (internal_day = bcd_31)) or
                                        ((not below_august) and (not even_month) and (internal_day = bcd_30)) or
                                        (below_august and even_month and (not is_februar) and (internal_day = bcd_30)) or
                                        (is_februar and leap_year and (internal_day = bcd_28)) or
                                        (is_februar and (not leap_year) and (internal_day = bcd_29)))
                                        then 
                                        internal_day <= bcd_1;
                                        
                                        if internal_month = bcd_12 then
                                            internal_month <= bcd_1;
                                            
                                            if internal_year = bcd_99 then
                                                internal_year <= bcd_1;
                                            else
                                                internal_year <= increment_bcd(internal_year);
                                            end if;
                                            
                                        else
                                            internal_month <= increment_bcd(internal_month);
                                        end if;
                                    
                                    else
                                        internal_day <= increment_bcd(internal_day);  
                                    end if;
                                                    
                                else
                                    internal_hour <= increment_bcd(internal_hour);
                                end if;
                            else
                                internal_min <= increment_bcd(internal_min);
                            end if; 

                        else
                            internal_second_counter <= increment_bcd(internal_second_counter);
                            internal_clock_counter <= to_unsigned(1,internal_clock_counter'length);
                        end if;
                    else
                        internal_clock_counter <= internal_clock_counter + 1;        
                    end if;
       
        end if;
        
        reset_prev <= reset;    
        de_set_prev <= de_set; 
        
    end if; 
   
end process;

end Behavioral;
