-- Table: common.importance_rejected
-- Includes constraints and indexes

--

CREATE TABLE common.importance_rejected (
    id smallint NOT NULL,
    level smallint NOT NULL,
    name VARCHAR(100) NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE common.importance_rejected OWNER TO postgres;

--

--

ALTER TABLE common.importance_rejected
    ADD CONSTRAINT pk_importance_rejected PRIMARY KEY (id);


--

--

ALTER TABLE common.importance_rejected
    ADD CONSTRAINT fk_importance_rejected_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.importance_rejected
    ADD CONSTRAINT fk_importance_rejected_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.importance_rejected
    ADD CONSTRAINT fk_importance_rejected_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
