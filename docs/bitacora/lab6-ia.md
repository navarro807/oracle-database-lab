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
