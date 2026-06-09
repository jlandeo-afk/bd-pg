-- Function: questions.fn_origin_question(bigint)

--

CREATE FUNCTION questions.fn_origin_question(p_question_id bigint) RETURNS TABLE(id bigint, question_id bigint, year character varying, region_id bigint, region character varying, university_id bigint, university character varying, option_id bigint, option character varying, modality_id bigint, modality character varying, areas character varying, version character varying, order_version integer)
    LANGUAGE plpgsql
    AS $$
            BEGIN
                RETURN QUERY
                WITH tlb_versions AS (
                    SELECT
                        ou.id AS university_id,
                        (v.value->>'order')::INT AS order,
                        (v.value->>'version')::SMALLINT AS version
                    FROM origin_university ou,
                        LATERAL jsonb_array_elements(ou.versions::jsonb) AS v(value)
                    WHERE ou.versions IS NOT NULL
                    AND ou.versions::text <> '[]'
                ), tbl_origin_questions AS (
                    SELECT
                        oq.id,
                        oq.question_id,
                        oq.year,
                        oq.region_id,
                        r.name AS region,
                        op_u.university_id,
                        ou.name AS university,
                        op_u.id as option_id, -- ID de la opción desde la nueva tabla option_university
                        op_u.name AS option, -- Nombre desde la nueva tabla option_university
                        mo.id as modality_id, -- ID de la modality_id para no romper nada
                        mo.name AS modality, -- Nombre desde la nueva tabla modality_options
                        oq.areas,
                        fn_number_to_roman(oq.version::smallint)::varchar AS version,
                        tv.order AS order_version
                    FROM origin_question oq
                    LEFT JOIN region r ON oq.region_id = r.id
                    -- NUEVO: JOIN a modality_options usando global modality_id y el pivote de la opción
                    LEFT JOIN modality_options mo ON mo.id = oq.modality_option_id
                        AND mo.deleted_at IS NULL
                    
                    -- NUEVO: JOIN a option_university usando el global option_id y university_id
                    LEFT JOIN option_university op_u ON op_u.id = mo.option_university_id 
                        AND op_u.deleted_at IS NULL
					
                    LEFT JOIN origin_university ou ON op_u.university_id = ou.id
                        
                    LEFT JOIN tlb_versions tv ON ou.id = tv.university_id
                        AND oq.version::smallint = tv.version
                    WHERE oq.question_id = p_question_id
                        AND oq.fl_status = true
                    ORDER BY common.unaccent(ou.name) ASC, oq.year DESC, tv.order ASC
                )
                SELECT toq.* FROM tbl_origin_questions toq;
            END;
            $$;


ALTER FUNCTION questions.fn_origin_question(p_question_id bigint) OWNER TO postgres;

--
