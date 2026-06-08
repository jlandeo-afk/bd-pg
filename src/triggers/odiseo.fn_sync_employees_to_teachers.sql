-- Trigger Function: odiseo.fn_sync_employees_to_teachers()

--

CREATE FUNCTION odiseo.fn_sync_employees_to_teachers() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
                    BEGIN
                        -- El cargo_id 2 corresponde a docentes
                        IF NEW.charge_id = 2 THEN
                            INSERT INTO teachers (
                                employee_id,
                                code,
                                limit_assigned_questions,
                                limit_assigned_questions_initial,
                                fl_unlimit_questions,
                                level_rate_id,
                                goal,
                                lot,
                                fl_active,
                                company_id,
                                fl_resolve_missing_questions,
                                limit_missing_questions,
                                created_by,
                                updated_by,
                                deleted_by,
                                created_at,
                                updated_at,
                                deleted_at
                            )
                            VALUES (
                                NEW.id,
                                NEW.code,
                                NEW.limit_assigned_questions,
                                NEW.limit_assigned_questions_initial,
                                NEW.fl_unlimit_questions,
                                NEW.level_id,
                                NEW.goal,
                                NEW.lot,
                                NEW.fl_status,
                                NEW.company_id,
                                NEW.fl_resolve_missing_questions,
                                NEW.limit_missing_questions,
                                NEW.created_by,
                                NEW.updated_by,
                                NEW.deleted_by,
                                NEW.created_at,
                                NEW.updated_at,
                                NEW.deleted_at
                            )
                            ON CONFLICT (employee_id) DO UPDATE SET
                                code = EXCLUDED.code,
                                limit_assigned_questions = EXCLUDED.limit_assigned_questions,
                                limit_assigned_questions_initial = EXCLUDED.limit_assigned_questions_initial,
                                fl_unlimit_questions = EXCLUDED.fl_unlimit_questions,
                                level_rate_id = EXCLUDED.level_rate_id,
                                goal = EXCLUDED.goal,
                                lot = EXCLUDED.lot,
                                fl_active = EXCLUDED.fl_active,
                                company_id = EXCLUDED.company_id,
                                fl_resolve_missing_questions = EXCLUDED.fl_resolve_missing_questions,
                                limit_missing_questions = EXCLUDED.limit_missing_questions,
                                updated_by = EXCLUDED.updated_by,
                                deleted_by = EXCLUDED.deleted_by,
                                updated_at = EXCLUDED.updated_at,
                                deleted_at = EXCLUDED.deleted_at;
                        ELSE
                            -- Si es que el docente estaba antes y ahora ya no es docente, eliminarlo logicamente.
                            UPDATE teachers
                            SET deleted_at = NOW(),
                            deleted_by = NEW.updated_by
                            WHERE employee_id = NEW.id
                            AND deleted_at IS NULL;
                        END IF;

                        RETURN NEW;
                    END;
                    $$;


ALTER FUNCTION odiseo.fn_sync_employees_to_teachers() OWNER TO postgres;

--
