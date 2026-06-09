-- Table: materials.material_per_period_level_limit_config
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_level_limit_config (
    id BIGINT NOT NULL,
    material_per_period_id BIGINT NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    lower_level_limit smallint DEFAULT '1'::smallint NOT NULL,
    upper_level_limit smallint DEFAULT '1'::smallint NOT NULL,
    created_by INTEGER NOT NULL,
    updated_by INTEGER,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    deleted_by INTEGER,
    fl_use_question_type BOOLEAN DEFAULT true NOT NULL
);


ALTER TABLE materials.material_per_period_level_limit_config OWNER TO postgres;

--

--

ALTER TABLE materials.material_per_period_level_limit_config
    ADD CONSTRAINT pk_material_per_period_level_limit_config PRIMARY KEY (id);


--

--

ALTER TABLE materials.material_per_period_level_limit_config
    ADD CONSTRAINT fk_material_per_period_level_limit_config_material_per_period FOREIGN KEY (material_per_period_id) REFERENCES materials.material_per_period(id);


--
