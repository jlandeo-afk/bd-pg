-- Trigger Bindings

--

CREATE TRIGGER trg_audit_cycle AFTER DELETE OR UPDATE ON academic.cycle FOR EACH ROW EXECUTE FUNCTION audit.fn_audit_trigger();


--

--

CREATE TRIGGER trg_audit_roles AFTER DELETE OR UPDATE ON auth.roles FOR EACH ROW EXECUTE FUNCTION audit.fn_audit_trigger();


--

--

CREATE TRIGGER trg_audit_type_material AFTER DELETE OR UPDATE ON materials.type_material FOR EACH ROW EXECUTE FUNCTION audit.fn_audit_trigger();


--

--

CREATE TRIGGER trg_audit_type_material_periodicity AFTER DELETE OR UPDATE ON materials.type_material_periodicity FOR EACH ROW EXECUTE FUNCTION audit.fn_audit_trigger();


--

--

CREATE TRIGGER trg_audit_users AFTER DELETE OR UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION audit.fn_audit_trigger();


--

--

CREATE TRIGGER trg_audit_users_roles AFTER DELETE OR UPDATE ON auth.users_roles FOR EACH ROW EXECUTE FUNCTION audit.fn_audit_trigger();


--

--

CREATE TRIGGER trg_sync_employees_to_teachers AFTER INSERT OR UPDATE ON organization.employees FOR EACH ROW EXECUTE FUNCTION odiseo.fn_sync_employees_to_teachers();

ALTER TABLE organization.employees DISABLE TRIGGER trg_sync_employees_to_teachers;


--

--

CREATE TRIGGER trigger_parent_rebuild_after AFTER INSERT OR UPDATE ON questions.parent_question FOR EACH ROW EXECUTE FUNCTION odiseo.trg_update_parent_from_self();


--

--

CREATE TRIGGER trigger_update_parent_after AFTER INSERT OR DELETE OR UPDATE ON questions.question FOR EACH ROW EXECUTE FUNCTION odiseo.trg_update_parent_from_child();


--

--

CREATE TRIGGER trigger_update_status_date AFTER INSERT ON questions.question_status FOR EACH ROW EXECUTE FUNCTION odiseo.trg_update_question_status_date();


--
