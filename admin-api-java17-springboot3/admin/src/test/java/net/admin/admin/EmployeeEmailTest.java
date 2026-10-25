package net.admin.admin;

import jakarta.validation.Validation;
import jakarta.validation.ValidatorFactory;
import net.admin.admin.module.system.department.dao.DepartmentDao;
import net.admin.admin.module.system.department.domain.entity.DepartmentEntity;
import net.admin.admin.module.system.employee.dao.EmployeeDao;
import net.admin.admin.module.system.employee.domain.entity.EmployeeEntity;
import net.admin.admin.module.system.employee.domain.form.EmployeeAddForm;
import net.admin.admin.module.system.employee.domain.form.EmployeeUpdateForm;
import net.admin.admin.module.system.employee.domain.form.EmployeeUpdateCenterForm;
import net.admin.admin.module.system.employee.manager.EmployeeManager;
import net.admin.admin.module.system.employee.service.EmployeeService;
import net.admin.admin.module.system.login.service.LoginService;
import net.admin.base.module.support.securityprotect.service.SecurityPasswordService;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.test.util.ReflectionTestUtils;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class EmployeeEmailTest {

    @Test
    void optionalEmailStillValidatesNonEmptyAddresses() {
        try (ValidatorFactory factory = Validation.buildDefaultValidatorFactory()) {
            for (Class<?> form : new Class<?>[]{EmployeeAddForm.class, EmployeeUpdateForm.class, EmployeeUpdateCenterForm.class}) {
                for (String email : new String[]{null, "", "employee@example.com"}) {
                    assertTrue(factory.getValidator().validateValue(form, "email", email).isEmpty(), form.getSimpleName() + ": " + email);
                }
                for (String email : new String[]{"invalid", "employee@", "@example.com", "employee@example", " "}) {
                    assertFalse(factory.getValidator().validateValue(form, "email", email).isEmpty(), form.getSimpleName() + ": " + email);
                }
            }
        }
    }

    @Test
    void createsEmployeesWithoutEmailAndReturnsInitialPassword() {
        EmployeeService service = new EmployeeService();
        EmployeeDao employees = mock(EmployeeDao.class);
        DepartmentDao departments = mock(DepartmentDao.class);
        EmployeeManager manager = mock(EmployeeManager.class);
        SecurityPasswordService passwords = mock(SecurityPasswordService.class);
        ReflectionTestUtils.setField(service, "employeeDao", employees);
        ReflectionTestUtils.setField(service, "departmentDao", departments);
        ReflectionTestUtils.setField(service, "employeeManager", manager);
        ReflectionTestUtils.setField(service, "securityPasswordService", passwords);
        when(departments.selectById(1L)).thenReturn(new DepartmentEntity());
        when(passwords.randomPassword()).thenReturn("TestPassword1!");

        for (String email : new String[]{null, ""}) {
            EmployeeAddForm form = new EmployeeAddForm();
            form.setLoginName("employee");
            form.setActualName("employee");
            form.setPhone("13800000001");
            form.setDepartmentId(1L);
            form.setGender(1);
            form.setDisabledFlag(false);
            form.setEmail(email);
            var response = service.addEmployee(form);
            assertTrue(response.getOk());
            assertEquals("TestPassword1!", response.getData());
        }

        ArgumentCaptor<EmployeeEntity> saved = ArgumentCaptor.forClass(EmployeeEntity.class);
        verify(manager, times(2)).saveEmployee(saved.capture(), isNull());
        assertNull(saved.getAllValues().get(0).getEmail());
        assertEquals("", saved.getAllValues().get(1).getEmail());
        assertNotNull(saved.getValue().getLoginPwd());
    }

    @Test
    void emptyEmailsDoNotConflictButFilledEmailsRemainUnique() {
        EmployeeService service = new EmployeeService();
        EmployeeDao employees = mock(EmployeeDao.class);
        DepartmentDao departments = mock(DepartmentDao.class);
        EmployeeManager manager = mock(EmployeeManager.class);
        ReflectionTestUtils.setField(service, "employeeDao", employees);
        ReflectionTestUtils.setField(service, "departmentDao", departments);
        ReflectionTestUtils.setField(service, "employeeManager", manager);
        ReflectionTestUtils.setField(service, "loginService", mock(LoginService.class));
        EmployeeEntity current = new EmployeeEntity();
        current.setEmployeeId(1L);
        current.setEmail("current@example.com");
        EmployeeEntity other = new EmployeeEntity();
        other.setEmployeeId(2L);
        when(employees.selectById(1L)).thenReturn(current);
        when(departments.selectById(1L)).thenReturn(new DepartmentEntity());
        when(employees.getByEmail("", null)).thenReturn(other);
        when(employees.getByEmail("taken@example.com", null)).thenReturn(other);
        when(employees.getByEmail("current@example.com", null)).thenReturn(current);

        EmployeeUpdateForm update = new EmployeeUpdateForm();
        update.setEmployeeId(1L);
        update.setLoginName("employee");
        update.setPhone("13800000001");
        update.setDepartmentId(1L);
        EmployeeUpdateCenterForm center = new EmployeeUpdateCenterForm();
        center.setEmployeeId(1L);
        center.setPhone("13800000001");
        for (String email : new String[]{null, "", "current@example.com"}) {
            update.setEmail(email);
            center.setEmail(email);
            assertTrue(service.updateEmployee(update).getOk(), "employee: " + email);
            assertTrue(service.updateCenter(center).getOk(), "center: " + email);
        }
        verify(employees, never()).getByEmail(eq(""), isNull());
        verify(employees, never()).getByEmail(isNull(), isNull());
        ArgumentCaptor<EmployeeEntity> edited = ArgumentCaptor.forClass(EmployeeEntity.class);
        verify(manager, times(3)).updateEmployee(edited.capture(), isNull());
        assertEquals("", edited.getAllValues().get(1).getEmail());
        ArgumentCaptor<EmployeeEntity> profile = ArgumentCaptor.forClass(EmployeeEntity.class);
        verify(employees, times(3)).updateById(profile.capture());
        assertEquals("", profile.getAllValues().get(1).getEmail());

        clearInvocations(manager, employees);
        update.setEmail("taken@example.com");
        center.setEmail("taken@example.com");
        assertFalse(service.updateEmployee(update).getOk());
        assertFalse(service.updateCenter(center).getOk());
        verifyNoInteractions(manager);
        verify(employees, never()).updateById(any(EmployeeEntity.class));
    }
}
