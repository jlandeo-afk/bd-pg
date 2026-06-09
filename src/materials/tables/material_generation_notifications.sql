-- Table: materials.material_generation_notifications
-- Includes constraints and indexes

--

CREATE TABLE materials.material_generation_notifications (
    id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message VARCHAR(255) NOT NULL,
    url_internal VARCHAR(255),
    request_status VARCHAR(255) DEFAULT 'success'::VARCHAR NOT NULL,
    user_id BIGINT NOT NULL,
    created_by BIGINT,
    type BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    fl_read BOOLEAN DEFAULT false NOT NULL,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT material_generation_notifications_request_status_check CHECK (((request_status)::TEXT = ANY (ARRAY[('success'::VARCHAR)::TEXT, ('failure'::VARCHAR)::TEXT])))
);


ALTER TABLE materials.material_generation_notifications OWNER TO postgres;

--

--

ALTER TABLE materials.material_generation_notifications
    ADD CONSTRAINT pk_material_generation_notifications PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_generation_notifications
    ADD CONSTRAINT fk_material_generation_notifications_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_generation_notifications
    ADD CONSTRAINT fk_material_generation_notifications_type FOREIGN KEY (type) REFERENCES materials.material_generation_notification_types(id);


--

--

ALTER TABLE materials.material_generation_notifications
    ADD CONSTRAINT fk_material_generation_notifications_user FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
