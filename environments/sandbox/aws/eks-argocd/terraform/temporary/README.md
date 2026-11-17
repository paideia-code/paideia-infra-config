# Recursos temporales de EKS

Infraestructura de sandbox que se crea al levantar el entorno y se destruye al retirarlo. Utiliza los recursos de `shared` y los permisos preparados en la capa `persistent`.

## Recursos

| Recurso | Propósito | Archivo |
| --- | --- | --- |
| **Red** | VPC, dos subredes públicas, rutas e Internet Gateway, sin NAT Gateway. | [network.tf](network.tf) |
| **Clúster EKS** | Proporcionar Kubernetes para ejecutar las aplicaciones. | [eks.tf](eks.tf) |
| **Nodos EC2** | Máquinas donde se ejecutan los pods. | [eks.tf](eks.tf) |
| **Complementos** | Red de pods, comunicación de servicios y DNS: VPC CNI, kube-proxy y CoreDNS. | [eks.tf](eks.tf) |
| **Acceso a Kubernetes** | Autorizar al administrador y al operador de sandbox. | [eks.tf](eks.tf) |

## Operación

| Aspecto | Funcionamiento |
| --- | --- |
| Arranque y retirada | **Automatizados mediante workflows de GitHub Actions, iniciados manualmente**. |
| Workflows | `sandbox-aws-eks-argocd-up.yml` y `sandbox-aws-eks-argocd-down.yml`. |
| CI | Valida la configuración de Terraform. |
| Dependencias | Bucket de [shared](../../../shared/terraform/README.md) y roles de la [capa persistente](../persistent/README.md), consultados en [data-eks-roles.tf](data-eks-roles.tf). |
| Estado de esta capa | Se guarda en **S3**, según [backend.tf](backend.tf), separado de los otros estados. |
| Acceso a la API | `admin_cidr` autoriza la IP del administrador; `automation_cidr`, la IP temporal del runner. Se definen en [variables.tf](variables.tf). El workflow de arranque retira el acceso temporal al finalizar. |
| Capacidad actual | **Un nodo `c7i-flex.large`**, con mínimo, máximo y cantidad deseada en 1; sin escalamiento automático configurado. |
| Resultados | [outputs.tf](outputs.tf) expone los identificadores de red, el nombre del clúster y su endpoint. |

Después de Terraform, el workflow de arranque instala **Argo CD mediante Helm** y registra la aplicación raíz. Argo CD despliega las aplicaciones declaradas en Git.

La retirada conserva los recursos de `shared` y de la capa persistente. Si una ejecución falla, pueden quedar recursos creados o acceso temporal pendiente de retirar; se revisa el resultado antes de reintentar.
