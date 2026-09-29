-- scripts/deployment/env/07-primera-conexion.sql
SELECT banner_full FROM v$version WHERE ROWNUM = 1;

SELECT sys_context('USERENV','CON_NAME') AS con_name FROM dual;

SELECT instance_name, status FROM v$instance;

SELECT username, account_status
FROM dba_users
WHERE username = 'ALUMNO';

EXIT;
