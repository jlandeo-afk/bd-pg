# PLAN: Reestructuración por Entidad

## Resumen del cambio

Reorganizar `src/{schema}/functions/` (plano) → `src/{schema}/{entidad}/` con un archivo por verbo.

Las funciones multi-entidad van a `src/{schema}/cross/`.

Triggers y views residuales en `odiseo.*` migran a su schema de dominio correspondiente.

---

## Reglas del nuevo layout

```
src/{schema}/
  {entidad}/           → funciones CRUD de esa entidad
    fn_get.sql         → schema.fn_get_{entidad}(...)
    fn_create.sql      → schema.fn_create_{entidad}(...)
    fn_update.sql      → schema.fn_update_{entidad}(...)
    fn_delete.sql      → schema.fn_delete_{entidad}(...)
    fn_search.sql      → schema.fn_search_{entidad}(...)
    fn_list.sql        → schema.fn_list_{entidad}(...)
    fn_paginate.sql    → schema.fn_paginate_{entidad}(...)
    …
  cross/               → funciones que tocan 2+ entidades
    fn_create_user_from_contributor.sql
    …
  triggers/            → funciones trigger (RETURNS TRIGGER)
    trg_{tabla}_{accion}.sql
  views/               → vistas + materializadas
    vw_{entidad}_{detalle}.sql
    mv_{entidad}_{detalle}.sql
```

---

## 1. Auth (src/auth/)

| Entidad | Tablas | Archivos a crear |
|---|---|---|
| **users** | users | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_search.sql`, `fn_profile.sql`, `fn_image.sql` |
| **roles** | roles | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_list.sql`, `fn_list_users.sql` |
| **permissions** | permissions | `fn_get.sql`, `fn_create.sql`, `fn_list.sql`, `fn_paginate.sql` |
| **roles_permissions** | roles_permissions | `fn_get.sql`, `fn_create.sql`, `fn_edit.sql` |
| **tokens** | personal_access_tokens, nq_user_token, password_reset_tokens, remembered_sessions, nq_user_request | `fn_get.sql`, `fn_create.sql`, `fn_invalidate.sql`, `fn_revoke.sql` |
| **cross/** | — | `fn_create_user_role.sql`, `fn_create_user_from_contributor.sql`, `fn_create_rol_with_permission.sql`, `fn_update_rol_with_permission.sql` |

### Renombres necesarios

| Actual → | Nuevo | Razón |
|---|---|---|
| `fn_get_user.sql` | `users/fn_get.sql` | Consolidar con `fn_get_user_by_id` (absorbido como param opcional) |
| `fn_get_user_by_id.sql` | *eliminar* | Absorbido por `users/fn_get.sql` con `p_id DEFAULT NULL` |
| `fn_get_auth_user_details.sql` | `users/fn_profile.sql` | Es perfil de usuario autenticado |
| `fn_deleted_user.sql` | `users/fn_delete.sql` | Corregir typo (deleted → delete) |
| `fn_update_image_user.sql` | `users/fn_image.sql` | Caso específico |
| `fn_rol.sql` | `roles/fn_list.sql` | Estandarizar verbo |
| `fn_rol_users.sql` | `roles/fn_list_users.sql` | Verb + entidad |
| `fn_create_rol.sql` → `roles/fn_create.sql` | — | — |
| `fn_edit_rol.sql` → `roles/fn_update.sql` | — | Estandarizar verbo (edit → update) |
| `fn_list_permissions.sql` → `permissions/fn_list.sql` | — | — |
| `fn_paginate_permissions.sql` → `permissions/fn_paginate.sql` | — | — |
| `fn_nq_create_user_token.sql` | `tokens/fn_create.sql` | La entidad es token |
| `fn_get_nq_user_token.sql` | `tokens/fn_get.sql` | — |
| `fn_get_token_user.sql` | `tokens/fn_get.sql` | Misma función (consolidar) |
| `fn_invalidate_token_user.sql` | `tokens/fn_invalidate.sql` | — |
| `fn_revoke_user_token.sql` | `tokens/fn_revoke.sql` | — |
| `fn_edit_rol_permission.sql` → `roles_permissions/fn_edit.sql` | — | — |

---

## 2. Academic (src/academic/)

| Entidad | Tablas | Archivos a crear |
|---|---|---|
| **courses** | course, course_level, course_assigned_categories, course_assigned_subcategories, course_pseudo_course, course_pseudo_courses, course_text_category_settings | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_search.sql`, `fn_list.sql`, `fn_list_categories.sql`, `fn_save_category.sql`, `fn_update_category.sql`, `fn_delete_category.sql`, `fn_save_subcategory.sql`, `fn_update_subcategory.sql`, `fn_delete_subcategory.sql`, `fn_diagram.sql`, `fn_save_config_diagram.sql`, `fn_update_config_diagram.sql`, `fn_search_config_diagram.sql` |
| **syllabus** | syllabus, syllabus_topic, syllabus_detail_subtopic, syllabus_texts, syllabus_text_content, syllabus_text_detail, syllabus_text_distributions, syllabus_text_weeks, syllabus_week_titles, syllabus_subtopic_type_material, syllabus_type_text, syllabus_template, syllabus_template_topic, syllabus_template_topic_subtopic, history_syllabus | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_search.sql`, `fn_list.sql`, `fn_get_texts.sql`, `fn_save_texts.sql`, `fn_get_week_title.sql`, `fn_update_week_title.sql`, `fn_get_details.sql`, `fn_get_level_detail.sql`, `fn_save_level.sql`, `fn_search_level.sql`, `fn_get_categories_weeks.sql`, `fn_get_subtopics_weeks.sql` |
| **topics** | topic | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_list.sql`, `fn_search.sql`, `fn_edit_position.sql`, `fn_unify.sql` |
| **subtopics** | subtopic, subtopic_history, frequent_university_subtopic | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_search.sql`, `fn_list.sql`, `fn_edit_position.sql`, `fn_frequent.sql`, `fn_change_frequent_status.sql`, `fn_disable_outdated_frequent.sql`, `fn_process_change_frequent.sql`, `fn_validate_frequent.sql`, `fn_source_layers.sql` |
| **cycles** | cycle, cycle_types, cycle_weeks | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_list.sql`, `fn_search.sql`, `fn_paginate.sql`, `fn_get_actives.sql`, `fn_classroom.sql`, `fn_clean_posterior_weeks.sql` |
| **levels** | level, level_rates | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_list.sql`, `fn_get_amount_texts.sql` |
| **universities** | origin_university, option_university, institution_types | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_list.sql`, `fn_search.sql`, `fn_get_employee_university.sql`, `fn_get_all_by_employee.sql`, `fn_get_by_employee_of_syllabus.sql`, `fn_list_by_region.sql`, `fn_get_modalities.sql`, `fn_get_options.sql`, `fn_search_modality_option.sql`, `fn_activate_schema.sql` |
| **weeks** | week, type_week, detail_week_type_mat | `fn_list.sql`, `fn_get_available_per_period.sql`, `fn_generate_detail_type_mat.sql`, `fn_get_ids.sql` |
| **templates** | syllabus_template, syllabus_template_topic, syllabus_template_topic_subtopic | `fn_get.sql`, `fn_search.sql`, `fn_save_topics.sql`, `fn_save_subtopics.sql`, `fn_save_courses.sql`, `fn_get_topics.sql`, `fn_get_subtopics.sql` |
| **templates_syllabus** | syllabus_template, syllabus_template_topic, syllabus_template_topic_subtopic | Template syllabus functions |
| **cross/** | — | `fn_insert_or_update_period_course.sql`, `fn_insert_or_update_period_week_course.sql`, `fn_change_user_courses.sql`, `fn_courses_complete_management.sql`, `fn_create_and_update_employee_university.sql`, `fn_find_employee_university.sql`, `fn_get_employee_university.sql`, `fn_block_unblock_syllabus.sql`, `fn_valid_syllabus_cycle.sql`, `fn_total_text_by_courses_levels.sql`, `fn_total_text_by_courses_syllabus.sql`, `fn_get_structure_by_course_ids.sql`, `fn_unify_topic_suptopic.sql`, `fn_update_subtopic_syllabus.sql`, `fn_update_topic_syllabus.sql`, `fn_delete_subtopic_syllabus.sql`, `fn_delete_topic_syllabus.sql`, `fn_change_topic_subtopics.sql` |

### Renombres notables

| Actual → | Nuevo |
|---|---|
| `fn_updated_course.sql` | `courses/fn_update.sql` |
| `fn_course_all.sql` | `courses/fn_list.sql` |
| `fn_get_all_course_by_employee_and_university.sql` | `courses/fn_list_by_employee_university.sql` |
| `fn_get_courses_by_employee_of_syllabus.sql` | `courses/fn_list_by_employee_syllabus.sql` |
| `fn_find_course.sql` | `courses/fn_get.sql` |
| `fn_find_syllabus.sql` | `syllabus/fn_get.sql` |
| `fn_find_by_subtopic.sql` | `subtopics/fn_get.sql` |
| `fn_find_level.sql` | `levels/fn_get.sql` |
| `fn_find_cycle.sql` | `cycles/fn_get.sql` |
| `fn_level.sql` | `levels/fn_get.sql` |
| `fn_level_all.sql` | `levels/fn_list.sql` |
| `fn_cycle_all.sql` | `cycles/fn_list.sql` |
| `fn_syllabus.sql` + `fn_syllabus_all.sql` | `syllabus/fn_get.sql` + `syllabus/fn_list.sql` |
| `fn_week_all.sql` | `weeks/fn_list.sql` |
| `fn_origin_university.sql` + `fn_origin_university_all.sql` | `universities/fn_get.sql` + `universities/fn_list.sql` |
| `fn_edit_syllabus.sql` | `syllabus/fn_update.sql` |
| `fn_edit_position_topics.sql` | `topics/fn_edit_position.sql` |
| `fn_delete_course_category.sql` + `fn_delete_course_subcategory.sql` | `courses/fn_delete_category.sql` + `courses/fn_delete_subcategory.sql` |

---

## 3. Questions (src/questions/)

| Entidad | Tablas | Archivos a crear |
|---|---|---|
| **parent_questions** | parent_question, parent_question_correlative, parent_image, parent_observation, origin_parent_question | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_search.sql`, `fn_detail.sql`, `fn_find_detail.sql`, `fn_verified.sql`, `fn_archived.sql`, `fn_change_status.sql`, `fn_generate_code.sql`, `fn_sync_status.sql`, `fn_get_available.sql` |
| **questions** | question, question_correlative, question_secondary, question_subtopic, question_image, question_maths, question_attributes, question_attributes_type, question_attributes_type_course, question_attributes_types_values, question_history_course, question_history_cycle, question_history_usage_exam_parent_question, question_ia_images, question_pdf_jobs, question_refuzed, question_status, question_temporary, question_teacher_ia, question_shares, origin_question, origin_question_nq, field_diagrammed, question_field_diagrammed_nq, course_didi_assignment_state | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_search.sql`, `fn_verified.sql`, `fn_archived.sql`, `fn_change_status.sql`, `fn_generate_code.sql`, `fn_insert_with_alternatives.sql`, `fn_insert_verified_with_alternatives.sql`, `fn_get_by_subtopic.sql`, `fn_get_urls.sql`, `fn_get_usage_stats.sql`, `fn_get_history.sql`, `fn_validate_history.sql`, `fn_report_verified.sql`, `fn_list_verified.sql`, `fn_search_similar.sql` |
| **alternatives** | alternative, alternative_ia_images, alternative_maths, alternative_questions_ia, configuration_alternative, employee_didi_question, employee_didi_question_field, employee_didi_question_field_image, employee_didi_question_field_image_active, employee_didi_question_field_image_inactive, employee_didi_question_image, employee_question, employee_question_document, employee_question_image, employee_question_maths | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_config_create.sql`, `fn_config_update.sql`, `fn_config_delete.sql`, `fn_config_validate.sql`, `fn_config_search.sql`, `fn_edit_ia.sql` |
| **digitalization** | essential_knowledge_image, essential_knowledge_questions, essential_knowledges, image_galery_topic, image_gallery, history_digitalized_solution_question_pdf, solution_ia_images | `fn_list.sql`, `fn_get.sql`, `fn_digitalized_teacher.sql`, `fn_revised.sql`, `fn_find_digitalized.sql`, `fn_get_field_digitized.sql`, `fn_insert_field_digitized.sql`, `fn_insert_or_update_field_digitized.sql`, `fn_save_url_file.sql`, `fn_update_file_document.sql` |
| **diagrammed** | field_diagrammed, question_field_diagrammed_nq | `fn_get.sql`, `fn_search.sql`, `fn_detail.sql`, `fn_delete.sql`, `fn_revised.sql`, `fn_find_details.sql`, `fn_migrate_fields.sql` |
| **assignments** | employee_didi_question*, employee_question*, course_didi_assignment_state | `fn_assign.sql`, `fn_assign_teacher.sql`, `fn_change_assigned.sql`, `fn_unassign.sql`, `fn_get_to_assign.sql`, `fn_get_missing.sql`, `fn_reassign.sql`, `fn_report.sql`, `fn_totals.sql` |
| **essential_knowledges** | essential_knowledges, essential_knowledge_questions, essential_knowledge_image | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_list.sql`, `fn_get_by_question.sql`, `fn_index.sql`, `fn_list_uses.sql` |
| **image_gallery** | image_gallery, image_galery_topic | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_search.sql`, `fn_get_details.sql` |
| **IA** | question_teacher_ia, question_ia_images, solution_ia_images, alternative_ia_images, alternative_questions_ia | `fn_add_bank.sql`, `fn_get.sql`, `fn_edit_description.sql`, `fn_edit_solution.sql`, `fn_edit_alternative.sql`, `fn_update_answer_correct.sql`, `fn_get_validate.sql`, `fn_teacher_ia_by_id.sql` |
| **cross/** | — | `fn_sync_parent_question_with_subquestions_status.sql`, `fn_question_verified_duplicate.sql`, `fn_insert_question_gpt.sql`, `fn_save_incomplete_questions.sql`, `fn_save_incomplete_questions_area.sql`, `fn_save_incomplete_text.sql`, `fn_verify_question.sql`, `fn_change_status_reserved_to_verified.sql` |

---

## 4. Materials (src/materials/)

Es el schema con más funciones (170). Entidades principales:

| Entidad | Tablas | 
|---|---|
| **type_materials** | type_material, type_material_area, type_material_area_courses, type_material_bound, type_material_course, type_material_detail_course_texts, type_material_detail_courses, type_material_detail_template, type_material_detail_text_subquestions, type_material_periodicity, type_material_template, type_material_template_configuration_columns |
| **material_configurations** | material_configurations, material_configuration_details, material_configuration_detail_value, material_column_configurations |
| **materials** | material, material_class_week |
| **ballots** | material_ballot_question, material_ballot_stats_*, material_distribution_ballot_questions |
| **exams** (materials) | material_exam_*, separated_material_exam_week |
| **revisions** | material_revisions, material_revision_items, material_revision_courses, material_revision_histories |
| **notifications** | material_generation_notifications, material_generation_notification_types |
| **templates** | type_material_template, type_material_template_configuration_columns, template_type_material_configurations, template_type_material_courses_order |
| **periods** | material_per_period*, periodicity |
| **cross/** | Funciones que cruzan ballots + exams + materials |

> Pendiente: mapeo fino de las 170 funciones. Se recomienda hacer después de aprobar la estructura de los otros schemas, ya que sigue el mismo patrón.

---

## 5. Exams (src/exams/)

| Entidad | Tablas | Archivos |
|---|---|---|
| **areas** | area, exam_area | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql`, `fn_list.sql`, `fn_search.sql`, `fn_get_course_and_exam_area.sql`, `fn_get_search_exam_areas.sql`, `fn_get_detail_exam_questions_by_area_courses.sql`, `fn_get_detail_exam_questions_by_areas.sql` |
| **type_exams** | type_exams | `fn_get.sql`, `fn_list.sql` |
| **exam_keys** | — | `fn_exam_key_generation.sql`, `fn_report_exam_key_generation.sql` |
| **exam_questions** | — | `fn_store_exam_parent_question.sql`, `fn_get_exam_questions.sql`, `fn_get_available_parent_question_for_exam.sql`, `fn_get_exam_generated_questions.sql`, `fn_get_exam_subquestions_per_text.sql`, `fn_deactive_parent_questions_exams.sql`, `fn_insert_questions_missing_exam.sql`, `fn_get_report_missing_question_exam.sql`, `fn_get_report_missing_text_exam.sql`, `fn_update_and_find_excluded_questions_exam.sql` |
| **exam_config** | — | `fn_validate_config_exam.sql`, `fn_get_exam_configuration_inconsistencies.sql`, `fn_get_exam_inconsistency_status.sql`, `fn_insert_or_update_distribution_levels_exam.sql`, `fn_get_topics_and_subtopics_probabilities_for_exam.sql`, `fn_get_exam_usage_stats.sql` |
| **cross/** | — | `fn_missing_text_exam.sql` |

---

## 6. Organization (src/organization/)

| Entidad | Tablas | Archivos |
|---|---|---|
| **companies** | companies, clientes_empresas, company_legal_representatives, company_user_admin | `fn_get.sql` (fn_companies, fn_find_company), `fn_create.sql`, `fn_update.sql`, `fn_find_advanced.sql` |
| **employees** | employees, employee_course, employee_university | `fn_get.sql` (fn_employee_not_user, fn_find_employee_user, get_employee_data, get_employee_detail), `fn_create.sql`, `fn_update.sql` (fn_update_employee, update_data_employee, update_user_id_employee), `fn_search.sql` (fn_get_search_employees), `fn_name.sql` (fn_name_employee) |
| **headquarters** | headquarters, company_headquarters, headquarters_classroom | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql` |
| **teachers** | teachers | `fn_list.sql`, `fn_all.sql`, `fn_generate_code.sql`, `fn_update_manual.sql` |
| **regions** | region, provinces, districts | `fn_list.sql` (fn_list_universities_by_region) |
| **classrooms** | classroom, headquarters_classroom | (pocas funciones específicas) |
| **charges** | charge | (relacionado a employees) |
| **cross/** | — | `fn_verified_save_user_employee.sql`, `fn_generate_code_teacher.sql` |

---

## 7. Common (src/common/)

| Entidad | Tablas | Archivos |
|---|---|---|
| **plans** | plans | `fn_get.sql`, `fn_create.sql`, `fn_update.sql`, `fn_delete.sql` |
| **prospects** | prospect, code_prospect | `fn_get.sql`, `fn_create.sql`, `fn_validate_code.sql` |
| **type_documents** | type_documents | `fn_list.sql` |
| **type_text** | type_text, type_text_level, type_texts_subtopics, type_texts_topics, type_text_subcategories, type_text_templates, type_text_to_subcategory | (funciones relacionadas en materials mayormente) |
| **notifications** | individual_notifications | `fn_get_user_notifications.sql`, `fn_change_status_admin.sql` |
| **rejected_reasons** | category_rejected, importance_rejected | `fn_get.sql` |
| **type_archive** | type_archive | `fn_get.sql` |
| **utility** | — | `fn_immutable_unaccent.sql`, `fn_number_to_roman.sql`, `fn_params_index.sql`, `fn_update_index.sql`, `fn_search_option.sql`, `fn_update_set_massive_attributes.sql`, `unaccent.sql`, `merge_json_array_except.sql` |

---

## 8. Audit (src/audit/)

| Entidad | Archivos |
|---|---|
| **config** | audit_config.sql (table) |
| **log** | audit_log.sql (table) |
| **triggers** | `trg_audit_trigger.sql` (hoy en `src/triggers/audit.fn_audit_trigger.sql` → mover a `src/audit/triggers/trg_audit.sql`) |
| **function_log** | function_log.sql (table), `trg_on_function_event.sql` (hoy en `src/triggers/audit.on_function_event.sql` → mover a `src/audit/triggers/trg_on_function_event.sql`) |

---

## 9. Triggers: migración de residuales en odiseo.*

| Actual (src/triggers/) | Destino |
|---|---|
| `odiseo.fn_sync_employees_to_teachers.sql` | `src/organization/cross/fn_sync_employees_to_teachers.sql` |
| `odiseo.trg_question_self_text.sql` | `src/questions/triggers/trg_question_self_text.sql` |
| `odiseo.trg_update_parent_from_child.sql` | `src/questions/triggers/trg_update_parent_from_child.sql` |
| `odiseo.trg_update_parent_from_self.sql` | `src/questions/triggers/trg_update_parent_from_self.sql` |
| `odiseo.trg_update_question_status_date.sql` | `src/questions/triggers/trg_update_question_status_date.sql` |
| `triggers.sql` (bindings) | Desglosar por schema en `src/{schema}/triggers/bindings.sql` |

## 10. Views: migración de residuales en odiseo.*

| Actual (src/views/) | Destino |
|---|---|
| `odiseo.v_all_parent_origins.sql` | `src/questions/views/vw_all_parent_origins.sql` |
| `odiseo.v_all_parent_origins_by_university.sql` | `src/questions/views/vw_all_parent_origins_by_university.sql` |
| `odiseo.v_all_question_origins.sql` | `src/questions/views/vw_all_question_origins.sql` |
| `odiseo.v_all_question_origins_by_university.sql` | `src/questions/views/vw_all_question_origins_by_university.sql` |
| `odiseo.vm_material_exam_parent_question_with_subquestions.sql` | `src/materials/views/mv_exam_parent_question_with_subquestions.sql` |

---

## Checklist de migración (orden sugerido)

- [ ] **Fase 1 — Estructura**: crear carpetas nuevas (`{entidad}/`, `cross/`, `triggers/`, `views/`) en cada schema
- [ ] **Fase 2 — Auth**: migrar auth (es el más pequeño y sirve como piloto)
- [ ] **Fase 3 — Exams + Organization**: schemas medianos
- [ ] **Fase 4 — Academic + Questions**: schemas grandes (más funciones)
- [ ] **Fase 5 — Materials**: el más grande, al final
- [ ] **Fase 6 — Common + Audit**: schemas transversales
- [ ] **Fase 7 — Triggers/Views residuales**: mover de `odiseo.*` a su schema
- [ ] **Fase 8 — UPPERCASE**: normalizar function bodies
- [ ] **Fase 9 — Regenerar baseline**: `python split_schema.py` + validar con Shadow DB
- [ ] **Fase 10 — Limpiar archivos `scratch/` obsoletos**: ya no serán necesarios tras el refactor

Por cada schema:
  1. Crear estructura de carpetas
  2. Mover + renombrar archivos (con `git mv`)
  3. Actualizar nombre de función SQL dentro del archivo
  4. `split_schema.py` no aplica aquí (es manual) — o adaptar script
  5. Ejecutar contra Shadow DB para validar que nada se rompe
