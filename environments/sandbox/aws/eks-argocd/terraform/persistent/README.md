# Recursos persistentes de EKS

Identidades y permisos de sandbox que se conservan al retirar EKS, administrados por separado de `shared` y de la capa temporal.

## Recursos

| Recurso | Propósito | Archivo |
| --- | --- | --- |
| **Operador IAM** | Usuario que utilizan los workflows para levantar y retirar el sandbox. | [iam-operator.tf](iam-operator.tf) |
| **Roles IAM** | Permisos que utilizarán el servicio EKS y sus nodos EC2. | [iam-eks-cluster-and-node-roles.tf](iam-eks-cluster-and-node-roles.tf) |
| **Acceso al estado** | Leer y actualizar el estado temporal en S3 y gestionar su bloqueo. | [iam-operator-terraform-state.tf](iam-operator-terraform-state.tf) |
| **Acceso a red y EC2** | Gestionar los recursos de red y EC2 necesarios para sandbox. | [iam-operator-ec2.tf](iam-operator-ec2.tf) |
| **Acceso a EKS** | Gestionar el clúster y sus componentes. | [iam-operator-eks.tf](iam-operator-eks.tf) |
| **Acceso a roles** | Consultar y entregar los roles preparados a EKS y EC2. | [iam-operator-role-access.tf](iam-operator-role-access.tf) |

## Operación

| Aspecto | Funcionamiento |
| --- | --- |
| Aplicación de cambios | **Manual**, mediante Terraform con permisos para administrar IAM. |
| CI | Solo valida la configuración. |
| Dependencia | Bucket S3 creado por [shared](../../../shared/terraform/README.md), consultado en [data-shared-resources.tf](data-shared-resources.tf). |
| Estado de esta capa | Se guarda en **S3**, según [backend.tf](backend.tf), separado del estado temporal. |
| Workflows dependientes | `sandbox-aws-eks-argocd-up.yml` y `sandbox-aws-eks-argocd-down.yml` utilizan el operador y los roles preparados aquí. |
| Credenciales del operador | Se configuran aparte en **GitHub Secrets**. |
| Resultados | [outputs.tf](outputs.tf) expone los identificadores AWS (ARN) del operador y de los roles. |
