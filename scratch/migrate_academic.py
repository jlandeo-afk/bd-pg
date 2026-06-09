import os

# Create academic directories
DIRS = [
    "src/academic/tables",
    "src/academic/functions",
    "src/academic/views",
    "src/academic/triggers"
]

for d in DIRS:
    os.makedirs(d, exist_ok=True)
    print(f"Directory verified: {d}")

# Tables to migrate
TABLES = [
    "course", "course_assigned_categories", "course_assigned_subcategories",
    "course_level", "course_pseudo_course", "course_pseudo_courses",
    "course_text_category_settings", "cycle", "cycle_types", "cycle_weeks",
    "syllabus", "syllabus_detail_subtopic", "syllabus_subtopic_type_material",
    "syllabus_template", "syllabus_template_topic", "syllabus_template_topic_subtopic",
    "syllabus_text_content", "syllabus_text_detail", "syllabus_text_distributions",
    "syllabus_text_weeks", "syllabus_texts", "syllabus_topic", "syllabus_topic_week",
    "syllabus_type_text", "syllabus_week_titles", "topic", "subtopic",
    "subtopic_history", "modality", "modality_options", "option",
    "option_university", "origin_university", "pseudo_course",
    "university_headquarters", "week"
]

# Functions to migrate (matching python script list)
FUNCTIONS = [
    "fn_activate_schema_origin_university", "fn_block_unblock_syllabus",
    "fn_change_subtopic_frequent_status", "fn_change_topic_subtopics",
    "fn_change_user_courses", "fn_classroom_cycle", "fn_clean_cycle_posterior_weeks",
    "fn_course_all", "fn_courses_complete_management", "fn_courses_diagram_settings",
    "fn_courses_order_and_amount", "fn_create_and_update_employee_university",
    "fn_create_configuration_diagram_course", "fn_create_course",
    "fn_create_cycle", "fn_create_topic", "fn_cycle_all", "fn_cycle_paginated",
    "fn_delete_course", "fn_delete_course_category", "fn_delete_course_subcategory",
    "fn_delete_cycle", "fn_delete_origin_university", "fn_delete_subtopic",
    "fn_delete_subtopic_syllabus", "fn_delete_syllabus", "fn_delete_topic",
    "fn_delete_topic_syllabus", "fn_diagrammed_by_course_category",
    "fn_disable_outdated_frequent_subtopics", "fn_edit_origin_university",
    "fn_edit_position_subtopics", "fn_edit_position_topics", "fn_edit_syllabus",
    "fn_edit_syllabus_texts", "fn_field_diagramm_by_course", "fn_find_by_subtopic",
    "fn_find_course", "fn_find_cycle", "fn_find_employee_university",
    "fn_find_syllabus", "fn_find_syllabus_detail_text", "fn_find_syllabus_text",
    "fn_find_university_by_id", "fn_frequent_subtopics_list",
    "fn_generate_detail_week_type_mat", "fn_get_all_course_by_employee_and_university",
    "fn_get_all_university_by_employee", "fn_get_available_weeks_per_period",
    "fn_get_course_by_syllabus", "fn_get_course_categories",
    "fn_get_courses_by_employee_of_syllabus", "fn_get_cycles_actives",
    "fn_get_detail_course_diagram", "fn_get_details_level_syllabus_by_id",
    "fn_get_details_syllabus", "fn_get_employee_university",
    "fn_get_history_syllabus", "fn_get_level_syllabus_detail", "fn_get_list_cycles",
    "fn_get_nq_courses_by_user_uuid", "fn_get_structure_by_course_ids",
    "fn_get_subcategories_by_course", "fn_get_syllabus",
    "fn_get_syllabus_all_text_weeks", "fn_get_syllabus_template_by_university_and_course",
    "fn_get_syllabus_template_subtopics", "fn_get_syllabus_template_topics",
    "fn_get_syllabus_week_title", "fn_get_teacher_nq_list_course",
    "fn_get_total_category_syllabus", "fn_get_university_by_employee_of_syllabus",
    "fn_has_user_nq_courses", "fn_insert_history_syllabus",
    "fn_insert_or_update_period_course", "fn_insert_or_update_period_week_course",
    "fn_list_courses_and_pseudo_courses_by_universities", "fn_list_courses_user",
    "fn_list_cycles", "fn_list_subtopics_by_universities_and_topic_and_course",
    "fn_list_topics_by_universities_and_course_or_pseudo", "fn_modalities_university",
    "fn_options_university", "fn_origin_university", "fn_origin_university_all",
    "fn_origin_university_with_cycle", "fn_paginate_cycles", "fn_paginate_cycles_simple",
    "fn_process_change_subtopic_frequent", "fn_save_course_category",
    "fn_save_course_subcategory", "fn_save_courses_template_syllabus",
    "fn_save_level_syllabus", "fn_save_origin_university",
    "fn_save_subtopics_template_syllabus", "fn_save_syllabus", "fn_save_syllabus_texts",
    "fn_save_topics_template_syllabus", "fn_search_configuration_diagrammed_course",
    "fn_search_course", "fn_search_cycle", "fn_search_level_syllabus",
    "fn_search_modality_option", "fn_search_subtopic", "fn_search_template_syllabus",
    "fn_search_topic", "fn_search_university", "fn_source_layers_on_subtopic",
    "fn_syllabus", "fn_syllabus_all", "fn_syllabus_categories_weeks",
    "fn_syllabus_subtopics_weeks", "fn_total_text_by_courses_levels",
    "fn_total_text_by_courses_syllabus", "fn_unify_topic_suptopic",
    "fn_universities_syllabus_template", "fn_update_configuration_diagrammed_course",
    "fn_update_course_category", "fn_update_course_subcategory", "fn_update_cycle",
    "fn_update_subtopic_syllabus", "fn_update_syllabus_week_title",
    "fn_updated_course", "fn_valid_syllabus_cycle", "fn_validate_frequent_university_subtopic",
    "fn_week_all", "fn_week_subtopics", "fn_weeks_syllabus_ids",
    "get_course_levels_totals", "get_detail_level_syllabus_week",
    "get_detail_level_syllabus_week_parent", "get_detail_syllabus_subtopic",
    "get_syllabus_export", "get_syllabus_export_by_topic", "get_syllabus_text",
    "get_syllabus_text_weekly", "sp_change_syllabus_template_subtopics"
]

# Replacements dictionary
REPLACEMENTS = {}

for t in TABLES:
    REPLACEMENTS[f"odiseo.{t}"] = f"academic.{t}"
    REPLACEMENTS[f"public.{t}"] = f"academic.{t}"
    # Sequences
    REPLACEMENTS[f"odiseo.{t}_id_seq"] = f"academic.{t}_id_seq"
    REPLACEMENTS[f"public.{t}_id_seq"] = f"academic.{t}_id_seq"

for f in FUNCTIONS:
    REPLACEMENTS[f"odiseo.{f}"] = f"academic.{f}"
    REPLACEMENTS[f"public.{f}"] = f"academic.{f}"

print(f"Compiled {len(REPLACEMENTS)} schema replacement rules for academic domain.")

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
    new_path = f"src/academic/tables/{t}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Table: odiseo.{t}", f"Table: academic.{t}")
        
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
            content = content.replace(f"Table: public.{t}", f"Table: academic.{t}")
            
            with open(new_path, "w", encoding="utf-8") as f:
                f.write(content)
            os.remove(old_pub_path)
            moved_tables += 1

print(f"Moved {moved_tables} table files to src/academic/tables/.")

# Move function files
moved_functions = 0
for fn in FUNCTIONS:
    old_path = f"src/functions/odiseo.{fn}.sql"
    new_path = f"src/academic/functions/{fn}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Function: {fn}", f"Function: academic.{fn}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.remove(old_path)
        moved_functions += 1

print(f"Moved {moved_functions} function files to src/academic/functions/.")

# Perform global search and replace in all files under src/ (excluding new files in src/academic/ and src/auth/)
updated_files = 0
for root, dirs_list, files in os.walk("src"):
    for file in files:
        if file.endswith(".sql"):
            file_path = os.path.join(root, file)
            # Skip new schemas folders to avoid reprocessing
            if "src/academic/" in file_path or "src/auth/" in file_path:
                continue
                
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
            new_content = apply_replacements(content)
            
            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                updated_files += 1

print(f"Updated references in {updated_files} other files.")
print("Academic migration completed successfully!")
