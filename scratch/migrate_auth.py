import os
import re

# Target directories
DIRS = [
    "src/auth/tables",
    "src/auth/functions",
    "src/auth/views",
    "src/auth/triggers"
]

for d in DIRS:
    os.makedirs(d, exist_ok=True)
    print(f"Directory verified: {d}")

# 1. Define files in auth domain to move
AUTH_TABLE_FILES = {
    "src/tables/odiseo.users.sql": "src/auth/tables/users.sql",
    "src/tables/odiseo.roles.sql": "src/auth/tables/roles.sql",
    "src/tables/odiseo.permissions.sql": "src/auth/tables/permissions.sql",
    "src/tables/odiseo.roles_permissions.sql": "src/auth/tables/roles_permissions.sql",
    "src/tables/odiseo.users_roles.sql": "src/auth/tables/users_roles.sql",
    "src/tables/odiseo.personal_access_tokens.sql": "src/auth/tables/personal_access_tokens.sql",
    "src/tables/public.password_reset_tokens.sql": "src/auth/tables/password_reset_tokens.sql",
    "src/tables/odiseo.remembered_sessions.sql": "src/auth/tables/remembered_sessions.sql",
    "src/tables/odiseo.nq_user_token.sql": "src/auth/tables/nq_user_token.sql",
    "src/tables/odiseo.nq_user_request.sql": "src/auth/tables/nq_user_request.sql",
}

# Deletions of redundant/legacy files
AUTH_TABLE_DELETIONS = [
    "src/tables/public.users.sql",
    "src/tables/public.personal_access_tokens.sql"
]

AUTH_FUNCTION_FILES = {
    "src/functions/odiseo.fn_create_user.sql": "src/auth/functions/fn_create_user.sql",
    "src/functions/odiseo.fn_create_user_from_contributor.sql": "src/auth/functions/fn_create_user_from_contributor.sql",
    "src/functions/odiseo.fn_deleted_user.sql": "src/auth/functions/fn_deleted_user.sql",
    "src/functions/odiseo.fn_find_user.sql": "src/auth/functions/fn_find_user.sql",
    "src/functions/odiseo.fn_get_auth_user.sql": "src/auth/functions/fn_get_auth_user.sql",
    "src/functions/odiseo.fn_show_user.sql": "src/auth/functions/fn_show_user.sql",
    "src/functions/odiseo.fn_show_user_uuid.sql": "src/auth/functions/fn_show_user_uuid.sql",
    "src/functions/odiseo.fn_update_user_by_uuid.sql": "src/auth/functions/fn_update_user_by_uuid.sql",
    "src/functions/odiseo.fn_update_image_user.sql": "src/auth/functions/fn_update_image_user.sql",
    "src/functions/odiseo.fn_search_users.sql": "src/auth/functions/fn_search_users.sql",
    "src/functions/odiseo.create_user_rol.sql": "src/auth/functions/create_user_rol.sql",
    "src/functions/odiseo.fn_create_rol.sql": "src/auth/functions/fn_create_rol.sql",
    "src/functions/odiseo.fn_create_permission.sql": "src/auth/functions/fn_create_permission.sql",
    "src/functions/odiseo.fn_create_rol_permission.sql": "src/auth/functions/fn_create_rol_permission.sql",
    "src/functions/odiseo.fn_create_rol_with_permission.sql": "src/auth/functions/fn_create_rol_with_permission.sql",
    "src/functions/odiseo.fn_delete_rol.sql": "src/auth/functions/fn_delete_rol.sql",
    "src/functions/odiseo.fn_edit_rol.sql": "src/auth/functions/fn_edit_rol.sql",
    "src/functions/odiseo.fn_edit_rol_permission.sql": "src/auth/functions/fn_edit_rol_permission.sql",
    "src/functions/odiseo.fn_find_permission.sql": "src/auth/functions/fn_find_permission.sql",
    "src/functions/odiseo.fn_find_permission_rol.sql": "src/auth/functions/fn_find_permission_rol.sql",
    "src/functions/odiseo.fn_find_rol.sql": "src/auth/functions/fn_find_rol.sql",
    "src/functions/odiseo.fn_find_rol_permission.sql": "src/auth/functions/fn_find_rol_permission.sql",
    "src/functions/odiseo.fn_find_rol_user.sql": "src/auth/functions/fn_find_rol_user.sql",
    "src/functions/odiseo.fn_permissions.sql": "src/auth/functions/fn_permissions.sql",
    "src/functions/odiseo.fn_permissions_all.sql": "src/auth/functions/fn_permissions_all.sql",
    "src/functions/odiseo.fn_rol.sql": "src/auth/functions/fn_rol.sql",
    "src/functions/odiseo.fn_rol_users.sql": "src/auth/functions/fn_rol_users.sql",
    "src/functions/odiseo.fn_update_rol_with_permission.sql": "src/auth/functions/fn_update_rol_with_permission.sql",
    "src/functions/odiseo.fn_user_has_permission.sql": "src/auth/functions/fn_user_has_permission.sql",
    "src/functions/odiseo.fn_get_nq_user_token.sql": "src/auth/functions/fn_get_nq_user_token.sql",
    "src/functions/odiseo.fn_get_token_user.sql": "src/auth/functions/fn_get_token_user.sql",
    "src/functions/odiseo.fn_invalidate_token_user.sql": "src/auth/functions/fn_invalidate_token_user.sql",
    "src/functions/odiseo.fn_nq_create_user_token.sql": "src/auth/functions/fn_nq_create_user_token.sql",
    "src/functions/odiseo.fn_revoke_user_token.sql": "src/auth/functions/fn_revoke_user_token.sql",
}

# 2. Build replacements mapping
REPLACEMENTS = {}

# Map old tables to new schema
TABLE_NAMES = [
    "users", "roles", "permissions", "roles_permissions", 
    "users_roles", "personal_access_tokens", "password_reset_tokens", 
    "remembered_sessions", "nq_user_token", "nq_user_request"
]

for t in TABLE_NAMES:
    REPLACEMENTS[f"odiseo.{t}"] = f"auth.{t}"
    REPLACEMENTS[f"public.{t}"] = f"auth.{t}"
    # Sequences associated
    REPLACEMENTS[f"odiseo.{t}_id_seq"] = f"auth.{t}_id_seq"
    REPLACEMENTS[f"public.{t}_id_seq"] = f"auth.{t}_id_seq"

# Map old functions to new schema
FUNCTION_NAMES = [
    "fn_create_user", "fn_create_user_from_contributor", "fn_deleted_user", 
    "fn_find_user", "fn_get_auth_user", "fn_show_user", "fn_show_user_uuid", 
    "fn_update_user_by_uuid", "fn_update_image_user", "fn_search_users", 
    "create_user_rol", "fn_create_rol", "fn_create_permission", 
    "fn_create_rol_permission", "fn_create_rol_with_permission", "fn_delete_rol", 
    "fn_edit_rol", "fn_edit_rol_permission", "fn_find_permission", 
    "fn_find_permission_rol", "fn_find_rol", "fn_find_rol_permission", 
    "fn_find_rol_user", "fn_permissions", "fn_permissions_all", "fn_rol", 
    "fn_rol_users", "fn_update_rol_with_permission", "fn_user_has_permission", 
    "fn_get_nq_user_token", "fn_get_token_user", "fn_invalidate_token_user", 
    "fn_nq_create_user_token", "fn_revoke_user_token"
]

for f in FUNCTION_NAMES:
    REPLACEMENTS[f"odiseo.{f}"] = f"auth.{f}"
    REPLACEMENTS[f"public.{f}"] = f"auth.{f}"

print(f"Compiled {len(REPLACEMENTS)} schema replacement rules.")

# Helper function to apply all replacements to text content
def apply_replacements(content):
    # Sort keys by length in descending order to avoid partial replacement issues
    sorted_keys = sorted(REPLACEMENTS.keys(), key=len, reverse=True)
    for key in sorted_keys:
        val = REPLACEMENTS[key]
        # Use simple string replacement
        content = content.replace(key, val)
    return content

# 3. Read, apply replacements, write to target, and delete old files for Tables
for old_path, new_path in AUTH_TABLE_FILES.items():
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        # Update file header if present
        content = content.replace(f"Table: {os.path.basename(old_path).replace('.sql', '')}", f"Table: auth.{os.path.basename(new_path).replace('.sql', '')}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Moved table: {old_path} -> {new_path}")
        os.remove(old_path)
    else:
        print(f"Warning: Table file {old_path} not found.")

# Delete legacy files
for path in AUTH_TABLE_DELETIONS:
    if os.path.exists(path):
        os.remove(path)
        print(f"Deleted legacy file: {path}")

# 4. Read, apply replacements, write to target, and delete old files for Functions
for old_path, new_path in AUTH_FUNCTION_FILES.items():
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        # Update function header
        fn_name_old = os.path.basename(old_path).replace('.sql', '')
        fn_name_new = os.path.basename(new_path).replace('.sql', '')
        content = content.replace(f"Function: {fn_name_old}", f"Function: auth.{fn_name_new}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"Moved function: {old_path} -> {new_path}")
        os.remove(old_path)
    else:
        print(f"Warning: Function file {old_path} not found.")

# 5. Perform global search and replace in all remaining files in src/
# Walk through all directories under src/
for root, dirs_list, files in os.walk("src"):
    for file in files:
        if file.endswith(".sql"):
            file_path = os.path.join(root, file)
            # Skip the newly moved files in src/auth to avoid double-processing
            if "src/auth" in file_path:
                continue
                
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
            new_content = apply_replacements(content)
            
            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                print(f"Updated references in: {file_path}")

print("Refactoring and migration to src/auth/ completed successfully!")
