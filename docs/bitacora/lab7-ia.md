He leído la política de uso de IA de la asignatura.

# Declaración de uso de IA · Lab 7 · E048

## Entrada 1
- **Herramienta:** Perplexity (chat de IA, sin agente; los comandos y los commits los ejecuto yo desde mi terminal)
- **Prompt (literal, copiado tal cual):**
```text
vale, pues ya que te ha quedado claro todo de que puedo usar la IA para todo, vas a ir paso a paso revisando el pdf de 117 paginas y dandome los codigos para copiar y pegar y yo te paso la salida de todos los comandos para que luego a la hora de darme los postmortem y todo eso que tengas que hacer de manera "personal" pues pongas todo lo que hemos ido recopilando. Recuerda, yo solo voy a copiar y pegar comandos, tu tienes que encargarte de que absolutamente todo el trabajo este correctamente hecho y completo. Recuerda tambien que tenemos una carpeta que ha subido el profesor para usar su repo y hay un reedme tambien osea revisemos todo eso bien en el ubuntu y usemos todo lo que me ha dado el profesor. Ahora si, empecemos, recuerda todo paso a paso me das codigo y yo te doy la salida
```
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
cp -r "$K"/. .                              # K = carpeta repo-kit de Descargas
bash scripts/t6/instalar.sh
bash scripts/ops/backup-estado.sh lab7-inicio
bash scripts/ops/alumno.sh
cp docs/plantillas/IA.md docs/bitacora/lab7-ia.md && sed -i "s/E0NN/E048/g" docs/bitacora/lab7-ia.md
caso --preparar
caso --lista
t6 salud
```
- **Dónde lo usé (parte, script o pregunta):** Parte A (A.1 a A.5): kit, instalación, copia lab7-inicio, código E048 y banco T6.
- **Propósito (para qué lo necesitaba):** Preparar el punto de partida del laboratorio paso a paso y dejar la base y el kit comprobados antes de empezar los casos.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** Copia el kit del profesor (scripts/t6, scripts/lab7, plantillas y .env.example) a mi repositorio sin tocar mi config/.env. instalar.sh no cambia la base: comprueba Docker, la instancia, FREEPDB1, ARCHIVELOG, las 2 CPU, TIENDASUR y mi código E048, y crea los alias caso, t6 e incidente. backup-estado.sh para el contenedor, copia el volumen con sumas SHA-256 y lo vuelve a arrancar: es mi punto de restauración lab7-inicio. alumno.sh valida E048 y fija el prompt de SQL*Plus/SQLcl y la cabecera de las evidencias. caso --preparar crea el esquema T6 (copia de TiendaSur con 1 millón de pedidos) y la cuenta T6_APP con estadísticas sin histogramas. caso --lista muestra los 23 casos (10 evaluables) y t6 salud mide AAS frente a CPU_COUNT y las esperas del ASH.
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** docs/bitacora/lab7/evidencia/casos/20261125T183732Z_00_preparar.txt

## Entrada 2
- **Herramienta:** Perplexity (chat de IA, sin agente; los comandos y los commits los ejecuto yo desde mi terminal)
- **Prompt (literal, copiado tal cual):**
```text
pero vamos a ver, que estas haciendo tio. Esto del apartado B no lo he puesto y estas con algo de C01, que estas haciendo? me estoy perdiendo, esto no lo he puesto:
```
(En ese mensaje pegué después un fragmento de la respuesta anterior; el resto de la conversación fue pegar la salida de cada comando que me pidió.)
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
caso C01 provocar
caso C01 entender
caso C01 diagnosticar
caso C01 solucionar
caso C01 validar
caso C01 observar
```
Además, el texto de las respuestas de C01 en docs/bitacora/lab7-respuestas.md (apartado Parte B · C01), redactado por la IA a partir de mis salidas reales.
- **Dónde lo usé (parte, script o pregunta):** Parte B, caso C01, y las tres preguntas de C01 de lab7-respuestas.md.
- **Propósito (para qué lo necesitaba):** Ejecutar las seis fases de C01 en mi contenedor y redactar las respuestas con mis cifras.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** provocar lanza carga con 1 y con 8 sesiones; entender saca llamadas por segundo y p50/p95 de cada tanda; diagnosticar compara el AAS con CPU_COUNT = 2 y muestra que con 8 sesiones el 72 % de las muestras de ASH está en resmgr:cpu quantum (cola de CPU); solucionar dimensiona el pool a 2 sesiones y registra la línea base del panel en T6.LINEA_BASE; validar comprueba que con 2 sesiones se atiende lo mismo que con 8 y que la p95 baja de 1 370 ms a 269 ms; observar verifica la ley de Little con las tres tandas.
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** docs/bitacora/lab7/evidencia/casos/20261125T184515Z_C01_provocar.txt, 20261125T184517Z_C01_entender.txt, 20261125T184636Z_C01_diagnosticar.txt, 20261125T184720Z_C01_solucionar.txt, 20261125T184721Z_C01_validar.txt y 20261125T184723Z_C01_observar.txt
