# Autopsia de la instancia

## 1. Identidad y disponibilidad

- CDB: `CDB$ROOT`, `READ WRITE`.
- PDB principal: `FREEPDB1`, `READ WRITE`.
- La base está disponible para operar.

## 2. Memoria

- SGA máxima: `1529 MB`.
- Buffer cache: `976 MB`.
- Shared pool: `512 MB`.
- PGA objetivo: `512 MB`.
- PGA máxima observada: `586 MB`.

**Hallazgo:** la instancia tiene una configuración de memoria limitada, pero no aparece por sí sola una condición de fallo.

**Acción:** revisar la evolución de consumo antes de modificar parámetros.

**Prioridad:** baja.

## 3. Procesos

- Procesos de segundo plano: `88`.
- Servidores u otros procesos: `5`.
- Se observan `PMON`, `SMON`, `DBW0`, `LGWR`, `CKPT` y `LREG`.

**Hallazgo:** los procesos fundamentales de Oracle están activos.

**Acción:** mantener la observación mediante el script de autopsia.

**Prioridad:** informativa.

## 4. Archivos

- Datafiles: `16`.
- Control files: `2`.
- Miembros redo: `3`.
- Tempfiles: `3`.
- Archived logs observados: `5`.

**Hallazgo:** hay dos control files, pero `db_recovery_file_dest_size` aparece en `0`.

**Riesgo:** la estrategia de recuperación y el espacio destinado a archivos de recuperación no están claramente configurados.

**Acción:** revisar la política de recuperación antes de activar o depender de archivado y Flashback.

**Prioridad:** media.

## 5. Tablespaces

- `TBS_ACADEMIA`: `2.3%` usado.
- `TBS_CLINICA`: `0.6%` usado.
- `TBS_FINTECH`: `0.6%` usado.
- `TBS_LOGISTICA`: `0.6%` usado.
- `TBS_RETAIL`: `0.6%` usado.

**Hallazgo:** los tablespaces de negocio tienen mucho margen disponible.

**Acción:** continuar monitorizando crecimiento y porcentaje usado.

**Prioridad:** baja.

## 6. Índices

- No válidos: `0` en los esquemas observados.
- Algunos esquemas no muestran estadísticas completas de índices.

**Hallazgo:** no hay índices inválidos, pero el optimizador puede carecer de estadísticas en algunos esquemas.

**Acción:** planificar `DBMS_STATS.GATHER_SCHEMA_STATS` en una ventana controlada.

**Prioridad:** media.

## 7. Seguridad

- `COPSRO` aparece como usuario común.
- No se observan cuentas de aplicación con el rol `DBA`.
- La observabilidad está separada del acceso SYSDBA.

**Hallazgo:** el acceso observado respeta el principio de mínimo privilegio.

**Acción:** mantener la cuenta de observabilidad separada de las cuentas administrativas.

**Prioridad:** baja.

## 8. Red

- Servicios observados: `free`, `freeXDB` y `freepdb1`.
- No se observa el puerto muerto `8181`.

**Hallazgo:** los servicios publicados corresponden a servicios de Oracle conocidos.

**Acción:** revisar periódicamente los puertos publicados del contenedor.

**Prioridad:** baja.

## 9. Configuración

- `db_block_size`: `8192`.
- `processes`: `200`.
- `sga_target`: `1610612736`.
- `pga_aggregate_target`: `536870912`.
- `open_cursors`: `300`.

**Hallazgo:** el tamaño de bloque coincide con el utilizado en las pruebas de almacenamiento.

**Acción:** no modificar estos parámetros sin una medición y una justificación operativa.

**Prioridad:** informativa.

## 10. Alert log

- Errores ORA en las últimas 24 horas: `6`.
- `ORA-00800`: `4`.
- `ORA-65025`: `1`.
- `ORA-959`: `1`.

**Hallazgo:** existen errores recientes en el alert log.

**Riesgo:** cambiar parámetros o ignorar los errores sin analizar su contexto podría ocultar un problema real.

**Acción:** consultar cada aparición en el alert log, relacionarla con su hora y revisar la evidencia de las Partes anteriores antes de corregir.

**Prioridad:** alta para investigación; no implica todavía un cambio inmediato.

## Resumen ejecutivo

La instancia y `FREEPDB1` están disponibles, y los tablespaces de negocio tienen margen suficiente.

No hay índices inválidos ni cuentas de aplicación con `DBA`, aunque conviene completar las estadísticas de los esquemas que no las muestran.

La prioridad operativa es investigar los seis errores ORA del alert log y confirmar la estrategia de recuperación.

