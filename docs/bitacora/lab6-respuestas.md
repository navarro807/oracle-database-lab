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
