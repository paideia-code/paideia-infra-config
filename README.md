# paideia-infra-config

Configuración de infraestructura y despliegues de Paideia, organizada por entorno. Contiene escenarios de aprendizaje, sus recursos y los procedimientos concretos para operarlos. El código de las aplicaciones permanece en sus propios repositorios.

Los ejemplos de terminal usan Bash: Linux/macOS, Git Bash o WSL en Windows. Las rutas son relativas a la raíz del repositorio, salvo que se indique otra carpeta.

## Entornos

| Entorno | Propósito | Guía |
| --- | --- | --- |
| **Local / Kubernetes** | Ejecutar aplicaciones en un clúster local, gestionadas con Argo CD y App of Apps. | [Kubernetes local](environments/local/kubernetes/README.md) |
| **Local / Floci / AWS / ECS** | Practicar Courses en ECS con ALB y dependencias AWS emuladas con Floci. | [Laboratorio Floci](environments/local/floci/aws/ecs/paideia-poc-microservices-nest/README.md) |
| **Sandbox / AWS / EKS + Argo CD** | Crear y retirar un entorno AWS real y desplegar aplicaciones desde Git. | [Sandbox AWS](environments/sandbox/aws/README.md) |

## Responsabilidades

| Repositorio | Contenido |
| --- | --- |
| **paideia-infra-config** | Recursos y aplicaciones concretos, más los workflows específicos de cada escenario. |
| **paideia-infra-automations** | Tareas reutilizables de GitHub Actions para validar aplicaciones, construir imágenes y comprobar identidades AWS. |

Los procedimientos de este repositorio se describen en [Workflows de infraestructura](.github/workflows/README.md). Las guías de cada capa explican sus recursos, dependencias y forma de ejecución.

## Recorrido recomendado

1. Leer la [vista general de sandbox AWS](environments/sandbox/aws/README.md).
2. Recorrer las capas en orden: `shared` → `persistent` → `temporary` → `argocd` → `applications`.
3. Revisar los workflows que coordinan el arranque y la retirada.

Se versionan configuración, documentación y `.terraform.lock.hcl`. Los estados, planes guardados, cachés y archivos con secretos permanecen fuera de Git.
