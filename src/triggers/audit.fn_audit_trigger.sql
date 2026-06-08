-- Trigger Function: audit.fn_audit_trigger()

--

CREATE FUNCTION audit.fn_audit_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
        v_old_data       JSONB;
        v_new_data       JSONB;
        v_old_clean      JSONB;
        v_new_clean      JSONB;
        v_record         JSONB;
        v_transaction_id UUID;
        v_changed_by     BIGINT;
        v_company_id     INTEGER;
        v_key            TEXT;
    BEGIN
        -- Verifica si la tabla tiene auditoría activa
        IF NOT EXISTS (
            SELECT 1 FROM audit.audit_config
            WHERE table_name = TG_TABLE_NAME
            AND fl_active = true
        ) THEN
            RETURN COALESCE(NEW, OLD);
        END IF;

        -- Reutiliza transaction_id si ya existe en la sesión, sino genera uno nuevo
        IF current_setting('app.transaction_audit_id', true) IS NULL
            OR current_setting('app.transaction_audit_id', true) = '' THEN
            PERFORM set_config(
                'app.transaction_audit_id',
                gen_random_uuid()::text,
                true
            );
        END IF;

        v_transaction_id := NULLIF(current_setting('app.transaction_audit_id', true), '')::UUID;

        IF TG_OP = 'DELETE' THEN
            v_old_data   := row_to_json(OLD)::JSONB;
            v_new_data   := NULL;
            v_record     := v_old_data;

        ELSIF TG_OP = 'UPDATE' THEN
            v_old_data  := row_to_json(OLD)::JSONB;
            v_record    := row_to_json(NEW)::JSONB;

            -- Excluir updated_by y updated_at de ambos lados antes de comparar
            v_old_clean := v_old_data - 'updated_by' - 'updated_at';
            v_new_clean := v_record   - 'updated_by' - 'updated_at';

            -- Si no hubo cambios reales, no registrar
            IF v_old_clean = v_new_clean THEN
                RETURN NEW;
            END IF;

            -- Guardar solo los campos que cambiaron
            v_new_data := '{}'::JSONB;
            FOR v_key IN SELECT key FROM jsonb_object_keys(v_new_clean) AS key
            LOOP
                IF (v_new_clean -> v_key) IS DISTINCT FROM (v_old_clean -> v_key) THEN
                    v_new_data := v_new_data || jsonb_build_object(v_key, v_new_clean -> v_key);
                END IF;
            END LOOP;

            IF v_new_data = '{}'::JSONB THEN
                RETURN NEW;
            END IF;
        END IF;

        -- Leer changed_by según operación y tabla
        IF TG_OP = 'DELETE' THEN
            IF TG_TABLE_NAME = 'users_roles' THEN
                v_changed_by := (v_old_data ->> 'updated_by')::BIGINT;
            ELSE
                v_changed_by := (v_old_data ->> 'deleted_by')::BIGINT;
            END IF;
        ELSIF TG_OP = 'UPDATE' THEN
            v_changed_by := (v_record ->> 'updated_by')::BIGINT;
        END IF;
        v_company_id := (v_record ->> 'company_id')::INTEGER;

        INSERT INTO audit.audit_log (
            transaction_id,
            table_name,
            record_id,
            action,
            old_data,
            new_data,
            changed_by,
            changed_at,
            company_id
        )
        VALUES (
            v_transaction_id,
            TG_TABLE_NAME,
            CASE WHEN TG_OP = 'DELETE' THEN OLD.id ELSE NEW.id END::VARCHAR,
            TG_OP,
            v_old_data,
            v_new_data,
            v_changed_by,
            NOW(),
            v_company_id
        );

        RETURN CASE WHEN TG_OP = 'DELETE' THEN OLD ELSE NEW END;
    END;
    $$;


ALTER FUNCTION audit.fn_audit_trigger() OWNER TO postgres;

--
