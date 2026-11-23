# Respuestas Lab 6 · Juan Francisco Navarro Cruz · E048

## Parte B · Lista de turno y automatización

### Lista de turno (evidencia 01)
- Identidad: C##OPS_RO en CDB$ROOT. Solo lectura, no puede cambiar nada.
- Instancia: FREE OPEN, LOGINS ALLOWED. Base READ WRITE en ARCHIVELOG.
- PDB: PDB$SEED READ ONLY y FREEPDB1 READ WRITE, sin RESTRICTED.
- Sesiones bloqueadas: 0. Alertas pendientes: 0. Ningún tablespace supera el 85 %.
- Línea base: 4 errores ORA- en las últimas 24 h (2026-11-23).
  Es mi referencia de hoy: un número solo no dice nada, solo sirve comparado.
  Si mañana saliera el triple, sería una señal; el mismo número no significa nada.

### Lo que Oracle hace solo (evidencia 01-automatizacion)
- AutoTask: 3 tareas ENABLED (estadísticas del optimizador, Segment Advisor y SQL Tuning Advisor).
- Ventanas: lunes a viernes a las 22:00 durante 4 h; sábado y domingo a las 06:00 durante 20 h.
- Umbrales MMON: en FREEPDB1 los tablespaces SYSTEM, USERS, TBS_ACADEMIA y TBS_TIENDASUR salen NONE.
  Nadie avisaría si se llenan. Se corrige en la Parte F.
- AWR: una foto cada hora y se guarda 8 días.
  control_management_pack_access = DIAGNOSTIC+TUNING; en Enterprise Edition es licencia.
- Scheduler: 24 trabajos de SYS (12 habilitados); ninguno falló en 7 días.

### Pregunta tipo examen B1
Respuesta: B. NONE significa que MMON no generará alertas de espacio para ese tablespace
hasta que se fije un umbral. No significa que esté vacío, ni que use el 85 % de la raíz,
ni que sea de solo lectura.

## Parte C · Parámetros, estados de la PDB y arranque

### C.1 Parámetros y SCOPE (evidencia 02-parametros)
- La instancia arrancó con un SPFILE binario (spfileFREE.ora), no con un PFILE de texto.
- Antes de tocar nada creé dos copias en texto: una FROM SPFILE (lo que alguien fijó)
  y otra FROM MEMORY (todo lo que está en uso, también lo que calcula Oracle).
- db_files es estático (ISSYS_MODIFIABLE = FALSE): con SCOPE=MEMORY da ORA-02095.
  Oracle protege la instancia en marcha.
- Con SCOPE=SPFILE se acepta: el archivo dice 250 pero la memoria sigue en 200.
  El cambio solo se aplica en el próximo arranque, y queda una diferencia pendiente.
- RESET quitó la línea del SPFILE y db_files volvió a estar sin fijar.
  Valía como vuelta atrás solo porque db_files NO estaba fijado antes (lo demuestra la copia del paso 2).
  Si ya estuviera fijado (por ejemplo processes), RESET lo cambiaría al valor por defecto.
- ORA-65040: desde FREEPDB1 no se puede cambiar un parámetro que es del CDB (processes).
- Las dos copias en texto: el PFILE desde SPFILE tiene 34 líneas y el PFILE desde MEMORY tiene 125 líneas.
  El SPFILE solo guarda lo que alguien fijó; la memoria tiene muchos más parámetros, casi todos con su valor por defecto.

### C.2 Estados de FREEPDB1 y SAVE STATE (evidencia 02-estados-pdb)
- READ ONLY: se puede consultar (20000 estudiantes) pero escribir da ORA-16000.
  Sirve para auditorías o para congelar una PDB.
- Abrir en READ WRITE una PDB ya abierta da ORA-65019. Hay que cerrarla antes
  o usar OPEN READ WRITE FORCE, que la cierra y la abre en un solo paso (expulsa a las sesiones).
- RESTRICTED: la PDB está abierta pero solo entra quien tiene RESTRICTED SESSION.
  C##OPS_RO no lo tiene y recibe ORA-01035. Es el modo de mantenimiento sin usuarios dentro.
- Reinicio SIN estado guardado (tras DISCARD STATE): la instancia dice "Database opened",
  pero FREEPDB1 queda MOUNTED. Por el servicio freepdb1 da ORA-01109 (database not open).
  Para la aplicación la base está caída aunque la instancia diga que está abierta.
- Con ALTER PLUGGABLE DATABASE ... SAVE STATE guardé el estado OPEN. Tras otro reinicio,
  FREEPDB1 volvió sola a READ WRITE: así "arriba" se comprueba por el camino del consumidor.
- En el alert log aparecen ORA-65019 (provocado por mí a propósito) y ORA-00800 [Set Priority Failed] [LGWR],
  que es un aviso del proceso LGWR al no poder subir su prioridad en Docker sobre WSL; no afecta a la base.

### C.3 Validar el arranque (evidencias 02-estados-pdb y 02-validar-arranque)
- Criterio de "arriba": no basta con que un comando diga "Database opened". Lo comprobé por
  el camino del consumidor: entrando por el servicio freepdb1 sale CONTENEDOR=FREEPDB1,
  READ WRITE, estado guardado OPEN, servicio freepdb1 activo y ningún datafile fuera de línea.
- Ruido conocido del arranque (lo anoto para perseguir solo lo nuevo):
  ORA-00800 [Set Priority Failed] [LGWR]: Linux en contenedor no deja a Oracle subir la prioridad
  de VKTM y LGWR; es ruido conocido de Docker/WSL.
  ORA-65019: lo provoqué yo a propósito en el paso 2 de C.2 (abrir una PDB ya abierta).

### Preguntas tipo examen de la Parte C
- C1. Respuesta: B (ALTER SYSTEM SET db_files = 300 SCOPE = SPFILE).
  Es estático: SCOPE=MEMORY da ORA-02095. Con SPFILE el valor se aplica en el próximo arranque
  sin afectar a la instancia actual. SCOPE=BOTH fallaría igual por incluir memoria; ALTER SESSION
  no vale para parámetros del sistema; RESET no pone el valor 300.
- C2. Respuesta: A y C (abrir la PDB con ALTER PLUGGABLE DATABASE freepdb1 OPEN y, ya abierta,
  ALTER PLUGGABLE DATABASE freepdb1 SAVE STATE). SAVE STATE guarda el modo actual de la PDB;
  DISCARD STATE lo borra y la PDB quedaría en MOUNTED tras cada reinicio.

## Parte D · Servicio por aplicación, su cuenta y sus sesiones

### D.1 y D.2 Servicio y cuenta (evidencias 03-servicio y 03-cuenta-app)
- Creé el servicio academia_app dentro de FREEPDB1 y lo arranqué. En DBA_SERVICES existen
  FREEPDB1 (por defecto) y academia_app; en V$ACTIVE_SERVICES ambos están arrancados (CON_ID 3).
  Hice SAVE STATE con el servicio arrancado para que sobreviva a un reinicio.
- common_user_prefix en mi imagen vale C##: un usuario común (como C##OPS_RO) debe empezar así.
  APP_ACADEMIA es LOCAL (COMMON = NO), solo existe en FREEPDB1, con QUOTA 0 en USERS.
- Sus privilegios son CREATE SESSION y SELECT, UPDATE sobre ADMIN_ACADEMIA.ACA_ESTUDIANTES, dados
  directamente a propósito: es la deuda de acceso que pago en la Parte G.

### D.3 Una sesión de principio a fin (evidencia 03-sesiones)
- La sesión de la aplicación tenía SID 67, SERIAL# 44117, SPID 2558 y evento PL/SQL lock timer
  (está dentro de DBMS_SESSION.SLEEP). MODULE=matriculas, ACTION=cierre-periodo y
  CLIENT_IDENTIFIER=ana.garcia@ucam me dicen qué hacía y para quién, algo que USERNAME no dice.
- Entró por el servicio academia_app, con PASSWORD, y su proceso de Linux es "oracleFREE (LOCAL=NO)".
- Con la fila 101 modificada sin confirmar la transacción usaba 1 bloque de undo y 1 registro de undo.
- CANCEL SQL '67,44117': la aplicación recibió ORA-01013 en la llamada en curso, siguió conectada
  ("sigo viva") y su transacción siguió abierta: 1 transacción abierta.
- KILL SESSION '67,44117' IMMEDIATE: sale ORA-00031 (marcada para terminar) y un instante después hay 0 sesiones
  de la aplicación. La aplicación recibió ORA-00028 y ORA-03114. El UPDATE sin confirmar se deshizo:
  la fila 101 sigue en ACTIVO. Terminar una sesión nunca confirma su trabajo.
- El alert log guarda quién mató a quién: KILL SESSION for sid=(67, 44117), requestor SYS, usuario de SO oracle.
- Orden de preferencia (de la herramienta más pequeña a la más grande): esperar o hablar con el dueño,
  CANCEL SQL, DISCONNECT/KILL SESSION y nunca kill -9 del proceso como primera opción.
- Escalera de privilegios: como SYSOPER mi usuario es PUBLIC y DBA_USERS no existe para él (ORA-00942):
  SYSOPER opera (arrancar, parar) pero no ve los datos.

### Pregunta tipo examen D1
- Respuesta: B (ALTER SYSTEM CANCEL SQL). Cae la llamada que lleva 40 minutos, pero la sesión y su
  transacción pendiente siguen vivas. KILL SESSION o kill -9 harían rollback y perderían el trabajo.

## Parte E · Diccionario y observabilidad

### E.1 La misma consulta, tres identidades (evidencia 04-tres-miradas)
| Vista | C##OPS_RO en CDB$ROOT | C##OPS_RO en FREEPDB1 | APP_ACADEMIA por academia_app |
|---|---|---|---|
| ALL_TABLES de ADMIN_ACADEMIA | 0 | 0 | 1 |
| ALL_USERS (los que veo) | 37 | 47 | 47 |
| DBA_USERS | 37 | 47 | ORA-00942 |
| CDB_USERS | CON_ID 1: 37; CON_ID 3: 47 | CON_ID 3: 47 | ORA-00942 |
| V$DATAFILE | 17 | 10 | ORA-00942 |

- Nadie miente: cada identidad ve lo que su rol y su contenedor le permiten.
- ALL_ muestra lo que puedes usar: APP_ACADEMIA ve 1 tabla de ADMIN_ACADEMIA porque tiene un permiso sobre ella.
  C##OPS_RO tiene SELECT_CATALOG_ROLE, que deja leer el catálogo pero no los datos, y ve 0.
- DBA_USERS devuelve 37 en la raíz y 47 dentro de FREEPDB1: los usuarios de la PDB son más que los de la raíz.
- CDB_USERS solo sirve desde la raíz y con CONTAINER_DATA: allí muestra 37 (raíz) y 47 (FREEPDB1).
  Dentro de la PDB solo ve su propio contenedor (CON_ID 3).
- V$DATAFILE: 17 desde la raíz (todos los contenedores) y 10 dentro de FREEPDB1. Las V$ también se filtran por contenedor.
- Para anotar en un incidente: siempre desde dónde y con quién he mirado.

### E.2 De dónde salen las vistas (evidencia spool 04-diccionario)
- V$FIXED_TABLE tiene 3394 objetos: 1591 tablas X$, 921 vistas V$ y 880 vistas GV$.
  Las X$ exponen estructuras de memoria de la instancia y datos del control file; no son tablas en disco.
- V$INSTANCE es GV$INSTANCE filtrada con inst_id = USERENV('Instance').
- Lo que escribo (V$SESSION, DBA_USERS) son sinónimos públicos de SYS.V_$SESSION y SYS.DBA_USERS.
- DICTIONARY solo me lista 16 vistas DBA_ porque solo enseña lo concedido a PUBLIC o a mí.
  Para buscar la vista de cuotas uso DBA_TAB_COMMENTS: la respuesta es DBA_TS_QUOTAS (y DBA_RESUMABLE para lo resumable).
- En DBA_TS_QUOTAS, MAX_BYTES = -1 significa cuota ilimitada, aunque el comentario del catálogo diga NULL.
- C##OPS_RO tiene ALL_CONTAINERS = Y: desde la raíz ve los datos de todos los contenedores.

### E.3 Acumulados frente a deltas (evidencia 04-deltas)
- Los acumulados desde el arranque no significan nada sin el "desde cuándo": mi instancia llevaba 7 minutos arriba
  con DB time 12.6 s y DB CPU 7.5 s. Un número suelto es una foto.
- Medí una carga conocida (10 recorridos completos de TIENDASUR.PEDIDO) restando dos fotos:
  tiempo de reloj 0.88 s, DB time 0.94 s, DB CPU 0.88 s, 53671 lecturas lógicas, 132 ejecuciones (incluye recursivas).
  Son 5367 lecturas lógicas por recorrido.
- DB time (0.94 s) es casi igual a DB CPU (0.88 s): la carga casi no esperó, fue trabajo de CPU.
  Si DB time fuera mucho mayor que DB CPU, la diferencia serían esperas (E/S, bloqueos...).
- Las tasas por minuto de V$CON_SYSMETRIC salen a 0 porque en ese minuto no había actividad. Dentro de una PDB
  V$SYSMETRIC sale vacía, por eso se usa V$CON_SYSMETRIC.
- Esperas acumuladas de la PDB desde el arranque: Concurrency 8 s, User I/O 7.3 s, System I/O 0.2 s.
  Salen más altas que en el material del profesor porque hubo reinicios recientes.
- Es un AWR de bolsillo: AWR toma una foto cada hora y su informe es la resta de dos fotos.

### Pregunta tipo examen E1
- Respuesta: B (solo los usuarios de FREEPDB1). Conectado por el servicio freepdb1, CDB_USERS solo enseña
  el contenedor actual (CON_ID 3: 47 usuarios en mi salida). La vista existe también dentro de la PDB;
  los otros contenedores solo se ven desde la raíz con CONTAINER_DATA.

## Parte F · Espacio, cuotas, reanudable y HWM

### F.1 Tablespace con techo, tres medidas y cuotas (evidencia 05-almacenamiento)
- Creé TBS_ACADEMIA_HIST con ruta explícita, 10 MB iniciales, AUTOEXTEND NEXT 5M y MAXSIZE 40M (con techo).
  En 26ai es bigfile por defecto, con gestión local de extensiones y segmentos AUTO (ASSM).
- Las tres medidas de TBS_ACADEMIA_HIST antes de la carga: asignado 10 MB, libre 3.9 MB y máximo alcanzable 40 MB.
  Para TBS_ACADEMIA: asignado 100 MB, libre 76.8 MB y máximo 1024 MB. No son lo mismo: asignado es lo que ocupan
  los datafiles hoy, libre es lo libre dentro de lo asignado y máximo es hasta donde puede crecer con AUTOEXTEND.
- DBA_TABLESPACE_USAGE_METRICS mide contra el máximo: TBS_ACADEMIA_HIST estaba al 15.16 % y TBS_ACADEMIA al 2.27 %.
  Es la cifra que sirve para alertar y la que usa la lista de turno.
- Los tablespaces no crecen solos, crecen sus segmentos: en TBS_ACADEMIA los que más ocupan son ACA_MATRICULAS
  y su índice UQ_ACA_MATRICULA_UNICA (3 MB cada uno).
- CARGA_HIST es un esquema sin contraseña (NO AUTHENTICATION), sin cuota en su tablespace por defecto.
  La tabla REGISTRO existe pero tiene 0 segmentos (creación diferida): no ocupa nada hasta la primera fila.
- ORA-01950: SYS (que inserta) provoca la creación del segmento, pero el segmento sería de CARGA_HIST,
  que no tiene cuota. Insertó SYS y pagó (le faltaba la cuota) CARGA_HIST: la cuota la paga el dueño del segmento.
- ORA-01536: con QUOTA 2M, 5000 filas de 1 KB no caben. Ampliar el tablespace no lo habría resuelto: el tablespace
  tenía sitio de sobra; lo que faltaba era permiso (cuota) para usarlo.
- ORA-30041: no se puede dar cuota sobre un tablespace temporal (ni de undo).
- El umbral de TBS_ACADEMIA_HIST pasó de NONE a aviso 80 % y crítico 95 % con DBMS_SERVER_ALERT.SET_THRESHOLD,
  para que MMON avise antes de que la carga falle.
- Tres errores, tres remedios: ORA-01950/ORA-01536 falta cuota (ampliar la cuota del dueño) y
  ORA-01653/ORA-01654 falta espacio en el tablespace (ampliar el datafile, subir MAXSIZE o añadir otro).

### F.2 Asignación reanudable (evidencia 05-resumable)
- Con la cuota de partida de 2 MB lancé la carga de APP_ACADEMIA con ALTER SESSION ENABLE RESUMABLE TIMEOUT 180.
  La sentencia no falló: quedó SUSPENDED en CDB_RESUMABLE con ORA-01536 (suspend_time 10:50:04), y la sesión
  mostraba el evento "statement suspended, wait error to be cleared".
- El menor cambio útil fue ampliar la CUOTA de CARGA_HIST a 30 MB y no el tablespace, que tenía sitio.
  La carga se reanudó sola y terminó: inicio 10:50:04 y fin 10:50:23, es decir unos 19 segundos suspendida y 20000 filas.
- El alert log lo dejó escrito: "statement in resumable session 'carga-historico' was suspended due to ..."
  y después "... was resumed".
- Convierte un fallo en una pausa: el DBA tiene 180 s para arreglarlo sin que la aplicación pierda el trabajo.
- Dejé a APP_ACADEMIA permisos temporales (INSERT sobre la tabla y RESUMABLE): es deuda de acceso que se paga en la Parte G.

### F.3 Borrar no devuelve espacio: HWM y SHRINK (evidencia 05-hwm-shrink)
- Antes del DELETE: 20000 filas, 2944 bloques, 23 MB.
- Tras borrar el 90 % (18000 filas): 2000 filas pero siguen 2944 bloques y 23 MB. El segmento no encoge: los bloques
  siguen por debajo de la marca de agua alta (HWM), medio vacíos, y la cuota sigue consumida. Un recorrido completo los lee todos.
- ENABLE ROW MOVEMENT + SHRINK SPACE (compacta en línea, mueve filas y cambia sus ROWID, por eso hace falta ROW MOVEMENT y ASSM):
  2000 filas, 304 bloques y 2.4 MB. La cuota consumida de CARGA_HIST bajó de 23 MB a 2.4 MB.

### Pregunta tipo examen F1
- Respuesta: C (ALTER USER hist QUOTA 100M ON tbshist). El ORA-01536 es de cuota y la paga el dueño del segmento (HIST),
  no quien inserta (APP). Añadir un datafile no resuelve nada: el tablespace ya tenía 500 MB libres.

## Parte G · Gobierno del acceso

### G.1 Perfil, roles, cuenta nominal y deuda (evidencia 06-gobierno-acceso)
- No supongas los valores por defecto: mi perfil DEFAULT tiene FAILED_LOGIN_ATTEMPTS 10, PASSWORD_LIFE_TIME 180,
  PASSWORD_LOCK_TIME 1, PASSWORD_GRACE_TIME 7, INACTIVE_ACCOUNT_TIME 365 y PASSWORD_VERIFY_FUNCTION NULL.
  Es lo que hay que revisar el primer día: sin función de verificación se aceptan contraseñas débiles.
- Creé PRF_PERSONAS para personas: 3 intentos fallidos, bloqueo de 1 minuto (solo en laboratorio; en producción
  1 día o desbloqueo manual), contraseña de 90 días con 7 de gracia, cuenta inactiva a los 90 días y
  ORA12C_VERIFY_FUNCTION. La función rechazó una contraseña corta con ORA-28003 y ORA-20000 (menos de 8 caracteres).
- Roles funcionales: ROL_LECTURA_ACADEMIA (SELECT ANY TABLE ON SCHEMA ADMIN_ACADEMIA, privilegio de esquema de 23ai/26ai:
  lee las tablas actuales y futuras de ese esquema y solo de ese), ROL_SECRETARIA_ACADEMIA (incluye el de lectura y
  UPDATE solo sobre la columna ESTADO de ACA_ESTUDIANTES) y ROL_APP_ACADEMIA (SELECT y UPDATE sobre ACA_ESTUDIANTES).
- Alta nominal: ANA_GARCIA, con el perfil PRF_PERSONAS, el rol ROL_SECRETARIA_ACADEMIA y como único privilegio de sistema CREATE SESSION.
  Una persona, una cuenta: altas y bajas con un solo GRANT/REVOKE de rol.
- Deuda de acceso pagada: APP_ACADEMIA pasó de privilegios sueltos (Parte D) y permisos temporales (INSERT y RESUMABLE de la Parte F)
  a UN rol, ROL_APP_ACADEMIA. Solo conserva CREATE SESSION como privilegio de sistema.

### G.2 Validar con las identidades reales (evidencia 06-probar-acceso)
- Ana entra por freepdb1 y tiene 2 roles activos: ROL_LECTURA_ACADEMIA y ROL_SECRETARIA_ACADEMIA. Lee 20000 estudiantes y
  60000 matrículas, aunque nadie le concedió ACA_MATRICULAS por nombre: lo lee por el privilegio de esquema.
- Puede cambiar el ESTADO de un estudiante (1 row updated, con rollback), pero no su nombre ni borrar: ORA-41900
  "missing UPDATE/DELETE privilege on ADMIN_ACADEMIA.ACA_ESTUDIANTES". En 26ai el error nombra el privilegio que falta;
  en versiones anteriores el mismo caso daba el genérico ORA-01031.
- APP_ACADEMIA sigue funcionando por su rol (lee 17600 estudiantes y actualiza una fila), pero ya no puede insertar en el histórico:
  ORA-00942, porque sin privilegio el objeto ni siquiera existe para ella.
- Tras tres contraseñas erróneas (ORA-01017) la cuenta de Ana pasó a LOCKED(TIMED) y hasta la correcta dio ORA-28000.
  El DBA la desbloqueó con ALTER USER ... ACCOUNT UNLOCK; en producción, antes del UNLOCK se confirma la identidad por otro canal.

### G.3 ADMIN OPTION frente a GRANT OPTION (evidencia 06-cascada)
- Monté dos usuarios temporales: a U6_A le di CREATE SESSION WITH ADMIN OPTION (sistema) y SELECT sobre ACA_ASIGNATURAS
  WITH GRANT OPTION (objeto), y U6_A los repartió a U6_B.
- Al revocar a U6_A los dos privilegios, el de SISTEMA de U6_B sobrevive (CREATE SESSION sigue en U6_B)
  y el de OBJETO de U6_B cae en cascada (0 privilegios de objeto).
- Regla: ADMIN OPTION (sistema y roles) no se propaga al revocar; GRANT OPTION (objeto) sí.
- Limpieza: los usuarios de prueba se borraron (ciclo de vida: también incluye la baja).

### Preguntas tipo examen G1 y G2
- G1. Respuesta: B (solo CREATE TABLE). El privilegio de sistema concedido con ADMIN OPTION no se revoca en cascada,
  mientras que el de objeto con GRANT OPTION sí (SELECT ON hr.emp desaparece de B).
- G2. Respuesta: B. SELECT ANY TABLE ON SCHEMA ventas permite leer todas las tablas actuales y futuras del esquema VENTAS,
  y solo de ese esquema.

## Parte H · Objetos, memoria, archivos críticos y ADR

### H.1 Validez, dependencias, UNUSABLE y papelera (evidencia 07-objetos)
- Trabajé sobre una copia (ACA_EST_LAB6) con dos vistas y una función que dependen de ella; nunca sobre la tabla de negocio.
- Columna nueva que nadie usa (telefono): no se invalidó nada. Oracle registra dependencias de grano fino por columna, no solo por tabla.
- Ampliar email_institucional: solo V_CONTACTO_LAB6 pasó a INVALID, porque es la única que usa esa columna.
- Ampliar nombres: V_ACTIVOS_LAB6 pasó a INVALID y la función F_TOTAL_ACTIVOS_LAB6 también, en cascada.
  DBA_DEPENDENCIES explica la cadena: la función depende de V_ACTIVOS_LAB6, y la vista depende de la tabla.
- Cuando un usuario llamó a la función (17600 activos), Oracle la recompiló sola y también a V_ACTIVOS_LAB6; funciona,
  pero lo paga ese usuario en su llamada, quizá en hora punta. V_CONTACTO_LAB6, que nadie había usado, siguió INVALID.
- UTL_RECOMP.RECOMP_SERIAL('ADMIN_ACADEMIA') la dejó VALID: el DBA recompila antes de abrir el servicio.
- ALTER TABLE ... MOVE cambia los ROWID y dejó el índice IX_EST_LAB6_ESTADO UNUSABLE sin dar error: las consultas dejan
  de usarlo en silencio. ALTER INDEX ... REBUILD ONLINE lo devolvió a VALID.
- Papelera: DROP sin PURGE no libera espacio (el índice 0.5 MB y la tabla 2 MB quedaron en DBA_RECYCLEBIN);
  PURGE TABLE la dejó en 0. Validación final: 0 objetos inválidos en los esquemas de negocio.

### H.2 La memoria y sus advisors (evidencia spool 07-memoria)
- SGA: máximo 1529 MB, buffer cache 896 MB, shared pool 592 MB, Shared IO Pool 80 MB y large pool 16 MB.
  Con ASMM, 0 movimientos entre componentes desde el arranque: no ha movido memoria.
- PGA: objetivo agregado 512 MB, 356 MB en uso y 437 MB asignados; over allocation count 0 y cache hit 100 %.
  Los procesos que más PGA usan en mi salida son M002 (32.3 MB), M007 (25.7 MB) y M006 (25 MB), junto a los ARCn.
- Advisor de SGA: duplicar la SGA (factor 2, 3072 MB) deja el DB time estimado en 1 (sin mejora) y las lecturas
  físicas en 34957 igual que ahora; reducirla a la mitad (768 MB) subiría el DB time estimado a 1.2151 y las lecturas físicas a 49097.
  Conclusión: duplicar la SGA no ahorraría ni un segundo de DB time.
- Advisor de PGA: con 128 y 256 MB habría sobreasignaciones (OVERALLOC 7, acierto del 69 %); con 384 MB ya no (0, 100 %).
  Es decir, por debajo de unos 384 MB la PGA tendría sobreasignaciones; la actual (512 MB) está bien.
- No se cambia la memoria por intuición: se pregunta al advisor antes.

### H.3 Inventario de archivos críticos (evidencia 07-archivos-criticos)
- Control files: tres copias (control01.ctl, control02.ctl y control03.ctl en /opt/oracle/oradata/FREE).
- Redo en línea: 3 grupos de 200 MB con 2 miembros cada uno (redo0Xb.log como segunda copia); el grupo 2 es el CURRENT
  y los grupos 1 y 3 están INACTIVE y archivados.
- SPFILE y password file viven en dbs/, que es un enlace simbólico al volumen (/opt/oracle/oradata/dbconfig/FREE/dbs):
  por eso sobreviven a recrear el contenedor.
- FRA: 453 MB usados de 4096 MB. La base está en ARCHIVELOG con 25 redo archivados en disco.
- Copia RMAN: la última pieza es de 2026-11-23 10:56 y hay 10 piezas; una base sin copia reciente es una alarma aunque todo funcione.
- Solo SYS puede conectarse con SYSDBA y SYSOPER por el password file.

### H.4 El ADR y la traza de la sesión de otro usuario (evidencia 07-adr-trazas)
- El ADR cuelga de /opt/oracle (ADR Base) y su home es /opt/oracle/diag/rdbms/free/FREE. El alert log existe dos veces:
  en texto (trace/alert_FREE.log) y en XML (alert/log.xml), que es el que lee V$DIAG_ALERT_EXT. Hay 642 trazas en trace/.
- Un problema agrupa los incidentes del mismo error crítico: el problema 1 es ORA 800 (Set Priority Failed) con 38 incidentes,
  el ruido conocido de los contenedores Linux. ADRCI está disponible en mi imagen y lista los mismos datos.
- Con DBMS_MONITOR.SESSION_TRACE_ENABLE traza la sesión 62,23683 de APP_ACADEMIA sin pedirle nada y sin reiniciar;
  tracefile_identifier puso lab6_app en el nombre del archivo (FREE_ora_3746_lab6_app.trc).
- En la traza en bruto aparecen PARSING (la sentencia), EXEC, FETCH y WAIT (evento 'PL/SQL lock timer').
  La consulta de la aplicación (SELECT COUNT(*) ... estado = 'ACTIVO') necesitó 247 lecturas lógicas: lo dice la línea
  FETCH con cr=247, y tkprof lo confirma con query = 247 para devolver 1 fila.

### Pregunta tipo examen H1
- Respuesta: B. Tras un ALTER TABLE ... MOVE los índices quedan UNUSABLE sin dar error, y el optimizador los ignora:
  por eso las consultas por cliente van lentas. La tabla no queda INVALID y no se pierden estadísticas.
## Parte I · Guardia nocturna

### Pregunta 20: una línea por incidente
- INC-601 (secretaría colgada). Evidencia clave: en la consulta 1 del diagnóstico la sesión 227 (ANA_GARCIA) esperaba 28 s en enq: TX - row lock contention, bloqueada por el SID 63 (APP_ACADEMIA, módulo matriculas, acción cierre-periodo); la consulta 4 decía que solo se deshacían 1 bloque y 1 registro de undo.
  Intervención: ALTER SYSTEM KILL SESSION '63,64045' IMMEDIATE, solo la sesión bloqueadora.
  Validación: la fila 101 quedó en ACTIVO y no había sesiones bloqueadas.
- INC-602 (ORA-12514). Evidencia clave: en la consulta 6, academia_app existía pero con ARRANCADO = NO mientras FREEPDB1 estaba en SI, así que la base estaba bien y el listener no anunciaba el servicio.
  Intervención: DBMS_SERVICE.START_SERVICE('academia_app') y después ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE.
  Validación: V$ACTIVE_SERVICES mostró academia_app, el listener lo anunció en READY y APP_ACADEMIA entró por ese servicio y leyó 17600 estudiantes.
- INC-603 (ORA-28000). Evidencia clave: en la consulta 7, APP_ACADEMIA salía LOCKED y no LOCKED(TIMED), con perfil DEFAULT y 10 intentos permitidos, así que no fue por fallar la contraseña sino un bloqueo manual del script de bajas.
  Intervención: ALTER USER app_academia ACCOUNT UNLOCK, sin cambiar la contraseña.
  Validación: la cuenta pasó a OPEN y APP_ACADEMIA entró por academia_app con ROL_APP_ACADEMIA y leyó 17600 estudiantes.

## Simulacro de examen 1Z0-182
Formato: letra y Parte del laboratorio donde lo comprobé.
- S1: B (Parte B y F). Las alertas de umbral de espacio las genera MMON, no un trabajo del Scheduler.
- S2: C (Parte C). Con DEFERRED el cambio solo vale para las sesiones que se conecten después.
- S3: B (Parte C). CREATE PFILE FROM MEMORY incluye también lo que calcula Oracle: mi copia tuvo 125 líneas frente a 34 del SPFILE.
- S4: B y C (Parte C). OPEN READ WRITE FORCE o cerrar y volver a abrir; el OPEN READ WRITE a secas dio ORA-65019.
- S5: C (Parte C). DBA_PDB_SAVED_STATES guarda el estado de cada PDB.
- S6: B (Parte C). Sin RESTRICTED SESSION sale ORA-01035.
- S7: A (Parte D). DBMS_SERVICE creó y arrancó academia_app.
- S8: B (Parte D). V$SESSION.PADDR = V$PROCESS.ADDR.
- S9: C (Parte D). CANCEL SQL corta la llamada pero la transacción sigue abierta.
- S10: C (Parte D). Como SYSOPER el usuario es PUBLIC y por eso no veía DBA_USERS (ORA-00942).
- S11: B (Parte E). V$CON_SYSMETRIC; V$SYSMETRIC sale vacía dentro de una PDB.
- S12: A y C (Parte E). DB time suma CPU y esperas no Idle de las sesiones de primer plano.
- S13: B (Parte F). La cuota la paga el dueño del segmento, no quien inserta; con CARGA_HIST pasó igual.
- S14: A y C (Parte F). No se concede cuota sobre undo ni sobre temporal (ORA-30041 con TEMP).
- S15: A y C (Parte F). La sentencia se suspende hasta el timeout y se ve en DBA_RESUMABLE.
- S16: B (Parte F). SHRINK SPACE exige ENABLE ROW MOVEMENT y ASSM.
- S17: B (Parte G). Con intentos fallidos el estado es LOCKED(TIMED).
- S18: B (Parte G). Con ADMIN OPTION la revocación no cae en cascada.
- S19: A y B (Parte H). MOVE sin UPDATE INDEXES y ALTER INDEX ... UNUSABLE.
- S20: B (Parte H). DBMS_MONITOR.SESSION_TRACE_ENABLE, como hice con la sesión 62,23683.
- S21: C (Parte H). DIAGNOSTIC_DEST fija la raíz del ADR (/opt/oracle).
- S22: C (Parte I). Primero identificar al bloqueador y qué hace, como en INC-601.
