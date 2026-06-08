-- Function: odiseo.fn_number_to_roman(smallint)

--

CREATE FUNCTION odiseo.fn_number_to_roman(num smallint) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    result VARCHAR(10) := '';
    value INTEGER := num;
    roman_values INTEGER[] := ARRAY[1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    roman_symbols VARCHAR[] := ARRAY['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];
    i INTEGER;
BEGIN
    IF num <= 0 OR num > 3999 THEN
        RAISE EXCEPTION 'Input % is out of range for Roman numerals (1 to 3999)', num;
    END IF;

    FOR i IN 1..array_length(roman_values, 1) LOOP
        WHILE value >= roman_values[i] LOOP
            result := result || roman_symbols[i];
            value := value - roman_values[i];
        END LOOP;
    END LOOP;

    RETURN result;
END;
$$;


ALTER FUNCTION odiseo.fn_number_to_roman(num smallint) OWNER TO postgres;

--
