-- Table: questions.parent_image
-- Includes constraints and indexes

--

CREATE TABLE questions.parent_image (
    id BIGINT NOT NULL,
    code VARCHAR(50) NOT NULL,
    extension VARCHAR(10),
    image TEXT NOT NULL,
    parent_id BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE questions.parent_image OWNER TO postgres;

--

--

ALTER TABLE questions.parent_image
    ADD CONSTRAINT pk_parent_image PRIMARY KEY (id);


--

--

ALTER TABLE questions.parent_image
    ADD CONSTRAINT fk_parent_image_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.parent_image
    ADD CONSTRAINT fk_parent_image_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE questions.parent_image
    ADD CONSTRAINT fk_parent_image_parent FOREIGN KEY (parent_id) REFERENCES questions.parent_question(id);


--

--

ALTER TABLE questions.parent_image
    ADD CONSTRAINT fk_parent_image_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
