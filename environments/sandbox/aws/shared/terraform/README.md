# Recursos compartidos de AWS

Recursos de sandbox que se conservan persistentemente, administrados por separado de las capas persistente y temporal de `eks-argocd`.

## Recursos

| Recurso | Propósito | Archivo |
| --- | --- | --- |
| **S3** | Guardar los estados de Terraform. | [terraform-state-bucket.tf](terraform-state-bucket.tf) |
| **ECR** | Almacenar las imágenes de las aplicaciones. | [ecr.tf](ecr.tf) |
| **IAM** | Usuario y permisos para publicar imágenes desde GitHub Actions. | [iam-ecr-publisher.tf](iam-ecr-publisher.tf) |

## Operación

| Aspecto | Funcionamiento |
| --- | --- |
| Aplicación de cambios | **Manual**, mediante Terraform. |
| CI | Solo valida la configuración. |
| Estado de esta capa | Se guarda en **S3**, según [backend.tf](backend.tf). |
| Workflow dependiente | La publicación en ECR de `docker-build-publish-ecr.yml`, en `paideia-infra-automations`, necesita los repositorios y permisos creados aquí. |
| Credenciales del publicador | Se configuran aparte en **GitHub Secrets**. |
