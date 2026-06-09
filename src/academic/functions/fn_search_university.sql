-- Function: academic.fn_search_university(character varying)

--

CREATE FUNCTION academic.fn_search_university(p_name character varying) RETURNS TABLE(id smallint, name character varying, slug character varying, type smallint, region_id smallint, region character varying, areas text, versions text, fl_status boolean, created_by bigint, created_at timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                SELECT
                    u.id,
                    u.name,
                    u.slug,
                    u.type,
                    u.region_id,
                    r.name AS region,
                    u.areas,
                    u.versions,
                    u.fl_status,
                    u.created_by,
                    u.created_at
                FROM
                    academic.origin_university u
                LEFT JOIN odiseo.region r
                    ON u.region_id = r.id
                WHERE
                    unaccent(lower(u.name)) = unaccent(lower(p_name))
                    OR unaccent(lower(u.slug)) = unaccent(lower(p_name));
            END;
            $$;


ALTER FUNCTION academic.fn_search_university(p_name character varying) OWNER TO postgres;

--
