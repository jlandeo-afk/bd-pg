-- Table: organization.clientes_empresas
-- Includes constraints and indexes

--

CREATE TABLE organization.clientes_empresas (
    id BIGINT NOT NULL,
    ruc VARCHAR(255) NOT NULL,
    razon_social VARCHAR(255) NOT NULL,
    tipo VARCHAR(255) NOT NULL,
    nombre_comercial VARCHAR(255) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    departamento_id BIGINT NOT NULL,
    provincia_id BIGINT NOT NULL,
    distrito_id BIGINT NOT NULL,
    numero_estudiantes INTEGER,
    numero_colaboradores INTEGER,
    nivel_educativo VARCHAR(255),
    correo_contacto_principal VARCHAR(255) NOT NULL,
    correo_facturacion VARCHAR(255),
    telefono VARCHAR(255),
    pagina_web VARCHAR(255),
    facebook VARCHAR(255),
    instagram VARCHAR(255),
    tiktok VARCHAR(255),
    plan_contratado VARCHAR(255) DEFAULT 'Free'::VARCHAR NOT NULL,
    fecha_inicio DATE NOT NULL,
    modalidad_pago VARCHAR(255),
    subdominio VARCHAR(255) NOT NULL,
    estado VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    company_id INTEGER
);


ALTER TABLE organization.clientes_empresas OWNER TO postgres;

--

--

ALTER TABLE organization.clientes_empresas
    ADD CONSTRAINT pk_clientes_empresas PRIMARY KEY (id);


--

--

ALTER TABLE organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_ruc_unique UNIQUE (ruc);


--

--

ALTER TABLE organization.clientes_empresas
    ADD CONSTRAINT clientes_empresas_subdominio_unique UNIQUE (subdominio);


--

--

ALTER TABLE organization.clientes_empresas
    ADD CONSTRAINT fk_clientes_empresas_company FOREIGN KEY (company_id) REFERENCES organization.companies(id);


--

--

ALTER TABLE organization.clientes_empresas
    ADD CONSTRAINT fk_clientes_empresas_departamento FOREIGN KEY (departamento_id) REFERENCES organization.region(id) ON DELETE SET NULL;


--

--

ALTER TABLE organization.clientes_empresas
    ADD CONSTRAINT fk_clientes_empresas_distrito FOREIGN KEY (distrito_id) REFERENCES organization.districts(id) ON DELETE SET NULL;


--

--

ALTER TABLE organization.clientes_empresas
    ADD CONSTRAINT fk_clientes_empresas_provincia FOREIGN KEY (provincia_id) REFERENCES organization.provinces(id) ON DELETE SET NULL;


--
