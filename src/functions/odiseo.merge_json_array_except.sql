-- Function: odiseo.merge_json_array_except(json, json)

--

CREATE FUNCTION odiseo.merge_json_array_except(existing json, incoming json) RETURNS json
    LANGUAGE plpgsql IMMUTABLE
    AS $$
        DECLARE
            existingb  jsonb := coalesce(existing, '[]'::json)::jsonb;
            incomingb  jsonb := coalesce(incoming, '[]'::json)::jsonb;
            elems_new  jsonb;
            mergedb    jsonb;
        BEGIN
            -- 1) Sacamos los elementos nuevos (incomingb − existingb)
            SELECT jsonb_agg(value) 
                INTO elems_new
            FROM (
                SELECT value
                FROM jsonb_array_elements(incomingb)
                EXCEPT
                SELECT value
                FROM jsonb_array_elements(existingb)
            ) sub;

            -- 2) Concatenamos existingb + elems_new (o solo existingb si no hay elems_new)
            IF elems_new IS NULL THEN
                mergedb := existingb;
            ELSE
                mergedb := existingb || elems_new;
            END IF;

            -- 3) Devolvemos como JSON puro
            RETURN mergedb::json;
        END;
        $$;


ALTER FUNCTION odiseo.merge_json_array_except(existing json, incoming json) OWNER TO postgres;

--
