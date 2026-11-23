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
