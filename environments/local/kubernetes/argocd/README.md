# Argo CD local

Helm instala Argo CD. La Application raíz registra las hijas mediante **App of Apps**.

| Archivo | Función |
| --- | --- |
| [install/values.yaml](install/values.yaml) | Opciones para instalar el chart oficial de Argo CD. |
| [root-application.yaml](root-application.yaml) | Raíz `local-applications`, con sincronización automática. |
| [applications/](applications/) | Applications hijas: origen de los manifiestos, destino y política de sincronización. |

## Instalación

Desde la raíz de `paideia-infra-config`, con Kubernetes local iniciado:

Los valores de instalación configuran el usuario `admin` con contraseña `admin` para este laboratorio local.

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd \
  --version 10.17.0 \
  --kube-context docker-desktop \
  --namespace argocd \
  --create-namespace \
  -f environments/local/kubernetes/argocd/install/values.yaml \
  --wait \
  --timeout 10m
```

Si Helm 4 informa de un conflicto con `argocd-server` en `admin.password` y `admin.passwordMtime` al cambiar una contraseña existente, repetir el comando agregando `--force-conflicts`. Esto permite que Helm gestione esos campos con los valores declarados. No es necesario para una instalación nueva.

## Registro de la Application raíz

Antes de registrar la raíz, las hijas y sus manifiestos deben estar disponibles en la rama `main` de GitHub. El siguiente comando lee el archivo raíz desde el equipo y crea o actualiza su recurso en Kubernetes:

```bash
kubectl --context docker-desktop apply \
  -f environments/local/kubernetes/argocd/root-application.yaml

kubectl --context docker-desktop -n argocd get applications
```

Esperar a que aparezcan `local-applications` y sus hijas. La raíz lee `argocd/applications/` desde Git y registra las hijas automáticamente; cada hija conserva su propia política de sincronización.

Continuar con el despliegue y los túneles en [Ejecución y acceso](../README.md#ejecución).

| Cambio | Cómo aplicarlo |
| --- | --- |
| Valores de instalación | Repetir el comando de Helm con el archivo local actualizado. |
| Definición de la raíz | Repetir `kubectl apply` con el archivo local actualizado. |
| Hijas o manifiestos | Publicar en Git; sincronizar cada hija según su política. |
