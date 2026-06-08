-- Function: anon.generar_lorem_ajustado(integer)

--

CREATE FUNCTION anon.generar_lorem_ajustado(largo_objetivo integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    palabras_estimadas INT;
    texto_crudo TEXT;
BEGIN
    IF largo_objetivo <= 0 THEN RETURN ''; END IF;
    palabras_estimadas := (largo_objetivo / 5) + 5;
    texto_crudo := anon.lorem_ipsum(palabras_estimadas);
    WHILE length(texto_crudo) < largo_objetivo LOOP
        texto_crudo := texto_crudo || ' ' || anon.lorem_ipsum(5);
    END LOOP;
    RETURN substring(initcap(texto_crudo), 1, largo_objetivo);
END;
$$;


ALTER FUNCTION anon.generar_lorem_ajustado(largo_objetivo integer) OWNER TO postgres;

--
