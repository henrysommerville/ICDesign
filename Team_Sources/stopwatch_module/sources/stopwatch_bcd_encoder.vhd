library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch_bcd_encoder is
    port (
        bin_in : in  std_logic_vector(7 downto 0);
        bcd_out   : out std_logic_vector(7 downto 0)  -- 2 BCD digits: [7:4] tens, [3:0] units
    );
end stopwatch_bcd_encoder;

architecture rtl of stopwatch_bcd_encoder is
    type bcd_array is array (0 to 99) of std_logic_vector(7 downto 0);
    
    -- Lookup table mapping 0..99 to BCD (tens and units)
    constant bin_to_bcd_table : bcd_array := (
        x"00", x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09",  -- 0-9
        x"10", x"11", x"12", x"13", x"14", x"15", x"16", x"17", x"18", x"19",  -- 10-19
        x"20", x"21", x"22", x"23", x"24", x"25", x"26", x"27", x"28", x"29",  -- 20-29
        x"30", x"31", x"32", x"33", x"34", x"35", x"36", x"37", x"38", x"39",  -- 30-39
        x"40", x"41", x"42", x"43", x"44", x"45", x"46", x"47", x"48", x"49",  -- 40-49
        x"50", x"51", x"52", x"53", x"54", x"55", x"56", x"57", x"58", x"59",  -- 50-59
        x"60", x"61", x"62", x"63", x"64", x"65", x"66", x"67", x"68", x"69",  -- 60-69
        x"70", x"71", x"72", x"73", x"74", x"75", x"76", x"77", x"78", x"79",  -- 70-79
        x"80", x"81", x"82", x"83", x"84", x"85", x"86", x"87", x"88", x"89",  -- 80-89
        x"90", x"91", x"92", x"93", x"94", x"95", x"96", x"97", x"98", x"99"   -- 90-99
    );
begin
    process(bin_in)
    begin
        if unsigned(bin_in) <= 99 then
            bcd_out <= std_logic_vector(bin_to_bcd_table(to_integer(unsigned(bin_in))));
        else
            bcd_out <= (others => '0');  -- or handle invalid input as needed
        end if;
    end process;
end rtl;


--library ieee;
--use ieee.std_logic_1164.all;

--entity stopwatch_bcd_encoder is
--    port (
--        bin_in  : in  std_logic_vector(7 downto 0);
--        bcd_out : out std_logic_vector(7 downto 0)
--    );
--end stopwatch_bcd_encoder;

--architecture Behavioral of stopwatch_bcd_encoder is
--begin
--    process(bin_in)
--    begin
--        case bin_in is
--            -- map each decimal value 0 to 99
--            when "00000000" => bcd_out <= "00000000"; -- 00
--            when "00000001" => bcd_out <= "00000001"; -- 01
--            when "00000010" => bcd_out <= "00000010"; -- 02
--            when "00000011" => bcd_out <= "00000011"; -- 03
--            when "00000100" => bcd_out <= "00000100"; -- 04
--            when "00000101" => bcd_out <= "00000101"; -- 05
--            when "00000110" => bcd_out <= "00000110"; -- 06
--            when "00000111" => bcd_out <= "00000111"; -- 07
--            when "00001000" => bcd_out <= "00001000"; -- 08
--            when "00001001" => bcd_out <= "00001001"; -- 09
            
--            when "00001010" => bcd_out <= "00010000"; -- 10
--            when "00001011" => bcd_out <= "00010001"; -- 11
--            when "00001100" => bcd_out <= "00010010"; -- 12
--            when "00001101" => bcd_out <= "00010011"; -- 13
--            when "00001110" => bcd_out <= "00010100"; -- 14
--            when "00001111" => bcd_out <= "00010101"; -- 15
--            when "00010000" => bcd_out <= "00010110"; -- 16
--            when "00010001" => bcd_out <= "00010111"; -- 17
--            when "00010010" => bcd_out <= "00011000"; -- 18
--            when "00010011" => bcd_out <= "00011001"; -- 19
            
--            when "00010100" => bcd_out <= "00100000"; -- 20
--            when "00010101" => bcd_out <= "00100001"; -- 21
--            when "00010110" => bcd_out <= "00100010"; -- 22
--            when "00010111" => bcd_out <= "00100011"; -- 23
--            when "00011000" => bcd_out <= "00100100"; -- 24
--            when "00011001" => bcd_out <= "00100101"; -- 25
--            when "00011010" => bcd_out <= "00100110"; -- 26
--            when "00011011" => bcd_out <= "00100111"; -- 27
--            when "00011100" => bcd_out <= "00101000"; -- 28
--            when "00011101" => bcd_out <= "00101001"; -- 29
            
--            when "00011110" => bcd_out <= "00110000"; -- 30
--            when "00011111" => bcd_out <= "00110001"; -- 31
--            when "00100000" => bcd_out <= "00110010"; -- 32
--            when "00100001" => bcd_out <= "00110011"; -- 33
--            when "00100010" => bcd_out <= "00110100"; -- 34
--            when "00100011" => bcd_out <= "00110101"; -- 35
--            when "00100100" => bcd_out <= "00110110"; -- 36
--            when "00100101" => bcd_out <= "00110111"; -- 37
--            when "00100110" => bcd_out <= "00111000"; -- 38
--            when "00100111" => bcd_out <= "00111001"; -- 39
            
--            when "00101000" => bcd_out <= "01000000"; -- 40
--            when "00101001" => bcd_out <= "01000001"; -- 41
--            when "00101010" => bcd_out <= "01000010"; -- 42
--            when "00101011" => bcd_out <= "01000011"; -- 43
--            when "00101100" => bcd_out <= "01000100"; -- 44
--            when "00101101" => bcd_out <= "01000101"; -- 45
--            when "00101110" => bcd_out <= "01000110"; -- 46
--            when "00101111" => bcd_out <= "01000111"; -- 47
--            when "00110000" => bcd_out <= "01001000"; -- 48
--            when "00110001" => bcd_out <= "01001001"; -- 49
            
--            when "00110010" => bcd_out <= "01010000"; -- 50
--            when "00110011" => bcd_out <= "01010001"; -- 51
--            when "00110100" => bcd_out <= "01010010"; -- 52
--            when "00110101" => bcd_out <= "01010011"; -- 53
--            when "00110110" => bcd_out <= "01010100"; -- 54
--            when "00110111" => bcd_out <= "01010101"; -- 55
--            when "00111000" => bcd_out <= "01010110"; -- 56
--            when "00111001" => bcd_out <= "01010111"; -- 57
--            when "00111010" => bcd_out <= "01011000"; -- 58
--            when "00111011" => bcd_out <= "01011001"; -- 59
            
--            when "00111100" => bcd_out <= "01100000"; -- 60
--            when "00111101" => bcd_out <= "01100001"; -- 61
--            when "00111110" => bcd_out <= "01100010"; -- 62
--            when "00111111" => bcd_out <= "01100011"; -- 63
--            when "01000000" => bcd_out <= "01100100"; -- 64
--            when "01000001" => bcd_out <= "01100101"; -- 65
--            when "01000010" => bcd_out <= "01100110"; -- 66
--            when "01000011" => bcd_out <= "01100111"; -- 67
--            when "01000100" => bcd_out <= "01101000"; -- 68
--            when "01000101" => bcd_out <= "01101001"; -- 69
            
--            when "01000110" => bcd_out <= "01110000"; -- 70
--            when "01000111" => bcd_out <= "01110001"; -- 71
--            when "01001000" => bcd_out <= "01110010"; -- 72
--            when "01001001" => bcd_out <= "01110011"; -- 73
--            when "01001010" => bcd_out <= "01110100"; -- 74
--            when "01001011" => bcd_out <= "01110101"; -- 75
--            when "01001100" => bcd_out <= "01110110"; -- 76
--            when "01001101" => bcd_out <= "01110111"; -- 77
--            when "01001110" => bcd_out <= "01111000"; -- 78
--            when "01001111" => bcd_out <= "01111001"; -- 79
            
--            when "01010000" => bcd_out <= "10000000"; -- 80
--            when "01010001" => bcd_out <= "10000001"; -- 81
--            when "01010010" => bcd_out <= "10000010"; -- 82
--            when "01010011" => bcd_out <= "10000011"; -- 83
--            when "01010100" => bcd_out <= "10000100"; -- 84
--            when "01010101" => bcd_out <= "10000101"; -- 85
--            when "01010110" => bcd_out <= "10000110"; -- 86
--            when "01010111" => bcd_out <= "10000111"; -- 87
--            when "01011000" => bcd_out <= "10001000"; -- 88
--            when "01011001" => bcd_out <= "10001001"; -- 89
            
--            when "01011010" => bcd_out <= "10010000"; -- 90
--            when "01011011" => bcd_out <= "10010001"; -- 91
--            when "01011100" => bcd_out <= "10010010"; -- 92
--            when "01011101" => bcd_out <= "10010011"; -- 93
--            when "01011110" => bcd_out <= "10010100"; -- 94
--            when "01011111" => bcd_out <= "10010101"; -- 95
--            when "01100000" => bcd_out <= "10010110"; -- 96
--            when "01100001" => bcd_out <= "10010111"; -- 97
--            when "01100010" => bcd_out <= "10011000"; -- 98
--            when "01100011" => bcd_out <= "10011001"; -- 99

--            when others => bcd_out <= (others => '0');
--        end case;
--    end process;
--end Behavioral;