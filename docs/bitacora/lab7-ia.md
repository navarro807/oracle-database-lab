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

## Entrada 3
- **Herramienta:** Perplexity (chat de IA, sin agente; los comandos y los commits los ejecuto yo desde mi terminal)
- **Prompt (literal, copiado tal cual):**
```text
cd ~/oracle-database-lab
source ~/.bashrc
caso C03 provocar
caso C03 entender
caso C03 diagnosticar
caso C03 solucionar
caso C03 validar
caso C03 observar
```
(Es el comienzo de mi mensaje; después pegué la salida completa de cada comando. Hice lo mismo con C04.)
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
caso C03 provocar && entender && diagnosticar && solucionar && validar && observar
caso C04 provocar && entender && diagnosticar && solucionar && validar && observar
```
Además, el texto de las respuestas de C03 y C04 en docs/bitacora/lab7-respuestas.md (apartados Parte C · C03 y Parte C · C04), redactado por la IA a partir de mis salidas reales.
- **Dónde lo usé (parte, script o pregunta):** Parte C, casos C03 y C04, y las cuatro preguntas de esos casos en lab7-respuestas.md.
- **Propósito (para qué lo necesitaba):** Ejecutar las seis fases de C03 y C04 en mi contenedor y redactar las respuestas con mis cifras.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** C03: provocar lanza 5 000 fichas con el id pegado en el texto (literales) y vacía la shared pool; entender mide el coste por ficha y los cursores de un solo uso; diagnosticar cuenta los hard parses, el tiempo de análisis y la FORCE_MATCHING_SIGNATURE; solucionar repite con variable de enlace; validar compara hard parses, tiempo y cursores; observar prueba CURSOR_SHARING = FORCE como parche. C04: provocar crea un disparador de logon que fuerza workarea_size_policy = MANUAL y sort_area_size = 1 MB y lanza el informe de 1 000 000 de pedidos, que desborda a TEMP (1 PASS); diagnosticar muestra el área de trabajo y el disparador; solucionar borra el disparador y compara el informe completo con un TOP 100 (FETCH FIRST 100 ROWS); validar comprueba que no hay disparador, que el TOP 100 no toca TEMP y que se ordena en memoria (OPTIMAL).
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** docs/bitacora/lab7/evidencia/casos/20261125T185005Z_C03_provocar.txt, 20261125T185007Z_C03_entender.txt, 20261125T185009Z_C03_diagnosticar.txt, 20261125T185011Z_C03_solucionar.txt, 20261125T185013Z_C03_validar.txt, 20261125T185015Z_C03_observar.txt, 20261125T185118Z_C04_provocar.txt, 20261125T185120Z_C04_entender.txt, 20261125T185124Z_C04_diagnosticar.txt, 20261125T185132Z_C04_solucionar.txt, 20261125T185135Z_C04_validar.txt y 20261125T185139Z_C04_observar.txt

## Entrada 4
- **Herramienta:** Perplexity (chat de IA, sin agente; los comandos y los commits los ejecuto yo desde mi terminal)
- **Prompt (literal, copiado tal cual):**
```text
vale ya hemos vuelto, vamos a seguir por donde lo dejamos, mira la salida:
```
(Es el comienzo de mi mensaje; después pegué la salida de arrancar el contenedor. En el siguiente mensaje pegué la salida completa de los comandos de C07 y C08.)
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
for c in C07 C08; do for f in provocar entender diagnosticar solucionar validar observar; do caso $c $f; done; done
```
Además, el texto de las respuestas de C07 y C08 en docs/bitacora/lab7-respuestas.md (apartados Parte D · C07 y Parte D · C08), redactado por la IA a partir de mis salidas reales.
- **Dónde lo usé (parte, script o pregunta):** Parte D, casos C07 y C08, y las cuatro preguntas de esos casos en lab7-respuestas.md.
- **Propósito (para qué lo necesitaba):** Ejecutar las seis fases de C07 y C08 en mi contenedor y redactar las respuestas con mis cifras.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** C07: provocar lanza 40 búsquedas de la web con la variable de tipo NUMBER contra la columna CODIGO_POSTAL (VARCHAR2); entender compara EXPLAIN PLAN, que predice el índice, con la latencia real; diagnosticar muestra con DISPLAY_CURSOR el filter(TO_NUMBER(CODIGO_POSTAL)=:B1) y el TABLE ACCESS FULL; solucionar lanza la versión V2 con la variable VARCHAR2 y recupera el INDEX RANGE SCAN; validar compara lecturas y p95. C08: provocar ejecuta un listado con ciudad y comunidad; entender compara los 56 clientes reales con la estimación independiente (2,9); diagnosticar usa GATHER_PLAN_STATISTICS y E-Rows x Starts frente a A-Rows para ver que la primera línea que se desvía es la de CLIENTE; solucionar crea el grupo de columnas con DBMS_STATS.CREATE_EXTENDED_STATS sobre (CIUDAD, COMUNIDAD) y recoge estadísticas con no_invalidate => FALSE; validar comprueba que la estimación pasa de 3 a 50.
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** docs/bitacora/lab7/evidencia/casos/20261126T144000Z_C07_provocar.txt, 20261126T144002Z_C07_entender.txt, 20261126T144004Z_C07_diagnosticar.txt, 20261126T144006Z_C07_solucionar.txt, 20261126T144008Z_C07_validar.txt, 20261126T144009Z_C07_observar.txt, 20261126T144012Z_C08_provocar.txt, 20261126T144014Z_C08_entender.txt, 20261126T144016Z_C08_diagnosticar.txt, 20261126T144018Z_C08_solucionar.txt, 20261126T144020Z_C08_validar.txt y 20261126T144021Z_C08_observar.txt

## Entrada 5
- **Herramienta:** Perplexity (chat de IA, sin agente; los comandos y los commits los ejecuto yo desde mi terminal)
- **Prompt (literal, copiado tal cual):**
```text
cd ~/oracle-database-lab
source ~/.bashrc
t6 fra
for c in C12 C13 C14; do for f in provocar entender diagnosticar solucionar validar observar; do caso $c $f; done; done
ls -lt docs/bitacora/lab7/evidencia/casos | head -20
```
(Es el comienzo de mi mensaje; después pegué la salida completa de los comandos.)
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
for c in C12 C13 C14; do for f in provocar entender diagnosticar solucionar validar observar; do caso $c $f; done; done
```
Además, el texto de las respuestas de C12, C13 y C14 en docs/bitacora/lab7-respuestas.md (apartados Parte E · C12, C13 y C14), redactado por la IA a partir de mis salidas reales.
- **Dónde lo usé (parte, script o pregunta):** Parte E, casos C12, C13 y C14, y las seis preguntas de esos casos en lab7-respuestas.md.
- **Propósito (para qué lo necesitaba):** Ejecutar las seis fases de C12, C13 y C14 en mi contenedor y redactar las respuestas con mis cifras.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** C12: carga 200 000 filas en CARRITO sin recoger estadísticas (el optimizador cree que tiene 100), diagnostica el NESTED LOOPS de 212 169 lecturas con el plan real y STALE_STATS, y lo arregla recogiendo solo CARRITO con DBMS_STATS.GATHER_TABLE_STATS(no_invalidate => FALSE), que pasa a HASH JOIN con 5 907 lecturas. C13: pasa 135 277 pedidos a estado E; PUBLISH = FALSE deja las estadísticas nuevas como pendientes, se prueban en mi sesión con optimizer_use_pending_statistics = TRUE, se publican con PUBLISH_PENDING_STATS, se restauran con RESTORE_TABLE_STATS desde el historial y se bloquean con LOCK_TABLE_STATS (la recogida posterior da ORA-20005). C14: crea el índice (estado, canal, fecha_pedido) INVISIBLE ONLINE, lo prueba solo en mi sesión con optimizer_use_invisible_indexes = TRUE, lo publica con ALTER INDEX VISIBLE y mide el redo con el índice invisible y visible.
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** docs/bitacora/lab7/evidencia/casos/20261126T144331Z_C12_provocar.txt, 20261126T144333Z_C12_entender.txt, 20261126T144335Z_C12_diagnosticar.txt, 20261126T144338Z_C12_solucionar.txt, 20261126T144340Z_C12_validar.txt, 20261126T144342Z_C12_observar.txt, 20261126T144350Z_C13_provocar.txt, 20261126T144352Z_C13_entender.txt, 20261126T144356Z_C13_diagnosticar.txt, 20261126T144407Z_C13_solucionar.txt, 20261126T144409Z_C13_validar.txt, 20261126T144447Z_C13_observar.txt, 20261126T144457Z_C14_provocar.txt, 20261126T144500Z_C14_entender.txt, 20261126T144502Z_C14_diagnosticar.txt, 20261126T144518Z_C14_solucionar.txt, 20261126T144520Z_C14_validar.txt y 20261126T144544Z_C14_observar.txt

## Entrada 6
- **Herramienta:** Perplexity (chat de IA, sin agente; los comandos y los commits los ejecuto yo desde mi terminal)
- **Prompt (literal, copiado tal cual):**
```text
cd ~/oracle-database-lab
source ~/.bashrc
t6 fra
for f in provocar entender diagnosticar solucionar validar observar; do caso C18 $f; done
t6 awr lista
ls -lt docs/bitacora/lab7/evidencia/casos | head -8
```
(Es el comienzo de mi mensaje; después pegué la salida completa. Hice lo mismo con C17 usando caso C17.)
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```bash
for f in provocar entender diagnosticar solucionar validar observar; do caso C17 $f; done
for f in provocar entender diagnosticar solucionar validar observar; do caso C18 $f; done
t6 awr lista
```
Además, el texto de las respuestas de C17 y C18 en docs/bitacora/lab7-respuestas.md (apartados Parte F · C17 y Parte F · C18), redactado por la IA a partir de mis salidas reales.
- **Dónde lo usé (parte, script o pregunta):** Parte F, casos C17 y C18, y las cuatro preguntas de esos casos en lab7-respuestas.md.
- **Propósito (para qué lo necesitaba):** Resolver INC-604 con el método de ocho pasos y proteger un plan bueno con SPM, y redactar las respuestas con mis cifras.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** C17: provocar toma una instantánea AWR, lanza 120 s de carga con la V1 (3 sesiones) y otra instantánea, y registra la línea base; entender mide el SLI (p95) frente al SLO de 20 ms; diagnosticar usa ASH (quién y en qué), AWR (qué SQL pesa), ADDM (lo cuantifica) y el plan real con el filtro TO_NUMBER; solucionar despliega la V2 (parámetro VARCHAR2), un solo cambio; validar repite la misma carga y comprueba p95, capacidad, lecturas por ejecución y uso del índice. C18: provocar simula el lunes (con histograma) y el martes (sin histograma, tras la recogida nocturna); diagnosticar muestra el plan nuevo y que el histograma de ESTADO ha desaparecido; solucionar carga el plan del lunes desde AWR con DBMS_SPM.LOAD_PLANS_FROM_AWR como línea base aceptada y activa; validar comprueba que el informe usa la línea base con 189 lecturas; observar ejecuta la evolución y muestra que el plan nuevo no se acepta.
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** docs/bitacora/lab7/evidencia/casos/20261126T145410Z_C17_provocar.txt, 20261126T145412Z_C17_entender.txt, 20261126T145416Z_C17_diagnosticar.txt, 20261126T145418Z_C17_solucionar.txt, 20261126T145628Z_C17_validar.txt, 20261126T145630Z_C17_observar.txt, 20261126T145916Z_C18_provocar.txt, 20261126T145919Z_C18_entender.txt, 20261126T145922Z_C18_diagnosticar.txt, 20261126T145927Z_C18_solucionar.txt, 20261126T145930Z_C18_validar.txt y 20261126T145933Z_C18_observar.txt

## Entrada 7
- **Herramienta:** Perplexity (chat de IA, sin agente; los comandos y los commits los ejecuto yo desde mi terminal)
- **Prompt (literal, copiado tal cual):**
```text
cd ~/oracle-database-lab
source ~/.bashrc
incidente INC-606 romper
incidente INC-606 pistas
echo "=========== PB-2 ==========="; cat scripts/t6/playbooks/PB-2_una-consulta-va-lenta.md
echo "=========== RB-3 ==========="; cat scripts/t6/runbooks/RB-3_indices-con-red.md
```
(Es el comienzo de mi mensaje; después pegué la salida completa. Hice lo mismo con INC-607 e INC-610 y con cada comando de diagnóstico y de arreglo.)
- **Código recibido (el fragmento, o la ruta del archivo donde está):**
```sql
-- INC-606
ALTER INDEX t6.ix_t6_ped_cp REBUILD ONLINE;
ALTER SYSTEM FLUSH SHARED_POOL;
-- INC-607
-- t6 spm quitar SQL_68ec219200df8fe9   (DBMS_SPM.DROP_SQL_PLAN_BASELINE)
ALTER SYSTEM FLUSH SHARED_POOL;
-- INC-610
ALTER SYSTEM RESET optimizer_index_cost_adj SCOPE = BOTH;
ALTER SYSTEM FLUSH SHARED_POOL;
-- diagnóstico
SELECT index_name, status, visibility FROM dba_indexes WHERE owner = 'T6' AND index_name = 'IX_T6_PED_CP';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_SQL_PLAN_BASELINE('SQL_68ec219200df8fe9', NULL, 'BASIC +NOTE'));
SELECT con_id, sid, name, value FROM v$spparameter WHERE name = 'optimizer_index_cost_adj';
```
Además, el texto de los tres postmortems en docs/bitacora/lab7-respuestas.md (apartados Parte G · Incidente 1, 2 y 3), redactado por la IA a partir de mis salidas reales.
- **Dónde lo usé (parte, script o pregunta):** Parte G, incidentes INC-606, INC-607 e INC-610, y sus postmortems en lab7-respuestas.md.
- **Propósito (para qué lo necesitaba):** Diagnosticar, arreglar con el cambio mínimo, verificar y documentar mis tres incidentes (semilla 48) siguiendo los playbooks PB-2 y PB-3 y los runbooks RB-3, RB-4 y RB-1.
- **Qué hace (con mis palabras; línea a línea si es SQL corto):** INC-606: el índice IX_T6_PED_CP estaba UNUSABLE, así que el optimizador recorría la tabla; ALTER INDEX ... REBUILD ONLINE lo deja VALID sin bloquear la escritura. INC-607: había una línea base de SQL Plan Management FIXED con un plan de recorrido completo; t6 spm quitar borra esa línea base y el optimizador vuelve a elegir el índice de ID_CLIENTE. INC-610: optimizer_index_cost_adj valía 4600 en la PDB (el valor por defecto es 100), lo que encarece los índices a ojos del optimizador; ALTER SYSTEM RESET lo devuelve al valor por defecto y lo quita del SPFILE de la PDB. En los tres casos ALTER SYSTEM FLUSH SHARED_POOL vacía la shared pool de mi PDB para medir con cursores nuevos.
- **Evidencia de ejecución (archivo de docs/bitacora/lab7/evidencia con mi cabecera):** docs/bitacora/lab7/evidencia/incidentes/20261126T150229Z_INC-606_romper.txt, 20261126T150615Z_INC-606_verificar.txt, 20261126T151020Z_INC-607_romper.txt, 20261126T151401Z_INC-607_verificar.txt, 20261126T151426Z_INC-610_romper.txt y 20261126T151642Z_INC-610_verificar.txt; y las evidencias de las herramientas t6 en docs/bitacora/lab7/evidencia/herramientas/
