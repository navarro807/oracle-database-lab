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
