-- Function: questions.fn_find_question_refuzed(bigint)

--

CREATE FUNCTION questions.fn_find_question_refuzed(p_id bigint) RETURNS TABLE(id bigint, category_rejected_id smallint, category_rejected character varying, importance_rejected_id smallint, level_importance smallint, importance character varying, observation text, images text, question_id bigint, fl_status boolean, employee_documents jsonb, board_image text, fl_board_refuzed boolean)
    LANGUAGE plpgsql
    AS $$
        BEGIN
            RETURN QUERY
            SELECT
                qr.id,
                qr.category_rejected_id,
                cr.name AS category_rejected,
                qr.importance_rejected AS importance_rejected_id,
                ir.level AS level_importance,
                ir.name AS importance,
                qr.observation,
                qr.images,
                qr.question_id,
                qr.fl_status,
                tbl_employee_images.employee_documents,
                tbl_employee_images.board_image,
				tbl_employee_images.fl_refuzed as fl_board_refuzed
            FROM questions.question_refuzed qr
            INNER JOIN common.category_rejected cr ON qr.category_rejected_id = cr.id
            INNER JOIN common.importance_rejected ir ON qr.importance_rejected = ir.id
            LEFT JOIN (
            	SELECT
            		eq.question_id as question_id,
            		eq.document_solution as board_image,
            		eq.fl_refuzed as fl_refuzed,
                        COALESCE(
                        JSONB_AGG(
                            JSONB_BUILD_OBJECT(
                                'employee_question_document_id', eqd.id,
                                'employee_question_id', eqd.employee_question_id,
                                'type_archive_id', eqd.type_archive_id,
                                'document_solution', eqd.document
                            )
                        ) FILTER (WHERE eqd.id IS NOT NULL),
                        '[]'::jsonb
                    ) AS employee_documents
            	FROM questions.employee_question eq
            	LEFT  JOIN questions.employee_question_document eqd
            	on eqd.employee_question_id = eq.id  and eqd.fl_status = true
            	where eq.fl_status = true
            	group by eq.question_id,eq.document_solution, eq.fl_refuzed
            ) tbl_employee_images on tbl_employee_images.question_id = qr.question_id
            WHERE qr.fl_active IS TRUE
            AND qr.question_id = p_id
            AND qr.fl_status IS TRUE;
      END;
    $$;


ALTER FUNCTION questions.fn_find_question_refuzed(p_id bigint) OWNER TO postgres;

--
