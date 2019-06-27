library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utils is
    type Word is (W_NONE, W_0FILL, W_1FILL, W_LITERAL);

    function parse_word_type (word_size: natural;
    input_word: std_logic_vector)
    return Word;

    function invert_F (word_size: natural;
    input_word: std_logic_vector)
    return std_logic_vector;

    function invert_L (word_size: natural;
    input_word: std_logic_vector)
    return std_logic_vector;

    function decode_literal (word_size: natural;
    content: std_logic_vector)
    return std_logic_vector;

    function decode_fill (word_size: natural;
    fill_type: std_logic)
    return std_logic_vector;

    function parse_fill_length (word_size: natural;
    fill_counter_size: natural;
    old_fill_length: unsigned;
    fill_word: std_logic_vector)
    return unsigned;

    function encode_literal (word_size: natural;
    content: std_logic_vector)
    return std_logic_vector;

    function encode_fill (word_size: natural;
    fill_counter_size: natural;
    fill_type: std_logic;
    length: unsigned;
    word_no: natural)
    return std_logic_vector;

    function fill_words_needed (word_size: natural;
    fill_counter_size: natural;
    length: unsigned)
    return natural;

    function parse_block_type (word_size: natural;
    input_word: std_logic_vector)
    return Word;

    function logic_function (in0, in1: std_logic_vector)
    return std_logic_vector;

    function to_std_logic (input: boolean)
    return std_logic;

    function decode_single (word_size: natural;
    input_block: std_logic_vector)
    return std_logic_vector;
end;

package body utils is
    --
    -- determine the word type of input_word by parsing the control bits
    -- (MSB for literals and MSB, MSB-1 for fills)
    --
    function parse_word_type (word_size: natural;
    input_word: std_logic_vector)
    return Word is
    begin
        if input_word(word_size-1) = '0' then
            return W_LITERAL;
        elsif input_word(word_size-2) = '0' then
            return W_0FILL;
        elsif input_word(word_size-2) = '1' then
            return W_1FILL;
        else
            return W_NONE;
        end if;
    end parse_word_type;

    --
    -- returns the inverse version of the input fill
    --
    function invert_F (word_size: natural;
    input_word: std_logic_vector)
    return std_logic_vector is
        variable output: std_logic_vector(word_size-1 downto 0) := (others => 'U');
    begin
        output(word_size-1) := input_word(word_size-1);
        output(word_size-2) := not(input_word(word_size-2));
        output(word_size-3 downto 0) := input_word(word_size-3 downto 0);
        return output;
    end invert_F;

    --
    -- returns the inverse version of the input literal
    --
    function invert_L (word_size: natural;
    input_word: std_logic_vector)
    return std_logic_vector is
        variable output: std_logic_vector(word_size-1 downto 0);
    begin
        output(word_size-1) := input_word(word_size-1);
        for i in word_size-2 downto 0 loop
            output(i) := not(input_word(i));
        end loop;
        return output;
    end invert_L;

    --
    -- returns a decoded literal derived from the encoded input literal
    --
    function decode_literal (word_size: natural;
    content: std_logic_vector)
    return std_logic_vector is
    begin
        -- determine output representation and write word to output buffer
        return content(word_size-2 downto 0);
    end decode_literal;

    --
    -- returns a decoded fill block of the given type
    --
    function decode_fill (word_size: natural;
    fill_type: std_logic)
    return std_logic_vector is
        variable buf: std_logic_vector(word_size-2 downto 0);
    begin
        -- fill all bits of buf with the given type
        for idx in word_size-2 downto 0 loop
            buf(idx)    := fill_type;
        end loop;

        return buf;
    end decode_fill;

    --
    -- concatenates the length of an encoded fill to the decoded old_fill_length and
    -- returns the result
    --
    function parse_fill_length (word_size: natural;
    fill_counter_size: natural;
    old_fill_length: unsigned;
    fill_word: std_logic_vector)
    return unsigned is
        variable new_fill_length: unsigned(fill_counter_size-1 downto 0);
    begin
        -- shift old fill length by the number of new bits from the next fill word
        new_fill_length := shift_left(old_fill_length, word_size-2);

        -- copy the newly obtained bits to the least significant positions of new_fill_length
        for idx in word_size-3 downto 0 loop
            new_fill_length(idx) := fill_word(idx);
        end loop;

        return new_fill_length;
    end parse_fill_length;

    --
    -- returns an encoded literal word with the given content
    --
    function encode_literal (word_size: natural;
    content: std_logic_vector)
    return std_logic_vector is
        variable buf: std_logic_vector(word_size-1 downto 0);
    begin
        -- set control bit and copy word contents
        buf(word_size-1) := '0';
        buf(word_size-2 downto 0) := content;
        return buf;
    end encode_literal;

    --
    -- returns an encoded fill word of the given type.
    -- the total length of the fill is gven by the parameter length.
    -- for concatenated fills, word_no is the reversed position of the fill word inside the concatenated group
    --
    function encode_fill (word_size: natural;
    fill_counter_size: natural;
    fill_type: std_logic;
    length: unsigned;
    word_no: natural)
    return std_logic_vector is
        variable length_vector: std_logic_vector(fill_counter_size-1 downto 0);
        variable lowest_bit_idx: natural;
        variable buf: std_logic_vector(word_size-1 downto 0);
    begin
        length_vector := std_logic_vector(length);
        lowest_bit_idx := word_no * (word_size-2);

        -- set control bits
        buf(word_size-1)          := '1';
        buf(word_size-2)          := fill_type;

        -- copy the related (word_size-2) bits of the length representation vector
        buf(word_size-3 downto 0) := length_vector(lowest_bit_idx + (word_size-3) downto lowest_bit_idx);
        return buf;
    end encode_fill;

    --
    -- returns the number of fill words needed to represent a fill of the given length
    --
    function fill_words_needed (word_size: natural;
    fill_counter_size: natural;
    length: unsigned)
    return natural is
    begin
        for i in fill_counter_size-1 downto 0 loop
            if length(i) = '1' then
                return (i / (word_size-2)) + 1;
            end if;
        end loop;
        return 0;
    end fill_words_needed;

    --
    -- determine the type of input_word by parsing identifying the contents as fill or literal
    --
    function parse_block_type (word_size: natural;
    input_word: std_logic_vector)
    return Word is
    variable one_fill: boolean := true;
    variable zero_fill: boolean := true;
    begin
        for bit_idx in 0 to word_size-2 loop
            case input_word(bit_idx) is
                when '0' =>
                    one_fill := false;
                when '1' =>
                    zero_fill := false;
                when others =>
                    return W_NONE;
            end case;
        end loop;

        if zero_fill then
            return W_0FILL;
        elsif one_fill then
            return W_1FILL;
        else
            return W_LITERAL;
        end if;
    end parse_block_type;

    --
    -- actual implementation of the logic or function
    --
    function logic_function (in0, in1: std_logic_vector)
    return std_logic_vector is
    begin
        return in0 or in1;
    end logic_function;

    --
    -- convert boolean to std_logic
    --
    function to_std_logic (input: boolean)
    return std_logic is
    begin
        if input then
            return '1';
        else
            return '0';
        end if;
    end to_std_logic;

    --
    -- decodes the literal representation of a single block
    -- for fill words only a single representative block is returned
    --
    function decode_single (word_size: natural;
    input_block: std_logic_vector)
    return std_logic_vector is
        variable decoded_block: std_logic_vector(word_size-2 downto 0) := (others => 'U');
        variable word_type: Word := parse_word_type(word_size, input_block);
    begin
        case word_type is
            when W_LITERAL =>
                decoded_block := input_block(word_size-2 downto 0);
            when W_0FILL =>
                decoded_block := (others => '0');
            when W_1FILL =>
                decoded_block := (others => '1');
            when others =>
        end case;
        return decoded_block;
    end decode_single;

end package body;