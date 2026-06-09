-- Table: academic.cycle_weeks
-- Includes constraints and indexes

--

CREATE TABLE academic.cycle_weeks (
    id bigint NOT NULL,
    week smallint,
    type_week_id bigint NOT NULL,
    cycle_id bigint NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE academic.cycle_weeks OWNER TO postgres;

--

--

ALTER TABLE ONLY academic.cycle_weeks
    ADD CONSTRAINT cycle_weeks_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX idx_cycle_weeks_unique_date ON academic.cycle_weeks USING btree (cycle_id, start_date) WHERE (fl_status IS TRUE);


--

--

ALTER TABLE ONLY academic.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_created_by_foreign FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE ONLY academic.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE ONLY academic.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_type_week_id_foreign FOREIGN KEY (type_week_id) REFERENCES academic.type_week(id);


--

--

ALTER TABLE ONLY academic.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
