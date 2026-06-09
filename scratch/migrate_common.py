import os

# Create common, audit, anon directories
DIRS = [
    "src/audit/tables", "src/audit/functions",
    "src/anon/tables", "src/anon/functions",
    "src/common/tables", "src/common/functions",
    "src/common/views", "src/common/triggers"
]

for d in DIRS:
    os.makedirs(d, exist_ok=True)
    print(f"Directory verified: {d}")

# 1. Audit files (directly move, keeping audit. prefix in filename mapped to simple name in folder)
AUDIT_TABLES = ["ON", "audit_config", "audit_log", "function_log"]
for t in AUDIT_TABLES:
    old_path = f"src/tables/audit.{t}.sql"
    new_path = f"src/audit/tables/{t}.sql"
    if os.path.exists(old_path):
        os.rename(old_path, new_path)
        print(f"Moved audit table: {t}")

# 2. Anon files
ANON_FUNCTIONS = ["generar_lorem_ajustado", "html_math_aware_mask"]
for fn in ANON_FUNCTIONS:
    old_path = f"src/functions/anon.{fn}.sql"
    new_path = f"src/anon/functions/{fn}.sql"
    if os.path.exists(old_path):
        os.rename(old_path, new_path)
        print(f"Moved anon function: {fn}")

# 3. Late additions to academic, questions, materials
ACADEMIC_ADD_TABLES = [
    "level", "level_rates", "level_syllabus", "level_syllabus_weeks",
    "detail_level_syllabus_weeks", "detail_level_syllabus_weeks_parents",
    "detail_week_type_mat", "type_week", "frequent_university_subtopic",
    "history_syllabus", "setting_diagrammed_courses"
]
ACADEMIC_ADD_FUNCTIONS = [
    "fn_level", "fn_level_all", "fn_create_level", "fn_delete_level",
    "fn_update_level", "fn_find_level", "fn_get_amount_levels_required_per_text",
    "fn_get_subcategories_by_category"
]

QUESTIONS_ADD_TABLES = ["image_gallery", "image_galery_topic", "field_diagrammed"]
QUESTIONS_ADD_FUNCTIONS = [
    "fn_delete_image_gallery", "fn_get_image_gallery_details", "fn_save_image_gallery",
    "fn_search_image_gallery", "fn_update_image_gallery", "fn_detail_diagrammed",
    "fn_search_field_diagrammed", "fn_migrate_diagrammed_fields", "fn_update_answer_correct_ia",
    "fn_edit_description_ia", "fn_save_incomplete_text", "fn_update_file_document_solution",
    "update_image_digitalized_by_id", "fn_save_url_file_digitalized_images", "fn_change_status_parent",
    "fn_change_status_reserved_to_verified", "get_shared_status"
]

MATERIALS_ADD_FUNCTIONS = ["fn_clean_ballor_url_period", "fn_validate_parent_type_mat"]

# 4. Common files
COMMON_TABLES = [
    "failed_jobs", "migrations", "job_batches", "advanced_settings", "plans",
    "status", "type_archive", "type_documents", "type_templates", "type_text",
    "type_text_level", "type_text_subcategories", "type_text_templates",
    "type_text_to_subcategory", "type_texts_subtopics", "type_texts_topics",
    "prospect", "code_prospect", "_bkp_migration_tm_mapping", "_bkp_migration_tma_mapping",
    "_bkp_migration_tmc_mapping"
]
COMMON_FUNCTIONS = [
    "fn_immutable_unaccent", "unaccent", "fn_number_to_roman", "merge_json_array_except",
    "fn_params_index", "fn_get_type_documents", "fn_type_archive", "fn_plans",
    "fn_save_plan", "fn_delete_plan", "fn_update_plan", "fn_prospect",
    "fn_save_prospect", "fn_validate_save_code_prospect", "fn_get_user_notifications",
    "fn_change_status_admin", "fn_update_index", "fn_update_set_massive_attributes",
    "fn_search_option"
]

# Compile replacement maps
REPLACEMENTS = {}

def add_rules(lst, target_schema):
    for item in lst:
        REPLACEMENTS[f"odiseo.{item}"] = f"{target_schema}.{item}"
        REPLACEMENTS[f"public.{item}"] = f"{target_schema}.{item}"
        REPLACEMENTS[f"odiseo.{item}_id_seq"] = f"{target_schema}.{item}_id_seq"
        REPLACEMENTS[f"public.{item}_id_seq"] = f"{target_schema}.{item}_id_seq"

add_rules(ACADEMIC_ADD_TABLES, "academic")
add_rules(ACADEMIC_ADD_FUNCTIONS, "academic")
add_rules(QUESTIONS_ADD_TABLES, "questions")
add_rules(QUESTIONS_ADD_FUNCTIONS, "questions")
add_rules(MATERIALS_ADD_FUNCTIONS, "materials")
add_rules(COMMON_TABLES, "common")
add_rules(COMMON_FUNCTIONS, "common")

def apply_replacements(content):
    sorted_keys = sorted(REPLACEMENTS.keys(), key=len, reverse=True)
    for key in sorted_keys:
        val = REPLACEMENTS[key]
        content = content.replace(key, val)
    return content

# Move late-additions tables and functions
def move_files(lst, is_table, target_schema, subfolder):
    moved = 0
    for item in lst:
        if is_table:
            old_path = f"src/tables/odiseo.{item}.sql"
            new_path = f"src/{target_schema}/tables/{item}.sql"
            header_old = f"Table: odiseo.{item}"
            header_new = f"Table: {target_schema}.{item}"
        else:
            old_path = f"src/functions/odiseo.{item}.sql"
            new_path = f"src/{target_schema}/functions/{item}.sql"
            header_old = f"Function: {item}"
            header_new = f"Function: {target_schema}.{item}"
            
        if not os.path.exists(old_path) and is_table:
            # Fallback for public schema
            old_path = f"src/tables/public.{item}.sql"
            header_old = f"Table: public.{item}"
            
        if not os.path.exists(old_path) and not is_table:
            # Fallback for public schema functions
            old_path = f"src/functions/public.{item}.sql"
            
        if os.path.exists(old_path):
            with open(old_path, "r", encoding="utf-8") as f:
                content = f.read()
            content = apply_replacements(content)
            content = content.replace(header_old, header_new)
            
            with open(new_path, "w", encoding="utf-8") as f:
                f.write(content)
            os.remove(old_path)
            moved += 1
    return moved

moved_academic_t = move_files(ACADEMIC_ADD_TABLES, True, "academic", "tables")
moved_academic_f = move_files(ACADEMIC_ADD_FUNCTIONS, False, "academic", "functions")
print(f"Moved {moved_academic_t} tables & {moved_academic_f} functions to academic.")

moved_questions_t = move_files(QUESTIONS_ADD_TABLES, True, "questions", "tables")
moved_questions_f = move_files(QUESTIONS_ADD_FUNCTIONS, False, "questions", "functions")
print(f"Moved {moved_questions_t} tables & {moved_questions_f} functions to questions.")

moved_materials_f = move_files(MATERIALS_ADD_FUNCTIONS, False, "materials", "functions")
print(f"Moved {moved_materials_f} functions to materials.")

# Move common tables and functions
moved_common_t = move_files(COMMON_TABLES, True, "common", "tables")
moved_common_f = move_files(COMMON_FUNCTIONS, False, "common", "functions")
print(f"Moved {moved_common_t} tables & {moved_common_f} functions to common.")

# Global replacement in all files
updated_files = 0
for root, dirs_list, files in os.walk("src"):
    for file in files:
        if file.endswith(".sql"):
            file_path = os.path.join(root, file)
            # Apply replacements to all files, including newly moved files to ensure all cross references are correct!
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
            new_content = apply_replacements(content)
            
            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                updated_files += 1

print(f"Updated references in {updated_files} files globally.")
print("Cleanup and Common migration completed successfully!")
