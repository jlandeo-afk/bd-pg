-- Function: anon.html_math_aware_mask(text)

--

CREATE FUNCTION anon.html_math_aware_mask(input_text text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    fragment RECORD;
    output_text TEXT := '';
    in_math_block BOOLEAN := false;
    is_tag BOOLEAN;
    clean_content TEXT;
    fragment_length INT;
BEGIN
    IF input_text IS NULL THEN RETURN NULL; END IF;
    FOR fragment IN SELECT match[1] AS token FROM regexp_matches(input_text, '(<[^>]+>|[^<]+)', 'g') AS match LOOP
        is_tag := (substring(fragment.token, 1, 1) = '<');
        IF is_tag THEN
            IF fragment.token ILIKE '<math%' THEN in_math_block := true; END IF;
            output_text := output_text || fragment.token;
            IF fragment.token ILIKE '</math>' THEN in_math_block := false; END IF;
        ELSE
            clean_content := regexp_replace(fragment.token, '\s+', '', 'g');
            fragment_length := length(fragment.token);
            IF in_math_block THEN
                output_text := output_text || fragment.token;
            ELSIF length(clean_content) > 0 THEN
                output_text := output_text || anon.generar_lorem_ajustado(fragment_length);
            ELSE
                output_text := output_text || fragment.token;
            END IF;
        END IF;
    END LOOP;
    RETURN output_text;
END;
$$;


ALTER FUNCTION anon.html_math_aware_mask(input_text text) OWNER TO postgres;

--
