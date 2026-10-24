#!/usr/bin/env bash
set -uo pipefail

source scripts/deployment/env/00-config.sh

fallos=0
ok() {
  printf '  [OK]    %s\n' "$1"
}
fallo() {
  printf '  [FALLO] %s -> repasa %s\n' "$1" "$2"
  fallos=$((fallos + 1))
}
comprobar() {
  if [ "$2" = "$3" ]; then
    ok "$1 ($2)"
  else
    fallo "$1: hay '$2', se esperaba '$3'" "$4"
  fi
}

VALORES=$(docker exec -i "$CONT_NAME" sqlplus -s -L / as sysdba <<'SQL'
SET HEADING OFF FEEDBACK OFF PAGESIZE 0 LINESIZE 200

SELECT 'open_mode=' || open_mode FROM v$database;
SELECT 'log_mode=' || log_mode FROM v$database;
SELECT 'controlfiles=' || COUNT(*) FROM v$controlfile;
SELECT 'grupos_1_miembro=' || COUNT(*) FROM v$log WHERE members < 2;
SELECT 'fra=' ||
       CASE WHEN value IS NOT NULL THEN 'definida' ELSE 'vacia' END
FROM v$parameter
WHERE name = 'db_recovery_file_dest';
SELECT 'fra_size_spfile=' || NVL(MAX(value), 'no')
FROM v$spparameter
WHERE name = 'db_recovery_file_dest_size'
  AND isspecified = 'TRUE';
SELECT 'archivados=' ||
       CASE WHEN COUNT(*) > 0 THEN 'si' ELSE 'no' END
FROM v$archived_log
WHERE name IS NOT NULL;
SELECT 'pdbs=' || COUNT(*)
FROM v$pdbs
WHERE name NOT IN ('PDB$SEED');
SELECT 'ops_ro_alert=' || COUNT(*)
FROM dba_tab_privs
WHERE grantee = 'C##OPS_RO'
  AND table_name = 'V_$DIAG_ALERT_EXT';
SELECT 'rman=' ||
       CASE WHEN COUNT(*) > 0 THEN 'si' ELSE 'no' END
FROM v$rman_backup_job_details
WHERE status = 'COMPLETED';

ALTER SESSION SET CONTAINER = FREEPDB1;

SELECT 'fila101=' || estado
FROM admin_academia.aca_estudiantes
WHERE estudiante_id = 101;
SELECT 'fila102=' || estado
FROM admin_academia.aca_estudiantes
WHERE estudiante_id = 102;
SELECT 'matriculas=' || COUNT(*)
FROM admin_academia.aca_matriculas;
SELECT 'fila104=' || estado
FROM admin_academia.aca_estudiantes
WHERE estudiante_id = 104;
SELECT 'tiendasur=' ||
       (SELECT COUNT(*) FROM tiendasur.cliente) || '/' ||
       (SELECT COUNT(*) FROM tiendasur.pedido)
FROM dual;
SELECT 'indices_pedido=' ||
       LISTAGG(index_name, ',') WITHIN GROUP (ORDER BY index_name)
FROM dba_indexes
WHERE owner = 'TIENDASUR'
  AND table_name = 'PEDIDO';
SELECT 'ux_cli_dni=' || COUNT(*)
FROM dba_indexes
WHERE owner = 'TIENDASUR'
  AND index_name = 'UX_CLI_DNI'
  AND uniqueness = 'UNIQUE';
SELECT 'invisibles=' || COUNT(*)
FROM dba_indexes
WHERE owner = 'TIENDASUR'
  AND visibility = 'INVISIBLE';
SELECT 'medir=' || status
FROM dba_objects
WHERE owner = 'LAB_TOOLS'
  AND object_name = 'MEDIR'
  AND object_type = 'PACKAGE BODY';
SELECT 'lab5_pruebas=' || COUNT(*)
FROM dba_users
WHERE username = 'LAB5_PRUEBAS';

EXIT
SQL
)

val() {
  echo "$VALORES" |
    sed -n "s/^$1=//p" |
    tr -d '[:space:]'
}

echo "== Partes I a L · SCN, control files, redo y ARCHIVELOG =="
comprobar "copias del control file" "$(val controlfiles)" "3" "Parte J"
comprobar "grupos de redo con un solo miembro" \
  "$(val grupos_1_miembro)" "0" "Parte K"
comprobar "modo de la base" "$(val log_mode)" "ARCHIVELOG" "Parte L"
comprobar "FRA configurada" "$(val fra)" "definida" "Parte L"
comprobar "hay redo archivado" "$(val archivados)" "si" "Parte L"

echo "== Partes M a P · Undo, simulacros y salud =="
comprobar "fila 101 de vuelta a ACTIVO" \
  "$(val fila101)" "ACTIVO" "Parte M"
comprobar "fila 102 de vuelta a ACTIVO" \
  "$(val fila102)" "ACTIVO" "Parte O"
comprobar "matrículas restauradas" \
  "$(val matriculas)" "60000" "Parte O"
comprobar "fila 104 de vuelta a ACTIVO" \
  "$(val fila104)" "ACTIVO" "Parte O"
comprobar "hay copias RMAN completadas" \
  "$(val rman)" "si" "Parte O"
comprobar "PDB de usuario" "$(val pdbs)" "1" "Lab 4"
comprobar "CDB abierta" "$(val open_mode | sed 's/READWRITE/READ WRITE/')" "READ WRITE" "Parte O"

echo "== Evidencias =="
for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15; do
  if ls "$EVID_LAB5"/*/*_"$n"[a-z-]* >/dev/null 2>&1; then
    ok "evidencia $n"
  else
    fallo "falta la evidencia $n" "parte correspondiente"
  fi
done

if git ls-files --error-unmatch config/.env >/dev/null 2>&1; then
  fallo "config/.env está en Git" ".gitignore"
else
  ok "config/.env fuera de Git"
fi

if git ls-files | grep -q '^backups/'; then
  fallo "hay backups versionados en Git" ".gitignore"
else
  ok "backups/ fuera de Git"
fi

echo
if [ "$fallos" -eq 0 ]; then
  echo "RESULTADO: TODO OK. Lab 5 listo para entregar."
else
  echo "RESULTADO: $fallos FALLO(S). Corrige antes de abrir el PR."
fi

exit "$fallos"
