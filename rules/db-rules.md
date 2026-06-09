# Estándar de Ingeniería de Base de Datos y Seguridad (v2)

Este documento define el estándar arquitectónico, de seguridad y rendimiento para la base de datos PostgreSQL 16 y su integración con el backend Laravel. Todo desarrollo realizado por humanos o agentes de IA en este repositorio debe cumplir estrictamente con estas reglas.

---

## 1. Arquitectura de Esquemas Físicos (Namespaces)

Para evitar un esquema monolítico saturado y confuso, la base de datos se estructura en **esquemas físicos de PostgreSQL** que actúan como límites lógicos de dominio (Domain-Driven Design a nivel de base de datos):

*   **`auth`**: Seguridad, autenticación, usuarios, roles, permisos y sesiones.
*   **`academic`**: Estructuras educativas: cursos, syllabus, temas, subtemas, semanas, ciclos y universidades.
*   **`questions`**: Banco de preguntas, alternativas, digitalización de imágenes de soluciones e integraciones de IA.
*   **`materials`**: Materiales de clase, PDFs finales, balotas por periodos y plantillas de configuración.
*   **`exams`**: Exámenes, áreas de evaluación, claves y estadísticas de rendimiento.
*   **`organization`**: Estructura de la organización: compañías (clientes), empleados, docentes, sedes y aulas.
*   **`audit`**: Tablas y triggers destinados al registro histórico de cambios (auditoría).
*   **`public`**: Reservado exclusivamente para extensiones globales y utilidades transversales sin lógica de negocio.

---

## 2. Nomenclatura y Estructura Estricta (Clean DDL)

### A. Tablas, Columnas y Estructura SQL
*   **Nombres de Tablas**: `snake_case` y en plural (ej. `auth.users`, `academic.courses`).
*   **Tablas Intermedias (N:M)**: Nombre de las dos tablas combinadas en orden alfabético o lógico de dependencia (ej. `auth.roles_permissions`).
*   **Primary Keys (PK)**: Siempre columna `id` de tipo `UUID` (preferido para resiliencia y seguridad) o `BIGINT` / `BIGSERIAL`.
*   **Foreign Keys (FK)**: Nombre de la tabla referenciada en singular seguido de `_id` (ej. `course_id`).
*   **Timestamps**: `created_at` y `updated_at` de tipo `TIMESTAMPTZ` (nunca `timestamp without time zone` para mantener la consistencia horaria global).
*   **Soft Deletes**: Columna `deleted_at` de tipo `TIMESTAMPTZ` únicamente en tablas críticas.

#### Reglas de Estilo DDL (Clean Code):
1.  **Palabras Clave en Mayúsculas**: Las palabras clave de SQL (ej: `CREATE TABLE`, `BIGINT`, `NOT NULL`, `CONSTRAINT`, `FOREIGN KEY`, `REFERENCES`, `ON DELETE RESTRICT`) deben escribirse estrictamente en **MAYÚSCULAS**.
2.  **Prefijos de Restricciones (Constraints)**:
    *   Primary Keys: `pk_[nombre_tabla]` (ej: `pk_users`).
    *   Foreign Keys: `fk_[nombre_tabla]_[columna_fk]` (ej: `fk_course_assigned_subcategories_subcategory`).
    *   Índices Únicos: `uq_[nombre_tabla]_[columnas]` (ej: `uq_users_email`).
    *   Índices Estándar: `idx_[nombre_tabla]_[columnas]` (ej: `idx_users_email`).
3.  **Cobertura de Índices para FKs**: Cada foreign key **debe** tener un índice asociado. Si la columna FK es la primera en un índice único compuesto, no requiere índice adicional. Si es la segunda o no está en ningún índice compuesto, se debe crear un índice `idx_` exclusivo para evitar escaneos secuenciales (`seq scan`) en los `JOIN` y cascadas de eliminación.

##### Ejemplo DDL Refactorado:
```sql
CREATE TABLE academic.course_assigned_subcategories (
    id BIGINT NOT NULL,
    course_assigned_category_id BIGINT NOT NULL,
    subcategory_id INTEGER NOT NULL,
    created_by BIGINT NOT NULL,
    updated_by BIGINT,
    deleted_by BIGINT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,

    CONSTRAINT pk_course_assigned_subcategories PRIMARY KEY (id)
);

-- Índice Único (cubre course_assigned_category_id por ser primera columna)
CREATE UNIQUE INDEX uq_course_assigned_subcategories_active_mapping 
    ON academic.course_assigned_subcategories (course_assigned_category_id, subcategory_id) 
    WHERE (deleted_at IS NULL);

-- Índice Adicional para subcategory_id (cubre la FK secundaria)
CREATE INDEX idx_course_assigned_subcategories_subcategory 
    ON academic.course_assigned_subcategories (subcategory_id);

-- Restricciones de Llaves Foráneas Limpias
ALTER TABLE academic.course_assigned_subcategories
    ADD CONSTRAINT fk_course_assigned_subcategories_category
    FOREIGN KEY (course_assigned_category_id) REFERENCES academic.course_assigned_categories(id) ON DELETE CASCADE;
```

### B. Prefijos de Objetos SQL
*   **Funciones**: `fn_` seguido del verbo y el dominio/entidad (ej. `fn_create_user`, `fn_list_courses_by_employee`).
*   **Procedimientos**: `sp_` para procesos batch o transaccionales que requieran gestión interna de transacciones (`COMMIT`/`ROLLBACK`).
*   **Triggers**: `trg_` seguido de la tabla y la acción (ej. `trg_audit_users`).
*   **Vistas**:
    *   Estándar: `vw_` (ej. `vw_active_teachers`).
    *   Materializadas: `mv_` (ej. `mv_exam_usage_stats`).
*   **Índices**:
    *   B-Tree estándar: `idx_nombretabla_columnas` (ej. `idx_users_email`).
    *   Único: `uq_nombretabla_columnas` (ej. `uq_users_document`).
    *   Llave foránea: `fk_nombretabla_tablaorigen` (ej. `fk_courses_company_id`).

---

## 3. Estándar de Funciones y Volatilidad (PL/pgSQL)

### A. Verbos de Funciones (Strict)
*   **Lectura (STABLE)**:
    *   `get`: Retorna exactamente 1 registro o fila (arroja error o NULL si no existe).
    *   `list`: Retorna un conjunto de filas (N filas) sin paginar.
    *   `paginate`: Retorna un subconjunto de filas con metadatos de paginación (offset, limit, total).
    *   `search`: Retorna filas filtradas dinámicamente.
    *   `count`: Retorna un entero.
    *   `exists` / `is` / `has` / `can`: Retorna un booleano.
*   **Escritura (VOLATILE)**:
    *   `create` / `update` / `delete`: Operaciones estándar de escritura.
    *   `archive`: Soft delete (cambio de estado / `deleted_at`).
    *   `restore`: Revierte un soft delete.
    *   `upsert`: Inserta o actualiza en conflicto.
*   **Lógica / Procesamiento (VOLATILE / IMMUTABLE)**:
    *   `calculate`: Operaciones matemáticas puras (debe ser `IMMUTABLE` si no consulta tablas).
    *   `process` / `sync`: Flujos lógicos complejos y sincronización de datos.
    *   `approve` / `reject` / `assign`: Transiciones de estado de negocio.

### B. Reglas de Volatilidad
1.  **`IMMUTABLE`**: No puede modificar ni leer la base de datos. Ante los mismos argumentos, siempre retorna el mismo valor (ej. formateo de texto, cálculos matemáticos puros). Permite al planificador de consultas cachear el resultado.
2.  **`STABLE`**: No puede modificar la base de datos. Puede realizar lecturas (SELECT). Garantiza retornar los mismos resultados dentro de la misma transacción para los mismos parámetros.
3.  **`VOLATILE`**: Puede modificar datos (INSERT, UPDATE, DELETE). Se ejecuta para cada fila evaluada y no puede ser optimizada mediante caché por el planificador de consultas.

### C. Retornos Estrictos
*   **NUNCA** utilices `SETOF record`. Requiere definir los tipos al invocar la función, lo cual acopla innecesariamente el backend.
*   Utiliza siempre `RETURNS TABLE(columna tipo, ...)` para retornos multi-columna o tipos compuestos (`RETURNS auth.users`).

### D. Principio de Reutilización, Nomenclatura Estricta y Evitación de Duplicados (Anti-Redundancia)
Cuando múltiples desarrolladores o agentes crean funciones sin un estándar riguroso, surgen funciones redundantes (ej: `fn_get_user_by_email`, `fn_get_user_by_uuid`, `fn_get_user_by_username`). Para evitar esto, se aplican las siguientes directrices:

#### 1. Consolidación de Funciones de Búsqueda y Obtención
*   **PROHIBIDO** crear funciones individuales para cada columna que se use como clave de búsqueda en la misma tabla.
*   **OBLIGATORIO** consolidar la obtención de registros en una única función que reciba parámetros opcionales (por defecto `NULL`) y aplique filtros condicionales en el `WHERE`.

##### Ejemplo de Obtención Unificada (GET / 1 Registro):
```sql
-- CORRECTO: Una sola función para obtener un usuario por cualquier clave única
CREATE OR REPLACE FUNCTION auth.fn_get_user(
    p_id bigint DEFAULT NULL,
    p_uuid uuid DEFAULT NULL,
    p_email text DEFAULT NULL,
    p_username text DEFAULT NULL
) RETURNS SETOF auth.users AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM auth.users u
    WHERE (p_id IS NULL OR u.id = p_id)
      AND (p_uuid IS NULL OR u.uuid = p_uuid)
      AND (p_email IS NULL OR u.email = p_email)
      AND (p_username IS NULL OR u.user = p_username)
    LIMIT 1;
END;
$$ LANGUAGE plpgsql STABLE;
```

##### Ejemplo de Búsqueda Dinámica (SEARCH / Múltiples Registros):
```sql
-- CORRECTO: Filtros dinámicos con cortocircuito
CREATE OR REPLACE FUNCTION academic.fn_search_courses(
    p_company_id integer DEFAULT NULL,
    p_level_id integer DEFAULT NULL,
    p_status boolean DEFAULT NULL
) RETURNS TABLE(id integer, name text, status boolean) AS $$
BEGIN
    RETURN QUERY
    SELECT c.id, c.name, c.status
    FROM academic.courses c
    WHERE (p_company_id IS NULL OR c.company_id = p_company_id)
      AND (p_level_id IS NULL OR c.level_id = p_level_id)
      AND (p_status IS NULL OR c.status = p_status);
END;
$$ LANGUAGE plpgsql STABLE;
```

#### 2. Formato de Nomenclatura de Funciones: `fn_[verbo]_[entidad]_[condicion]`
El nombre de la función debe permitir su autodescubrimiento al ordenar los archivos alfabéticamente.
*   `fn_`: Prefijo fijo.
*   `[verbo]`: Verbo exacto definido en la sección A (`get`, `list`, `paginate`, `exists`, `create`, `update`, etc.).
*   `[entidad]`: El nombre del recurso principal en singular (ej: `user`, `course`, `question`).
*   `[condicion]`: **Omitir si la función está consolidada**. Agregar solo si responde a un caso de uso sumamente particular (ej: `by_company`, `active`).

**Comparación de Nombres:**
*   ❌ `fn_user_has_permission` $\rightarrow$  `fn_exists_user_permission` o `fn_can_user_permission`
*   ❌ `fn_permissions_all` $\rightarrow$  `fn_list_permissions`
*   ❌ `fn_show_user_uuid` $\rightarrow$  `fn_get_user` (usando el parámetro `p_uuid`)
*   ❌ `fn_find_subtopic` $\rightarrow$  `fn_search_subtopics` (si es búsqueda dinámica)

#### 3. Protocolo de Descubrimiento (Búsqueda obligatoria antes de codificar)
Antes de crear cualquier función nueva, el programador o agente **debe** realizar una búsqueda en el subdirectorio de funciones del esquema correspondiente (ej: `src/academic/functions/` para cursos, `src/auth/functions/` para usuarios) buscando palabras clave del recurso. 
*   **Si ya existe una función**: Se debe **extender** su firma y lógica (por ejemplo, agregando un parámetro opcional más al `fn_get_user` o `fn_search_courses`) en lugar de crear un archivo nuevo.

---

## 4. Seguridad de Base de Datos y Vulnerabilidades

### A. Prevención de SQL Injection (Crítico)
*   **SQL Dinámico en PL/pgSQL**: Si construyes consultas SQL como strings dentro de funciones usando `EXECUTE`, **NUNCA** concatenes parámetros directamente con `||`. Utiliza siempre la cláusula `USING` para inyectar parámetros de forma segura:
    ```sql
    -- INCORRECTO (Vulnerable a SQL Injection)
    EXECUTE 'SELECT * FROM auth.users WHERE name = ''' || p_name || '''';

    -- CORRECTO (Seguro, utiliza bindings)
    EXECUTE 'SELECT * FROM auth.users WHERE name = $1' USING p_name;
    ```
*   **En Laravel**: Utiliza siempre Eloquent o Query Builder con bindings de parámetros. Si es estrictamente necesario usar `DB::raw()`, asegúrate de pasar los parámetros en un array secundario, nunca concatenes variables directamente en la cadena SQL.

### B. Principio de Menor Privilegio (Least Privilege)
*   La conexión de la aplicación backend (Laravel) **no debe usar el superusuario `postgres`**.
*   Se debe definir un rol de usuario restringido de aplicación (ej. `odiseo_app`) que solo tenga permisos de ejecución (`EXECUTE`) en el esquema de interfaz o permisos mínimos de lectura/escritura (`SELECT, INSERT, UPDATE, DELETE`) en los esquemas de tablas, previniendo alteraciones al DDL (no `ALTER`, no `DROP` en producción).

### C. Seguridad a Nivel de Fila (Row-Level Security - RLS)
*   Para datos altamente confidenciales o arquitecturas multi-tenant, se deben activar políticas de RLS en PostgreSQL para asegurar que un cliente o usuario solo pueda leer filas que le correspondan, incluso si la consulta SQL del backend carece de un filtro `WHERE company_id = X`.
    ```sql
    ALTER TABLE organization.employees ENABLE ROW LEVEL SECURITY;
    CREATE POLICY employee_tenant_isolation ON organization.employees
        USING (company_id = current_setting('app.current_company_id')::uuid);
    ```

---

## 5. Rendimiento, Consultas e Índices

### A. Consulta de Datos
*   **SELECT explícito**: Especifica siempre las columnas deseadas. Evita `SELECT *` para reducir la transferencia de red y permitir que el optimizador utilice índices de cobertura (*Index-Only Scans*).
*   **Filtros de Fechas**: Evita aplicar funciones sobre columnas indexadas de tipo timestamp en el `WHERE` (ej. `WHERE EXTRACT(YEAR FROM created_at) = 2026`), ya que invalida el uso del índice. Utiliza rangos en su lugar:
    ```sql
    -- CORRECTO
    WHERE created_at >= '2026-01-01 00:00:00+00' AND created_at < '2027-01-01 00:00:00+00'
    ```
*   **Evitar `BETWEEN` en marcas de tiempo**: `BETWEEN` es inclusivo en ambos extremos. En marcas de tiempo con milisegundos, esto puede incluir registros del día siguiente a las `00:00:00`. Usa siempre `>=` y `<`.
*   **UNION vs UNION ALL**: Utiliza `UNION ALL` por defecto. `UNION` realiza una operación implícita de ordenamiento y deduplicación en memoria que degrada el rendimiento.

### B. Optimización de Relaciones (N+1)
*   En Laravel, utiliza siempre carga ansiosa (*Eager Loading* con `with()`) para evitar consultas redundantes en bucles.
*   En SQL puro, resuelve relaciones uno a muchos complejas utilizando `LATERAL JOIN` o expresiones tipo `JSONB` agregadas en subconsultas para retornar estructuras jerárquicas en un solo viaje de red.

---

## 6. Flujo de Trabajo y Migraciones Declarativas

Para garantizar la sincronización limpia de la base de datos entre el código local y los entornos de producción sin perder el control de la estructura declarativa de Git, se promueve el uso de **Migraciones Declarativas**:

```mermaid
graph LR
    A[Modificar src/ SQL] --> B[Aplicar en Shadow DB]
    B --> C[Atlas / Migra calcula el Diff]
    C --> D[Generar Migración Flyway V1.0.X]
    D --> E[Ejecutar flyway migrate]
```

### ¿Qué son las Migraciones Declarativas y cómo funcionan?
En lugar de escribir manualmente engorrosos archivos de migración incrementales que alteran tablas, el desarrollador (o agente de IA) modifica directamente los archivos fuente declarativos en `src/` (ej. agregar una columna en `src/academic/tables/course.sql`).

Luego, herramientas modernas como **Atlas DB** (atlasgo.io) o **Migra** automatizan el proceso:
1.  **Shadow DB**: Levanta una base de datos temporal vacía en Docker.
2.  **Compilación**: Carga todos los archivos actuales de `src/` en la base de datos temporal.
3.  **Comparación (Diff)**: La herramienta compara el esquema resultante de la Shadow DB con tu base de datos local o de producción actual.
4.  **Generación de Script**: Genera de forma automatizada un script incremental limpio y preciso (ej. `migrations/V1.0.2__add_column_to_course.sql`) para Flyway.
5.  **Despliegue**: Flyway ejecuta este script generado de forma segura en producción.

Esto combina lo mejor de dos mundos: mantienes tus archivos fuente SQL perfectamente organizados y modulares en carpetas por dominios en tu repositorio de Git, y sigues disponiendo de migraciones secuenciales estrictas para tus despliegues.