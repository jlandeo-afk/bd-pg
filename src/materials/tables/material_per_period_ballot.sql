-- Table: materials.material_per_period_ballot
-- Includes constraints and indexes

--

CREATE TABLE materials.material_per_period_ballot (
    id BIGINT NOT NULL,
    material_per_period_id BIGINT NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    fl_config_type BOOLEAN DEFAULT true NOT NULL,
    lower_level_limit smallint DEFAULT '0'::smallint NOT NULL,
    upper_level_limit smallint DEFAULT '0'::smallint NOT NULL,
    questions_missing_url VARCHAR(255),
    courses_missing_url VARCHAR(255),
    text_missing_url VARCHAR(255),
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    fl_missing_questions BOOLEAN DEFAULT false NOT NULL,
    fl_missing_courses BOOLEAN DEFAULT false NOT NULL,
    fl_missing_text BOOLEAN DEFAULT false NOT NULL,
    date_completed TIMESTAMPTZ,
    user_completed_id BIGINT,
    order_date TIMESTAMPTZ,
    order_by_user_id BIGINT
);


ALTER TABLE materials.material_per_period_ballot OWNER TO postgres;

--

--

ALTER TABLE materials.material_per_period_ballot
    ADD CONSTRAINT pk_material_per_period_ballot PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_material_per_period_ballot_material_per_period_id_start_w ON materials.material_per_period_ballot USING btree (material_per_period_id, start_week, end_week) WHERE (deleted_at IS NULL);


--

--

ALTER TABLE materials.material_per_period_ballot
    ADD CONSTRAINT fk_material_per_period_ballot_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_ballot
    ADD CONSTRAINT fk_material_per_period_ballot_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_ballot
    ADD CONSTRAINT fk_material_per_period_ballot_material_per_period FOREIGN KEY (material_per_period_id) REFERENCES materials.material_per_period(id);


--

--

ALTER TABLE materials.material_per_period_ballot
    ADD CONSTRAINT fk_material_per_period_ballot_order_by_user FOREIGN KEY (order_by_user_id) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_ballot
    ADD CONSTRAINT fk_material_per_period_ballot_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE materials.material_per_period_ballot
    ADD CONSTRAINT fk_material_per_period_ballot_user_completed FOREIGN KEY (user_completed_id) REFERENCES auth.users(id);


--
