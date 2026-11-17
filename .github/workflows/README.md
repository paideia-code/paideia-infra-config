# Workflows de infraestructura

Procedimientos específicos para operar `sandbox/aws/eks-argocd` y validar la configuración de este repositorio.

## Workflows

| Workflow | Propósito | Activación |
| --- | --- | --- |
| [Comprobar identidad](sandbox-aws-eks-argocd-check-identity.yml) | Verificar la cuenta y el usuario operador de AWS. | Manual. |
| [Levantar sandbox](sandbox-aws-eks-argocd-up.yml) | Crear la infraestructura temporal, instalar Argo CD, registrar la raíz y esperar aplicaciones sincronizadas y saludables. | Manual. |
| [Retirar sandbox](sandbox-aws-eks-argocd-down.yml) | Destruir la infraestructura temporal, conservando los recursos compartidos y persistentes. | Manual, confirmando `paideia-code-sandbox`. |
| [Validar Terraform](sandbox-aws-terraform-validate.yml) | Comprobar formato, inicializar sin backend y validar las tres configuraciones Terraform de sandbox AWS. | Push a `main` y pull requests con cambios en sus rutas; también manual. |
| [Validar workflows](ci-workflows.yml) | Revisar los workflows con actionlint. | Push a `main` y pull requests con cambios en `.github/workflows`; también manual. |

## Operación

| Aspecto | Funcionamiento |
| --- | --- |
| Ejecución | Máquinas de **GitHub Actions** con Ubuntu; independientes del PC del usuario. |
| Preparación previa | Aplicar manualmente [shared](../../environments/sandbox/aws/shared/terraform/README.md) y la [capa persistente](../../environments/sandbox/aws/eks-argocd/terraform/persistent/README.md). |
| Variables | `AWS_REGION`, `AWS_ACCOUNT_ID` y `SANDBOX_ADMIN_CIDR` (IP pública del administrador con `/32`). |
| Credenciales AWS | GitHub Secrets: `AWS_SANDBOX_OPERATOR_ACCESS_KEY_ID` y `AWS_SANDBOX_OPERATOR_SECRET_ACCESS_KEY`. |
| Tarea reutilizada | Comprobación de identidad desde `paideia-infra-automations`, referenciada como `aws-identity-check.yml@v0.9.0`. La versión debe estar publicada. |
| Operaciones AWS | Restringidas a `main`. El arranque rechaza eliminaciones o reemplazos; la retirada comprueba el alcance de su plan. |
| Concurrencia | Arranque y retirada comparten un grupo para evitar ejecuciones simultáneas. |
| Acceso temporal | El arranque autoriza la IP del runner para acceder a EKS y después intenta retirarla, admitiendo únicamente ese cambio. |

```text
Verificar identidad → Terraform temporal → Helm / Argo CD → Applications → retirar IP del runner
```

Las validaciones de CI no despliegan infraestructura. Un fallo no revierte automáticamente los recursos ya creados; puede dejar infraestructura o acceso temporal pendientes de retirar. Revisar los logs y el estado antes de reintentar.
