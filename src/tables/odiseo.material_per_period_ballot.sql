-- Table: odiseo.material_per_period_ballot
-- Includes constraints and indexes

--

CREATE TABLE odiseo.material_per_period_ballot (
    id bigint NOT NULL,
    material_per_period_id bigint NOT NULL,
    start_week smallint NOT NULL,
    end_week smallint NOT NULL,
    fl_config_type boolean DEFAULT true NOT NULL,
    lower_level_limit smallint DEFAULT '0'::smallint NOT NULL,
    upper_level_limit smallint DEFAULT '0'::smallint NOT NULL,
    questions_missing_url character varying(255),
    courses_missing_url character varying(255),
    text_missing_url character varying(255),
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone,
    fl_missing_questions boolean DEFAULT false NOT NULL,
    fl_missing_courses boolean DEFAULT false NOT NULL,
    fl_missing_text boolean DEFAULT false NOT NULL,
    date_completed timestamp(0) without time zone,
    user_completed_id bigint,
    order_date timestamp(0) without time zone,
    order_by_user_id bigint
);


ALTER TABLE odiseo.material_per_period_ballot OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.material_per_period_ballot
    ADD CONSTRAINT material_per_period_ballot_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX per_material_ba_and_type_id ON odiseo.material_per_period_ballot USING btree (material_per_period_id, start_week, end_week) WHERE (deleted_at IS NULL);


--

--

ALTER TABLE ONLY odiseo.material_per_period_ballot
    ADD CONSTRAINT material_per_period_ballot_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_ballot
    ADD CONSTRAINT material_per_period_ballot_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_ballot
    ADD CONSTRAINT material_per_period_ballot_material_per_period_id_foreign FOREIGN KEY (material_per_period_id) REFERENCES odiseo.material_per_period(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_ballot
    ADD CONSTRAINT material_per_period_ballot_order_by_user_id_foreign FOREIGN KEY (order_by_user_id) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_ballot
    ADD CONSTRAINT material_per_period_ballot_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.material_per_period_ballot
    ADD CONSTRAINT material_per_period_ballot_user_completed_id_foreign FOREIGN KEY (user_completed_id) REFERENCES odiseo.users(id);


--
