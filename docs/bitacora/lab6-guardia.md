# Guardia nocturna Lab 6 · Postmortems sin culpables · E048

## INC-601 · La pantalla de secretaría se queda colgada al guardar la ficha del alumno 101
- **Detección:** 11:01 UTC (2026-11-23). Avisó Ana García (Secretaría) por ticket de prioridad ALTA: la pantalla se cuelga al guardar la ficha.
- **Impacto:** Secretaría no pudo guardar la ficha del alumno 101 desde las 11:01 hasta la intervención, poco más de un minuto. Una sola persona afectada y sin pérdida de datos.
- **Diagnóstico:** 08-diagnostico.sql (consulta 1): la sesión 227 (ANA_GARCIA, módulo secretaria, acción ficha-alumno) espera con el evento
  "enq: TX - row lock contention" (clase Application) y el bloqueador es el SID 63. La consulta 2 da la fila exacta (ACA_ESTUDIANTES, archivo 1024, bloque 781, fila 5).
  En V$LOCK, el SID 63 tiene el TX con LMODE 6 y BLOCK 1 y el SID 227 lo pide con REQUEST 6.
  El bloqueador es la sesión 63,64045 de APP_ACADEMIA (módulo matriculas, acción cierre-periodo), parada en un PL/SQL lock timer.
  La consulta 4 dice que desharía 1 bloque de undo y 1 registro de undo: casi nada. ASH guardó 5 muestras seguidas del bloqueo.
  Los servicios estaban arrancados y no había cuentas bloqueadas, así que la base no estaba caída.
- **Causa raíz:** una transacción de la aplicación de matrículas (cierre de periodo) actualizó la fila y quedó abierta, sin COMMIT ni ROLLBACK, mientras la sesión esperaba.
  La causa de fondo es sistémica: ni la aplicación limita el tiempo de una transacción abierta ni hay una alerta que avise cuando una sesión bloquea a otra.
- **Intervención:** ALTER SYSTEM KILL SESSION '63,64045' IMMEDIATE. Es la intervención más pequeña posible: afecta solo a la sesión bloqueadora y su rollback es mínimo.
  CANCEL SQL no servía, porque cancelaría el SLEEP pero la transacción seguiría abierta y el bloqueo permanecería. No se reinició nada ni se tocó la sesión de Ana.
- **Validación:** sesiones bloqueadas = 0 y la fila 101 sigue en ACTIVO (consulta como SYSDBA dentro de FREEPDB1).
  Evidencia: 20261123T110149Z_08-diagnostico-inc1.script.log y 20261123T110302Z_08-intervencion-inc1.script.log.
- **Acción preventiva:** (1) vigilar las sesiones bloqueadas en la lista de turno (pregunta 6) con una alerta cuando una sesión lleve más de unos segundos bloqueando;
  (2) que la aplicación confirme o deshaga rápido, y use SELECT ... FOR UPDATE WAIT n o un tiempo máximo de transacción.

## INC-602 · La aplicación de matrículas no conecta (ORA-12514)
- **Detección:** 11:05 UTC (2026-11-23). Avisó el equipo de matrículas por ticket de prioridad CRÍTICA: ninguna instancia de la aplicación conectaba y el error era ORA-12514.
- **Impacto:** la aplicación de matrículas no pudo conectar por su servicio (academia_app) desde las 11:05 hasta que se arrancó el servicio, aproximadamente un minuto. Afectó a todas las instancias de la aplicación, pero no hubo pérdida de datos.
- **Diagnóstico:** ORA-12514 lo da el listener y no la base, así que antes de reiniciar nada comprobé si la base estaba caída. 08-diagnostico.sql (consulta 6):
  FREEPDB1 estaba arrancada (SI) pero academia_app existía en el diccionario con ARRANCADO = NO, es decir, no se anunciaba al listener.
  Las consultas de bloqueos salían vacías y no había cuentas bloqueadas: la base y la PDB estaban abiertas y el problema era solo del servicio.
- **Causa raíz:** el servicio academia_app estaba parado (en el ejercicio lo paró el script de la guardia). La causa de fondo es que nada vigilaba que
  los servicios existentes estuvieran también arrancados: la base y la PDB estaban sanas, pero nadie lo detectó hasta que la aplicación falló.
- **Intervención:** BEGIN DBMS_SERVICE.START_SERVICE('academia_app'); END; y después ALTER PLUGGABLE DATABASE FREEPDB1 SAVE STATE.
  Es lo más pequeño que lo resuelve: arranca solo ese servicio, sin reiniciar la base, la PDB ni el listener.
  El SAVE STATE guarda el estado con el servicio arrancado para que no vuelva a quedar parado tras un reinicio (como vimos en la Parte C).
- **Validación:** por el camino del consumidor. V$ACTIVE_SERVICES muestra academia_app y freepdb1, lsnrctl status anuncia "Service academia_app has 1 instance(s)"
  con la instancia FREE en READY, y APP_ACADEMIA entra por academia_app con el rol ROL_APP_ACADEMIA, lee 17600 estudiantes y actualiza una fila (con rollback).
  El ORA-00942 final del INSERT en el histórico es el esperado de la Parte G. Evidencia: 20261123T110546Z_08-diagnostico-inc2.script.log y 20261123T110707Z_08-intervencion-inc2.script.log.
- **Acción preventiva:** añadir a la lista de turno la comparación entre servicios que existen y servicios arrancados (consulta 6 del diagnóstico) con una alerta;
  hacer SAVE STATE siempre que se cree o se pare un servicio de aplicación; y una conexión de prueba por academia_app que avise antes que los usuarios.

## INC-603 · La aplicación no entra (ORA-28000)
- **Detección:** 11:08 UTC (2026-11-23). Avisó el equipo de matrículas por ticket de prioridad ALTA: tras el despliegue de las 21:00 la aplicación no entraba (ORA-28000) y no habían cambiado la contraseña.
  La nota del turno de tarde decía que ese día se había ejecutado el script trimestral de bajas.
- **Impacto:** la aplicación de matrículas no pudo iniciar sesión con su cuenta (APP_ACADEMIA) desde el bloqueo (11:08) hasta que se desbloqueó, poco más de un minuto. Sin pérdida de datos.
- **Diagnóstico:** 08-diagnostico.sql (consulta 7): APP_ACADEMIA aparecía con ACCOUNT_STATUS = LOCKED, con fecha de bloqueo 2026-11-23 11:08 y perfil DEFAULT, que permite 10 intentos fallidos.
  LOCKED a secas es un bloqueo manual (de una persona o de un script); si hubiera sido por intentos fallidos se vería LOCKED(TIMED). Por eso la cuenta no se bloqueó sola.
  Los servicios estaban arrancados (consulta 6) y no había bloqueos de filas, así que la base y el servicio estaban bien.
- **Causa raíz:** el script trimestral de bajas bloqueó una cuenta de aplicación. La causa de fondo es que el script no distingue las cuentas de personas de las cuentas de aplicación:
  actúa sobre cualquier cuenta, sin una lista de cuentas protegidas ni una revisión previa. No fue un fallo de la cuenta ni de la contraseña.
- **Intervención:** ALTER USER app_academia ACCOUNT UNLOCK, dentro de FREEPDB1. Es lo más pequeño que lo resuelve: no se cambió la contraseña (nadie la cambió ni hay señales de que esté comprometida),
  no se tocó el perfil y no se reinició nada. Antes de desbloquear, el diagnóstico confirmó que el bloqueo era manual y no por intentos fallidos.
- **Validación:** la cuenta pasó a OPEN y APP_ACADEMIA entra por academia_app con el rol ROL_APP_ACADEMIA, lee 17600 estudiantes y actualiza una fila (con rollback).
  El ORA-00942 final del INSERT en el histórico es el esperado de la Parte G. Evidencia: 20261123T110814Z_08-diagnostico-inc3.script.log y 20261123T110922Z_08-intervencion-inc3.script.log.
- **Acción preventiva:** (1) que el script de bajas trabaje solo sobre cuentas de personas (por ejemplo las del perfil PRF_PERSONAS) y tenga una lista de cuentas de aplicación protegidas;
  (2) que haga primero una ejecución en seco que muestre qué cuentas va a bloquear y que alguien la revise; (3) alertar cuando una cuenta de aplicación no esté en OPEN
  (la consulta 7 del diagnóstico) antes de que falle un despliegue.
