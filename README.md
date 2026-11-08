# Paideia Infra Environments

Aquí viven las composiciones concretas de los ambientes de Paideia: qué recursos
usan, qué aplicaciones se habilitan y qué versiones queremos ejecutar.

Para entender el proyecto completo, empieza por la
**[vista general de la plataforma](../paideia-infra-platform/README.md)**.

## Implementado hoy

El [POC AWS en local-aws](pocs/paideia-poc-aws-microservices/local-aws/README.md)
contiene el laboratorio Compose/Floci y su Terraform: ECR, PostgreSQL, mensajería,
EC2 de estudio y Courses en ECS con ALB. Sus recursos son emulados y su estado
es independiente de cualquier cuenta AWS real.

La guía conserva el recorrido completo con Compose y diferencia la ampliación
ECS. Floci Dash permite inspeccionar los recursos emulados.

## Diseño pendiente de implementación

| Ubicación prevista | Responsabilidad |
| --- | --- |
| `foundation/terraform/` | Base conservada entre sesiones: backend, identidad CI, registro |
| `clusters/local/` | Bootstrap y aplicaciones del Kubernetes local |
| `clusters/sandbox/` | EKS temporal, política del ambiente y registro de aplicaciones |
| `pocs/<proyecto>/kubernetes/local/` | Valores/versiones del proyecto en local |
| `pocs/<proyecto>/kubernetes/sandbox/` | Valores/versiones del proyecto en AWS |
| `.github/workflows/` | Validación, promoción, creación y retirada del ambiente |

Estas rutas no son comandos ni una implementación ya disponible. La estructura
completa y sus límites están en [Arquitectura](../paideia-infra-platform/docs/arquitectura.md).

## Reglas principales

- Una aplicación puede provenir de un repositorio propio o de un monorepo.
- `main` puede construir/promover sin crear EKS si el ambiente está retirado.
- Terraform administra AWS; Argo CD administrará los recursos Kubernetes elegidos.
- La base conservada y el clúster temporal tendrán estados Terraform separados.
- Estados, credenciales y valores privados no van a Git.
- El apagado remoto requiere liberar recursos externos y comprobar qué permanece.

Consulta [Despliegues](../paideia-infra-platform/docs/despliegues.md),
[Ciclo de vida](../paideia-infra-platform/docs/ciclo-de-vida.md) y
[Costos](../paideia-infra-platform/docs/costos.md) según la operación que necesites.
