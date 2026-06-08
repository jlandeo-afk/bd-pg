-- Function: odiseo.unaccent(text)

--

CREATE FUNCTION odiseo.unaccent(text) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
            SELECT public.unaccent($1);
        $_$;


ALTER FUNCTION odiseo.unaccent(text) OWNER TO postgres;

--
