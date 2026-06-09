-- Function: academic.fn_block_unblock_syllabus(integer, integer, integer)

--

CREATE FUNCTION academic.fn_block_unblock_syllabus(p_syllabus_id integer, p_company_id integer, p_user_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    UPDATE academic.syllabus 
                    SET is_disabled = NOT is_disabled 
                    WHERE id = p_syllabus_id AND company_id = p_company_id;
                END;
                
        $$;


ALTER FUNCTION academic.fn_block_unblock_syllabus(p_syllabus_id integer, p_company_id integer, p_user_id integer) OWNER TO postgres;

--
