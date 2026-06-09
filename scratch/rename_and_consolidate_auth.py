import os

# Definition of the target consolidations and renamings
RENAME_MAP = {
    # Old filename/funcname -> New filename/funcname
    "fn_find_user": "fn_get_user",
    "fn_show_user": "fn_get_user_by_id",
    "fn_show_user_uuid": "fn_get_user_profile",
    "fn_get_auth_user": "fn_get_auth_user_details",
    "fn_find_rol": "fn_get_rol",
    "fn_find_rol_permission": "fn_get_rol_permission",
    "fn_find_rol_user": "fn_get_user_role",
    "fn_find_permission_rol": "fn_list_permissions_by_rol",
    "fn_permissions": "fn_paginate_permissions",
    "create_user_rol": "fn_create_user_role"
}

# Source folder
AUTH_DIR = "src/auth/functions"

# 1. Consolidate fn_find_permission and fn_permissions_all into fn_list_permissions
consolidated_sql = """-- Function: auth.fn_list_permissions(integer, boolean, boolean, integer, character varying, boolean)

CREATE OR REPLACE FUNCTION auth.fn_list_permissions(
    p_company_id integer,
    p_administrator boolean DEFAULT false,
    f_status boolean DEFAULT true,
    f_permission_id integer DEFAULT NULL,
    p_name_text character varying DEFAULT NULL,
    p_can_filter_companies boolean DEFAULT false
) RETURNS TABLE(
    id bigint,
    name character varying,
    fl_status boolean,
    created_by bigint,
    updated_by bigint,
    deleted_by bigint,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    deleted_at timestamp without time zone,
    module character varying,
    fl_administrator boolean,
    roles json,
    user_name character varying,
    user_email odiseo.email_citext
)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.name,
        p.fl_status,
        p.created_by,
        p.updated_by,
        p.deleted_by,
        p.created_at,
        p.updated_at,
        p.deleted_at,
        p.module,
        p.fl_administrator,
        COALESCE(json_agg(r.*) FILTER (WHERE r.id IS NOT NULL), '[]'::json) AS roles,
        u.user as user_name,
        u.email as user_email
    FROM auth.permissions p
    LEFT JOIN (
        SELECT rp.id, rp.rol_id, rp.permission_id, rp.fl_status, rp.company_id
        FROM auth.roles_permissions rp
        WHERE rp.fl_status = true
    ) rp ON p.id = rp.permission_id AND rp.company_id = p_company_id
    LEFT JOIN (
        SELECT r.id, r.name, r.slug, r.fl_status, r.fl_administrator, r.company_id
        FROM auth.roles r
        WHERE r.fl_status = true
    ) r ON rp.rol_id = r.id AND r.company_id = p_company_id
    LEFT JOIN auth.users u ON p.created_by = u.id
    WHERE p.fl_status = f_status
      AND p.deleted_at IS NULL
      AND (f_permission_id IS NULL OR p.id = f_permission_id)
      AND (p_administrator = true OR p.fl_administrator = false)
      AND (p_name_text IS NULL OR LOWER(p.name) LIKE '%' || LOWER(p_name_text) || '%')
      AND (p_can_filter_companies = true OR p.fl_to_use_client = true)
    GROUP BY
        p.id,
        p.name,
        p.fl_status,
        p.created_by,
        p.updated_by,
        p.deleted_by,
        p.created_at,
        p.updated_at,
        p.deleted_at,
        p.module,
        p.fl_administrator,
        u.user,
        u.email
    ORDER BY p.id ASC;
END;
$$;

ALTER FUNCTION auth.fn_list_permissions(integer, boolean, boolean, integer, character varying, boolean) OWNER TO postgres;
"""

with open(f"{AUTH_DIR}/fn_list_permissions.sql", "w", encoding="utf-8") as f:
    f.write(consolidated_sql)
print("Generated consolidated function fn_list_permissions.sql")

# Delete old duplicate files
for old_file in ["fn_find_permission.sql", "fn_permissions_all.sql"]:
    old_path = f"{AUTH_DIR}/{old_file}"
    if os.path.exists(old_path):
        os.remove(old_path)
        print(f"Deleted legacy duplicate file: {old_file}")

# 2. Rename and update internal names for the rest of RENAME_MAP
for old_name, new_name in RENAME_MAP.items():
    old_path = f"{AUTH_DIR}/{old_name}.sql"
    new_path = f"{AUTH_DIR}/{new_name}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        
        # Replace the function signature inside the SQL file
        content = content.replace(f"CREATE FUNCTION auth.{old_name}", f"CREATE FUNCTION auth.{new_name}")
        content = content.replace(f"CREATE OR REPLACE FUNCTION auth.{old_name}", f"CREATE OR REPLACE FUNCTION auth.{new_name}")
        content = content.replace(f"ALTER FUNCTION auth.{old_name}", f"ALTER FUNCTION auth.{new_name}")
        content = content.replace(f"Function: auth.{old_name}", f"Function: auth.{new_name}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.remove(old_path)
        print(f"Renamed file: {old_name}.sql -> {new_name}.sql")

# 3. Propagate renamings globally in the entire codebase
REPLACEMENTS = {}
for old_name, new_name in RENAME_MAP.items():
    REPLACEMENTS[f"auth.{old_name}"] = f"auth.{new_name}"
    
# Add consolidated ones
REPLACEMENTS["auth.fn_find_permission"] = "auth.fn_list_permissions"
REPLACEMENTS["auth.fn_permissions_all"] = "auth.fn_list_permissions"

def apply_replacements(content):
    sorted_keys = sorted(REPLACEMENTS.keys(), key=len, reverse=True)
    for key in sorted_keys:
        val = REPLACEMENTS[key]
        content = content.replace(key, val)
    return content

updated_files = 0
for root, _, files in os.walk("src"):
    for file in files:
        if file.endswith(".sql"):
            file_path = os.path.join(root, file)
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
            new_content = apply_replacements(content)
            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                updated_files += 1

print(f"Updated references in {updated_files} files globally across the repository.")
print("Consolidation and renaming of auth functions completed successfully!")
