-- Table: academic.history_syllabus
-- Includes constraints and indexes

--

CREATE TABLE academic.history_syllabus (
    id BIGINT NOT NULL,
    syllabus_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    correlative INTEGER,
    description TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    token VARCHAR(255),
    weeks JSON,
    company_id BIGINT DEFAULT '1'::BIGINT NOT NULL
);


ALTER TABLE academic.history_syllabus OWNER TO postgres;

--

--

ALTER TABLE academic.history_syllabus
    ADD CONSTRAINT pk_history_syllabus PRIMARY KEY (id);


--

--

ALTER TABLE academic.history_syllabus
    ADD CONSTRAINT fk_history_syllabus_company FOREIGN KEY (company_id) REFERENCES organization.companies(id) ON DELETE CASCADE;


--

--

ALTER TABLE academic.history_syllabus
    ADD CONSTRAINT fk_history_syllabus_role FOREIGN KEY (role_id) REFERENCES auth.roles(id);


--

--

ALTER TABLE academic.history_syllabus
    ADD CONSTRAINT fk_history_syllabus_syllabus FOREIGN KEY (syllabus_id) REFERENCES academic.syllabus(id);


--

--

ALTER TABLE academic.history_syllabus
    ADD CONSTRAINT fk_history_syllabus_user FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
