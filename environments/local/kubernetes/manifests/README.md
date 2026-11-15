# Manifiestos de aplicaciones

Una carpeta por aplicación con sus recursos de Kubernetes. Su registro en Argo CD se declara en [argocd/applications](../argocd/applications/).

| Archivo habitual | Función |
| --- | --- |
| `namespace.yaml` | Declarar el namespace de la aplicación. |
| `deployment.yaml` | Declarar imágenes, réplicas, recursos y comprobaciones de disponibilidad. |
| `service.yaml` | Proporcionar acceso a los pods dentro del clúster. |

Cada carpeta puede incluir otros recursos según las necesidades de la aplicación.

## Agregar o actualizar una aplicación

1. Crear o modificar sus manifiestos en `manifests/<nombre>/`.
2. Para una aplicación nueva, agregar su Application en `argocd/applications/`, apuntando a esa carpeta.
3. Asegurar que los nodos puedan obtener las imágenes declaradas. Para actualizar una imagen propia, construirla con una etiqueta nueva y actualizar el Deployment.
4. Publicar los cambios en Git. Argo CD sincroniza según la política de cada hija; si es manual, ejecutar **Sync**.
