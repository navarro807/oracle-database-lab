-- scripts/lab4/08-reto-literales.sql — reto de la Parte G: sentencias que la aplicación ejecuta con literales
-- Se ejecuta como SYSDBA justo después de 08-parse-y-pga.sql: bash scripts/ops/sysdba.sh <este archivo>
WHENEVER SQLERROR EXIT FAILURE
SET LINESIZE 170 PAGESIZE 100 FEEDBACK OFF
COLUMN firma FORMAT 99999999999999999999
COLUMN ejemplo FORMAT A70
SELECT force_matching_signature AS firma,
       COUNT(DISTINCT sql_id) AS cursores_distintos,
       SUM(executions) AS ejecuciones,
       MIN(SUBSTR(sql_text, 1, 70)) AS ejemplo
  FROM v$sql
 WHERE force_matching_signature <> 0
 GROUP BY force_matching_signature
HAVING COUNT(DISTINCT sql_id) > 50
 ORDER BY cursores_distintos DESC;
EXIT
