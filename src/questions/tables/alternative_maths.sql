-- Table: questions.alternative_maths
-- Includes constraints and indexes

--

CREATE TABLE questions.alternative_maths (
    id BIGINT NOT NULL,
    code VARCHAR(50) NOT NULL,
    path VARCHAR(255) NOT NULL,
    alternative_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    properties JSON NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE questions.alternative_maths OWNER TO postgres;

--

--

ALTER TABLE questions.alternative_maths
    ADD CONSTRAINT pk_alternative_maths PRIMARY KEY (id);


--

--

ALTER TABLE questions.alternative_maths
    ADD CONSTRAINT fk_alternative_maths_alternative FOREIGN KEY (alternative_id) REFERENCES questions.alternative(id);


--

--

ALTER TABLE questions.alternative_maths
    ADD CONSTRAINT fk_alternative_maths_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.alternative_maths
    ADD CONSTRAINT fk_alternative_maths_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.alternative_maths
    ADD CONSTRAINT fk_alternative_maths_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
