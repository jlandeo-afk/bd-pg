-- Table: odiseo.didi_maths
-- Includes constraints and indexes

--

CREATE TABLE odiseo.didi_maths (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    path character varying(255) NOT NULL,
    didi_question_id bigint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    properties json NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    deleted_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE odiseo.didi_maths OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.didi_maths
    ADD CONSTRAINT didi_maths_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.didi_maths
    ADD CONSTRAINT odiseo_didi_maths_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.didi_maths
    ADD CONSTRAINT odiseo_didi_maths_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.didi_maths
    ADD CONSTRAINT odiseo_didi_maths_didi_question_id_foreign FOREIGN KEY (didi_question_id) REFERENCES odiseo.employee_didi_question_field(id);


--

--

ALTER TABLE ONLY odiseo.didi_maths
    ADD CONSTRAINT odiseo_didi_maths_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
