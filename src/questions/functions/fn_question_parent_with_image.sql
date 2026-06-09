-- Function: questions.fn_question_parent_with_image(integer)

--

CREATE FUNCTION questions.fn_question_parent_with_image(p_parent_question_id integer) RETURNS TABLE(id bigint, code character varying, description text, text_traduction text, description_b text, type_text_id bigint, type_text_subcategory_id bigint, parent_img jsonb)
    LANGUAGE plpgsql
    AS $$
                BEGIN
                    RETURN QUERY 
                        select 
                        pq.id,
                        pq.code,
                        pq.description,
                        pq.text_traduction,
						pq.description_b,
						pq.type_text_id,
						pq.type_text_subcategory_id,
                        (
                            SELECT jsonb_agg(jsonb_build_object(
                            'id',pi.id,
                            'code',pi.code,
                            'image',pi.image))
                            from questions.parent_image pi
                            where pi.parent_id = pq.id
                            and pi.fl_status = true
                        ) as parent_img
                        from questions.parent_question pq 
                        where pq.id = p_parent_question_id;
                END;
            
$$;


ALTER FUNCTION questions.fn_question_parent_with_image(p_parent_question_id integer) OWNER TO postgres;

--
