import os

# Create exams directories
DIRS = [
    "src/exams/tables",
    "src/exams/functions",
    "src/exams/views",
    "src/exams/triggers"
]

for d in DIRS:
    os.makedirs(d, exist_ok=True)
    print(f"Directory verified: {d}")

# Tables to migrate
TABLES = [
    "area", "exam_area", "type_exams"
]

# Functions to migrate
FUNCTIONS = [
    "fn_area", "fn_area_all", "fn_create_area", "fn_deactive_parent_questions_exams",
    "fn_delete_area", "fn_exam_areas_all", "fn_exam_key_generation", "fn_exam_type",
    "fn_find_area", "fn_get_available_parent_question_for_exam", "fn_get_course_and_exam_area",
    "fn_get_detail_exam_questions_by_area_courses", "fn_get_detail_exam_questions_by_areas",
    "fn_get_exam_configuration_inconsistencies", "fn_get_exam_generated_questions",
    "fn_get_exam_inconsistency_status", "fn_get_exam_questions", "fn_get_exam_subquestions_per_text",
    "fn_get_exam_usage_stats", "fn_get_report_missing_question_exam", "fn_get_report_missing_text_exam",
    "fn_get_search_exam_areas", "fn_get_topics_and_subtopics_probabilities_for_exam",
    "fn_insert_or_update_distribution_levels_exam", "fn_insert_questions_missing_exam",
    "fn_missing_text_exam", "fn_report_exam_key_generation_v2", "fn_search_exam_area",
    "fn_store_exam_parent_question", "fn_update_and_find_excluded_questions_exam",
    "fn_update_area", "fn_validate_config_exam"
]

# Replacements dictionary
REPLACEMENTS = {}

for t in TABLES:
    REPLACEMENTS[f"odiseo.{t}"] = f"exams.{t}"
    REPLACEMENTS[f"public.{t}"] = f"exams.{t}"
    # Sequences
    REPLACEMENTS[f"odiseo.{t}_id_seq"] = f"exams.{t}_id_seq"
    REPLACEMENTS[f"public.{t}_id_seq"] = f"exams.{t}_id_seq"

for f in FUNCTIONS:
    REPLACEMENTS[f"odiseo.{f}"] = f"exams.{f}"
    REPLACEMENTS[f"public.{f}"] = f"exams.{f}"

print(f"Compiled {len(REPLACEMENTS)} schema replacement rules for exams domain.")

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
    new_path = f"src/exams/tables/{t}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Table: odiseo.{t}", f"Table: exams.{t}")
        
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
            content = content.replace(f"Table: public.{t}", f"Table: exams.{t}")
            
            with open(new_path, "w", encoding="utf-8") as f:
                f.write(content)
            os.remove(old_pub_path)
            moved_tables += 1

print(f"Moved {moved_tables} table files to src/exams/tables/.")

# Move function files
moved_functions = 0
for fn in FUNCTIONS:
    old_path = f"src/functions/odiseo.{fn}.sql"
    new_path = f"src/exams/functions/{fn}.sql"
    
    if os.path.exists(old_path):
        with open(old_path, "r", encoding="utf-8") as f:
            content = f.read()
        content = apply_replacements(content)
        content = content.replace(f"Function: {fn}", f"Function: exams.{fn}")
        
        with open(new_path, "w", encoding="utf-8") as f:
            f.write(content)
        os.remove(old_path)
        moved_functions += 1

print(f"Moved {moved_functions} function files to src/exams/functions/.")

# Perform global search and replace in all files under src/ (excluding target schemas)
updated_files = 0
for root, dirs_list, files in os.walk("src"):
    for file in files:
        if file.endswith(".sql"):
            file_path = os.path.join(root, file)
            # Skip new schemas folders to avoid reprocessing
            if any(x in file_path for x in ["src/exams/", "src/materials/", "src/questions/", "src/academic/", "src/auth/"]):
                continue
                
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
                
            new_content = apply_replacements(content)
            
            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                updated_files += 1

print(f"Updated references in {updated_files} other files.")
print("Exams migration completed successfully!")
