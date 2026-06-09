-- Table: materials.material_generation_notifications
-- Includes constraints and indexes

--

CREATE TABLE materials.material_generation_notifications (
    id bigint NOT NULL,
    title character varying(255) NOT NULL,
    message character varying(255) NOT NULL,
    url_internal character varying(255),
    request_status character varying(255) DEFAULT 'success'::character varying NOT NULL,
    user_id bigint NOT NULL,
    created_by bigint,
    type bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    fl_read boolean DEFAULT false NOT NULL,
    read_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT material_generation_notifications_request_status_check CHECK (((request_status)::text = ANY (ARRAY[('success'::character varying)::text, ('failure'::character varying)::text])))
);


ALTER TABLE materials.material_generation_notifications OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_generation_notifications
    ADD CONSTRAINT material_generation_notifications_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_generation_notifications
    ADD CONSTRAINT odiseo_material_generation_notifications_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY materials.material_generation_notifications
    ADD CONSTRAINT odiseo_material_generation_notifications_type_foreign FOREIGN KEY (type) REFERENCES materials.material_generation_notification_types(id);


--

--

ALTER TABLE ONLY materials.material_generation_notifications
    ADD CONSTRAINT odiseo_material_generation_notifications_user_id_foreign FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
