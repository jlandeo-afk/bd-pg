-- Table: materials.material_per_period_level_limit_config
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_level_limit_config (
    id bigint NOT NULL,
    material_per_period_id bigint NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    lower_level_limit smallint DEFAULT '1'::smallint NOT NULL,
    upper_level_limit smallint DEFAULT '1'::smallint NOT NULL,
    created_by integer NOT NULL,
    updated_by integer,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    deleted_by integer,
    fl_use_question_type boolean DEFAULT true NOT NULL
);


ALTER TABLE materials.material_per_period_level_limit_config OWNER TO postgres;

--

--

ALTER TABLE ONLY materials.material_per_period_level_limit_config
    ADD CONSTRAINT material_per_period_level_limit_config_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY materials.material_per_period_level_limit_config
    ADD CONSTRAINT material_per_period_level_limit_config_material_per_period_id_f FOREIGN KEY (material_per_period_id) REFERENCES materials.material_per_period(id);


--
