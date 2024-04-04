CREATE TABLE jobs (
    job_id VARCHAR2(10) PRIMARY KEY,
    job_title VARCHAR2(50),
    min_salary NUMBER,
    max_salary NUMBER
);

CREATE TABLE departments (
    department_id NUMBER PRIMARY KEY,
    department_name VARCHAR2(50),
    manager_id NUMBER
);

CREATE TABLE employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR2(10) NOT NULL,
    salary NUMBER NOT NULL,
    department_id NUMBER NOT NULL
);

CREATE TABLE job_history (
    employee_id NUMBER,
    start_date DATE,
    end_date DATE,
    job_id VARCHAR2(10),
    department_id NUMBER
);

ALTER TABLE employees ADD CONSTRAINT fk_job_id_emp FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE employees ADD CONSTRAINT fk_department_id_emp FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE departments ADD CONSTRAINT fk_manager_id_dep FOREIGN KEY (manager_id) REFERENCES employees(employee_id);
ALTER TABLE job_history ADD CONSTRAINT fk_employee_id_jh FOREIGN KEY (employee_id) REFERENCES employees(employee_id);
ALTER TABLE job_history ADD CONSTRAINT fk_job_id_jh FOREIGN KEY (job_id) REFERENCES jobs(job_id);
ALTER TABLE job_history ADD CONSTRAINT fk_department_id_jh FOREIGN KEY (department_id) REFERENCES departments(department_id);


-- sequência para gerar automaticamente iDs para os funcionários
CREATE SEQUENCE employees_seq START WITH 1 INCREMENT BY 1;


CREATE OR REPLACE PACKAGE employee_management AS
    FUNCTION add_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone_number IN VARCHAR2,
        p_hire_date IN DATE,
        p_job_id IN VARCHAR2,
        p_salary IN NUMBER,
        p_department_id IN NUMBER
    ) RETURN NUMBER;
END employee_management;
/

CREATE OR REPLACE PACKAGE BODY employee_management AS
    FUNCTION add_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone_number IN VARCHAR2,
        p_hire_date IN DATE,
        p_job_id IN VARCHAR2,
        p_salary IN NUMBER,
        p_department_id IN NUMBER
    ) RETURN NUMBER
    IS
    BEGIN
        INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id)
        VALUES (employees_seq.NEXTVAL, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date, p_job_id, p_salary, p_department_id);

        COMMIT;

        RETURN 1; -- Retorna 1 para sucesso
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN 0; -- Retorna 0 para erro
    END add_employee;
END employee_management;

DECLARE
    result NUMBER;
BEGIN
    result := employee_management.add_employee(
        'John',
        'Doe',
        'john.doe@example.com',
        '123456789',
        TO_DATE('2024-04-04', 'YYYY-MM-DD'),
        'IT_PROG',
        5000,
        1
    );
    IF result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Employee added successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error adding employee.');
    END IF;
END;
/

SELECT *
FROM employees
WHERE first_name = 'Joana'
AND last_name = 'Silva';



CREATE OR REPLACE PACKAGE employee_management AS
-- função para adicionar um novo funcionario
    FUNCTION add_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone_number IN VARCHAR2,
        p_hire_date IN DATE,
        p_job_id IN VARCHAR2,
        p_salary IN NUMBER,
        p_department_id IN NUMBER
    ) RETURN NUMBER;
    -- função para excluir um funcionário
    PROCEDURE delete_employee(p_employee_id IN NUMBER);
    
    -- proceimento para atualizar o salário de um funcionário
    PROCEDURE update_salary(p_employee_id IN NUMBER, p_new_salary IN NUMBER);
    -- procedimento para obter um funcionário por ID
    FUNCTION get_employee_by_id(p_employee_id IN NUMBER) RETURN SYS_REFCURSOR;
    -- Função para pesquisar um funcionário pelo nome
    FUNCTION search_employee_by_name(p_first_name IN VARCHAR2, p_last_name IN VARCHAR2) RETURN SYS_REFCURSOR;
END employee_management;
/

CREATE OR REPLACE PACKAGE BODY employee_management AS
    FUNCTION add_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_email IN VARCHAR2,
        p_phone_number IN VARCHAR2,
        p_hire_date IN DATE,
        p_job_id IN VARCHAR2,
        p_salary IN NUMBER,
        p_department_id IN NUMBER
    ) RETURN NUMBER IS
    BEGIN
      -- adicionar um novo funcionário á tabela employees
        INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id)
        VALUES (employees_seq.NEXTVAL, p_first_name, p_last_name, p_email, p_phone_number, p_hire_date, p_job_id, p_salary, p_department_id);

        COMMIT;

        RETURN 1; -- Retorna 1 para sucesso
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RETURN 0; -- Retorna 0 para erro
    END add_employee;
    
    -- implementação do procedimento delete_employee

    PROCEDURE delete_employee(p_employee_id IN NUMBER) IS
    BEGIN
        DELETE FROM employees WHERE employee_id = p_employee_id;

        COMMIT;
    END delete_employee;
    
    -- implementação do procedimento update-salary

    PROCEDURE update_salary(p_employee_id IN NUMBER, p_new_salary IN NUMBER) IS
    BEGIN
        UPDATE employees SET salary = p_new_salary WHERE employee_id = p_employee_id;

        COMMIT;
    END update_salary;
   -- implementação da função get_employee_by_id
    FUNCTION get_employee_by_id(p_employee_id IN NUMBER) RETURN SYS_REFCURSOR IS
        emp_cursor SYS_REFCURSOR;
    BEGIN
    
    -- Logica para obter um funcionário pelo ID da tabela employees
        OPEN emp_cursor FOR
        SELECT * FROM employees WHERE employee_id = p_employee_id;

        RETURN emp_cursor;
    END get_employee_by_id;
     -- implementação da função search_employee_by_name
    FUNCTION search_employee_by_name(p_first_name IN VARCHAR2, p_last_name IN VARCHAR2) RETURN SYS_REFCURSOR IS
        emp_cursor SYS_REFCURSOR;
    BEGIN
        OPEN emp_cursor FOR
        SELECT * FROM employees WHERE first_name = p_first_name AND last_name = p_last_name;

        RETURN emp_cursor;
    END search_employee_by_name;
END employee_management;
/



DECLARE
    result NUMBER;
BEGIN
    result := employee_management.add_employee(
        'Joana',
        'Silva',
        'joana.silva@example.com',
        '987654321',
        TO_DATE('2024-04-05', 'YYYY-MM-DD'),
        'SA_REP',
        6000,
        2
    );
    IF result = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Employee added successfully.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Error adding employee.');
    END IF;
END;
/


DECLARE
    emp_id NUMBER := 1; -- ID do funcionário a ser buscado
    emp_data employees%ROWTYPE;
BEGIN
    SELECT *
    INTO emp_data
    FROM employees
    WHERE employee_id = emp_id;

    DBMS_OUTPUT.PUT_LINE('Employee Found: ' || emp_data.first_name || ' ' || emp_data.last_name);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found.');
END;
/

SELECT *
FROM employees
WHERE employee_id = 1; -- Substitua 1 pelo ID do funcionário que deseja buscar


UPDATE employees
SET salary = 7000
WHERE employee_id = 1; -- ID do funcionário a ser atualizado

DELETE FROM employees
WHERE employee_id = 1; -- ID do funcionário a ser excluído


-- pacote para calcular salários de funcionários com base em um salário base de 
--entrada

CREATE OR REPLACE PACKAGE salary_calculator AS
    FUNCTION calculate_salary(p_base_salary NUMBER) RETURN NUMBER;
END salary_calculator;
/

CREATE OR REPLACE PACKAGE BODY salary_calculator AS
    FUNCTION calculate_salary(p_base_salary NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_base_salary;
    END calculate_salary;
END salary_calculator;
/


DECLARE
    emp_salary NUMBER;
BEGIN
    emp_salary := salary_calculator.calculate_salary(5000);
    DBMS_OUTPUT.PUT_LINE('Employee Salary: ' || emp_salary);
END;
/

CREATE TABLE employee_data (
    employee_id NUMBER PRIMARY KEY,
    employee_name VARCHAR2(100),
    department VARCHAR2(50),
    hire_date DATE
);




CREATE TABLE employees_archive (
    archive_id NUMBER PRIMARY KEY,
    employee_id NUMBER,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100),
    phone_number VARCHAR2(20),
    hire_date DATE,
    job_id VARCHAR2(10),
    salary NUMBER,
    department_id NUMBER,
    archive_date DATE,
    action VARCHAR2(10)
);

-- Trigger para arquivar dados da tabela 'employees' para a tabela 'employees_archive' antes de uma operação de atualização ou exclusão.
CREATE OR REPLACE TRIGGER archive_data_trigger
BEFORE UPDATE OR DELETE ON employees
FOR EACH ROW
BEGIN
    IF UPDATING THEN
        INSERT INTO employees_archive (archive_id, employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id, archive_date, action)
        VALUES (employees_seq.NEXTVAL, :OLD.employee_id, :OLD.first_name, :OLD.last_name, :OLD.email, :OLD.phone_number, :OLD.hire_date, :OLD.job_id, :OLD.salary, :OLD.department_id, SYSDATE, 'UPDATE');
    ELSIF DELETING THEN
        INSERT INTO employees_archive (archive_id, employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id, archive_date, action)
        VALUES (employees_seq.NEXTVAL, :OLD.employee_id, :OLD.first_name, :OLD.last_name, :OLD.email, :OLD.phone_number, :OLD.hire_date, :OLD.job_id, :OLD.salary, :OLD.department_id, SYSDATE, 'DELETE');
    END IF;
END;
/

INSERT INTO employee_data (employee_id, employee_name, department, hire_date)
VALUES (3, 'Mariana Froz', 'IT', TO_DATE('2024-04-10', 'YYYY-MM-DD'));

INSERT INTO employee_data (employee_id, employee_name, department, hire_date)
VALUES (4, 'Bibiana Araujo', 'HR', TO_DATE('2024-03-15', 'YYYY-MM-DD'));

INSERT INTO employee_data (employee_id, employee_name, department, hire_date)
VALUES (5, 'Carlos Medeiro', 'Finance', TO_DATE('2024-02-20', 'YYYY-MM-DD'));



select*from employees;

DELETE FROM employees
WHERE employee_id = 3;

SELECT * FROM employee_data;


INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id)
SELECT employee_id,
       SUBSTR(employee_name, 1, INSTR(employee_name, ' ') - 1) AS first_name,
       SUBSTR(employee_name, INSTR(employee_name, ' ') + 1) AS last_name,
       LOWER(REPLACE(REPLACE(employee_name, ' ', '_'), 'á', 'a')) || '@example.com' AS email,
       '1234567890' AS phone_number,
       hire_date,
       'IT_PROG' AS job_id,
       5000 AS salary,
       1 AS department_id
FROM employee_data
WHERE employee_id = 3;

INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id)
SELECT employee_id,
       SUBSTR(employee_name, 1, INSTR(employee_name, ' ') - 1) AS first_name,
       SUBSTR(employee_name, INSTR(employee_name, ' ') + 1) AS last_name,
       LOWER(REPLACE(REPLACE(employee_name, ' ', '_'), 'á', 'a')) || '@example.com' AS email,
       '1234567890' AS phone_number,
       hire_date,
       'HR_REP' AS job_id,
       5000 AS salary,
       2 AS department_id
FROM employee_data
WHERE employee_id = 4;

INSERT INTO employees (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id)
SELECT employee_id,
       SUBSTR(employee_name, 1, INSTR(employee_name, ' ') - 1) AS first_name,
       SUBSTR(employee_name, INSTR(employee_name, ' ') + 1) AS last_name,
       LOWER(REPLACE(REPLACE(employee_name, ' ', '_'), 'á', 'a')) || '@example.com' AS email,
       '1234567890' AS phone_number,
       hire_date,
       'FIN_REP' AS job_id,
       5000 AS salary,
       3 AS department_id
FROM employee_data
WHERE employee_id = 5;

