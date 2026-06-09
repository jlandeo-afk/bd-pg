import os

# Create materials directories
DIRS = [
    "src/materials/tables",
    "src/materials/functions",
    "src/materials/views",
    "src/materials/triggers"
]

for d in DIRS:
    os.makedirs(d, exist_ok=True)
    print(f"Directory verified: {d}")

# Tables to migrate
TABLES = [
    "exam_material_config_area_course_levels", "exam_material_config_area_courses", "exam_material_configurations",
    "material", "material_ballot_question", "material_ballot_stats_area_courses", "material_ballot_stats_areas",
    "material_ballot_stats_global", "material_ballot_subquestions", "material_class_week",
    "material_column_configurations", "material_configuration_detail_value", "material_configuration_details",
    "material_configurations", "material_distribution_ballot_questions", "material_exam_area_week",
    "material_exam_parent_question", "material_exam_question", "material_exam_stats_area_courses",
    "material_exam_stats_areas", "material_exam_stats_global", "material_generation_notification_types",
    "material_generation_notifications", "material_missing_question", "material_missing_question_detail",
    "material_missing_question_tracking", "material_per_period", "material_per_period_ballot",
    "material_per_period_ballot_class", "material_per_period_ballot_url", "material_per_period_course",
    "material_per_period_exam", "material_per_period_level_limit_config", "material_per_period_week_course",
    "material_question_change_reason", "material_revision_courses", "material_revision_histories",
    "material_revision_items", "material_revisions", "periodicity", "question_excluded_material",
    "separated_material_exam_week", "separated_material_week", "template_type_material_configurations",
    "template_type_material_courses_order", "type_material", "type_material_area",
    "type_material_area_courses", "type_material_bound", "type_material_course",
    "type_material_detail_course_texts", "type_material_detail_courses", "type_material_detail_template",
    "type_material_detail_text_subquestions", "type_material_periodicity", "type_material_template",
    "type_material_template_configuration_columns", "type_text_exam_material_configuration",
    "type_text_material_type_course", "type_text_material_type_course_area"
]

# Functions to migrate
FUNCTIONS = [
    "fn_ballot_questions_to_order", "fn_clean_material_per_period_course", "fn_clean_material_url_per_period",
    "fn_clear_exam_urls_by_material", "fn_completed_questions_ballot", "fn_create_material",
    "fn_create_material_notification", "fn_create_material_per_period_ballot", "fn_create_material_per_period_level_limit_config",
    "fn_create_material_revision", "fn_create_or_update_url_material_ballot_per_period", "fn_create_or_update_url_material_class_course",
    "fn_create_type_material", "fn_create_type_material_course", "fn_data_material_pdf",
    "fn_deactivate_material_distribution", "fn_deactive_ballot_per_course_url", "fn_deactive_ballot_per_period_url",
    "fn_delete_distribution_ballot_questions", "fn_delete_materials_pdfs", "fn_delete_question_materials_by_areas_get_questions",
    "fn_delete_question_materials_by_areas_get_questions_not_exclude", "fn_delete_question_materials_get_questions",
    "fn_delete_question_materials_get_questions_not_excluded", "fn_delete_type_material", "fn_detail_template_by_material",
    "fn_edit_status_2_zip_material_class", "fn_edit_zip_material_class", "fn_exam_material_list_cycle",
    "fn_find_material_per_period_level_limit_config", "fn_find_weeks_type_material", "fn_generated_courses_class_materials",
    "fn_generated_courses_materials", "fn_generated_courses_materials_per_period", "fn_get_all_courses_materials",
    "fn_get_ballot_question_single_type_material", "fn_get_ballot_questions", "fn_get_ballot_questions_per_period",
    "fn_get_children_material_type_ids", "fn_get_column_config_type_material_template", "fn_get_config_level_complete_ballot_period",
    "fn_get_config_level_register_ballot_period", "fn_get_config_syllabus_complete_ballot_period", "fn_get_config_syllabus_register_ballot_period",
    "fn_get_config_text_level_complete_ballot_period", "fn_get_config_text_level_register_ballot_period", "fn_get_config_text_syllabus_complete_ballot_period",
    "fn_get_config_text_syllabus_register_ballot_period", "fn_get_course_exam_areas_by_config_exam_material_id", "fn_get_course_material_details",
    "fn_get_course_materials_by_type", "fn_get_courses_by_type_material", "fn_get_courses_by_type_material_ballot",
    "fn_get_cycle_by_material", "fn_get_detail_level_parent_type_material_by_course", "fn_get_detail_level_type_material_by_course",
    "fn_get_detail_template_material", "fn_get_detail_week_type_material", "fn_get_group_material_periodicity",
    "fn_get_lock_status_on_material", "fn_get_matching_type_material_weeks", "fn_get_material_configuration_inconsistencies",
    "fn_get_material_configurations", "fn_get_material_exam_parent_question", "fn_get_material_incomplete_questions",
    "fn_get_material_inconsistency_status", "fn_get_material_missing_question", "fn_get_material_per_period_ballot",
    "fn_get_material_per_period_ballot_complete", "fn_get_material_per_period_exam", "fn_get_material_per_period_urls",
    "fn_get_material_periodicity_courses_pages", "fn_get_material_questions_change_position", "fn_get_material_questions_detail",
    "fn_get_material_revision_detail", "fn_get_material_revision_list", "fn_get_material_week_type_mat",
    "fn_get_missing_ballot_questions_per_period", "fn_get_parent_questions_missing_ballot", "fn_get_parent_questions_register_ballot",
    "fn_get_parent_type_material", "fn_get_periods_weeks_on_type_material", "fn_get_questions_missing_ballot",
    "fn_get_questions_register_ballot", "fn_get_questions_verified_and_not_excluded_material_filter", "fn_get_regeneration_pdfs_progress",
    "fn_get_sub_question_verified_and_not_excluded_material_filter", "fn_get_type_material", "fn_get_type_material_course_details",
    "fn_get_type_material_data", "fn_has_ballot_questions", "fn_has_ballot_questions_syllabus",
    "fn_insert_material_ballot_question", "fn_insert_material_distribution_ballot_parent_questions", "fn_insert_material_distribution_ballot_questions",
    "fn_list_material_per_period_level_limit_config", "fn_list_pagination_type_material_templates", "fn_material",
    "fn_material_amount_level_exam", "fn_material_amount_question_level_week", "fn_material_amount_question_level_week_v2",
    "fn_material_amount_question_subtopic_examen_v2", "fn_material_amount_question_subtopic_week", "fn_material_ballot_question",
    "fn_material_class_week", "fn_material_detail_generation", "fn_material_distribution_ballot_questions",
    "fn_material_distribution_ballot_text", "fn_material_exam_area_week", "fn_order_list_material_per_period",
    "fn_paginate_material_generated", "fn_paginate_material_questions_detail", "fn_paginate_material_revision_questions",
    "fn_paginate_type_materials", "fn_parent_question_verified_material", "fn_process_material_ballot_by_courses",
    "fn_process_material_class_week", "fn_process_material_question_replacement", "fn_process_separated_material_exam_week",
    "fn_process_separated_material_week", "fn_question_material_ballot_pdf", "fn_question_material_class_pdf",
    "fn_question_material_exam_pdf", "fn_question_verified_and_not_excluded_material", "fn_question_verified_material",
    "fn_question_verified_material_pagination", "fn_questions_verified_by_type_material_week", "fn_register_material_ballot_per_period",
    "fn_register_questions_ballot", "fn_remove_question_all_areas_from_material_exam", "fn_remove_question_from_material_ballot",
    "fn_remove_text_material_exam", "fn_remove_type_material_template", "fn_reset_material_per_period_ballot",
    "fn_save_material", "fn_save_material_exam", "fn_save_material_exam_quality", "fn_save_material_quality",
    "fn_save_question_material_ballot", "fn_save_question_material_exam", "fn_save_subquestion_material_ballot",
    "fn_save_text_material_ballot", "fn_save_text_material_exam", "fn_save_type_material_template",
    "fn_set_lock_status_on_material", "fn_store_question_material", "fn_store_text_material",
    "fn_sync_material_revision_status", "fn_sync_type_material_template_configuration_columns", "fn_type_material_all",
    "fn_type_material_course", "fn_type_material_periodicity", "fn_update_and_find_unverified_subquestion_ballot",
    "fn_update_material_ballot_question", "fn_update_material_distribution_ballot_parent_question", "fn_update_material_distribution_ballot_questions",
    "fn_update_material_per_period_level_limit_config", "fn_update_material_revision_course_status", "fn_update_material_revision_status",
    "fn_update_type_material", "fn_update_type_material_course_single", "fn_update_type_material_template",
    "fn_upsert_material_missing_question", "get_material_column_configurations", "get_material_configuration_details",
    "list_type_material_template_children", "save_config_material_question", "update_material_configuration_details"
]

# Replacements dictionary
REPLACEMENTS = {}

for t in TABLES:
    REPLACEMENTS[f"odiseo.{t}"] = f"materials.{t}"
    REPLACEMENTS[f"public.{t}"] = f"materials.{t}"
    # Sequences
    REPLACEMENTS[f"odiseo.{t}_id_seq"] = f"materials.{t}_id_seq"
    REPLACEMENTS[f"public.{t}_id_seq"] = f"materials.{t}_id_seq"

for f in FUNCTIONS:
    REPLACEMENTS[f"odiseo.{f}"] = f"materials.{f}"
    REPLACEMENTS[f"public.{f}"] = f"materials.{f}"

print(f"Compiled {len(REPLACEMENTS)} schema replacement rules for materials domain.")

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
    new_path = f"src/materials/tables/{t}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Table: odiseo.{t}", f"Table: materials.{t}")
        
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
            content = content.replace(f"Table: public.{t}", f"Table: materials.{t}")
            
            with open(new_path, "w", encoding="utf-8") as f:
                f.write(content)
            os.remove(old_pub_path)
            moved_tables += 1

print(f"Moved {moved_tables} table files to src/materials/tables/.")

# Move function files
moved_functions = 0
for fn in FUNCTIONS:
    old_path = f"src/functions/odiseo.{fn}.sql"
    new_path = f"src/materials/functions/{fn}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Function: {fn}", f"Function: materials.{fn}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.remove(old_path)
        moved_functions += 1

print(f"Moved {moved_functions} function files to src/materials/functions/.")

# Perform global search and replace in all files under src/ (excluding new files in target schemas)
updated_files = 0
for root, dirs_list, files in os.walk("src"):
    for file in files:
        if file.endswith(".sql"):
            file_path = os.path.join(root, file)
            # Skip new schemas folders to avoid reprocessing
            if any(x in file_path for x in ["src/materials/", "src/questions/", "src/academic/", "src/auth/"]):
                continue
                
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
            new_content = apply_replacements(content)
            
            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                updated_files += 1

print(f"Updated references in {updated_files} other files.")
print("Materials migration completed successfully!")
