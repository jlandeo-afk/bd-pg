-- Table: materials.material_generation_notification_types
-- Includes constraints and indexes

--

CREATE TABLE materials.material_generation_notification_types (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    created_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE materials.material_generation_notification_types OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_generation_notification_types
    ADD CONSTRAINT material_generation_notification_types_pkey PRIMARY KEY (id);


--
