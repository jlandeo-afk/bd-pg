-- Table: academic.cycle_weeks
-- Includes constraints and indexes

--

CREATE TABLE academic.cycle_weeks (
    id BIGINT NOT NULL,
    week smallint,
    type_week_id BIGINT NOT NULL,
    cycle_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE academic.cycle_weeks OWNER TO postgres;

--

--

ALTER TABLE academic.cycle_weeks
    ADD CONSTRAINT pk_cycle_weeks PRIMARY KEY (id);


--

--

CREATE UNIQUE INDEX uq_cycle_weeks_cycle_id_start_date ON academic.cycle_weeks USING btree (cycle_id, start_date) WHERE (fl_status IS TRUE);


--

--

ALTER TABLE academic.cycle_weeks
    ADD CONSTRAINT fk_cycle_weeks_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.cycle_weeks
    ADD CONSTRAINT fk_cycle_weeks_cycle FOREIGN KEY (cycle_id) REFERENCES academic.cycle(id);


--

--

ALTER TABLE academic.cycle_weeks
    ADD CONSTRAINT fk_cycle_weeks_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE academic.cycle_weeks
    ADD CONSTRAINT fk_cycle_weeks_type_week FOREIGN KEY (type_week_id) REFERENCES academic.type_week(id);


--

--

ALTER TABLE academic.cycle_weeks
    ADD CONSTRAINT fk_cycle_weeks_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
