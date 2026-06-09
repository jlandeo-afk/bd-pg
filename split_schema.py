import os
import re

def get_domain_path(schema, subfolder):
    domain = schema.strip().lower()
    if domain in ("public", "odiseo"):
        domain = "common"
    dir_path = f"src/{domain}/{subfolder}"
    os.makedirs(dir_path, exist_ok=True)
    return dir_path

def main():
    # 1. Create directory structure
    dirs = [
        "src/schemas",
        "src/roles",
        "migrations"
    ]
    for d in dirs:
        os.makedirs(d, exist_ok=True)
        print(f"Creating directory: {d}")

    # 2. Extract and format roles
    roles_content = ""
    if os.path.exists("roles_dump.sql"):
        print("Reading roles_dump.sql...")
        with open("roles_dump.sql", "r", encoding="utf-8") as f:
            roles_content = f.read()

    roles_lines = []
    for line in roles_content.splitlines():
        line_strip = line.strip()
        if line_strip.startswith("\\restrict") or line_strip.startswith("\\unrestrict"):
            continue
        if line_strip.startswith("--") or line_strip == "" or "SET " in line_strip:
            continue
        roles_lines.append(line)

    roles_sql_path = "src/roles/roles.sql"
    with open(roles_sql_path, "w", encoding="utf-8") as f:
        f.write("-- ==========================================\n")
        f.write("-- ROLES AND PERMISSIONS (Clean DB Architecture)\n")
        f.write("-- ==========================================\n\n")
        f.write("\n".join(roles_lines))
        f.write("\n")
    print(f"Generated {roles_sql_path}")

    # 3. Analyze and split schema_dump.sql
    print("Reading schema_dump.sql...")
    with open("schema_dump.sql", "r", encoding="utf-8") as f:
        schema_content = f.read()

    # Regex pattern to match metadata comments
    # Format: -- Name: generar_lorem_ajustado(integer); Type: FUNCTION; Schema: anon; Owner: postgres
    metadata_pattern = re.compile(
        r"^-- Name: (?P<name>.+?); Type: (?P<type>.+?); Schema: (?P<schema>.+?); Owner: (?P<owner>.+?)$"
    )

    # Parse line by line and accumulate blocks.
    lines = schema_content.splitlines()
    blocks = []
    
    current_block = {
        "name": "HEADER",
        "type": "HEADER",
        "schema": "-",
        "owner": "-",
        "lines": []
    }
    
    for line in lines:
        match = metadata_pattern.match(line.strip())
        if match:
            # Save the previous block if it has content
            if current_block["lines"]:
                blocks.append(current_block)
            current_block = {
                "name": match.group("name"),
                "type": match.group("type"),
                "schema": match.group("schema"),
                "owner": match.group("owner"),
                "lines": []
            }
        else:
            current_block["lines"].append(line)
            
    if current_block["lines"]:
        blocks.append(current_block)

    print(f"Found {len(blocks)} total code/metadata blocks in dump file.")

    # Group table statements by table
    table_files = {} # (schema, table_name) -> list of sql strings
    
    # Other lists/files
    schemas_sql = []
    extensions_sql = []
    domains_sql = []
    types_sql = []
    sequences_sql = []
    views_list = []      # list of dicts: {"schema": schema, "name": name, "sql": sql}
    functions_list = []  # list of dicts: {"schema": schema, "name": name, "sql": sql, "is_trigger_fn": bool}
    triggers_list = []   # list of SQL strings for CREATE TRIGGER
    other_sql = []       # fallback

    # A regex to match target table in CREATE INDEX statement, supporting quotes
    # Example: CREATE INDEX index_name ON schema.tablename USING ... or ON tablename ...
    index_table_pattern = re.compile(
        r'ON\s+(?:ONLY\s+)?(?:(?:"?(?P<schema>\w+)"?)\.)?(?:"?(?P<table>\w+)"?)',
        re.IGNORECASE
    )

    def sanitize_filename(name):
        # Remove parameters for functions and sanitize
        clean = name.split('(')[0]
        # Remove quotes
        clean = clean.replace('"', '').replace("'", "")
        # Replace non-word chars with underscore
        clean = re.sub(r'[^\w\.]', '_', clean)
        clean = re.sub(r'_+', '_', clean)
        return clean.strip('_')

    # Helper to clean lines: strip restrict lines
    def clean_block_lines(block_lines):
        cleaned = []
        for l in block_lines:
            l_strip = l.strip()
            if l_strip.startswith("\\restrict") or l_strip.startswith("\\unrestrict"):
                continue
            cleaned.append(l)
        # remove leading/trailing blank lines
        while cleaned and cleaned[0].strip() == "":
            cleaned.pop(0)
        while cleaned and cleaned[-1].strip() == "":
            cleaned.pop()
        return "\n".join(cleaned)

    # Process all blocks
    for b in blocks:
        b_type = b["type"].strip()
        b_name = b["name"].strip()
        b_schema = b["schema"].strip()
        sql = clean_block_lines(b["lines"])
        if not sql.strip():
            continue
            
        if b_type == "HEADER":
            other_sql.append(sql)
            
        elif b_type == "SCHEMA":
            schemas_sql.append(sql)
            
        elif b_type == "EXTENSION":
            extensions_sql.append(sql)
            
        elif b_type == "DOMAIN":
            domains_sql.append(sql)
            
        elif b_type == "TYPE":
            types_sql.append(sql)
            
        elif b_type == "SEQUENCE" or b_type == "SEQUENCE OWNED BY":
            sequences_sql.append(sql)
            
        elif b_type == "TABLE":
            name_clean = b_name.replace('"', '')
            schema_clean = b_schema.replace('"', '')
            key = (schema_clean, name_clean)
            if key not in table_files:
                table_files[key] = []
            table_files[key].append(sql)
            
        elif b_type in ("CONSTRAINT", "FK CONSTRAINT"):
            # Table name is the first token of the constraint name in comment
            # e.g. "alternative alternative_pkey" -> "alternative"
            name_clean = b_name.replace('"', '')
            parts = name_clean.split()
            if parts:
                table_name = parts[0]
                schema_clean = b_schema.replace('"', '')
                key = (schema_clean, table_name)
                if key not in table_files:
                    table_files[key] = []
                table_files[key].append(sql)
            else:
                other_sql.append(sql)
                
        elif b_type == "INDEX":
            # Extract table name from CREATE INDEX SQL
            idx_match = index_table_pattern.search(sql)
            if idx_match:
                table_name = idx_match.group("table").replace('"', '')
                schema_name = idx_match.group("schema") or b_schema
                schema_name = schema_name.replace('"', '')
                key = (schema_name, table_name)
                if key not in table_files:
                    table_files[key] = []
                table_files[key].append(sql)
            else:
                other_sql.append(sql)
                
        elif b_type in ("VIEW", "MATERIALIZED VIEW"):
            views_list.append({
                "schema": b_schema.replace('"', ''),
                "name": b_name,
                "sql": sql
            })
            
        elif b_type == "FUNCTION" or b_type == "PROCEDURE":
            # Check if returns trigger
            is_trigger_fn = False
            if re.search(r"RETURNS\s+(?:trigger|event_trigger)", sql, re.IGNORECASE):
                is_trigger_fn = True
                
            functions_list.append({
                "schema": b_schema.replace('"', ''),
                "name": b_name,
                "sql": sql,
                "is_trigger_fn": is_trigger_fn
            })
            
        elif b_type == "TRIGGER":
            triggers_list.append(sql)
            
        else:
            other_sql.append(sql)

    # 4. Write output files
    # 4.1 Write Schemas, Extensions, Domains, Types, Sequences
    if schemas_sql:
        with open("src/schemas/schemas.sql", "w", encoding="utf-8") as f:
            f.write("-- Schemas\n\n" + "\n\n".join(schemas_sql) + "\n")
        print("Generated src/schemas/schemas.sql")
        
    if extensions_sql:
        with open("src/schemas/extensions.sql", "w", encoding="utf-8") as f:
            f.write("-- Extensions\n\n" + "\n\n".join(extensions_sql) + "\n")
        print("Generated src/schemas/extensions.sql")

    if domains_sql:
        with open("src/schemas/domains.sql", "w", encoding="utf-8") as f:
            f.write("-- Domains\n\n" + "\n\n".join(domains_sql) + "\n")
        print("Generated src/schemas/domains.sql")
        
    if types_sql:
        with open("src/schemas/types.sql", "w", encoding="utf-8") as f:
            f.write("-- Custom Types\n\n" + "\n\n".join(types_sql) + "\n")
        print("Generated src/schemas/types.sql")
        
    if sequences_sql:
        with open("src/schemas/sequences.sql", "w", encoding="utf-8") as f:
            f.write("-- Sequences\n\n" + "\n\n".join(sequences_sql) + "\n")
        print("Generated src/schemas/sequences.sql")

    # 4.2 Write Tables
    for (schema, table_name), sqls in table_files.items():
        domain_dir = get_domain_path(schema, "tables")
        filename = f"{domain_dir}/{table_name}.sql"
        with open(filename, "w", encoding="utf-8") as f:
            f.write(f"-- Table: {schema}.{table_name}\n")
            f.write(f"-- Includes constraints and indexes\n\n")
            f.write("\n\n".join(sqls) + "\n")
        print(f"Generated {filename}")

    # 4.3 Write Views
    for v in views_list:
        v_name_clean = sanitize_filename(v["name"])
        domain_dir = get_domain_path(v["schema"], "views")
        filename = f"{domain_dir}/{v_name_clean}.sql"
        with open(filename, "w", encoding="utf-8") as f:
            f.write(f"-- View: {v['schema']}.{v['name']}\n\n")
            f.write(v["sql"] + "\n")
        print(f"Generated {filename}")

    # 4.4 Write Functions & Trigger Functions
    for fn in functions_list:
        fn_name_clean = sanitize_filename(fn["name"])
        if fn["is_trigger_fn"]:
            domain_dir = get_domain_path(fn["schema"], "triggers")
            filename = f"{domain_dir}/{fn_name_clean}.sql"
            header = f"-- Trigger Function: {fn['schema']}.{fn['name']}\n\n"
        else:
            domain_dir = get_domain_path(fn["schema"], "functions")
            filename = f"{domain_dir}/{fn_name_clean}.sql"
            header = f"-- Function: {fn['schema']}.{fn['name']}\n\n"
            
        with open(filename, "w", encoding="utf-8") as f:
            f.write(header)
            f.write(fn["sql"] + "\n")
        print(f"Generated {filename}")

    # 4.5 Write Triggers (bindings)
    if triggers_list:
        domain_dir = get_domain_path("common", "triggers")
        filename = f"{domain_dir}/triggers.sql"
        with open(filename, "w", encoding="utf-8") as f:
            f.write("-- Trigger Bindings\n\n" + "\n\n".join(triggers_list) + "\n")
        print(f"Generated {filename}")

    # 5. Generate baseline_schema.sql
    print("Generating migrations/V1.0.0__baseline_schema.sql...")
    
    clean_schema_lines = []
    for line in schema_content.splitlines():
        line_strip = line.strip()
        if line_strip.startswith("\\restrict") or line_strip.startswith("\\unrestrict"):
            continue
        clean_schema_lines.append(line)
        
    baseline_content = []
    baseline_content.append("-- ========================================================")
    baseline_content.append("-- V1.0.0__baseline_schema.sql")
    baseline_content.append("-- Generated automatically by Antigravity DBA & Architect")
    baseline_content.append("-- ========================================================\n")
    
    # Prepend Roles
    baseline_content.append("-- --------------------------------------------------------")
    baseline_content.append("-- ROLES AND SECURITY SETUP")
    baseline_content.append("-- --------------------------------------------------------")
    baseline_content.extend(roles_lines)
    baseline_content.append("\n")
    
    # Add Cleaned Schema Structure
    baseline_content.append("-- --------------------------------------------------------")
    baseline_content.append("-- DATABASE SCHEMA AND STRUCTURE")
    baseline_content.append("-- --------------------------------------------------------")
    baseline_content.extend(clean_schema_lines)
    
    with open("migrations/V1.0.0__baseline_schema.sql", "w", encoding="utf-8") as f:
        f.write("\n".join(baseline_content) + "\n")
        
    print("Generated migrations/V1.0.0__baseline_schema.sql")
    print("Reorganization and baseline generation completed successfully!")

if __name__ == "__main__":
    main()
