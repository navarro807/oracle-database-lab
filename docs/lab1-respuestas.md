# Laboratorio 1 — Respuestas a las preguntas de comprobación

Nombre: Juan Francisco Navarro Cruz

## 1. ¿Cuál es la diferencia entre Working Directory, Staging Area y Local Repository? Da un ejemplo de un archivo pasando por las tres.

El Working Directory es la carpeta normal del proyecto, tal como la veo y la edito en mi ordenador. La Staging Area es una zona intermedia donde preparo justo lo que quiero que entre en el próximo commit. El Local Repository es el historial ya guardado dentro de la carpeta `.git`, con todos los commits confirmados.

Ejemplo real: cuando edité `README.md` con VS Code y lo guardé, estaba en el Working Directory (Git lo veía como "untracked"). Al hacer `git add README.md`, pasó a la Staging Area (apareció en verde como "Changes to be committed"). Al hacer `git commit -m "docs: add initial project documentation"`, pasó al Local Repository, quedando guardado para siempre en el historial con su propio hash (d084835).

## 2. Si modificas un archivo pero no haces git add, ¿aparece ese cambio en tu próximo commit? Explica por qué.

No, no aparece. `git commit` solo confirma lo que está en la Staging Area en ese momento. Si el archivo es nuevo o está modificado y no hice `git add`, el commit se hace sin ese cambio. Lo comprobé en la Parte E: creé `docs/customer-schema.md` y probé a hacer commit directamente sin añadirlo antes, y Git respondió "nothing added to commit but untracked files present" — el commit no se realizó porque el archivo nunca pasó por la Staging Area.

## 3. ¿Por qué git status no mostraba las carpetas vacías que creaste en la Parte C? ¿Qué truco usamos para solucionarlo?

Porque Git no versiona carpetas, solo versiona archivos. Una carpeta completamente vacía no deja ningún rastro que Git pueda registrar, así que ni siquiera aparece como "untracked". El truco que usamos fue meter un archivo pequeño dentro de cada carpeta vacía, llamado `.gitkeep` (por convención, no es una palabra especial de Git). En cuanto la carpeta tuvo un archivo real dentro, sí empezó a aparecer en `git status`.

## 4. Explica con tus palabras qué es HEAD.

HEAD es un puntero que indica en qué commit o en qué rama estoy trabajando ahora mismo. Es como un marcador de "estoy aquí" dentro del historial de Git. Cuando cambié de rama con `git switch`, vi que HEAD se movía de una rama a otra (por ejemplo, de `main` a `feature/customer-search`), y el contenido de mis carpetas cambiaba según a qué commit apuntaba HEAD en cada momento.

## 5. ¿Qué diferencia hay entre crear una branch con git switch -c y crear una carpeta nueva con mkdir? ¿Cómo lo comprobamos en la Parte G?

Son cosas completamente distintas. `mkdir` crea una carpeta física nueva en el disco duro, algo que se puede ver con el explorador de archivos. `git switch -c` crea una rama, que es solo un puntero dentro de la carpeta `.git`, no una carpeta nueva en el disco. Lo comprobamos ejecutando `git switch -c feature/customer-search` y después `ls -la`: la lista de carpetas y archivos era exactamente la misma que antes, no apareció ninguna carpeta llamada `feature`. Además, al cambiar entre `main` y `feature/customer-search` con `git switch`, el archivo `customer-search.md` aparecía y desaparecía del disco, dependiendo de en qué rama estaba, sin que yo tocara nada a mano.

## 6. Durante el conflicto de la Parte H, ¿qué representaba el contenido entre <<<<<<< HEAD y =======? ¿Y entre ======= y >>>>>>>?

Entre `<<<<<<< HEAD` y `=======` estaba la versión que ya tenía guardada en mi rama actual (en mi caso, `main`, con el título "Training Edition"). Entre `=======` y `>>>>>>> fix/readme-subtitle` estaba la versión que venía de la rama que estaba intentando fusionar (con el título "Academic Version"). Git no sabía cuál de las dos quedarme, así que me dejó elegir a mí manualmente, borrando los marcadores y escribiendo el contenido final que yo decidiera.

## 7. ¿Por qué NO se debe hacer git commit --amend sobre un commit que ya se subió con git push?

Porque `--amend` no modifica el commit anterior, sino que crea uno completamente nuevo con distinto hash, y hace que el commit viejo desaparezca del historial local. Si ese commit ya se había subido a GitHub y otra persona ya se lo había descargado, al hacer amend se crea una diferencia entre el historial de esa persona y el mío, y luego es muy complicado y peligroso arreglar esa divergencia entre ambos repositorios. La regla que usaré siempre es: amend solo si el commit es todavía local, nunca después de un push.

## 8. Si borras por accidente la carpeta .git de tu proyecto, ¿qué se pierde exactamente? ¿Se pierde también el código fuente que está en el disco?

Se pierde todo el historial de Git: todos los commits, todas las ramas, la configuración del remoto y absolutamente todo lo relacionado con el control de versiones. Sin embargo, no se pierde el código fuente que está actualmente en el disco en ese momento, porque esos archivos viven fuera de `.git`, en el Working Directory normal. Lo que sí se pierde es la posibilidad de volver a versiones anteriores, comparar cambios o recuperar algo que ya se hubiera borrado antes.

## 9. Explica con tus propias palabras la diferencia entre Git y GitHub, sin usar la palabra "nube".

Git es un programa que se instala en mi ordenador y funciona completamente offline: con Git puedo hacer commits, crear ramas, fusionar y ver el historial sin necesitar internet en ningún momento. GitHub es una página web donde puedo alojar mis repositorios de Git para que otras personas los vean, colaboren conmigo, y donde además existen herramientas extra como Pull Requests, revisión de código o gestión de tareas (Issues), que Git por sí solo no tiene.

## 10. ¿Por qué no se debe subir un archivo .env con contraseñas reales a un repositorio, aunque el repositorio sea privado?

Porque una vez que un archivo entra en el historial de Git, queda guardado ahí para siempre, incluso si luego lo borras: cualquiera con acceso al repositorio (o a versiones antiguas del historial) podría recuperar esa contraseña. Además, un repositorio "privado" puede volverse público por error, puede tener colaboradores añadidos más adelante, o puede sufrir una fuga si se hackea la cuenta. Por eso la contraseña real nunca debería llegar a estar dentro de un commit.

## 11. Un compañero te dice: "hice push y ahora GitHub me rechaza el segundo push con 'non-fast-forward'". ¿Qué ha ocurrido probablemente y qué comando ejecutarías primero?

Probablemente el repositorio remoto en GitHub tiene commits nuevos que mi compañero no tiene descargados en su copia local (por ejemplo, alguien más hizo un cambio, o él mismo editó algo directamente desde la web de GitHub). El primer comando que ejecutaría es `git pull`, para traer y fusionar esos cambios que faltan. Si al hacer pull aparece un conflicto, tocaría resolverlo igual que hicimos en la Parte H, y después ya sí se podría hacer `git push` sin problema.

## 12. ¿Qué tipo de Conventional Commit (feat, fix, docs, test…) usarías para: añadir un índice de rendimiento a una tabla, corregir una restricción mal definida, y actualizar el README?

- Añadir un índice de rendimiento a una tabla: usaría `perf`, porque es una mejora de rendimiento, no una funcionalidad nueva ni una corrección de un error.
- Corregir una restricción mal definida: usaría `fix`, porque estoy corrigiendo algo que estaba mal.
- Actualizar el README: usaría `docs`, porque es un cambio que afecta solo a documentación.
