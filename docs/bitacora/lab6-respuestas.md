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
