# Laboratorio 7 · Respuestas · E048

<!--
CÓMO SE RELLENA
- Copia este archivo como docs/bitacora/lab7-respuestas.md y pon tu código en el título.
- Responde con TUS números: cada respuesta cita el archivo de evidencia de donde sale (docs/bitacora/lab7/evidencia/...).
  Una cifra sin evidencia no puntúa. Las cifras del PPTX son de referencia: las tuyas serán parecidas, no iguales.
- 3 a 6 líneas por pregunta. No pegues salidas enteras: el archivo de evidencia ya las tiene.
- No borres los títulos: scripts/lab7/09-verificacion-final.sh comprueba que están todos.
-->

## Parte B · C01 · Más sesiones no es más rendimiento
1. ¿Cuántas llamadas por segundo y qué p95 tuviste con 1, 2 y 8 sesiones? ¿Qué número de sesiones recomiendas y por qué?
   **Respuesta:** Con 1 sesión conseguí 4,4 llamadas/s y p95 de 238,7 ms; con 2 sesiones, 9,0 llamadas/s y p95 de 269 ms; con 8 sesiones, 8,4 llamadas/s y p95 de 1 370,1 ms.
   Pasar de 1 a 2 sesiones duplica el trabajo (4,4 a 9,0) con casi la misma latencia; pasar de 2 a 8 no mejora nada (9,0 a 8,4) y la p95 se multiplica por 5.
   Recomiendo un pool de 2 sesiones, igual a CPU_COUNT = 2: da el mismo throughput que 8 sesiones y la p95 baja de 1 370 ms a 269 ms.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261125T184517Z_C01_entender.txt, 20261125T184721Z_C01_validar.txt y 20261125T184723Z_C01_observar.txt.
2. ¿Qué evento domina con 8 sesiones y qué significa en Oracle Free?
   **Respuesta:** Con 8 sesiones domina resmgr:cpu quantum: 234 de 325 muestras de ASH (72 %); el 28 % restante es ON CPU (91 muestras). El AAS fue 7,6 con CPU_COUNT = 2.
   En Oracle Free es la espera de turno que impone el Resource Manager al limitar la instancia a 2 CPU: la sesión está lista para trabajar pero no tiene CPU, así que hace cola.
   Con 1 sesión el AAS fue 0,9 y el 100 % de las muestras estaba ON CPU, sin esperas.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261125T184636Z_C01_diagnosticar.txt.
3. Comprueba la ley de Little (N = X · R) con tus tres medidas.
   **Respuesta:** N = X · R. Con 1 sesión: 4,4 llamadas/s x 0,2132 s = 0,94, es decir, 1. Con 2 sesiones: 9,0 x 0,2173 s = 1,96, es decir, 2. Con 8 sesiones: 8,4 x 0,8893 s = 7,47, es decir, 7,5.
   La ley se cumple en las tres tandas. Con 8 sesiones hay unas 7,5 llamadas en el sistema pero el throughput es el mismo que con 2, así que la latencia media sube de 0,22 s a 0,89 s: las sesiones sobrantes solo añaden cola.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261125T184723Z_C01_observar.txt.

## Parte C · C03 · Literales y análisis completos
1. Análisis completos y tiempo con literales, con variables de enlace y con CURSOR_SHARING = FORCE (tus cifras).
   **Respuesta:** Con literales hice 5 053 análisis completos y las 5 000 fichas tardaron 10 370 ms (2,074 ms por ficha); el 83 % del tiempo de la sesión (8 650 ms) fue análisis.
   Con CURSOR_SHARING = FORCE bajé a 28 análisis completos y 550 ms (0,110 ms por ficha). Con variable de enlace, 28 análisis completos y 360 ms (0,072 ms por ficha), unas 29 veces menos tiempo que con literales.
   En la shared pool quedaron 4 353 cursores de una sola ejecución (unos 116 MB) con literales, frente a 1 cursor con variable de enlace.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261125T185009Z_C03_diagnosticar.txt, 20261125T185011Z_C03_solucionar.txt y 20261125T185015Z_C03_observar.txt.
2. ¿Por qué FORCE es un puente y no la solución? ¿Qué ve el DBA en V$SQL que lo delata (FORCE_MATCHING_SIGNATURE)?
   **Respuesta:** FORCE hace que Oracle sustituya todos los literales de la sentencia por variables del sistema (en V$SQL el texto queda con :"SYS_B_0"; una sola sentencia con 5 000 ejecuciones). Alivia, pero cambia también los literales que dan selectividad al optimizador, es más lento que la variable de enlace (550 ms frente a 360 ms) y oculta el defecto de la aplicación, por lo que solo vale mientras se corrige el código.
   Lo que delata el problema en V$SQL es la FORCE_MATCHING_SIGNATURE: una sola firma (14573098645096361820) con 4 343 SQL_ID distintos ejecutados una vez cada uno significa que la aplicación no usa variables de enlace.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261125T185009Z_C03_diagnosticar.txt y 20261125T185015Z_C03_observar.txt.

## Parte C · C04 · El informe que se desborda a TEMP
1. Bloques de TEMP, tipo de pasada y tiempo del informe antes y después. ¿Qué hacía el disparador de logon?
   **Respuesta:** Antes: el informe de 1 000 000 de pedidos escribió 5 456 bloques en TEMP (42,6 MB), se ejecutó en 1 PASS y tardó 8 710 ms. Después de quitar el disparador: 0 bloques de TEMP, ordenación OPTIMAL y 4 050 ms. Con el TOP 100: 0 bloques, OPTIMAL y 130 ms.
   El disparador de logon T6.C04_LEGADO se ejecutaba al iniciar sesión la cuenta de informes y fijaba workarea_size_policy = MANUAL y sort_area_size = 1 MB, anulando la PGA automática. La ordenación necesitaba unos 48 MB y solo usaba 1 016 KB.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261125T185120Z_C04_entender.txt, 20261125T185124Z_C04_diagnosticar.txt y 20261125T185132Z_C04_solucionar.txt.
2. ¿Por qué el TOP 100 cabe en memoria y el informe completo no?
   **Respuesta:** El informe completo ordena 1 000 000 de filas y necesita unos 48 MB de área de trabajo; con la política MANUAL solo disponía de 1 MB, así que tuvo que volcar a TEMP y volver a leer (1 PASS).
   El TOP 100 se resuelve con SORT ORDER BY STOPKEY: solo mantiene las 100 mejores filas, así que necesita KB y no MB y cabe en memoria (OPTIMAL, 0 bloques de TEMP, 130 ms). Reducir antes de ordenar vale más que ordenar mejor o dar más memoria.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261125T185135Z_C04_validar.txt y 20261125T185139Z_C04_observar.txt.

## Parte D · C07 · EXPLAIN PLAN frente al plan real
1. Copia el predicado que delata el problema en el plan real y explica de dónde sale.
   **Respuesta:** En el plan real (DISPLAY_CURSOR) el predicado es filter(TO_NUMBER("CODIGO_POSTAL")=:B1) sobre un TABLE ACCESS FULL de PEDIDO (plan 2571571058, coste 1449).
   Sale de que la aplicación pasa la variable como NUMBER (el bind visto fue :B1 (NUMBER): 30038) contra la columna CODIGO_POSTAL, que es VARCHAR2: Oracle convierte la COLUMNA con TO_NUMBER para compararla y el índice IX_T6_PED_CP ya no se puede usar como clave de búsqueda.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144004Z_C07_diagnosticar.txt.
2. Lecturas y p95 de V1 y V2. ¿Por qué EXPLAIN PLAN no lo vio?
   **Respuesta:** V1 (variable NUMBER) hacía 5 234 lecturas por búsqueda y una p95 de 121,5 ms (p50 70,5 ms, 40 búsquedas). V2 (variable VARCHAR2, un solo cambio en la aplicación) hace 95 lecturas y p95 de 4,1 ms, con INDEX RANGE SCAN en IX_T6_PED_CP.
   EXPLAIN PLAN no lo detectó porque no ejecuta la sentencia ni conoce el tipo ni el valor de la variable: trató :CP como texto y predijo el índice (plan 2982358210, coste 94), que es el plan que luego tuvo V2 y no V1.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144002Z_C07_entender.txt, 20261126T144008Z_C07_validar.txt y 20261126T144006Z_C07_solucionar.txt.

## Parte D · C08 · E-Rows frente a A-Rows
1. Estimación y filas reales antes y después del grupo de columnas. ¿En qué línea del plan se separan por primera vez?
   **Respuesta:** Antes, el optimizador estimaba 3 clientes (E-Rows 3) y había 56 (A-Rows 56). Después de crear el grupo de columnas (CIUDAD, COMUNIDAD) y recoger estadísticas, la estimación es 50 frente a 56 reales.
   Las dos cifras se separan por primera vez en la línea 3 del plan, TABLE ACCESS BY INDEX ROWID BATCHED de CLIENTE (filtro de COMUNIDAD sobre el acceso por CIUDAD); todo lo que está encima hereda el error (E-Rows 28 y 30 frente a 599 filas reales).
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144016Z_C08_diagnosticar.txt, 20261126T144018Z_C08_solucionar.txt y 20261126T144020Z_C08_validar.txt.
2. ¿Por qué el optimizador multiplicaba mal las dos selectividades?
   **Respuesta:** Porque supone que las columnas son independientes y multiplica sus selectividades: 100 000 filas x 1/2 000 (CIUDAD) x 1/17 (COMUNIDAD) da unas 2,9 filas. Pero están correlacionadas: cada ciudad pertenece a una sola comunidad (el máximo de comunidades por ciudad es 1), así que la segunda condición apenas filtra y hay 56 clientes.
   El grupo de columnas crea una columna virtual oculta (SYS_STU...) que cuenta las combinaciones distintas (2 000), con lo que la estimación pasa a 100 000 / 2 000 = 50.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144014Z_C08_entender.txt y 20261126T144021Z_C08_observar.txt.

## Parte E · C12 · Estadísticas obsoletas
1. Filas según las estadísticas y reales; método de unión y lecturas antes y después.
   **Respuesta:** Según las estadísticas CARRITO tenía 100 filas (última recogida 14:43:29) y en realidad tenía 200 100: un error de unas 2 000 veces (STALE = YES, 200 000 inserciones desde la última recogida).
   Antes el informe usaba NESTED LOOPS (plan 3942147839, E-Rows 100 frente a A-Rows 200K) y hacía 212 169 lecturas lógicas en 454 ms. Después de recoger las estadísticas de CARRITO usa HASH JOIN (plan 582079594, E-Rows 200K) y hace 5 907 lecturas, unas 36 veces menos.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144333Z_C12_entender.txt, 20261126T144335Z_C12_diagnosticar.txt y 20261126T144340Z_C12_validar.txt.
2. ¿Por qué la tarea automática no lo habría arreglado a tiempo? ¿Quién debe recoger y cuándo?
   **Respuesta:** La tarea automática (auto optimizer stats collection, ENABLED) solo recoge en la ventana de mantenimiento, que empieza a las 22:00 y dura 4 h, y con un umbral STALE_PERCENT del 10 %. Una carga que termina de madrugada, por ejemplo a las 3:00, llega tarde: el informe de primera hora ya sufre el plan malo.
   Debe recoger el proceso que carga, al terminar la carga, con GATHER_TABLE_STATS solo sobre la tabla que cambió (CARRITO) y con no_invalidate => FALSE para que los cursores se rehagan ya (runbook RB-2). Con optimizer_adaptive_plans = TRUE el join se corregiría a mitad de ejecución, pero la estimación seguiría equivocada (E-Rows 100).
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144342Z_C12_observar.txt y 20261126T144338Z_C12_solucionar.txt.

## Parte E · C13 · El ciclo de estadísticas con red
1. Describe el ciclo que seguiste (pendientes, probar, publicar, restaurar, bloquear) con la vista que comprueba cada paso.
   **Respuesta:** Tras pasar 135 277 pedidos a estado E, el optimizador estimaba 250 000 filas (reparte 1/4 por estado, ESTADO sin histograma) frente a 185 277 reales, y PEDIDO estaba STALE = YES (DBA_TAB_STATISTICS, DBA_TAB_MODIFICATIONS con 135 277 updates, DBA_TAB_COL_STATISTICS).
   Ciclo: 1) pendientes: SET_TABLE_PREFS PUBLISH = FALSE y GATHER_TABLE_STATS con histograma en ESTADO; compruebo con DBA_TAB_PENDING_STATS que quedan sin publicar (pendientes de 14:43:59, publicadas de 14:43:44). 2) probar: en mi sesión optimizer_use_pending_statistics = TRUE y EXPLAIN PLAN da 185 277. 3) publicar: PUBLISH_PENDING_STATS y PUBLISH = TRUE (STALE = NO). 4) restaurar: DBA_TAB_STATS_HISTORY (retención de 31 días) y RESTORE_TABLE_STATS a hace 60 segundos, que devolvió ESTADO a sin histograma. 5) bloquear: LOCK_TABLE_STATS y STATTYPE_LOCKED = ALL.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144352Z_C13_entender.txt, 20261126T144356Z_C13_diagnosticar.txt, 20261126T144407Z_C13_solucionar.txt, 20261126T144409Z_C13_validar.txt y 20261126T144447Z_C13_observar.txt.
2. ¿Qué error obtuviste al recoger sobre estadísticas bloqueadas y cómo se recoge si de verdad hace falta?
   **Respuesta:** Obtuve ORA-20005: object statistics are locked (stattype = ALL) al ejecutar GATHER_TABLE_STATS sobre PEDIDO después de LOCK_TABLE_STATS. Es la protección de las tablas de trabajo frente a la tarea automática.
   Si de verdad hace falta recoger, se hace como decisión consciente: UNLOCK_TABLE_STATS (lo que hice yo) o GATHER_TABLE_STATS con force => TRUE, y se vuelve a bloquear si procede.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144447Z_C13_observar.txt.

## Parte E · C14 · El índice invisible
1. Lecturas por apertura del panel antes y después. ¿Cómo probaste el índice sin que lo viera nadie más?
   **Respuesta:** Antes, el panel hacía 5 261 lecturas lógicas por apertura y 40,4 ms (TABLE ACCESS FULL de un millón de filas para mostrar 2 056 pedidos). Después de publicar el índice IX_T6_C14_PEND (estado, canal, fecha_pedido) hace 118 lecturas y 0,76 ms con INDEX RANGE SCAN.
   Lo probé sin que nadie más lo viera: creé el índice INVISIBLE ONLINE (con él invisible el plan seguía en TABLE ACCESS FULL) y, solo en mi sesión, puse optimizer_use_invisible_indexes = TRUE; ahí salió el INDEX RANGE SCAN con 116 buffers. Después ALTER INDEX ... VISIBLE.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144457Z_C14_provocar.txt, 20261126T144518Z_C14_solucionar.txt y 20261126T144520Z_C14_validar.txt.
2. Redo con el índice INVISIBLE y VISIBLE: ¿qué demuestra?
   **Respuesta:** Cambiar el canal de 20 000 pedidos generó 9 008 KB de redo sin mantener el índice, 10 402 KB con el índice INVISIBLE y 10 403 KB con el índice VISIBLE.
   Demuestra que invisible no es gratis al escribir: el optimizador no lo usa para leer, pero cada DML lo mantiene igual que si fuera visible (unos 1 394 KB más, cerca del 15 %). INVISIBLE sirve para probar y para volver atrás sin reconstruir, no para ahorrar coste de escritura.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T144544Z_C14_observar.txt.

## Parte F · C17 · INC-604 con AWR, ASH y ADDM
1. SLI y SLO; p95 antes y después; instantáneas AWR que usaste.
   **Respuesta:** El SLI es la p95 de la búsqueda por código postal medida en T6.APP_LOG y el SLO acordado es p95 < 20 ms. Antes (V1, 3 sesiones, 120 s) la p95 era 484,8 ms (p50 136,7 ms, 1 868 llamadas): incumple el SLO. Después (V2, la misma carga) la p95 es 1,2 ms y se atienden 32 057 búsquedas frente a 1 868: cumple el SLO.
   Usé las instantáneas AWR 30 (14:52:04) y 31 (14:54:08), que cubren exactamente la carga de la V1; la línea base ANTES quedó registrada en T6.LINEA_BASE (SQL_ID 0dbx7196jdajy, plan 2571571058, 170,96 ms y 5 230 lecturas por ejecución).
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T145412Z_C17_entender.txt, 20261126T145410Z_C17_provocar.txt y 20261126T145628Z_C17_validar.txt.
2. ¿Qué dijeron ASH, AWR y ADDM, y qué no podían decirte? ¿Cuál fue el ÚNICO cambio?
   **Respuesta:** ASH dijo quién y en qué: casi todas las muestras eran del SQL_ID 0dbx7196jdajy (250 ON CPU y 65 en resmgr:cpu quantum). AWR (intervalo 30 a 31) dijo qué SQL pesa: ese SQL_ID con 1 867 ejecuciones, 319,2 s y 5 230 lecturas por ejecución. ADDM lo cuantificó (DB time de 355 s, AAS 2,82; Top SQL con impacto de 2,48 sesiones, el 87,1 % de la actividad) y recomendó ejecutar el SQL Tuning Advisor.
   Lo que no podían decirme era la causa. La dio el plan real: filter(TO_NUMBER("CODIGO_POSTAL")=:B1) con TABLE ACCESS FULL, porque la V1 pasa un NUMBER contra una columna VARCHAR2 y el índice IX_T6_PED_CP no sirve.
   El ÚNICO cambio fue desplegar buscar_cp_v2 (parámetro VARCHAR2; la web llama a buscar_cp_v2(TO_CHAR(:cp))) en lugar de buscar_cp_v1 (NUMBER). Con ello la V2 usa INDEX RANGE SCAN y hace 95 lecturas por ejecución frente a 5 230.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T145416Z_C17_diagnosticar.txt, 20261126T145418Z_C17_solucionar.txt y 20261126T145630Z_C17_observar.txt.

## Parte F · C18 · SQL Plan Management
1. PLAN_HASH_VALUE y lecturas del lunes, del martes y con la línea base.
   **Respuesta:** El lunes (con histograma en ESTADO) el informe de pendientes usaba el plan 1767728868 (INDEX RANGE SCAN en IX_T6_PED_ESTADO) con 194 lecturas por ejecución y 11,5 ms. El martes, tras la recogida nocturna con METHOD_OPT FOR ALL COLUMNS SIZE 1 (sin histograma), usaba el plan 2571571058 (TABLE ACCESS FULL) con 5 227 lecturas y 39,3 ms: mismo SQL_ID 8hn59jfgw00y7 y otro plan.
   Con la línea base SPM (SQL_PLAN_0a27u7nan424ba00b9863, cargada desde AWR con las instantáneas 34 a 35) vuelve al plan 1767728868 con 189 lecturas y 28,1 ms, sin tocar las estadísticas del martes.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T145916Z_C18_provocar.txt, 20261126T145919Z_C18_entender.txt, 20261126T145927Z_C18_solucionar.txt y 20261126T145930Z_C18_validar.txt.
2. ¿Qué hizo la evolución con el plan nuevo y por qué? ¿Qué queda pendiente para que no vuelva a pasar?
   **Respuesta:** El optimizador quería el recorrido completo y lo guardó en la historia del plan como SQL_PLAN_0a27u7nan424b95a18d93, origen AUTO-CAPTURE y NO aceptado. La evolución (SPM EVOLVE, TASK_71) ejecutó los dos planes y lo comparó: el plan nuevo no pasó el criterio de beneficio porque su rendimiento verificado era 0,15781 veces peor que el de la línea base, así que siguió sin aceptarse. SPM no adivina el mejor plan, protege el plan probado.
   Pendiente para que no vuelva a pasar: la causa sigue ahí, la preferencia METHOD_OPT de PEDIDO (SIZE 1) que elimina el histograma de ESTADO. Hay que corregirla (histograma en ESTADO con las estadísticas recogidas con red, como en C13 y el runbook RB-2) y vigilar con DBA_HIST_SQLSTAT por PLAN_HASH_VALUE. Además, la sentencia debe analizarla la cuenta de la aplicación, porque con SYS la evolución falla.
   Evidencia: docs/bitacora/lab7/evidencia/casos/20261126T145933Z_C18_observar.txt y 20261126T145922Z_C18_diagnosticar.txt.

## Parte G · Incidente 1 · INC-6NN
- **Síntoma (con números):**
- **Playbook y pasos seguidos (herramientas y vistas):**
- **Causa raíz:**
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
- **Verificación (archivo de evidencia con todo OK):**
- **Prevención (qué evitaría que se repita):**

## Parte G · Incidente 2 · INC-6NN
- **Síntoma (con números):**
- **Playbook y pasos seguidos (herramientas y vistas):**
- **Causa raíz:**
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
- **Verificación (archivo de evidencia con todo OK):**
- **Prevención (qué evitaría que se repita):**

## Parte G · Incidente 3 · INC-6NN
- **Síntoma (con números):**
- **Playbook y pasos seguidos (herramientas y vistas):**
- **Causa raíz:**
- **Arreglo aplicado (órdenes exactas) y por qué ese:**
- **Verificación (archivo de evidencia con todo OK):**
- **Prevención (qué evitaría que se repita):**

## Parte H · Reflexión
1. De todo el laboratorio, ¿qué cambio dio más mejora por menos riesgo? Justifícalo con tus números.
2. Un caso no evaluable (sin ★) que hayas hecho y qué aprendiste de él (opcional, cuenta para la certificación).
