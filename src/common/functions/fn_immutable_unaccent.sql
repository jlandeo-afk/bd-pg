-- Function: common.fn_immutable_unaccent(text)

--

CREATE FUNCTION common.fn_immutable_unaccent(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
            SELECT common.unaccent($1);
            $_$;


ALTER FUNCTION common.fn_immutable_unaccent(text) OWNER TO postgres;

--
