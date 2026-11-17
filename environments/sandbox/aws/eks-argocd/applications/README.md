# Aplicaciones de sandbox

Aplicaciones declaradas en Git que Argo CD registra y despliega en EKS. Actualmente incluye el piloto `paideia-template-nest-layered`.

## Recursos

| Recurso | Propósito | Archivo del piloto |
| --- | --- | --- |
| **Application** | Indicar a Argo CD qué repositorio, rama y carpeta desplegar. | [application.yaml](paideia-template-nest-layered/application.yaml) |
| **Namespace** | Agrupar los recursos de la aplicación en Kubernetes. | [namespace.yaml](paideia-template-nest-layered/manifests/namespace.yaml) |
| **Deployment** | Declarar la imagen, las réplicas, los recursos y la comprobación de salud del contenedor. | [deployment.yaml](paideia-template-nest-layered/manifests/deployment.yaml) |
| **Service** | Proporcionar acceso interno estable a los pods de la aplicación. | [service.yaml](paideia-template-nest-layered/manifests/service.yaml) |

## Operación

| Aspecto | Funcionamiento |
| --- | --- |
| Dependencia | EKS y [Argo CD](../argocd/README.md) preparados por el workflow de arranque. |
| Registro | La aplicación raíz `sandbox-applications` registra los archivos `application.yaml`. |
| Despliegue | Cada Application observa sus `manifests` en la rama `main` y los sincroniza **automáticamente**. |
| Namespaces | El objeto Application reside en `argocd`; los recursos del piloto, en `paideia-template-nest-layered`. |
| Versión de la aplicación | Se selecciona mediante `image` en `deployment.yaml`. Publicar ese cambio en Git permite que Argo CD lo despliegue. |
| Configuración actual | **Una réplica**, puerto `3000`, comprobación de disponibilidad en `/health` y solicitudes y límites de CPU y memoria. |
| Acceso | Service **ClusterIP** en el puerto `3000`; acceso local mediante `port-forward`, habitualmente en `23000`. |
| Borrado y corrección | `prune: false` evita el borrado automático; `selfHeal: false` no activa la corrección automática del drift. |

```text
Aplicación raíz → application.yaml → manifests → recursos de Kubernetes
```

Publicar una imagen en ECR y seleccionarla para desplegar son pasos separados. Quitar un manifiesto de Git no elimina automáticamente su recurso del clúster con la política actual.
