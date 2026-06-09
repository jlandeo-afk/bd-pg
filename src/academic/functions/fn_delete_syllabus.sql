-- Function: academic.fn_delete_syllabus(integer, integer, integer)

--

CREATE FUNCTION academic.fn_delete_syllabus(p_syllabus_id integer, p_company_id integer, p_deleted_by integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
                    DECLARE
                        verify_delet_syllabus BOOLEAN;
                    BEGIN
                        SELECT fn_has_ballot_questions_syllabus
                        INTO verify_delet_syllabus
                        FROM fn_has_ballot_questions_syllabus(p_syllabus_id,p_company_id);
                    
                        IF verify_delet_syllabus is null or verify_delet_syllabus = FALSE THEN
                            UPDATE syllabus
                            SET
                                deleted_by = p_deleted_by,
                                deleted_at = now(),
                                fl_status = FALSE
                            WHERE id = p_syllabus_id;
                            RETURN TRUE;
                        ELSE
                            UPDATE syllabus
                            SET
                                is_deleteable = false
                            WHERE id = p_syllabus_id;
                            RETURN FALSE;
                        END IF;
                    END;
                    
        $$;


ALTER FUNCTION academic.fn_delete_syllabus(p_syllabus_id integer, p_company_id integer, p_deleted_by integer) OWNER TO postgres;

--
