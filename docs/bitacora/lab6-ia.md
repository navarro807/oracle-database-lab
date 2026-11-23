He leído la política de uso de IA de la asignatura.

# Declaración de uso de IA · Lab 6 · E048

Autor: Juan Francisco Navarro Cruz (E048)

## Entrada 1
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
Tengo que hacer un trabajo de bases de datos y este es el enunciado.
Mi nombre es Juan Francisco Navarro Cruz. Mi número de estudiante es E048.
Quiero que me guíes paso a paso para hacerlo y me vayas dando
los códigos para copiar y pegar.
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
-- Preparación (Partes A.1 a A.3), comandos de terminal:
cp -r "$RUTA/scripts" "$RUTA/docs" .
source scripts/deployment/env/00-config.sh
mkdir -p $EVID_LAB6/{script,spool,config}
chmod +x scripts/lab6/*.sh scripts/ops/*.sh
printf "ESTUDIANTE='E048'..." >> config/.env
bash scripts/ops/alumno.sh
bash scripts/ops/backup-estado.sh lab6-inicio
```
- **Dónde lo usé (parte, script o pregunta):** Parte A, apartados A.1 a A.5.
- **Propósito (para qué lo necesitaba):** Preparar el entorno: copiar el kit, crear las carpetas de evidencia, guardar mi código y las contraseñas fuera de Git y hacer la copia del punto de partida.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  cp copia las carpetas scripts y docs del kit al repositorio.
  source carga las variables de 00-config.sh, entre ellas EVID_LAB6.
  mkdir crea las carpetas de evidencia y chmod da permiso de ejecución a los scripts.
  printf añade mi código y las contraseñas de las cuentas nuevas a config/.env, que está fuera de Git.
  alumno.sh genera login.sql con mi código en el prompt y muestra la cabecera de las evidencias.
  backup-estado.sh para la base de forma limpia, copia el volumen y la vuelve a arrancar.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/00-backup-lab6-inicio.script.log

## Entrada 2
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
recuerda que si hay que hacer en algun momento algun .md con cosas escritas
o lo que sea tienes que hacerlo tu, osea absolutamente todo tienes que hacerlo tu
y avisarme de cuando se hace y todo eso, yo solo copio y pego todo
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/ops/ro.sh scripts/ops/turno.sql | tee $EVID_LAB6/script/01-turno.script.log
bash scripts/ops/ro.sh scripts/lab6/01-automatizacion.sql freepdb1
```
- **Dónde lo usé (parte, script o pregunta):** Parte B, apartados B.1 y B.2.
- **Propósito (para qué lo necesitaba):** Ejecutar la lista de turno y revisar el mantenimiento automático de Oracle, y redactar mis respuestas de la Parte B.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  ro.sh entra con la cuenta de solo lectura C##OPS_RO y ejecuta el script SQL que le paso.
  turno.sql hace las 7 preguntas de turno: dónde estoy, estado de instancia y base, PDB abiertas,
  errores ORA- de 24 h, tablespaces por encima del 85 %, sesiones bloqueadas y alertas pendientes.
  01-automatizacion.sql entra por freepdb1 y muestra AutoTask, ventanas, umbrales MMON, AWR y Scheduler.
  tee guarda en un archivo lo mismo que se ve en pantalla, como evidencia.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/01-turno.script.log

## Entrada 3
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
estas usando todo lo que pide el pdf del profesor y la carpeta que nos ha adjuntado
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/lab6/02-pfile-so.sh preparar
bash scripts/ops/sysdba.sh scripts/lab6/02-parametros.sql
```
- **Dónde lo usé (parte, script o pregunta):** Parte C, apartado C.1.
- **Propósito (para qué lo necesitaba):** Entender de dónde sale la instancia y dónde queda un cambio de parámetro (memoria, archivo o ambos).
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  02-pfile-so.sh crea en el volumen la carpeta para las copias de seguridad de los parámetros.
  02-parametros.sql, como SYSDBA, crea dos PFILE en texto (desde SPFILE y desde MEMORY).
  Prueba db_files (estático): MEMORY da ORA-02095; SPFILE se acepta pero solo vale al reiniciar; RESET lo deshace.
  Intenta cambiar processes dentro de FREEPDB1 y da ORA-65040.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/02-parametros.script.log

## Entrada 4
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
quiero que me hagas el trabajo entero y yo voy copiando y pegando todo lo que me digas
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/lab6/02-estados-pdb.sh | tee $EVID_LAB6/script/02-estados-pdb.script.log
```
- **Dónde lo usé (parte, script o pregunta):** Parte C, apartado C.2.
- **Propósito (para qué lo necesitaba):** Pasar FREEPDB1 por sus estados y comprobar el efecto de SAVE STATE tras un reinicio.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  El script cierra FREEPDB1 y la abre en READ ONLY (se puede leer, escribir da ORA-16000).
  Intenta abrirla en READ WRITE sin cerrar (ORA-65019) y usa FORCE para hacerlo en un solo paso.
  La abre en RESTRICTED y comprueba que C##OPS_RO no entra (ORA-01035).
  Hace DISCARD STATE y reinicia la instancia: FREEPDB1 queda MOUNTED y falla con ORA-01109.
  Después la abre, hace SAVE STATE y reinicia otra vez: ahora vuelve sola a READ WRITE.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/02-estados-pdb.script.log

## Entrada 5
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
quiero que me hagas el trabajo entero y yo voy copiando y pegando todo lo que me digas
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/ops/ro.sh scripts/ops/validar-arranque.sql freepdb1 | tee $EVID_LAB6/script/02-validar-arranque.script.log
```
- **Dónde lo usé (parte, script o pregunta):** Parte C, apartado C.3 y preguntas C1 y C2.
- **Propósito (para qué lo necesitaba):** Validar que la base está arriba desde el servicio de la PDB, como lo haría la aplicación.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  validar-arranque.sql, con la cuenta de solo lectura, muestra por dónde he entrado (contenedor y servicio),
  el estado de la instancia y la base, el modo de cada PDB y su estado guardado, los servicios activos,
  los errores ORA- del alert log desde el último arranque y los datafiles que no están ONLINE.
  Si todo coincide con lo esperado, la base está arriba para el consumidor.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/02-validar-arranque.script.log

## Entrada 6
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
quiero que me hagas el trabajo entero y yo voy copiando y pegando todo lo que me digas
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/ops/sysdba.sh scripts/lab6/03-servicio.sql
bash scripts/lab6/03-cuenta-app.sh
bash scripts/lab6/03-sesiones.sh
```
- **Dónde lo usé (parte, script o pregunta):** Parte D, apartados D.1, D.2 y D.3 y pregunta D1.
- **Propósito (para qué lo necesitaba):** Crear un servicio por aplicación, su cuenta local y ver una sesión de principio a fin.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  03-servicio.sql crea y arranca el servicio academia_app en FREEPDB1 con DBMS_SERVICE y guarda el estado.
  03-cuenta-app.sh crea APP_ACADEMIA como cuenta local con la contraseña de config/.env y le da CREATE SESSION
  y SELECT, UPDATE sobre aca_estudiantes.
  03-sesiones.sh abre una sesión de la aplicación por el servicio, la observa en V$SESSION y V$PROCESS,
  usa CANCEL SQL (cae la llamada, la transacción sigue) y KILL SESSION (cae la sesión y se deshace el UPDATE).
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/03-sesiones.script.log

## Entrada 7
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
quiero que me hagas el trabajo entero y yo voy copiando y pegando todo lo que me digas
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/lab6/04-tres-miradas.sh
bash scripts/ops/ro.sh scripts/lab6/04-diccionario.sql
bash scripts/ops/sysdba.sh scripts/lab6/04-deltas.sql
```
- **Dónde lo usé (parte, script o pregunta):** Parte E, apartados E.1, E.2 y E.3 y pregunta E1.
- **Propósito (para qué lo necesitaba):** Entender por qué la misma consulta devuelve cifras distintas según la identidad y el contenedor, y medir una carga con deltas.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  04-tres-miradas.sh ejecuta la misma consulta con C##OPS_RO en la raíz, C##OPS_RO en FREEPDB1 y APP_ACADEMIA,
  y compara USER_, ALL_, DBA_, CDB_ y V$.
  04-diccionario.sql cuenta las tablas X$ y las vistas V$ y GV$, enseña que V$INSTANCE es GV$INSTANCE filtrada,
  que lo que escribo son sinónimos públicos y cómo buscar una vista con DBA_TAB_COMMENTS.
  04-deltas.sql toma una foto de V$SYS_TIME_MODEL y V$SYSSTAT, ejecuta 10 recorridos completos de PEDIDO,
  toma otra foto y resta para saber el DB time, la CPU y las lecturas lógicas de la carga.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/04-deltas.script.log

## Entrada 8
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
quiero que me hagas el trabajo entero y yo voy copiando y pegando todo lo que me digas
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/ops/sysdba.sh scripts/lab6/05-almacenamiento.sql
bash scripts/lab6/05-resumable.sh
bash scripts/ops/sysdba.sh scripts/lab6/05-hwm-shrink.sql
```
- **Dónde lo usé (parte, script o pregunta):** Parte F, apartados F.1, F.2 y F.3 y pregunta F1.
- **Propósito (para qué lo necesitaba):** Crear un tablespace con techo, medir el espacio, provocar errores de cuota y recuperar espacio.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  05-almacenamiento.sql crea TBS_ACADEMIA_HIST con MAXSIZE 40M, mide asignado, libre y máximo, crea CARGA_HIST sin cuota,
  provoca ORA-01950 y ORA-01536, prueba ORA-30041 y fija el umbral de alerta al 80 % y 95 %.
  05-resumable.sh lanza una carga con RESUMABLE que se suspende por falta de cuota y se reanuda al ampliarla.
  05-hwm-shrink.sql borra el 90 % de las filas, comprueba que el segmento no encoge y lo compacta con SHRINK SPACE.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/05-resumable.script.log

## Entrada 9
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
quiero que me hagas el trabajo entero y yo voy copiando y pegando todo lo que me digas
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/lab6/06-gobierno-acceso.sh
bash scripts/lab6/06-probar-acceso.sh
bash scripts/lab6/06-cascada.sh
```
- **Dónde lo usé (parte, script o pregunta):** Parte G, apartados G.1, G.2 y G.3 y preguntas G1 y G2. La IA redactó también borradores de las respuestas de las Partes B a G en lab6-respuestas.md.
- **Propósito (para qué lo necesitaba):** Montar el gobierno del acceso (perfil, roles, cuenta nominal, deuda pagada, cascada) y tener un borrador de las respuestas.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  06-gobierno-acceso.sh crea el perfil PRF_PERSONAS, los roles funcionales, la cuenta nominal ANA_GARCIA y cambia los privilegios
  sueltos de APP_ACADEMIA por un solo rol, retirando los permisos temporales de la Parte F.
  06-probar-acceso.sh entra como Ana y como la aplicación para comprobar lo que pueden y no pueden hacer, y provoca el bloqueo
  de Ana con tres contraseñas erróneas.
  06-cascada.sh crea dos usuarios temporales para ver que revocar ADMIN OPTION no se propaga y revocar GRANT OPTION sí.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/06-probar-acceso.script.log

## Entrada 10
- **Herramienta:** Perplexity (asistente de IA)
- **Prompt (literal, copiado tal cual):**
```text
quiero que me hagas el trabajo entero y yo voy copiando y pegando todo lo que me digas
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
bash scripts/ops/sysdba.sh scripts/lab6/07-objetos.sql
bash scripts/ops/ro.sh scripts/lab6/07-memoria.sql
bash scripts/ops/ro.sh scripts/lab6/07-archivos-criticos.sql
bash scripts/lab6/07-adr-trazas.sh
```
- **Dónde lo usé (parte, script o pregunta):** Parte H, apartados H.1 a H.4 y pregunta H1. La IA redactó también el borrador de las respuestas de la Parte H.
- **Propósito (para qué lo necesitaba):** Vigilar objetos inválidos e índices UNUSABLE, leer la memoria y sus advisors, inventariar los archivos críticos y trazar la sesión de otro usuario.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):**
  07-objetos.sql crea una copia de la tabla con dos vistas y una función, cambia columnas y mira qué objetos pasan a INVALID,
  los recompila con UTL_RECOMP, deja un índice UNUSABLE con un MOVE, lo reconstruye con REBUILD ONLINE y vacía la papelera.
  07-memoria.sql lee V$SGAINFO, V$PGASTAT y los advisors de SGA y PGA para decidir si cambiar la memoria.
  07-archivos-criticos.sql lista control files, redo, SPFILE, password file, FRA y copias RMAN.
  07-adr-trazas.sh enseña el ADR y activa con DBMS_MONITOR la traza de la sesión de APP_ACADEMIA para ver sus lecturas con tkprof.
- **Evidencia de ejecución (archivo de docs/bitacora/lab6/evidencia con mi cabecera):**
  docs/bitacora/lab6/evidencia/script/07-adr-trazas.script.log
