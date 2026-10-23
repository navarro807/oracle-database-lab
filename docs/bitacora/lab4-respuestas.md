# Lab 4 - Respuestas

## Parte A - Respaldo y diagnóstico

### Punto de control A.4: archivos FUERA del volumen
En mi evidencia 00 (20261023T100050Z_00-backup-lab3.script.log, paso 3) salieron 0 archivos como FUERA: todos están dentro de /opt/oracle/oradata. El manifiesto de la copia lo confirma con archivos_fuera_del_volumen=0.
Aun así, los 5 datafiles de negocio (academia01, clinica01, retail01, logistica01 y fintech01) están en una carpeta no estándar: $ORACLE_HOME/dbs. Lo muestra la evidencia 01 (20261023T100605Z_01-diagnostico.script.log, bloque 4).
Oracle los creó ahí porque V000 los creó con ruta relativa y db_create_file_dest está vacío (sin OMF, evidencia 01 bloque 5): sin destino por defecto, Oracle usa $ORACLE_HOME/dbs.
No se pierden porque mi imagen convierte $ORACLE_HOME/dbs en un enlace simbólico a /opt/oracle/oradata/dbconfig/FREE/dbs, dentro del volumen (evidencia 01, bloque B: "DENTRO del volumen, pero en carpeta no estándar").

### Reto A.4: informe de diagnóstico (orden de corrección = orden de las líneas)
1. [1º, ALTO] V000 guarda las contraseñas de los 5 propietarios de esquema (5 líneas IDENTIFIED BY): quedan en el historial de Git para siempre, así que es lo primero que se invalida (Parte D).
2. [2º, ALTO] 08-aplicar-migraciones.sh usa sys/${ORACLE_PWD} en la conexión: la contraseña de SYS se ve con ps y queda en el historial de la shell; va justo después por el mismo motivo (Parte D).
3. [3º, MEDIO] Los 5 datafiles de negocio están en $ORACLE_HOME/dbs y no en /opt/oracle/oradata/FREE/FREEPDB1; hoy se salvan solo porque mi imagen enlaza esa carpeta al volumen (Parte C).
4. [4º, BAJO] 05-crear-contenedor.sh publica el puerto 8181 sin servicio detrás (ORDS escucha en 8080): una puerta abierta sin función, pero sin datos en juego (Parte C).
5. [5º, BAJO] El documento del Lab 3 tiene incoherencias (touch de V000 en vez de V001, APP_USER_PASSWORD frente a APP_USER_PWD): confunden, pero no ponen datos en riesgo (Parte C).

### P1 (copia consistente)
Respuesta: A y D.
SHUTDOWN IMMEDIATE hace un checkpoint y cierra la base limpiamente, así que todos los archivos tienen el mismo SCN: la copia es consistente, no necesita redo al restaurarla y se abre directamente con STARTUP.
La B es falsa porque una copia en frío no exige ARCHIVELOG: vale con la base en cualquier modo (la mía está en ARCHIVELOG, línea 5 del log 00). La C es falsa porque la copia es consistente. La E es falsa porque no hace falta RMAN.

### 8.1 Respaldo y diagnóstico (A)

**1. ¿Por qué la copia es consistente? ¿Y si se tomara con la base abierta?**
Es consistente porque backup-estado.sh hace SHUTDOWN IMMEDIATE antes de copiar (paso 4 de 20261023T100050Z_00-backup-lab3.script.log, y manifiesto.txt: tipo=copia en frio consistente (SHUTDOWN IMMEDIATE)). Oracle hace un checkpoint y cierra limpiamente, así que todos los datafiles quedan con el mismo SCN y al restaurar no hace falta redo.
Con la base abierta saldría inconsistente: cada archivo se copiaría en un instante distinto, con cambios a medias. Mi base está en ARCHIVELOG (línea 5 del log 00: log_mode=ARCHIVELOG; línea 11 del log 01), así que una copia en caliente solo sería válida si se acompaña del redo archivado (con RMAN, por ejemplo); una copia simple de los archivos con la base abierta, sin ese redo, no sería consistente ni recuperable.

**2. ¿Para qué sirven manifiesto.txt y SHA256SUMS? ¿Qué comprueba restaurar-estado.sh antes de tocar nada?**
manifiesto.txt describe la copia. El mío (backups/20261023T100058Z_lab3-final/manifiesto.txt) dice etiqueta=lab3-final, fecha_utc=20261023T100246Z, contenedor=oralab-26ai, volumen=oralab-26ai-data, git_commit=9f6a5d0 y archivos_fuera_del_volumen=0. SHA256SUMS guarda la huella SHA-256 de cada archivo para detectar daños: sha256sum --check dio "Copia íntegra" en mi equipo.
Antes de tocar nada, restaurar-estado.sh ejecuta sha256sum --check y, si falla, se detiene sin modificar el volumen. Después exige escribir el nombre del volumen (salvo con --si), y solo entonces lo vacía y restaura.

**3. RPO y RTO con los datos de mi copia.**
RPO (cuántos datos puedo perder): mi copia es del 23 de octubre de 2026 a las 10:02 UTC (fecha_utc=20261023T100246Z del manifiesto), el estado del Lab 3. Si restauro, pierdo todo lo hecho después, y una copia en frío no permite volver a un instante intermedio.
Ejemplo real: la cuenta C##OPS_RO se creó a las 10:14 UTC (20261023T101448Z_02-cuenta-observabilidad.script.log), después de la copia. Si restaurara, se perdería y habría que repetir 02-cuenta-observabilidad.sh.
RTO (cuánto tardo en volver a dar servicio): lo que tarda restaurar-estado.sh en comprobar SHA-256, vaciar y restaurar el volumen (copia comprimida de 545 MB según du -sh) y arrancar hasta READ WRITE. Todavía no he restaurado ninguna copia, así que no tengo un RTO medido; el PDF da alrededor de un minuto en su entorno de pruebas y el Lab 5 lo medirá con simulacros.

## Parte B - Mínimo privilegio

### Reto B: ¿dar el rol DBA a C##OPS_RO?
Riesgo 1: el rol DBA incluye privilegios ANY de escritura (modificar o borrar datos y objetos de cualquier esquema), así que un despiste de la cuenta "de solo mirar" sería una incidencia; la verificación final exige justo lo contrario (0 privilegios ANY de escritura).
Riesgo 2: el rol DBA incluye también privilegios de administración (como crear usuarios), y la cuenta existe en todos los contenedores (CONTAINER ALL): si se filtra su contraseña, el atacante tendría control casi total de toda la CDB.
Privilegio exacto para leer el alert log: GRANT SELECT ON sys.v_$diag_alert_ext TO c##ops_ro CONTAINER=ALL, sobre la vista V_$ y no sobre el sinónimo V$. Se ejecuta en la Parte J con 11-ampliar-ops-ro.sql.

## Parte C - Reubicar datafiles y prueba de persistencia

### 8.1.1 Correcciones del Lab 3 (C, D)

**4. ¿Dónde creó Oracle los datafiles de V000 y por qué? ¿Qué parámetro habría evitado el problema?**
V000 usó rutas relativas y db_create_file_dest estaba vacío (evidencia 01, bloque 5), así que Oracle los creó en $ORACLE_HOME/dbs (evidencia 01, bloque 4). En mi imagen esa carpeta es un enlace simbólico al volumen, por eso no se perdían, pero estaban en una carpeta no estándar y dependían de ese enlace. Lo habría evitado db_create_file_dest (OMF) o una ruta absoluta dentro del volumen en cada CREATE TABLESPACE.

**5. ¿Por qué RENAME DATAFILE no basta para mover un archivo?**
Porque solo cambia la ruta que guarda el control file: no copia ni mueve nada, y si el archivo no está ya en la ruta nueva, Oracle no lo encuentra. Por eso 03-reubicar-datafiles.sh pone el tablespace OFFLINE NORMAL, copia con cp -p, hace RENAME DATAFILE, lo pone ONLINE y solo entonces borra el original (evidencia 20261023T104622Z_03-reubicar-datafiles.script.log).

**6. ¿Por qué no se edita V000 y se crea V003? ¿Por qué invalidar una contraseña es mejor que borrarla del archivo?**
V000 ya se aplicó, y una migración aplicada es historia: si la edito, el repositorio deja de describir lo que se ejecutó de verdad y otro entorno llegaría a un estado distinto. Por eso el cambio va en una migración nueva (V003), que además deja constancia de la corrección. Borrar la contraseña del archivo no sirve, porque sigue en el historial de Git (en mi diagnóstico, evidencia 01, V000 tiene 5 líneas IDENTIFIED BY). Invalidarla con ALTER USER ... NO AUTHENTICATION deja al propietario como cuenta de solo esquema: sigue poseyendo sus objetos, pero la contraseña filtrada ya no abre nada.

**7. ¿Qué demuestra la prueba de persistencia y por qué se ejecuta después de reubicar?**
Demuestra que todo el estado de la base vive en el volumen oralab-26ai-data y que el contenedor es desechable. En mi evidencia 20261023T105253Z_03-prueba-persistencia.script.log, tras SHUTDOWN IMMEDIATE, borrar el contenedor y recrearlo (id b5d714c0e880), los 5 TBS_* siguen ONLINE en /opt/oracle/oradata/FREE/FREEPDB1/ con 100 MB cada uno, y los propietarios conservan las mismas tablas (3, 3, 2, 3 y 3). La base volvió a READ WRITE en unos 20 s (sección 3 del log). Se ejecuta después de reubicar porque, si algún datafile siguiera fuera del volumen, el borrado del contenedor lo habría destruido y la prueba habría fallado. Además, la sección 5 muestra que el puerto 8181 ya no se publica: solo queda el 1521.

### Reto C - Que no vuelva a pasar (db_create_file_dest)
Comando: ALTER SYSTEM SET db_create_file_dest = '/opt/oracle/oradata' SCOPE = BOTH; ejecutado dentro de FREEPDB1 (ALTER SESSION SET CONTAINER = FREEPDB1). SCOPE=BOTH hace que el cambio se aplique ya y que se conserve tras reiniciar.
Efecto medido (evidencia 20261023T105637Z_04-omf-destino.script.log): el parámetro quedó con valor /opt/oracle/oradata y un CREATE TABLESPACE tbsx sin DATAFILE creó /opt/oracle/oradata/FREE/55E54F210F100828E0630B00580ADFD0/datafile/o1_mf_tbsx_ofphc6jh_.dbf, dentro del volumen, de 100 MB, autoextensible y con MAXMB 33554432. Después lo borré con DROP TABLESPACE ... INCLUDING CONTENTS AND DATAFILES y tbsx_restantes salió 0.
Matiz: OMF usa la carpeta del GUID de la PDB y no /FREE/FREEPDB1/, pero sigue dentro del volumen. Además OMF fija el sitio, no el techo: el archivo salió sin límite práctico (unos 32 TB), así que cada CREATE TABLESPACE debe seguir llevando MAXSIZE 1G.

### P2 (mover un datafile en Standard Edition)
Respuesta: B.
La secuencia correcta es tablespace OFFLINE, copiar el archivo con el sistema operativo, RENAME DATAFILE y ONLINE: es la que ejecuta mi 03-reubicar-datafiles.sh (evidencia 20261023T104622Z_03-reubicar-datafiles.script.log, pasos a-d). La A es falsa porque MOVE DATAFILE online no está disponible en Free (ORA-00439). La C es falsa porque RENAME DATAFILE no copia nada, solo cambia la ruta en el control file. La D es falsa porque SHUTDOWN ABORT dejaría la base inconsistente y no hace falta parar la base.

## Parte D - Migraciones V003 y V002

### P-D1 (propietario de esquema sin inicio de sesión)
Respuesta: C.
ALTER USER ... NO AUTHENTICATION convierte al propietario en cuenta de solo esquema: sigue poseyendo sus objetos, pero no tiene ninguna forma de iniciar sesión. Lo comprobé con mi V003 (evidencia 20261023T111339Z_04-V003__cuentas_esquema_sin_password.spool.log: los 5 ADMIN_* salen con AUTHENTICATION_TYPE NONE) y la contraseña antigua da ORA-01017 (evidencia 20261023T111405Z_04-contrasena-invalida.script.log). La A es falsa porque ACCOUNT LOCK conserva la contraseña y se puede desbloquear. La B es falsa porque PASSWORD EXPIRE solo obliga a cambiarla en el siguiente acceso. La D es falsa porque quitar CREATE SESSION se puede devolver con un GRANT y la contraseña seguiría existiendo.

## Parte E - Instancia, arranque y alert log

### 8.1.2 Instancia, arranque y parámetros (E, F)

**8. Tres datos de la instancia y tres de la base de datos**
Instancia (evidencias 20261023T111759Z_05-instancia-y-base.spool.log y 20261023T111826Z_05-instancia-so.script.log): su estado OPEN con arranque el 2026-10-23 10:53:18, los 60 procesos de background (db_pmon_FREE, db_dbw0_FREE...) y la memoria del contenedor, 1.939 GiB, que incluye la SGA (1603398928 bytes en el arranque por etapas).
Base de datos: el DBID 1509902213, que no cambia aunque cambie el contenedor; los archivos (16 datafiles, 3 tempfiles, 3 miembros de redo y 2 control files); y su fecha de creación, 2026-07-05, con LOG_MODE ARCHIVELOG.
La instancia es mucho más joven que la base: nació al recrear el contenedor en la Parte C y la base sobrevivió porque sus archivos están en el volumen.

**9. Qué lee Oracle en NOMOUNT, MOUNT y OPEN**
En NOMOUNT lee el SPFILE (/opt/oracle/product/26ai/dbhomeFree/dbs/spfileFREE.ora), reserva la SGA y arranca los procesos; v$parameter responde, pero v$database da ORA-01507 (database not mounted) porque aún no se ha leído el control file.
En MOUNT abre los control files (control01.ctl y control02.ctl), y ya conoce los 16 datafiles y el modo ARCHIVELOG; dba_tables da ORA-01219 porque el diccionario está en los datafiles de SYSTEM, que siguen cerrados.
En OPEN abre los datafiles y el redo (el alert log muestra Thread 1 opened y Completed: ALTER DATABASE OPEN) y FREEPDB1 se abre sola en READ WRITE por su estado guardado (evidencia 20261023T112130Z_06-arranque-por-etapas.script.log).

### Preguntas tipo examen de la Parte E

**P3. Respuesta: A y C.**
A: STARTUP_TIME de v$instance cambia en cada arranque, porque describe la instancia (en mi evidencia 05 es la hora del último arranque). C: CREATED de v$database dice cuándo se creó la base, no cuándo se arrancó (la base es de julio y la instancia de hoy).
B es falsa: el DBID no cambia al recrear el contenedor, porque la base vive en los archivos del volumen. D es falsa: una instancia monta una sola base. E es falsa: v$database funciona desde MOUNT, no solo en OPEN.

**P4. Respuesta: A y C.**
En NOMOUNT solo existe la instancia: v$parameter responde porque los parámetros están en memoria (lo vi en el arranque por etapas) y se puede ejecutar CREATE CONTROLFILE porque aún no hay control file abierto.
B es falsa: DBA_USERS está en el diccionario (SYSTEM), que solo se abre en OPEN. D y E necesitan MOUNT.

**P5. Respuesta: B (MOUNT).**
ALTER DATABASE ARCHIVELOG exige la base montada pero cerrada: el control file está abierto y los datafiles no.

### Reto E.4 - El parte del reinicio (alert log, horas en UTC, 2026-10-23)

- Parada solicitada: 11:21:31 (Shutting down ORACLE instance (immediate)). Instancia parada a las 11:21:40, unos 10 s después.
- Apertura: el último registro con hora antes de Completed: ALTER DATABASE OPEN es de las 11:21:46.85. Unos 6 s desde que terminó la parada y unos 15 s en total.
- Recuperación de instancia: no. Solo el mensaje informativo "Crash Recovery excluding pdb 2/3 which was cleanly closed", porque la parada fue IMMEDIATE y las PDB estaban cerradas limpiamente.
- ORA-00800 Set Priority Failed (VKTM y LGWR): CONOCIDO. El contenedor no deja subir la prioridad de esos procesos y la base funciona.
- ORA-07427 / ORA-27300..27303 (traza FREE_j002, "spstp: cannot change directory to dbs"): A INVESTIGAR. Aparece una sola vez en el alert log, el 2026-07-05 a las 22:02:54 UTC, en el primer arranque del contenedor (Lab 3). No ocurre en el reinicio de hoy ni se ha repetido. Un proceso de jobs no pudo hacer chdir a ORACLE_HOME/dbs, posiblemente por el empaquetado de la imagen, aunque no lo he verificado. No está en la lista de errores conocidos, así que se documenta y se vigila.
- La base está en ARCHIVELOG (v$database), así que ALTER DATABASE ARCHIVELOG no hace falta.


## Parte F - Parámetros, SCOPE y PDB

**10. Diferencia entre v$parameter y v$spparameter, con el ejemplo de db_files**

`v$parameter` muestra el valor que la instancia usa ahora, en memoria. `v$spparameter` muestra solo lo que hay escrito en el SPFILE, que es lo que se aplicará en el próximo arranque. En mi evidencia `07-parametros-cambios.script.log`, bloque 3, tras `ALTER SYSTEM SET db_files = 300 SCOPE = SPFILE` la consulta devolvió `db_files  200  300`: `v$parameter` seguía en 200 y `v$spparameter` ya tenía 300 pendiente. Tras `ALTER SYSTEM RESET db_files SCOPE = SPFILE` devolvió 200 y "(no especificado)": se borró la línea del SPFILE y el parámetro vuelve a su valor por defecto. Además, en `07-parametros-lectura.spool.log` el SPFILE tiene unas 17 entradas distintas (control_files aparece dos veces) mientras que `v$parameter` lista 564 parámetros documentados, porque el resto usa el valor por defecto de Oracle y no está escrito en el SPFILE.

**11. Por qué PROCESSES rechaza el cambio en memoria aunque v$parameter lo marque IMMEDIATE**

En `07-parametros-lectura.spool.log`, bloque 2, `processes` aparece con `SYS_MOD = IMMEDIATE`. Sin embargo, en `07-parametros-cambios.script.log`, bloque 4, `ALTER SYSTEM SET processes = 250 SCOPE = MEMORY` falló con ORA-02097 y ORA-02095. PROCESSES dimensiona estructuras de la SGA que se reservan al arrancar, así que en la práctica es estático aunque la metadata diga otra cosa. Para cambiarlo hay que usar `SCOPE = SPFILE` y reiniciar. La metadata orienta, pero la prueba en el entorno es la que decide.

### Preguntas tipo examen de la Parte F

**P6. Respuesta: B.** Sin cláusula SCOPE, en una instancia arrancada con SPFILE el valor por defecto es BOTH: el cambio se aplica en memoria y en el SPFILE. En mi evidencia, el bloque 2 usa `SCOPE = BOTH` y deja 500 en las dos columnas.

**P7. Respuesta: C.** Falla con ORA-65040 porque PROCESSES es un parámetro de instancia y no se puede cambiar desde una PDB. Lo vi en el bloque 5 de mi evidencia.

**P8. Respuesta: A y C.** `STARTUP PFILE=ruta/initbueno.ora` arranca con la copia buena, y `CREATE SPFILE FROM PFILE='ruta/initbueno.ora'` repara el SPFILE. Por eso antes de tocar el SPFILE se hace `CREATE PFILE ... FROM SPFILE`, como en el bloque 7 de mi evidencia.

### Reto F.2 - Petición de cambio: open_cursors a 1000

- **Valor actual y origen:** 300, escrito en el SPFILE (aparece en `v$spparameter`, `ISDEFAULT = FALSE`). Lo veo en `07-parametros-lectura.spool.log`.
- **Valor propuesto:** 1000, solicitado por el equipo de desarrollo por el error ORA-01000.
- **Antes de cambiar:** ORA-01000 suele delatar cursores que la aplicación no cierra. Subir el límite solo retrasa el problema, así que primero hay que pedir a desarrollo que revise los cursores abiertos con `v$open_cursor`.
- **SCOPE:** primero `SCOPE = MEMORY` dentro de la PDB afectada, porque `open_cursors` es modificable por PDB. Si funciona, se pasa a `SCOPE = BOTH` para que sobreviva al reinicio.
- **Prueba:** comprobar el valor en `v$parameter` y `v$spparameter`, y vigilar `v$open_cursor` durante la carga normal.
- **Rollback:** `ALTER SYSTEM SET open_cursors = 300 SCOPE = BOTH;`. Antes del cambio se guarda un `CREATE PFILE FROM SPFILE`.
- **Evidencia:** la salida del script con antes y después, el PFILE versionado y el ticket de la petición.

## Parte G - Memoria, procesos y análisis

**12. Qué modelo de gestión de memoria usa mi instancia y por qué**

Usa gestión automática de la memoria compartida (ASMM): la SGA se reparte sola y la PGA se gestiona aparte. Lo justifico con tres parámetros de `20261023T114501Z_08-memoria.spool.log`, bloque 1: `memory_size = 0` y `memory_target = 0`, que descartan la gestión automática de toda la memoria (AMM); `sga_target = 1536M`, que fija el total que Oracle reparte entre buffer cache, shared pool y large pool; y `pga_aggregate_target = 512M`, que gestiona la PGA por separado. Además `db_cache_size = 0` y `shared_pool_size = 0` no significan "sin caché", sino que no hay mínimo fijado y decide ASMM. En el bloque 4 el buffer cache ocupa 928 MB y la shared pool 480 MB.

**13. Cifras de mi experimento de caché: lecturas lógicas, físicas y tasa de acierto**

En `08-experimento-cache.script.log`, tras `ALTER SYSTEM FLUSH BUFFER_CACHE`, la misma consulta sobre `ACA_ESTUDIANTES` (20000 filas en 244 bloques) dio en la ronda 1, con la caché fría, 355 lecturas lógicas y 259 físicas, y en la ronda 2, con la caché caliente, 247 lógicas y 0 físicas. Una lectura lógica encuentra el bloque en memoria y una física tiene que ir a disco. La tasa de acierto es 1 - físicas/lógicas: 27 % en la ronda 1 (1 - 259/355) y 100 % en la ronda 2. El bloque 4 muestra 245 bloques de la tabla en `v$bh`, los 244 de datos más uno, que sería la cabecera del segmento. Conclusión: el Buffer Cache convierte lecturas físicas en lógicas, y por eso la segunda ejecución no toca el disco. El vaciado de la caché solo se hace en laboratorio, nunca en producción.

**14. Literales frente a variables de enlace, con mis cifras de análisis (parse) y de V$SQL**

En `08-parse-y-pga.script.log`, bloque 1, las 1000 consultas con literales generaron 1048 análisis totales, 1008 de ellos duros (hard parse), con 5630 ms de CPU de análisis y 6080 ms de tiempo total. La consulta con variable de enlace (`:id`) ejecutada 1000 veces generó 1 análisis total y 1 duro, con 0 ms de CPU de análisis y 30 ms de tiempo total: unas 200 veces menos tiempo (6080 / 30). Con literales cada valor produce un texto de sentencia distinto, así que Oracle no lo encuentra en la library cache y lo analiza entero cada vez (análisis duro, que consume CPU y bloquea estructuras compartidas). Con la variable de enlace el texto es siempre el mismo y los demás usan el cursor ya analizado (análisis blando). En `V$SQL`, `con :id` ocupa 1 cursor de 39 KB con 1000 ejecuciones, y `con literales` ocupa 879 cursores y 32762 KB, unas 840 veces más memoria de la shared pool. Faltan 121 cursores de los 1000 porque la shared pool ya los había expulsado (aged out), lo que también es coste. Las variables de enlace ahorran CPU y memoria, y además evitan la inyección SQL.

**Experimento G.4: la PGA ordena en memoria o se va a TEMP**

En el bloque 2, `lab4_pga_auto` ordenó 60000 filas en 320 ms con 0 ordenaciones en disco, y su área de trabajo en `V$SQL_WORKAREA` figura como OPTIMAL con 0 KB en TEMP. `lab4_pga_64k`, con 64 KB manuales, ordenó las mismas filas en 540 ms (unas 1,7 veces más) con 1 ordenación en disco, 6 PASSES y 3072 KB en TEMP. Una ordenación óptima cabe en la memoria de la PGA; una de una pasada se escribe a TEMP y se relee una vez; una de varias pasadas la relee varias veces y es una alarma. En toda la instancia hay 4797 ejecuciones óptimas, 0 de una pasada y 2 de varias pasadas (las de este experimento). El `aggregate PGA target` de 512 MB es un objetivo y no un límite duro; el límite es `pga_aggregate_limit`, 2G. En mi ejecución `maximum PGA allocated` fue 469,3 MB y no lo superó.

**Reto G: encontrar las sentencias con literales en V$SQL**

En `08-reto-literales.script.log`, la consulta agrupa `V$SQL` por `force_matching_signature` (la huella de la sentencia sin sus literales) y muestra las firmas con más de 50 cursores distintos. Devolvió una sola fila: la firma 1863221789280198928 con 775 cursores distintos y 775 ejecuciones, cuyo texto de ejemplo es `SELECT /* lab4_literal */ COUNT(*) FROM admin_academia.aca_estudiantes`. Es la consulta de `08-parse-y-pga.sql` ejecutada con un literal distinto cada vez, así que cada ejecución ocupó un cursor propio. Antes había 879 cursores en `V$SQL` y ahora 775, porque la shared pool expulsó (aged out) más cursores viejos entre una consulta y otra. En una base real, esta misma consulta es lo primero que se ejecuta cuando la CPU está al 100 %: las firmas con muchos cursores son las sentencias que la aplicación debería reescribir con variables de enlace.

**P-G2. Una ordenación muestra LAST_EXECUTION = 6 PASSES y LAST_TEMPSEG_SIZE de varios MB. Qué significa**

Respuesta: B. El área de trabajo no cupo en la PGA y Oracle tuvo que releer seis veces sus datos desde TEMP. En mi `V$SQL_WORKAREA`, la ordenación con 64 KB manuales (`manual, 64 KB`) muestra `6 PASSES` y 3072 KB en TEMP, y su `KB_OPTIMO` era 1719, muy por encima de los 65 KB usados. La A es falsa porque una ordenación que cabe en memoria figura como OPTIMAL, como la de PGA automática (2377 KB usados, 0 en TEMP). La C es falsa porque `PASSES` no cuenta servidores paralelos. La D es falsa porque los análisis se miran en `V$MYSTAT` o `V$SQL`, no en `V$SQL_WORKAREA`.

**P-G1. Una aplicación ejecuta miles de veces por minuto la misma consulta cambiando solo un literal en el WHERE. V$SQL muestra miles de cursores casi idénticos y la CPU de análisis es alta. Qué solución definitiva recomiendo**

Respuesta: B. Modificar la aplicación para usar variables de enlace. Mi experimento lo confirma: las consultas con literales produjeron 1008 análisis duros y 5630 ms de CPU de análisis, mientras que la sentencia con `:id` produjo un solo análisis duro, 1000 ejecuciones y 30 ms de tiempo total. Los literales generan cursores distintos y consumen CPU y shared pool; la variable de enlace conserva el mismo texto de sentencia y permite reutilizar el cursor. Aumentar `SHARED_POOL_SIZE` solo conservaría más cursores duplicados, `ALTER SYSTEM FLUSH SHARED_POOL` empeoraría temporalmente el problema y `CURSOR_SHARING = FORCE` puede ser una contingencia, pero no sustituye la corrección de la aplicación.
