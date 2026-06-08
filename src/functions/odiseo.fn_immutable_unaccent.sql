-- Function: odiseo.fn_immutable_unaccent(text)

--

CREATE FUNCTION odiseo.fn_immutable_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
            SELECT public.unaccent($1);
            $_$;


ALTER FUNCTION odiseo.fn_immutable_unaccent(text) OWNER TO postgres;

--
