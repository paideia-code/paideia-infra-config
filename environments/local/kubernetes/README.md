# Kubernetes local

Entorno para ejecutar aplicaciones en el Kubernetes de Docker Desktop, con contexto `docker-desktop`. Argo CD gestiona sus despliegues desde Git.

| Carpeta | Contenido |
| --- | --- |
| [argocd](argocd/README.md) | Instalación Helm, Application raíz y Applications hijas. |
| [manifests](manifests/README.md) | Recursos de Kubernetes agrupados por aplicación. |

## Arranque

1. Iniciar Docker Desktop y Kubernetes.
2. Tener disponibles para los nodos las imágenes declaradas en los Deployments: construidas localmente o descargables desde un registro.
3. Publicar en `main` la configuración que observará Argo CD.
4. Seguir la [instalación y registro](argocd/README.md).

La raíz registra las Applications hijas automáticamente. Cada hija define si sus recursos se sincronizan manual o automáticamente.

## Acceso

Para acceder a Argo CD, mantener este túnel abierto:

```powershell
kubectl --context docker-desktop -n argocd port-forward svc/argocd-server 20443:443
```

Abrir [https://localhost:20443](https://localhost:20443).

Para acceder a una aplicación, abrir otro túnel hacia su Service. Sustituir los valores del ejemplo por los de esa aplicación:

```powershell
$appNamespace = "mi-aplicacion"
$appService = "mi-aplicacion"
$appServicePort = 3000
kubectl --context docker-desktop -n $appNamespace port-forward "svc/$appService" "23000:${appServicePort}"
```

El acceso será por `http://localhost:23000`. Usar puertos locales distintos del rango `20000` para mantener varios túneles simultáneos.

Si el pod se reemplaza, reiniciar su túnel.
