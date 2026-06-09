-- Table: common.individual_notifications
-- Includes constraints and indexes

--

CREATE TABLE common.individual_notifications (
    id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message VARCHAR(255) NOT NULL,
    url_internal VARCHAR(255),
    user_id BIGINT NOT NULL,
    type BIGINT NOT NULL,
    fl_status BOOLEAN DEFAULT true NOT NULL,
    fl_read BOOLEAN DEFAULT false NOT NULL,
    created_by BIGINT,
    updated_by BIGINT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
);


ALTER TABLE common.individual_notifications OWNER TO postgres;

--

--

ALTER TABLE common.individual_notifications
    ADD CONSTRAINT pk_individual_notifications PRIMARY KEY (id);


--

--

ALTER TABLE common.individual_notifications
    ADD CONSTRAINT fk_individual_notifications_created_by FOREIGN KEY (created_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.individual_notifications
    ADD CONSTRAINT fk_individual_notifications_updated_by FOREIGN KEY (updated_by) REFERENCES auth.users(id);


--

--

ALTER TABLE common.individual_notifications
    ADD CONSTRAINT fk_individual_notifications_user FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
