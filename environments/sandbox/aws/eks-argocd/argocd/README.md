# Argo CD en sandbox

Configuración de Argo CD y de la aplicación raíz que registra las aplicaciones de sandbox desde Git, mediante el patrón **App of Apps**.

## Recursos

| Recurso | Propósito | Archivo |
| --- | --- | --- |
| **Argo CD** | Configurar la instalación Helm: servicio interno, Dex y notificaciones desactivados, ApplicationSet con cero réplicas. | [values.yaml](values.yaml) |
| **Aplicación raíz** | `sandbox-applications` registra y actualiza las aplicaciones hijas declaradas en Git. | [root-application.yaml](root-application.yaml) |

## Operación

| Aspecto | Funcionamiento |
| --- | --- |
| Dependencia | Clúster y nodos preparados por la [capa temporal](../terraform/temporary/README.md). |
| Instalación | `sandbox-aws-eks-argocd-up.yml` instala Argo CD con **Helm** y registra la raíz con **kubectl**, en el namespace `argocd`. |
| Git observado | Rama `main` de `paideia-infra-config`; carpeta [applications](../applications), buscando recursivamente `**/application.yaml`. |
| Política de la raíz | Sincronización **automática**, con `prune: false` y `selfHeal: false`: sin borrado automático ni corrección automática del drift. Cada hija define su propia política. |
| Cambios en esta capa | Se aplican al ejecutar el paso de instalación del workflow o mediante Helm y kubectl manualmente. La raíz observa `applications`, no su propio archivo ni `values.yaml`. |
| Acceso web | Servicio **ClusterIP**, accesible localmente mediante `port-forward`. |
| Retirada | Al destruir EKS se eliminan Argo CD y sus recursos del clúster. Los archivos permanecen en Git para reconstruirlos. |

```text
Git → aplicación raíz → Applications hijas → recursos de las aplicaciones
```
