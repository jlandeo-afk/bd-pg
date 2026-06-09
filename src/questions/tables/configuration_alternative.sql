-- Table: questions.configuration_alternative
-- Includes constraints and indexes

--

CREATE TABLE questions.configuration_alternative (
    id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    columns smallint DEFAULT '3'::smallint NOT NULL,
    styles TEXT DEFAULT '{}'::TEXT NOT NULL,
    fl_image BOOLEAN DEFAULT false NOT NULL,
    fl_default BOOLEAN DEFAULT false NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    company_id BIGINT NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.configuration_alternative OWNER TO postgres;

--

--

ALTER TABLE questions.configuration_alternative
    ADD CONSTRAINT pk_configuration_alternative PRIMARY KEY (id);


--

--

ALTER TABLE questions.configuration_alternative
    ADD CONSTRAINT fk_configuration_alternative_company FOREIGN KEY (company_id) REFERENCES odiseo.companies(id);


--

--

ALTER TABLE questions.configuration_alternative
    ADD CONSTRAINT fk_configuration_alternative_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.configuration_alternative
    ADD CONSTRAINT fk_configuration_alternative_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.configuration_alternative
    ADD CONSTRAINT fk_configuration_alternative_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
