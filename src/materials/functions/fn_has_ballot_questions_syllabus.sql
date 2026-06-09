-- Function: materials.fn_has_ballot_questions_syllabus(integer, integer)

--

CREATE FUNCTION materials.fn_has_ballot_questions_syllabus(p_syllabus_id integer, p_company_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
        DECLARE
            response boolean;
        BEGIN
            response:= FALSE;

        WITH tbl_syllabus AS (
            SELECT
                id,
                cycle_id,
                university_id
            FROM syllabus
            WHERE deleted_at IS NULL
            AND company_id = p_company_id
            AND id = p_syllabus_id
        ),
        materiales AS (
            SELECT
                s.id AS syllabus_id,
                m.id AS material_id,
                s.cycle_id
            FROM material m
            JOIN tbl_syllabus s
                ON m.cycle_id = s.cycle_id
                AND m.university_id = s.university_id
        ),
        resumen AS (
        SELECT 
        * ,
        fn_has_ballot_questions(
            materiales.material_id::integer,
            materiales.cycle_id::integer
        )
        FROM materiales )

        SELECT TRUE INTO response
        WHERE EXISTS (SELECT 1 FROM resumen where fn_has_ballot_questions = true);

        return response;

        END;
        $$;


ALTER FUNCTION materials.fn_has_ballot_questions_syllabus(p_syllabus_id integer, p_company_id integer) OWNER TO postgres;

--
