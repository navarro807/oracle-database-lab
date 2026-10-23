# Laboratorio 5 — Respuestas y cierre

## 1. Punto de partida y banco de medida

### 1.1. Copia del Lab 4 frente a la del Lab 3

La copia de seguridad del estado anterior quedó registrada en:

`backups/20261023T181356Z_lab4-final`

La evidencia 00 demuestra que el estado del Lab 4 se respaldó antes de ejecutar los simulacros. También confirma que los archivos de la base están dentro del volumen persistente y que el repositorio no contiene copias binarias de Oracle.

Evidencia: `00-backup-lab4.script.log`.

### 1.2. Factor de bloqueo

El factor de bloqueo se calcula como:

\[ bfr = \left\lfloor \frac{B}{R} \right\rfloor \]

En la evidencia de TiendaSur, `CLIENTE` ocupa aproximadamente `1517` bloques y `PEDIDO` aproximadamente `5320` bloques. Las pequeñas diferencias entre el cálculo teórico y la medida real se deben a que el factor de bloqueo es una media y no todos los bloques contienen exactamente el mismo número de filas.

Evidencia: `01-perfil-tiendasur.script.log`.

### 1.3. Medición de consultas

La herramienta ejecuta cada sentencia dos veces y mide la segunda ejecución. Esto reduce el efecto del análisis inicial y de la carga fría de bloques en la caché. Las métricas relevantes son filas, lecturas lógicas, lecturas físicas, tiempo y plan real.

Evidencia: `01-herramienta-medir.script.log`.

## 2. Anatomía y tipos de índice

### 2.1. Árbol B+

Un índice B-tree está formado por raíz, ramas y hojas. Las hojas contienen las claves ordenadas y los ROWID de las filas. Las hojas están enlazadas para permitir recorridos ordenados y búsquedas por rango.

La altura crece logarítmicamente porque cada bloque de rama puede apuntar a muchos hijos. Por ello, aumentar mucho el número de filas normalmente añade pocos niveles.

Evidencia: `02-anatomia-indice.script.log`.

### 2.2. ROWID

El ROWID permite localizar físicamente una fila de una tabla heap. La entrada del índice contiene la clave y el ROWID; Oracle utiliza esa información para acceder al bloque de tabla correspondiente.

Evidencia: `02-grafico-PK_PEDIDO.script.log`.

### 2.3. Tipos de índice

Un índice simple es apropiado para búsquedas selectivas sobre una columna. Un índice compuesto es útil cuando las consultas utilizan la columna inicial del índice. Un índice cubriente puede evitar el acceso adicional a la tabla si contiene todas las columnas necesarias.

Un bitmap puede ser adecuado para columnas de baja cardinalidad en cargas analíticas, pero no suele ser apropiado para tablas OLTP con muchas escrituras concurrentes.

Evidencia: `03-tipos-indice.script.log`.

## 3. Agrupamiento, equilibrio y sargabilidad

### 3.1. Clustering factor

El clustering factor mide cuántas veces cambia el bloque de tabla al recorrer un índice en orden. Un valor cercano al número de bloques de la tabla indica buen agrupamiento. Un valor cercano al número de filas indica que las filas están dispersas.

Reconstruir un índice no reorganiza la tabla heap, por lo que no corrige un mal agrupamiento físico de las filas.

Evidencia: `04-agrupamiento-equilibrio.script.log`.

### 3.2. Punto de equilibrio

El acceso por índice deja de ser conveniente cuando visita demasiados bloques de tabla. El punto de equilibrio depende de la selectividad, el clustering factor, el factor de bloqueo y el coste relativo de las lecturas secuenciales y aleatorias.

Por eso una consulta selectiva puede beneficiarse de un índice, mientras que una consulta que devuelve una gran fracción de la tabla puede ser más rápida mediante un recorrido completo.

Evidencia: `04-agrupamiento-equilibrio.script.log`.

### 3.3. Sargabilidad

Una condición es sargable cuando la columna indexada queda desnuda a un lado del operador. Las funciones sobre la columna, la aritmética sobre ella, las conversiones implícitas, los comodines iniciales y ciertos `OR` pueden impedir el uso eficaz del índice.

La solución preferente es reescribir la consulta antes de crear un índice funcional o adicional.

Evidencia: `05-sargabilidad.script.log`.

## 4. Coste de escritura

Cada índice añade trabajo a los `INSERT`, `UPDATE` y `DELETE`. En cada operación Oracle debe mantener las entradas de índice afectadas, además de generar undo y redo.

La propuesta V005 aplica el protocolo de cinco preguntas:

1. Qué consulta mejora.
2. Qué selectividad tiene.
3. Qué lecturas y plan consigue.
4. Cuánto cuesta mantenerlo.
5. Si duplica otro índice existente.

La decisión queda registrada como migración versionada y no se modifica una migración ya aplicada.

Evidencia: `06-indices.script.log` y spool de V005.

## 5. Divisiones y patrón cola

Una división 50/50 reparte aproximadamente por igual las entradas de una hoja. Una división 90/10 aparece cuando las inserciones se concentran en un extremo, como ocurre con claves crecientes.

El patrón cola puede dejar hojas antiguas poco ocupadas. El remedio depende del objetivo: `COALESCE` puede combinar espacio de hojas, `SHRINK SPACE` puede compactar el segmento y `REBUILD ONLINE` puede reorganizarlo completamente con disponibilidad para las sesiones.

Evidencia: `07a-crecimiento.script.log`, `07b-patron-cola.script.log` y `07c-remedios.script.log`.

## 6. SCN, control files, redo y FRA

### 6.1. SCN y checkpoints

El SCN establece el orden lógico de los cambios. El checkpoint registra hasta dónde se han escrito cambios en los control files y en las cabeceras de los datafiles. Oracle utiliza esa información para decidir si necesita recuperación al arrancar.

Evidencia: `08-scn-checkpoint.script.log`.

### 6.2. Control files

Los control files contienen la identidad de la base, las rutas de los datafiles y redo logs, información de checkpoints y metadatos necesarios para la recuperación.

La base quedó con tres copias. Esto evita que el fallo de una copia individual impida montar la base. En producción, las copias deberían estar además en dispositivos físicos distintos.

Evidencia: `09-multiplexar-controlfile.script.log`.

### 6.3. Redo

Los redo logs tienen miembros multiplexados para reducir el riesgo de pérdida de un miembro. La configuración validada no deja grupos con un único miembro.

Evidencia: `10-redo.script.log`.

### 6.4. ARCHIVELOG y FRA

La base quedó en `ARCHIVELOG` y con la FRA configurada. El redo archivado permite recuperar cambios posteriores a una copia RMAN.

Si la FRA se llena, Oracle puede detener los cambios porque no puede archivar el redo necesario. La solución profesional es revisar la retención RMAN, ampliar la FRA o eliminar archivos únicamente mediante una política controlada.

Evidencia: `11-fra-llena.script.log` y `11-activar-archivelog.script.log`.

## 7. Undo, consistencia y write-ahead logging

### 7.1. Lectura consistente

Una sesión que consulta mientras otra tiene una actualización sin confirmar ve el valor confirmado anterior. Oracle reconstruye esa versión usando undo.

Evidencia: `12-lectura-consistente.script.log`.

### 7.2. Undo y redo

El `DELETE` suele generar más undo que el `INSERT` porque para deshacerlo debe conservar más información de la fila y de las entradas de índice. El undo también está protegido por redo para que Oracle pueda recuperar la instancia después de una caída.

Evidencia: `12-undo-y-redo.script.log`.

### 7.3. LGWR y DBWn

Al completar un `COMMIT`, LGWR garantiza que el redo está escrito en el redo log online. Los bloques de datos pueden seguir sucios en memoria y serán escritos posteriormente por DBWn, por ejemplo durante un checkpoint.

Por tanto, `COMMIT` no significa que todos los datafiles estén actualizados en ese instante. La garantía de durabilidad está en el redo.

Evidencia: `13-lgwr-dbwn.script.log`.

## 8. Simulacros de fallo

| Simulacro | Fallo | Recuperación | RPO | RTO |
|---|---|---|---|---|
| A | Caída brusca de instancia | Recuperación automática con redo y undo | 0 para cambios confirmados | No calculable: el log no registró inicio y fin |
| B | Pérdida de control file | Sustitución de la copia multiplexada sana | 0 | No calculable: el log no registró inicio y fin |
| C | Borrado de tabla | Restauración de la copia completa del estado | 5 s | 475 s |
| D | Pérdida de datafile | RMAN RESTORE y RECOVER con redo archivado | 0 | 45 s desde el fallo; 43 s de archivo offline a online |

El simulacro A demuestra que Oracle rehace cambios confirmados con redo y deshace cambios no confirmados con undo. El simulacro D demuestra que ARCHIVELOG permite aplicar cambios posteriores a la copia RMAN.

Los tiempos de A y B no pueden reconstruirse con precisión porque sus logs no registraron marcas de inicio y fin. En C, restaurar toda la base tardó 475 s y dejó un RPO de 5 s; en D, recuperar solo el datafile tardó 45 s desde el fallo y conservó el cambio posterior a la copia, con RPO 0. Esto muestra que una recuperación granular con RMAN puede reducir notablemente el RTO frente a una restauración completa.

Evidencias: `14a-caida-instancia.script.log`, `14b-perdida-controlfile.script.log`, `14c-simulacro-restauracion.script.log` y `14d-perdida-datafile.script.log`.

## 9. Simulacro de examen S1-S26

| Pregunta | Respuesta | Justificación |
|---|---|---|
| S1 | B | Un clustering factor cercano al número de filas indica filas dispersas. |
| S2 | A y C | Una condición sargable deja la columna disponible para el acceso por índice. |
| S3 | B | Una conversión implícita puede impedir el uso del índice normal. |
| S4 | B | Bitmap es adecuado para baja cardinalidad y poca escritura concurrente. |
| S5 | B | Un índice compuesto puede usar skip scan en determinadas condiciones. |
| S6 | B | Invisible permite probar un índice sin eliminarlo. |
| S7 | A y C | COALESCE y SHRINK SPACE tratan espacio libre de hojas. |
| S8 | B | REVERSE distribuye inserciones, pero no sirve normalmente para rangos. |
| S9 | C | Una columna no indexada no exige mantener entradas de índice. |
| S10 | B | La altura depende del número de entradas y del fan-out. |
| S11 | A y C | En una IOT la fila se almacena con la clave primaria. |
| S12 | B | Oracle compara SCN de control file y cabecera del datafile. |
| S13 | C | CKPT actualiza información de checkpoint. |
| S14 | B y E | NOMOUNT inicia la instancia sin montar la base. |
| S15 | B | ARCHIVELOG se activa con la base montada. |
| S16 | B | Un grupo inactivo y archivado puede limpiarse con CLEAR LOGFILE. |
| S17 | A y C | Undo permite lectura consistente y Flashback. |
| S18 | B | El redo protege también los bloques de undo. |
| S19 | A | COMMIT garantiza redo en el redo log online. |
| S20 | A | Un MTTR menor implica checkpoints más frecuentes. |
| S21 | B | El archivado puede bloquearse por FRA llena. |
| S22 | B | Un datafile no crítico puede recuperarse online. |
| S23 | B | SYSTEM requiere recuperar con la base montada. |
| S24 | B | NOARCHIVELOG solo permite recuperar hasta la copia en frío. |
| S25 | B y D | Hay que aumentar undo y garantizar retención si es necesario. |
| S26 | A | `V$RECOVERY_AREA_USAGE` permite vigilar la FRA. |

## 10. Retrospectiva

La principal lección de los simulacros es que la recuperación debe probarse antes de necesitarla. La multiplexación protege de fallos individuales, ARCHIVELOG permite recuperación temporal y RMAN proporciona el punto de partida físico para recuperar datafiles.

Las mejoras propuestas son:

- Alertar antes de que la FRA alcance niveles críticos.
- Mantener copias RMAN en almacenamiento independiente.
- Registrar automáticamente RTO y RPO en cada simulacro.
- Mantener un runbook accesible para el operador de guardia.
- Repetir periódicamente los simulacros en un entorno controlado.

## 11. Estado final

La verificación automática devuelve:

```text
RESULTADO: TODO OK. Lab 5 listo para entregar.
```

Las evidencias 00-16 están presentes. `config/.env` y `backups/` están fuera de Git. La CDB está abierta en `READ WRITE`, la base está en `ARCHIVELOG`, existen tres copias del control file, la FRA está configurada y hay copias RMAN completadas.
