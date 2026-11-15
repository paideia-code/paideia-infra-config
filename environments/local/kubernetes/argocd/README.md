# Argo CD local

Helm instala Argo CD. La Application raíz registra las hijas mediante **App of Apps**.

| Archivo | Función |
| --- | --- |
| [install/values.yaml](install/values.yaml) | Opciones para instalar el chart oficial de Argo CD. |
| [root-application.yaml](root-application.yaml) | Raíz `local-applications`, con sincronización automática. |
| [applications/](applications/) | Applications hijas: origen de los manifiestos, destino y política de sincronización. |

## Instalación

Desde la raíz de `paideia-infra-config`, con Kubernetes local iniciado:

```powershell
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm upgrade --install argocd argo/argo-cd `
  --version 10.17.0 `
  --kube-context docker-desktop `
  --namespace argocd `
  --create-namespace `
  -f environments/local/kubernetes/argocd/install/values.yaml `
  --wait `
  --timeout 10m
```

## Registro

Publicar primero en Git la raíz, las hijas y los manifiestos:

```powershell
kubectl --context docker-desktop apply `
  -f environments/local/kubernetes/argocd/root-application.yaml

kubectl --context docker-desktop -n argocd get applications
```

La raíz registra las hijas. Para cada hija sin sincronización automática, hacer **Sync** para desplegar sus recursos.

Los cambios en `install/values.yaml` se aplican repitiendo el comando de Helm; los de la raíz, repitiendo `kubectl apply`.
