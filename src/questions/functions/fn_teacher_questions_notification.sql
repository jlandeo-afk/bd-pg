-- Function: questions.fn_teacher_questions_notification(bigint, integer, integer, integer)

--

CREATE FUNCTION questions.fn_teacher_questions_notification(p_teacher_id bigint, p_week integer, p_year integer, p_company_id integer) RETURNS TABLE(not_exist_questions_available boolean, total_question_week bigint, limit_assigned_questions bigint)
    LANGUAGE plpgsql
    AS $$
            DECLARE
                v_total_available_question INT;
                v_limit_assigned_questions INT;
                v_question_last_week INT;
                v_total_question_week INT;
                v_total_question_assigned INT;
                v_not_exist_questions_available BOOL;
                v_block_assigned_questions INT;
            BEGIN
                -- Obtener la cantidad de preguntas sin asignar
                SELECT COUNT(*)
                INTO v_total_available_question
                FROM questions.question q
                WHERE q.status = 'SASI'
                AND q.fl_status = TRUE
                AND q.course_id IN (
                    SELECT ec.course_id
                    FROM odiseo.employee_course ec
                    WHERE ec.teacher_id = p_teacher_id
                        AND ec.fl_status = TRUE
                );

               SELECT e.limit_assigned_questions
               INTO v_limit_assigned_questions
               FROM odiseo.employees e
               WHERE e.id = p_teacher_id;

               SELECT as2.block_assigned_questions
               INTO v_block_assigned_questions
               FROM common.advanced_settings as2
               WHERE as2.company_id = p_company_id;

              SELECT COUNT(*)
              INTO v_total_question_assigned
              FROM questions.employee_question eq
              WHERE eq.teacher_id  = p_teacher_id AND eq.solved = false AND eq.fl_status = TRUE;

             IF v_total_question_assigned = 0 THEN
             	-- Verificar si existen preguntas para asignar al profesor
                not_exist_questions_available := v_total_available_question < v_block_assigned_questions;

             ELSE
             	not_exist_questions_available := false;
             END IF;

            -- Cuantas preguntas tiene el profesor con respecto de la semana actual
                SELECT COUNT(*)
                INTO v_total_question_week
                FROM questions.employee_question eq
                INNER JOIN questions.question q ON eq.question_id = q.id
                WHERE eq.teacher_id = p_teacher_id
				AND eq.week = p_week
				AND eq.year = p_year
                AND q.status NOT IN('ARCH', 'DUPL');

                total_question_week := v_total_question_week;
                limit_assigned_questions := v_limit_assigned_questions;


                -- Retornar los valores calculados
                RETURN QUERY SELECT not_exist_questions_available, total_question_week, limit_assigned_questions ;
            END;
            $$;


ALTER FUNCTION questions.fn_teacher_questions_notification(p_teacher_id bigint, p_week integer, p_year integer, p_company_id integer) OWNER TO postgres;

--
