-- Table: materials.material_generation_notification_types
-- Includes constraints and indexes

--

CREATE TABLE materials.material_generation_notification_types (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE materials.material_generation_notification_types OWNER TO postgres;

--

--

ALTER TABLE materials.material_generation_notification_types
    ADD CONSTRAINT pk_material_generation_notification_types PRIMARY KEY (id);


--
