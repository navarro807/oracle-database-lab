# Lab 3 - Respuestas de comprobacion

## Docker

### 1. Diferencia entre imagen y contenedor
La imagen es una plantilla de solo lectura; el contenedor es una instancia en ejecucion creada a partir de ella. En G2, `docker run hello-world` creo un contenedor a partir de la imagen hello-world. En G4, `docker run -it alpine:3.20 sh` me metio dentro de un contenedor Alpine con su propio sistema de archivos.

### 2. Por que nota.txt desaparecio en G5 y no en G6
El sistema de archivos de un contenedor es temporal: al borrarlo con `docker rm` se pierde todo lo escrito dentro. En G6 escribi en un volumen con nombre, que Docker gestiona fuera del contenedor. Con `--rm` se borra el contenedor, pero no el volumen, y el segundo contenedor encontro el dato.

### 3. docker ps frente a docker ps -a, y Exited (0)
`docker ps` solo muestra los contenedores en marcha; `docker ps -a` muestra todos, tambien los detenidos. `Exited (0)` significa que el proceso principal termino correctamente; `Exited (1)` o mayor indica que termino con error.

### 4. Puertos en -p 8181:8181 y -p 80:8080
El formato es anfitrion:contenedor: el primer numero es el de mi equipo y el segundo el del contenedor. Con `-p 80:8080` en nginx, el puerto 80 de mi equipo iria al 8080 del contenedor, pero nginx escucha en el 80 dentro del contenedor, asi que la pagina no cargaria.

### 5. Por que Oracle sigue en marcha y hello-world termina solo
Un contenedor vive exactamente lo que vive su proceso principal. hello-world imprime su mensaje y acaba. En oralab-26ai el proceso principal es el motor de base de datos, que no termina mientras no se pare.

### 6. Digest de una imagen y por que se registra con :latest
El digest (sha256) es la huella digital exacta de una imagen: dos personas con el mismo digest tienen la misma imagen bit a bit. La etiqueta `latest` cambia con el tiempo, asi que el digest deja constancia de la version exacta que instale (sha256:f988b0c0...).

### 7. Que comando borraria los datos de Oracle
`docker volume rm oralab-26ai-data` (o un `docker system prune -a --volumes` con el contenedor parado). `docker rm oralab-26ai` solo borra el contenedor; los datos viven en el volumen con nombre, que sobrevive.

## Git, organizacion y evidencia

### 8. Por que dentro del repositorio con Issue, branch y Pull Request
Porque instalar un entorno es un cambio de infraestructura: queda reproducible (los scripts permiten rehacerlo), verificable (el reviewer ve scripts y salidas reales) y util para el onboarding. Una carpeta aparte perderia el historial, la proteccion de main y la revision.

### 9. source 00-config.sh frente a bash 00-config.sh
`bash` ejecuta el script en un proceso hijo que desaparece al terminar, y las variables se pierden. `source` lo ejecuta en mi propia terminal y las variables (CONT_NAME, EVID, etc.) quedan disponibles, por eso se usa source.

### 10. Nombre 20260915T091230Z_02-docker.script.log
- 20260915T091230Z: fecha y hora en UTC (15/09/2026, 09:12:30) en formato ISO 8601 compacto; la Z indica UTC.
- 02: numero del paso que genero la evidencia.
- docker: descripcion en kebab-case.
- .script.log: tipo de evidencia (salida de terminal).

### 11. Para que sirve .gitattributes
Fija los finales de linea (LF) de los .sh, .sql y .md. Evita que scripts con finales de linea de Windows (CRLF) fallen en Linux con errores como "command not found" o `$'\r'`, y evita diffs llenos de ruido.

### 12. Merge commit en lugar de Squash and merge
Cada commit corresponde a una Parte y tiene valor propio. Con "Create a merge commit" se conserva el historial paso a paso; con squash todo se aplastaria en un solo commit y se perderia cuando y como se verifico cada herramienta.

## Seguridad

### 13. Las cuatro capas de la estrategia de contrasenas
1. `.gitignore`: decirle a Git que ignore el archivo con secretos antes de crearlo.
2. Plantilla `.env.example` versionada, sin secretos reales.
3. Archivo real `config/.env`, local y nunca versionado.
4. Leer los valores como variables (`set -a; source ...; set +a`) sin escribir la contrasena a mano.
Si me salto la primera, el archivo con la contrasena podria acabar en un commit y quedaria para siempre en el historial de Git.

### 14. Por que no escribir la contrasena en el comando docker run
Todo lo que se teclea queda guardado en el historial de la terminal (.bash_history) en texto plano, aunque el script no se suba a Git. Usando una variable, en el historial solo queda el nombre de la variable.

### 15. Contrasena en un commit ya publicado
No basta con borrarla en un commit nuevo: sigue en el historial. Hay que dar la contrasena por comprometida y rotarla (cambiarla, recreando el contenedor con otra en el archivo de secretos), no hacer push si aun no se ha publicado y avisar al docente para limpiar la branch.

## Oracle y herramientas

### 16. Por que no usar SPOOL ni @archivo.sql con sqlplus dentro del contenedor
Dentro del contenedor, SPOOL escribiria el archivo en el sistema de archivos del contenedor (no en mi repositorio) y `@archivo.sql` buscaria el archivo dentro del contenedor y fallaria (SP2-0310). En su lugar, ejecute sqlplus desde el anfitrion con `docker exec -i ... < archivo.sql` y capture la salida con `tee`; el SPOOL real se hizo desde SQLcl en mi equipo.

### 17. WHENEVER SQLERROR EXIT SQL.SQLCODE
Hace que el script se detenga en el primer error SQL y salga con el codigo de error. Sin esa linea, SQL*Plus seguiria ejecutando el resto de sentencias y podria dejar la base en un estado a medias sin que se note.

### 18. Que es una migracion y por que no editar V000 y V001
Una migracion es un script SQL versionado y numerado que cambia la base de datos de forma controlada y reproducible. Una vez aplicada no se edita, porque otros companeros ya la habrian ejecutado y los esquemas dejarian de coincidir; los cambios se hacen con una migracion nueva.

### 19. Por que FREEPDB1 y no FREE ni un SID
FREEPDB1 es la base de datos enchufable (PDB) donde trabajamos; FREE es el contenedor raiz (CDB). Con Service name = FREEPDB1 se llega a la base de trabajo; usar SID o FREE llevaria al contenedor raiz.

### 20. SQLcl frente a SQL*Plus
SQLcl aporta autocompletado, historial, formato automatico, conexiones guardadas e integracion con Liquibase. SQL*Plus existe en cualquier servidor Oracle desde 1982, y si solo hay una terminal en el servidor es lo unico disponible; un DBA debe dominar ambas.

## Entorno de trabajo

### 21. Por que pasar de Git Bash a Ubuntu en WSL 2
Oracle, Docker y la infraestructura empresarial corren sobre Linux; Ubuntu en WSL 2 es Linux real y Git Bash es una emulacion. Problemas de Git Bash que desaparecen: convierte rutas como /opt a rutas de Windows y rompe argumentos de Docker, y `docker run -it` falla con "not a TTY" (hace falta winpty); ademas no trae utilidades como free, ss o htop y las herramientas Java tienen problemas al pedir contrasenas.

### 22. Por que clonar en ~/oracle-database-lab y por que bash frente a zsh
Trabajar en /mnt/c cruza dos sistemas de archivos distintos, con lo que Git y Docker van mucho mas lentos, no se conservan los permisos de ejecucion y reaparecen los problemas de finales de linea. bash es la shell por defecto de los servidores, asi que un script se comporta igual que el comando escrito a mano; zsh solo es una comodidad personal.
