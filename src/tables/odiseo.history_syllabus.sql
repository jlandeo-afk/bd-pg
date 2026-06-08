-- Table: odiseo.history_syllabus
-- Includes constraints and indexes

--

CREATE TABLE odiseo.history_syllabus (
    id bigint NOT NULL,
    syllabus_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    correlative integer,
    description text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    token character varying(255),
    weeks json,
    company_id bigint DEFAULT '1'::bigint NOT NULL
);


ALTER TABLE odiseo.history_syllabus OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.history_syllabus
    ADD CONSTRAINT history_syllabus_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.history_syllabus
    ADD CONSTRAINT history_syllabus_company_id_foreign FOREIGN KEY (company_id) REFERENCES odiseo.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE ONLY odiseo.history_syllabus
    ADD CONSTRAINT history_syllabus_role_id_foreign FOREIGN KEY (role_id) REFERENCES odiseo.roles(id);


--

--

ALTER TABLE ONLY odiseo.history_syllabus
    ADD CONSTRAINT history_syllabus_syllabus_id_foreign FOREIGN KEY (syllabus_id) REFERENCES odiseo.syllabus(id);


--

--

ALTER TABLE ONLY odiseo.history_syllabus
    ADD CONSTRAINT history_syllabus_user_id_foreign FOREIGN KEY (user_id) REFERENCES odiseo.users(id);


--
