-- Table: odiseo.plans
-- Includes constraints and indexes

--

CREATE TABLE odiseo.plans (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    cost numeric(20,2) DEFAULT '0'::numeric NOT NULL,
    benefits character varying(255) NOT NULL,
    number_users smallint DEFAULT '0'::smallint NOT NULL,
    number_questions smallint DEFAULT '0'::smallint NOT NULL,
    fl_status boolean DEFAULT true NOT NULL,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    deleted_at timestamp(0) without time zone
);


ALTER TABLE odiseo.plans OWNER TO postgres;

--

--

ALTER TABLE ONLY odiseo.plans
    ADD CONSTRAINT plans_pkey PRIMARY KEY (id);


--

--

ALTER TABLE ONLY odiseo.plans
    ADD CONSTRAINT odiseo_plans_created_by_foreign FOREIGN KEY (created_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.plans
    ADD CONSTRAINT odiseo_plans_deleted_by_foreign FOREIGN KEY (deleted_by) REFERENCES odiseo.users(id);


--

--

ALTER TABLE ONLY odiseo.plans
    ADD CONSTRAINT odiseo_plans_updated_by_foreign FOREIGN KEY (updated_by) REFERENCES odiseo.users(id);


--
