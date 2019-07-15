library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--  A testbench has no ports.
entity decoder_tb is
    end decoder_tb;

architecture behav of decoder_tb is

    -- found this function implementation at: https://stackoverflow.com/questions/15406887/vhdl-convert-vector-to-string
    function to_string ( a: std_logic_vector) return string is
        variable b : string (1 to a'length) := (others => NUL);
        variable stri : integer := 1; 
    begin
        for i in a'range loop
            b(stri) := std_logic'image(a((i)))(2);
            stri := stri+1;
        end loop;
        return b;
    end function;

    -- Declaration of the components that will be instantiated.
    component decoder
        generic (
                    constant word_size: natural := 5;
                    constant fill_counter_size: natural := 32
                );
        port (
                 clk:           in std_logic;
                 blk_in:        in std_logic_vector(4 downto 0);
                 in_empty:      in std_logic;
                 out_full:      in std_logic;
                 blk_out:       out std_logic_vector(3 downto 0);
                 in_rd:         out std_logic;
                 out_wr:        out std_logic;
                 final_in:      in std_logic;
                 final_out:     out std_logic;
                 reset:         in std_logic
             );
    end component;

    component input_fifo
        Generic (
                    constant addr_width: natural := 3;
                    constant word_size: natural := 5
                );
        Port ( BLK_IN   : in  STD_LOGIC_VECTOR (word_size-1 downto 0);
               WR_EN    : in  STD_LOGIC;
               BLK_OUT  : out STD_LOGIC_VECTOR (word_size-1 downto 0);
               RD_EN    : in  STD_LOGIC;
               EMPTY : out STD_LOGIC;
               FULL  : out STD_LOGIC;
               CLK   : in  STD_LOGIC;
               FINAL_IN: in std_logic;
               Final_out: out std_logic;
               RESET: in std_logic
           );
    end component;

    component output_fifo
        Generic (
                    constant addr_width: natural := 3;
                    constant word_size: natural := 4
                );
        Port ( BLK_IN   : in  STD_LOGIC_VECTOR (word_size-1 downto 0);
               WR_EN    : in  STD_LOGIC;
               BLK_OUT  : out STD_LOGIC_VECTOR (word_size-1 downto 0);
               RD_EN    : in  STD_LOGIC;
               EMPTY : out STD_LOGIC;
               FULL  : out STD_LOGIC;
               CLK   : in  STD_LOGIC;
               FINAL_IN: in std_logic;
               Final_out: out std_logic;
               RESET: in std_logic
           );
    end component;

    --  Specifies which entity is bound with the component.
    for decoder_0: decoder use entity work.decoder;
    for input_fifo_0: input_fifo use entity work.FIFO_bb;
    for output_fifo_0: output_fifo use entity work.FIFO_bb;

    -- inner signals
    signal blk_in:          std_logic_vector(4 downto 0);
    signal blk_out:         std_logic_vector(3 downto 0);
    signal in_empty:        std_logic;
    signal out_full:        std_logic;
    signal in_rd:           std_logic;
    signal out_wr:          std_logic;
    signal final_in:        std_logic;
    signal final_out:       std_logic;

    -- outer signals
    signal outer_clk:      std_logic;
    signal outer_input:    std_logic_vector(4 downto 0);
    signal outer_wr_en:    std_logic;
    signal outer_rd_en:    std_logic;
    signal outer_output:   std_logic_vector(3 downto 0);
    signal outer_empty:    std_logic;
    signal outer_full:     std_logic;
    signal outer_final_in: std_logic;
    signal outer_final_out:std_logic;
    signal outer_reset:    std_logic;

    begin
        --  Component instantiation.
        decoder_0: decoder
        port map (clk => outer_clk,
                  blk_in => blk_in,
                  blk_out => blk_out,
                  in_empty => in_empty,
                  out_full => out_full,
                  in_rd => in_rd,
                  final_in => final_in,
                  final_out => final_out,
                  reset => outer_reset,
                  out_wr => out_wr);

        input_fifo_0: input_fifo
        port map (CLK => outer_clk,
                  BLK_IN => outer_input,
                  WR_EN => outer_wr_en,
                  BLK_OUT => blk_in,
                  RD_EN => in_rd,
                  EMPTY => in_empty,
                  FINAL_IN => outer_final_in,
                  Final_out => final_in,
                  RESET => outer_reset,
                  FULL => outer_full);

        output_fifo_0: output_fifo
        port map (CLK => outer_clk,
                  BLK_IN => blk_out,
                  WR_EN => out_wr,
                  BLK_OUT => outer_output,
                  RD_EN => outer_rd_en,
                  EMPTY => outer_empty,
                  FINAL_IN => final_out,
                  Final_out => outer_final_out,
                  RESET => outer_reset,
                  FULL => out_full);

        --  This process does the real job.
        process
        type pattern_type is record
            --  The inputs of the decoder.
            outer_reset: std_logic;
            outer_final_in: std_logic;
            outer_input: std_logic_vector(4 downto 0);
            outer_wr_en: std_logic;
            outer_rd_en: std_logic;
            --  The expected outputs of the decoder.
            outer_output: std_logic_vector(3 downto 0);
            outer_empty: std_logic;
            outer_final_out: std_logic;
        end record;
        --  The patterns to apply.
        type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
        (('1', '0', "00001", '1', '1', "UUUU", '1', '0'),  -- 00
         ('1', '0', "10011", '1', '1', "UUUU", '1', '0'),  -- 01
         ('1', '0', "11001", '1', '1', "UUUU", '1', '0'),  -- 02
         ('1', '0', "11010", '1', '1', "UUUU", '1', '0'),  -- 03
         ('1', '0', "00000", '0', '1', "UUUU", '0', '0'),  -- 04
         ('1', '0', "00000", '0', '1', "0001", '0', '0'),  -- 05
         ('1', '0', "00000", '0', '1', "0000", '0', '0'),  -- 06
         ('1', '0', "00000", '0', '1', "0000", '0', '0'),  -- 07
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 08
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 09
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 10
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 11
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 12
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 13
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 14
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 15
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 16
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 17
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 18
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 19
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 20
         ('1', '0', "00001", '1', '1', "0000", '1', '0'),  -- 21
         ('1', '0', "00000", '0', '1', "0000", '1', '0'),  -- 22
         ('1', '0', "00000", '0', '1', "0000", '0', '0'),  -- 23
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 24
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 25
         ('1', '1', "00010", '1', '1', "1111", '0', '0'),  -- 26
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 27
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 28
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 29
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 30
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 31
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 32
         ('1', '0', "00000", '0', '1', "1111", '0', '0'),  -- 33
         ('1', '0', "00000", '0', '1', "0001", '0', '0'),  -- 34
         ('1', '0', "00000", '0', '1', "0010", '1', '1'),  -- 35
         ('1', '0', "00000", '0', '1', "0010", '1', '1'),  -- 36
         ('1', '0', "00000", '0', '1', "0010", '1', '1'),  -- 37
         ('1', '0', "00000", '0', '1', "0010", '1', '1'),  -- 38
         ('1', '0', "00000", '0', '1', "0010", '1', '1'),  -- 39
         ('1', '0', "00000", '0', '1', "0010", '1', '1'),  -- 40
         ('0', '0', "00000", '0', '1', "0010", '1', '0'),  -- 41
         ('1', '0', "00000", '0', '1', "0010", '1', '0')); -- 42
        begin
            assert false report "begin of test" severity note;

            --  Check each pattern.
            for i in patterns'range loop
                --  Set the inputs.
                outer_wr_en <= patterns(i).outer_wr_en;
                outer_input <= patterns(i).outer_input;
                outer_rd_en <= patterns(i).outer_rd_en;
                outer_reset <= patterns(i).outer_reset;
                outer_final_in <= patterns(i).outer_final_in;

                -- simulate the clock
                outer_clk <= '0';
                wait for 1 ns;
                outer_clk <= '1';

                --  Wait for the results.
                wait for 1 ns;

                --  Check the outputs.
                assert outer_empty = patterns(i).outer_empty
                report "empty state incorrect in test " & integer'image(i) & ". Expected: " & std_logic'image(patterns(i).outer_empty) & " but found " & std_logic'image(outer_empty) severity error;

                assert outer_final_out = patterns(i).outer_final_out
                report "final state incorrect in test " & integer'image(i) & ". Expected: " & std_logic'image(patterns(i).outer_final_out) & " but found " & std_logic'image(outer_final_out) severity error;

                assert outer_output = patterns(i).outer_output
                report "bad decoding in test " & integer'image(i) & ". Expected: " & to_string(patterns(i).outer_output) & " but found " & to_string(outer_output) severity error;
            end loop;

            assert false report "end of test" severity note;
            --  Wait forever; this will finish the simulation.
            wait;
        end process;
    end behav;
