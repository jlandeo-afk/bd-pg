import os

# Create questions directories
DIRS = [
    "src/questions/tables",
    "src/questions/functions",
    "src/questions/views",
    "src/questions/triggers"
]

for d in DIRS:
    os.makedirs(d, exist_ok=True)
    print(f"Directory verified: {d}")

# Tables to migrate
TABLES = [
    "alternative", "alternative_ia_images", "alternative_maths", "alternative_questions_ia",
    "configuration_alternative", "parent_question", "parent_question_correlative", "question",
    "question_attributes", "question_attributes_type", "question_attributes_type_course",
    "question_attributes_types_values", "question_correlative", "question_field_diagrammed_nq",
    "question_history_course", "question_history_cycle", "question_history_usage_exam_parent_question",
    "question_ia_images", "question_image", "question_maths", "question_observation",
    "question_pdf_jobs", "question_refuzed", "question_secondary", "question_shares",
    "question_status", "question_subtopic", "question_teacher_ia", "question_temporary",
    "parent_image", "parent_observation", "origin_parent_question", "origin_question",
    "origin_question_nq", "didi_maths", "solution_ia_images",
    "essential_knowledge_image", "essential_knowledge_questions", "essential_knowledges",
    "course_didi_assignment_state", "employee_didi_question", "employee_didi_question_field",
    "employee_didi_question_field_image", "employee_didi_question_field_image_active",
    "employee_didi_question_field_image_inactive", "employee_didi_question_image",
    "employee_question", "employee_question_document", "employee_question_image",
    "employee_question_maths", "history_digitalized_solution_question_pdf"
]

# Functions to migrate
FUNCTIONS = [
    "change_status_verified_question", "fn_add_question_bank_ia", "fn_amount_parent_question_category",
    "fn_amount_parent_question_level", "fn_archived_parent_questions", "fn_archived_question",
    "fn_assign_questions_didi", "fn_assign_questions_docente", "fn_assigned_question",
    "fn_assigned_question_teacher", "fn_auto_assign_missing_questions_to_teacher", "fn_change_assigned_question",
    "fn_change_assigned_question_didi", "fn_change_index_question", "fn_change_status_parent_question",
    "fn_change_status_question", "fn_check_if_teacher_question_amount_exceed_limit", "fn_child_parent_question",
    "fn_configuration_alternative_create", "fn_configuration_alternative_delete", "fn_configuration_alternative_update",
    "fn_configuration_alternative_validate_exists_default", "fn_configuration_alternative_validate_name",
    "fn_create_essential_knowledge", "fn_create_origin_parent_question", "fn_create_origin_question",
    "fn_create_question_refuzed", "fn_deactive_and_retrieve_questions_for_registering", "fn_delete_diagram_question",
    "fn_delete_exception_question", "fn_delete_index_question", "fn_delete_origin_question",
    "fn_delete_parent_question", "fn_delete_pdfs_question", "fn_delete_question",
    "fn_delete_url_pds_question", "fn_didi_questions_totals_v2", "fn_digitalized_teacher_question",
    "fn_edit_alternative_ia", "fn_edit_origin_parent_question", "fn_edit_origin_question",
    "fn_edit_solution_ia", "fn_employee_question", "fn_employee_question_document",
    "fn_find_approved_question_for_word_download", "fn_find_detail_parent_question", "fn_find_details_in_diagrammed_question",
    "fn_find_images_maths_question", "fn_find_parent_question", "fn_find_parent_question_detail",
    "fn_find_parent_question_detail_all", "fn_find_parent_question_detail_all_assign", "fn_find_question",
    "fn_find_question_by_id", "fn_find_question_digitalized_by_id", "fn_find_question_digitalized_for_download",
    "fn_find_question_for_previewer", "fn_find_question_refuzed", "fn_find_question_subtopics",
    "fn_find_sub_question_parent_question", "fn_generate_code_parent_question", "fn_generate_code_question",
    "fn_generate_question_code", "fn_get_available_missing_questions_count", "fn_get_courses_with_questions",
    "fn_get_essential_knowledge_by_question_id", "fn_get_failed_question_jobs", "fn_get_history_generated_questions",
    "fn_get_history_questions", "fn_get_missing_questions", "fn_get_missing_questions_search",
    "fn_get_missing_questions_text_search", "fn_get_missing_questions_to_regenerate", "fn_get_missing_text_with_subquestions",
    "fn_get_parent_question_avalilable_to_add", "fn_get_question_all_maths", "fn_get_question_by_subtopic",
    "fn_get_question_id_simple", "fn_get_question_urls", "fn_get_question_usage_stats",
    "fn_get_questions_by_didi_status", "fn_get_questions_by_teacher_status", "fn_get_questions_ia",
    "fn_get_questions_to_assign_didi", "fn_get_questions_to_assign_teacher", "fn_get_validate_question_ia",
    "fn_get_verified_questions_summary_teacher", "fn_group_didi_question", "fn_group_teacher_question",
    "fn_index_essential_knowledge", "fn_indexar_question", "fn_indexar_question_teacher",
    "fn_insert_field_digitized_question", "fn_insert_or_update_field_digitized_question", "fn_insert_parent_question",
    "fn_insert_question_gpt", "fn_insert_question_shares", "fn_insert_question_status",
    "fn_insert_question_with_alternatives", "fn_insert_question_with_alternatives_v2", "fn_insert_verified_question_with_alternatives",
    "fn_list_digitalized_question", "fn_list_eligible_teachers_for_missing_questions", "fn_list_essential_knowledge",
    "fn_list_index_question", "fn_list_index_question_by_teacher", "fn_list_questions_verified_and_not_excluded",
    "fn_list_search_revised_question", "fn_list_uses_essential_knowledge", "fn_list_verified_question",
    "fn_list_verified_questions_co", "fn_list_verified_questions_teacher", "fn_order_by_list_verified_question",
    "fn_origin_parent_question", "fn_origin_question", "fn_paginate_compatible_questions",
    "fn_parent_question_detail", "fn_parent_question_detail_index", "fn_question",
    "fn_question_configuration_comparison", "fn_question_diagram", "fn_question_parent_with_image",
    "fn_question_teacher_ia_by_id", "fn_question_verified_duplicate", "fn_questions_area_deleted",
    "fn_reassign_missing_question", "fn_report_didi_gm_question", "fn_report_missing_questions",
    "fn_report_teacher_question_v3", "fn_report_verified_questions", "fn_report_verified_questions_total",
    "fn_revised_diagrammed_question", "fn_revised_question_digitalized", "fn_save_incomplete_questions",
    "fn_save_incomplete_questions_area", "fn_search_configuration_alternative", "fn_search_similar_parent_questions",
    "fn_search_similar_questions", "fn_search_similar_sub_question", "fn_search_tracking_question",
    "fn_subtopics_count_questions", "fn_sync_parent_question_with_subquestions_status", "fn_teacher_assigned_question",
    "fn_teacher_digitalized_questions", "fn_teacher_questions_notification", "fn_teacher_questions_totals",
    "fn_topics_count_questions", "fn_unassign_missing_question", "fn_unassign_missing_question_by_employee",
    "fn_unassigned_question", "fn_update_alternative", "fn_update_and_find_excluded_questions",
    "fn_update_and_find_unverified_questions", "fn_update_essential_knowledge", "fn_update_essential_knowledge_by_question",
    "fn_update_parent_question", "fn_update_question_simple", "fn_update_status_parent_question",
    "fn_upload_question_missing", "fn_validate_history_question", "fn_verified_course_question",
    "fn_verified_parent_question", "fn_verified_question", "get_detail_question_digitalized_v2",
    "get_didis_for_assignment", "get_limit_question_by_didi", "get_question_alternatives_and_file_solution",
    "get_questions_by_teacher_pdf", "sp_insert_didi_ghost_or_teacher_ghost", "subtopic_has_related_questions"
]

# Replacements dictionary
REPLACEMENTS = {}

for t in TABLES:
    REPLACEMENTS[f"odiseo.{t}"] = f"questions.{t}"
    REPLACEMENTS[f"public.{t}"] = f"questions.{t}"
    # Sequences
    REPLACEMENTS[f"odiseo.{t}_id_seq"] = f"questions.{t}_id_seq"
    REPLACEMENTS[f"public.{t}_id_seq"] = f"questions.{t}_id_seq"

for f in FUNCTIONS:
    REPLACEMENTS[f"odiseo.{f}"] = f"questions.{f}"
    REPLACEMENTS[f"public.{f}"] = f"questions.{f}"

print(f"Compiled {len(REPLACEMENTS)} schema replacement rules for questions domain.")

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
    new_path = f"src/questions/tables/{t}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Table: odiseo.{t}", f"Table: questions.{t}")
        
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
            content = content.replace(f"Table: public.{t}", f"Table: questions.{t}")
            
            with open(new_path, "w", encoding="utf-8") as f:
                f.write(content)
            os.remove(old_pub_path)
            moved_tables += 1

print(f"Moved {moved_tables} table files to src/questions/tables/.")

# Move function files
moved_functions = 0
for fn in FUNCTIONS:
    old_path = f"src/functions/odiseo.{fn}.sql"
    new_path = f"src/questions/functions/{fn}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Function: {fn}", f"Function: questions.{fn}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.remove(old_path)
        moved_functions += 1

print(f"Moved {moved_functions} function files to src/questions/functions/.")

# Perform global search and replace in all files under src/ (excluding new files in src/questions/ and target schemas)
updated_files = 0
for root, dirs_list, files in os.walk("src"):
    for file in files:
        if file.endswith(".sql"):
            file_path = os.path.join(root, file)
            # Skip new schemas folders to avoid reprocessing
            if any(x in file_path for x in ["src/questions/", "src/academic/", "src/auth/"]):
                continue
                
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
            new_content = apply_replacements(content)
            
            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                updated_files += 1

print(f"Updated references in {updated_files} other files.")
print("Questions migration completed successfully!")
