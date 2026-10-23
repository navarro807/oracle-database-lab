# Runbook: pérdida de un datafile Oracle

## Objetivo

Recuperar un datafile de un tablespace de aplicación con la base en
`ARCHIVELOG`, minimizando el impacto y sin perder cambios confirmados.

## Síntomas

Registrar en el alert log y en la sesión afectada:

- `ORA-01116`: error al abrir el archivo de base de datos.
- `ORA-01110`: identifica el datafile y su ruta.
- `ORA-27041`: el sistema operativo no puede abrir el archivo, normalmente porque no existe.
- `ORA-63999`: Oracle detectó un fallo de medios en la PDB.

No borrar ni recrear manualmente el archivo antes de confirmar el procedimiento.

## Comprobaciones iniciales

Como SYSDBA:

```sql
SELECT name, open_mode
FROM v$pdbs
ORDER BY name;

SELECT file#, name, status
FROM v$datafile
ORDER BY file#;

SELECT log_mode
FROM v$database;
```

Comprobar que la base está en `ARCHIVELOG`:

```sql
SELECT log_mode FROM v$database;
```

Comprobar que existe una copia RMAN utilizable:

```rman
LIST BACKUP OF DATAFILE <numero>;
```

Consultar el alert log para confirmar el archivo afectado y la causa.

## Camino A: tablespace de aplicación

Si el datafile no pertenece a SYSTEM ni al undo crítico:

```sql
ALTER DATABASE DATAFILE <numero> OFFLINE;
```

En RMAN:

```rman
RESTORE DATAFILE <numero>;
RECOVER DATAFILE <numero>;
```

Volver a ponerlo disponible:

```sql
ALTER DATABASE DATAFILE <numero> ONLINE;
```

Verificar:

```sql
SELECT file#, name, status
FROM v$datafile
WHERE file# = <numero>;
```

## Camino B: la PDB quedó montada

Si Oracle cerró la PDB y aparece `ORA-63999`, esperar a que termine el cierre y comprobar:

```sql
SELECT name, open_mode
FROM v$pdbs
WHERE name = 'FREEPDB1';
```

La PDB debe estar montada antes de restaurar y recuperar. Ejecutar en RMAN:

```rman
RESTORE DATAFILE <numero>;
RECOVER DATAFILE <numero>;
```

Después abrir la PDB:

```sql
ALTER PLUGGABLE DATABASE FREEPDB1 OPEN;
```

Verificar:

```sql
SELECT name, open_mode
FROM v$pdbs
WHERE name = 'FREEPDB1';

SELECT file#, name, status
FROM v$datafile
WHERE file# = <numero>;
```

## Si el datafile pertenece a SYSTEM

No intentar recuperarlo online. La secuencia general es:

```sql
SHUTDOWN ABORT;
STARTUP MOUNT;
```

En RMAN:

```rman
RESTORE DATAFILE <numero>;
RECOVER DATAFILE <numero>;
```

Después:

```sql
ALTER DATABASE OPEN;
```

## Criterios de cierre

El incidente solo se considera cerrado cuando:

- El datafile aparece `ONLINE` o `AVAILABLE`.
- La PDB afectada aparece `READ WRITE`.
- Las consultas de validación funcionan.
- El alert log no muestra nuevos errores del mismo archivo.
- Se comprueba la fila o aplicación afectada.
- Se registra RTO y RPO.
- Se informa al responsable de base de datos y al responsable del servicio.

## Registro del laboratorio

En el simulacro D se recuperó el datafile con RMAN y redo archivado.
El cambio confirmado después de la copia sobrevivió a la recuperación,
demostrando un RPO de 0 para ese cambio. El RTO exacto debe tomarse de
`14d-perdida-datafile.script.log`.
