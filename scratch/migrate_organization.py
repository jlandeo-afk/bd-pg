import os

# Create organization directories
DIRS = [
    "src/organization/tables",
    "src/organization/functions",
    "src/organization/views",
    "src/organization/triggers"
]

for d in DIRS:
    os.makedirs(d, exist_ok=True)
    print(f"Directory verified: {d}")

# Tables to migrate
TABLES = [
    "charge", "classroom", "clientes_empresas", "companies", "company_headquarters",
    "company_legal_representatives", "company_universities", "company_user_admin",
    "districts", "employee_course", "employee_university", "employees",
    "headquarters", "headquarters_classroom", "provinces", "region", "teachers"
]

# Functions to migrate
FUNCTIONS = [
    "fn_companies", "fn_create_company", "fn_create_employee", "fn_create_headquarter",
    "fn_delete_headquarter", "fn_employee_not_user", "fn_find_company",
    "fn_find_company_advanced_settings", "fn_find_employee_user", "fn_generate_code_teacher",
    "fn_get_search_employees", "fn_list_teachers_by_company", "fn_list_universities_by_region",
    "fn_name_employee", "fn_region", "fn_teacher_all", "fn_update_company",
    "fn_update_employee", "fn_update_headquarter", "fn_update_manual_assignment_teacher",
    "fn_verified_save_user_employee", "get_employee_data", "get_employee_detail",
    "update_data_employee", "update_user_id_employee"
]

# Replacements dictionary
REPLACEMENTS = {}

for t in TABLES:
    REPLACEMENTS[f"odiseo.{t}"] = f"organization.{t}"
    REPLACEMENTS[f"public.{t}"] = f"organization.{t}"
    # Sequences
    REPLACEMENTS[f"odiseo.{t}_id_seq"] = f"organization.{t}_id_seq"
    REPLACEMENTS[f"public.{t}_id_seq"] = f"organization.{t}_id_seq"

for f in FUNCTIONS:
    REPLACEMENTS[f"odiseo.{f}"] = f"organization.{f}"
    REPLACEMENTS[f"public.{f}"] = f"organization.{f}"

print(f"Compiled {len(REPLACEMENTS)} schema replacement rules for organization domain.")

def apply_replacements(content):
    # Sort keys by length to avoid partial replacement problems
    sorted_keys = sorted(REPLACEMENTS.keys(), key=len, reverse=True)
    for key in sorted_keys:
        val = REPLACEMENTS[key]
        content = content.replace(key, val)
    return content

# Move table files
moved_tables = 0
for t in TABLES:
    old_path = f"src/tables/odiseo.{t}.sql"
    new_path = f"src/organization/tables/{t}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Table: odiseo.{t}", f"Table: organization.{t}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.remove(old_path)
        moved_tables += 1
    else:
        # Check if in public schema
        old_pub_path = f"src/tables/public.{t}.sql"
        if os.path.exists(old_pub_path):
            with open(old_pub_path, "r", encoding="utf-8") as f:
                content = f.read()
            content = apply_replacements(content)
            content = content.replace(f"Table: public.{t}", f"Table: organization.{t}")
            
            with open(new_path, "w", encoding="utf-8") as f:
                f.write(content)
            os.remove(old_pub_path)
            moved_tables += 1

print(f"Moved {moved_tables} table files to src/organization/tables/.")

# Move function files
moved_functions = 0
for fn in FUNCTIONS:
    old_path = f"src/functions/odiseo.{fn}.sql"
    new_path = f"src/organization/functions/{fn}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Function: {fn}", f"Function: organization.{fn}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.remove(old_path)
        moved_functions += 1

print(f"Moved {moved_functions} function files to src/organization/functions/.")

# Perform global search and replace in all files under src/ (excluding target schemas)
updated_files = 0
for root, dirs_list, files in os.walk("src"):
    for file in files:
        if file.endswith(".sql"):
            file_path = os.path.join(root, file)
            # Skip new schemas folders to avoid reprocessing
            if any(x in file_path for x in ["src/organization/", "src/exams/", "src/materials/", "src/questions/", "src/academic/", "src/auth/"]):
                continue
                
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
            new_content = apply_replacements(content)
            
            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                updated_files += 1

print(f"Updated references in {updated_files} other files.")
print("Organization migration completed successfully!")
