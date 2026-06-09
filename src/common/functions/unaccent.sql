-- Function: common.unaccent(text)

--

CREATE FUNCTION common.unaccent(text) RETURNS text
    LANGUAGE sql STABLE
    AS $_$
            SELECT common.unaccent($1);
        $_$;


ALTER FUNCTION common.unaccent(text) OWNER TO postgres;

--
