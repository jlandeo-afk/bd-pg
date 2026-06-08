-- Table: odiseo.cycle_weeks
-- Includes constraints and indexes

--

CREATE TABLE odiseo.cycle_weeks (
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


ALTER TABLE odiseo.cycle_weeks OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.cycle_weeks
    ADD CONSTRAINT cycle_weeks_pkey PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX idx_cycle_weeks_unique_date ON odiseo.cycle_weeks USING btree (cycle_id, start_date) WHERE (fl_status IS TRUE);


--

--

ALTER TABLE ONLY odiseo.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_cycle_id_foreign FOREIGN KEY (cycle_id) REFERENCES odiseo.cycle(id);


--

--

ALTER TABLE ONLY odiseo.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_type_week_id_foreign FOREIGN KEY (type_week_id) REFERENCES odiseo.type_week(id);


--

--

ALTER TABLE ONLY odiseo.cycle_weeks
    ADD CONSTRAINT odiseo_cycle_weeks_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
