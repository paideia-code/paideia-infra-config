# Kubernetes local

Entorno para ejecutar aplicaciones en el Kubernetes de Docker Desktop, con contexto `docker-desktop`. Argo CD gestiona sus despliegues desde Git.

| Carpeta | Contenido |
| --- | --- |
| [argocd](argocd/README.md) | Instalación Helm, Application raíz y Applications hijas. |
| [manifests](manifests/README.md) | Recursos de Kubernetes agrupados por aplicación. |

## Ejecución

Requisitos: Docker Desktop con Kubernetes habilitado, `kubectl` y Helm. Ejecutar los comandos desde la raíz de `paideia-infra-config`. Los ejemplos con variables utilizan Bash (Linux/macOS, Git Bash o WSL en Windows).

1. **Iniciar Kubernetes local.** Abrir Docker Desktop y esperar a que este comando muestre el nodo en estado `Ready`:

   ```bash
   kubectl --context docker-desktop get nodes
   ```

2. **Preparar las imágenes.** Revisar `image` en los Deployments de [manifests/](manifests/). Las imágenes locales deben estar construidas y disponibles para los nodos; las de un registro deben poder descargarse.

3. **Comprobar la configuración en GitHub.** Argo CD leerá la rama `main` del repositorio indicado en cada Application. Si modificaste las hijas o sus manifiestos, subir esos cambios mediante commit y push. Con un clon sin cambios, no hace falta publicar nada.

4. **Instalar o actualizar Argo CD.** Ejecutar el [comando de instalación con Helm](argocd/README.md#instalación). Omitirlo si la instalación ya utiliza los valores actuales.

5. **Registrar la Application raíz.** Ejecutar el [comando de registro](argocd/README.md#registro-de-la-application-raíz). La raíz crea o actualiza automáticamente las hijas declaradas en Git. Repetir este comando cuando cambie la definición de la raíz.

6. **Desplegar las aplicaciones.** Abrir la web de Argo CD siguiendo [Acceso a Argo CD](#argo-cd). En cada hija con sincronización manual, ejecutar **Sync → Synchronize**. Esperar a que las aplicaciones que se quieran utilizar estén `Synced` y `Healthy` antes de abrir sus túneles.

## Acceso

### Argo CD

Después de instalar Argo CD, ejecutar en una terminal y mantenerla abierta:

```bash
kubectl --context docker-desktop -n argocd port-forward svc/argocd-server 20443:443
```

Abrir [https://localhost:20443](https://localhost:20443) y aceptar el certificado autofirmado de esta instalación local. Las credenciales se configuran con [install/values.yaml](argocd/install/values.yaml):

| Usuario | Contraseña |
| --- | --- |
| `admin` | `admin` |

### Aplicaciones

Después de desplegar una aplicación, abrir otra terminal. Sustituir las variables por su namespace, el nombre de su Service y el puerto declarado en `spec.ports[].port` del Service:

```bash
APP_NAMESPACE="mi-aplicacion"
APP_SERVICE="mi-aplicacion"
APP_SERVICE_PORT=3000
kubectl --context docker-desktop -n "$APP_NAMESPACE" port-forward "svc/$APP_SERVICE" "23000:$APP_SERVICE_PORT"
```

Mantener la terminal abierta. Para una aplicación HTTP, acceder a `http://localhost:23000` y a la ruta que exponga. Usar un puerto local libre entre `20000` y `29999` para cada túnel simultáneo.

Cerrar un túnel con `Ctrl+C`. Si el pod al que está conectado se reemplaza y el túnel se corta, volver a ejecutar su comando.
