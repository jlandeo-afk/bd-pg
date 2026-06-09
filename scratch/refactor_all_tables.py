import os
import re

# Directory to scan
SRC_DIR = "src"

# Regular expressions for replacement
KEYWORDS_MAP = {
    r"\bcreate table\b": "CREATE TABLE",
    r"\bnot null\b": "NOT NULL",
    r"\balter table only\b": "ALTER TABLE",
    r"\balter table\b": "ALTER TABLE",
    r"\badd constraint\b": "ADD CONSTRAINT",
    r"\bforeign key\b": "FOREIGN KEY",
    r"\breferences\b": "REFERENCES",
    r"\bon delete cascade\b": "ON DELETE CASCADE",
    r"\bon delete restrict\b": "ON DELETE RESTRICT",
    r"\bon delete set null\b": "ON DELETE SET NULL",
    r"\bprimary key\b": "PRIMARY KEY",
    r"\bunique index\b": "UNIQUE INDEX",
    r"\bcreate index\b": "CREATE INDEX",
    r"\bcreate unique index\b": "CREATE UNIQUE INDEX",
    r"\busing btree\b": "USING btree",
    r"\bowner to\b": "OWNER TO",
    r"\bdefault\b": "DEFAULT",
}

TYPES_MAP = {
    r"\bbigint\b": "BIGINT",
    r"\binteger\b": "INTEGER",
    r"\bcharacter varying\b": "VARCHAR",
    r"\bvarchar\b": "VARCHAR",
    r"\btext\b": "TEXT",
    r"\bboolean\b": "BOOLEAN",
    r"\bjsonb\b": "JSONB",
    r"\bjson\b": "JSON",
    r"\bnumeric\b": "NUMERIC",
    r"\bdouble precision\b": "DOUBLE PRECISION",
    r"\bdate\b": "DATE",
    r"\buuid\b": "UUID",
    r"\btimestamp\(\d+\) without time zone\b": "TIMESTAMPTZ",
    r"\btimestamp without time zone\b": "TIMESTAMPTZ",
    r"\btimestamp\(\d+\) with time zone\b": "TIMESTAMPTZ",
    r"\btimestamp with time zone\b": "TIMESTAMPTZ",
}

def clean_sql_content(file_path, content):
    # Get table name from file name (e.g. course.sql -> course)
    file_name = os.path.basename(file_path)
    table_name = file_name.replace(".sql", "")
    
    # 1. Apply keyword replacements
    for pattern, repl in KEYWORDS_MAP.items():
        content = re.sub(pattern, repl, content, flags=re.IGNORECASE)
        
    # 2. Apply type replacements
    for pattern, repl in TYPES_MAP.items():
        content = re.sub(pattern, repl, content, flags=re.IGNORECASE)
        
    # 3. Clean up Primary Key constraint names:
    # Look for: ADD CONSTRAINT table_pkey PRIMARY KEY (column)
    # We want to change it to: ADD CONSTRAINT pk_table PRIMARY KEY (column)
    content = re.sub(
        r"ADD CONSTRAINT\s+(\w+_pkey|\w+_primary_key)\s+PRIMARY KEY",
        f"ADD CONSTRAINT pk_{table_name} PRIMARY KEY",
        content,
        flags=re.IGNORECASE
    )
    
    # 4. Clean up Foreign Key constraint names:
    # Look for: ADD CONSTRAINT constraint_name FOREIGN KEY (fk_col) REFERENCES target(target_col) ...
    # We want to change the constraint_name to: fk_table_fk_col
    def fk_replacer(match):
        full_match = match.group(0)
        old_constraint = match.group(1)
        fk_col = match.group(2)
        target_table_full = match.group(3)
        
        # Simplify target table name (e.g. academic.course -> course)
        target_table = target_table_full.split(".")[-1]
        
        # Clean fk column name (e.g. course_id -> course)
        fk_clean = fk_col.replace("_id", "")
        
        new_constraint_name = f"fk_{table_name}_{fk_clean}"
        
        # Rebuild statement
        # Check if ON DELETE cascade or restrict is already present in full_match
        on_delete = ""
        if "ON DELETE CASCADE" in full_match.upper():
            on_delete = " ON DELETE CASCADE"
        elif "ON DELETE RESTRICT" in full_match.upper():
            on_delete = " ON DELETE RESTRICT"
        elif "ON DELETE SET NULL" in full_match.upper():
            on_delete = " ON DELETE SET NULL"
            
        return f"ADD CONSTRAINT {new_constraint_name} FOREIGN KEY ({fk_col}) REFERENCES {target_table_full}{match.group(4)}{on_delete}"

    content = re.sub(
        r"ADD CONSTRAINT\s+(\w+)\s+FOREIGN KEY\s*\((\w+)\)\s*REFERENCES\s*([\w\.]+)\s*(\([^\)]+\))(.*?)(?=;|\n|$)",
        fk_replacer,
        content,
        flags=re.IGNORECASE | re.DOTALL
    )

    # 5. Clean up Unique Index names
    # Look for: CREATE UNIQUE INDEX index_name ON table USING btree (cols)
    # We want: CREATE UNIQUE INDEX uq_table_cols ON table USING btree (cols)
    def uq_idx_replacer(match):
        idx_type = match.group(1) # UNIQUE or empty
        old_idx_name = match.group(2)
        target_tbl = match.group(3)
        cols_raw = match.group(4)
        
        # Clean columns (remove spaces, parentheses, convert to snake_case)
        cols_clean = re.sub(r"[^\w,]", "", cols_raw).replace(",", "_")
        
        prefix = "uq" if idx_type else "idx"
        new_idx_name = f"{prefix}_{table_name}_{cols_clean}"
        
        # Truncate index name if it's too long for Postgres (63 characters max)
        if len(new_idx_name) > 60:
            new_idx_name = new_idx_name[:60]
            
        unique_keyword = "UNIQUE " if idx_type else ""
        
        # Restore WHERE clauses if any
        rest = match.group(5) if len(match.groups()) >= 5 else ""
        return f"CREATE {unique_keyword}INDEX {new_idx_name} ON {target_tbl} USING btree ({cols_raw}){rest}"

    content = re.sub(
        r"CREATE\s+(UNIQUE\s+)?INDEX\s+(\w+)\s+ON\s+([\w\.]+)\s+USING\s+btree\s*\(([^\)]+)\)(.*)",
        uq_idx_replacer,
        content,
        flags=re.IGNORECASE
    )
    
    return content

print("Starting global table refactoring...")
processed_files = 0
for root, _, files in os.walk(SRC_DIR):
    for file in files:
        if file.endswith(".sql") and "tables" in root:
            file_path = os.path.join(root, file)
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
            
            new_content = clean_sql_content(file_path, content)
            
            # Write back
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(new_content)
            processed_files += 1

print(f"Successfully refactored {processed_files} table SQL files!")
