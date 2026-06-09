-- Table: common.plans
-- Includes constraints and indexes

--

CREATE TABLE common.plans (
    id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255) NOT NULL,
    cost NUMERIC(20,2) DEFAULT '0'::NUMERIC NOT NULL,
    benefits VARCHAR(255) NOT NULL,
    number_users smallint DEFAULT '0'::smallint NOT NULL,
    number_questions smallint DEFAULT '0'::smallint NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ
);


ALTER TABLE common.plans OWNER TO postgres;

--

--

ALTER TABLE common.plans
    ADD CONSTRAINT pk_plans PRIMARY KEY (id);


--

--

ALTER TABLE common.plans
    ADD CONSTRAINT fk_plans_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.plans
    ADD CONSTRAINT fk_plans_deleted_by FOREIGN KEY (deleted_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.plans
    ADD CONSTRAINT fk_plans_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--
