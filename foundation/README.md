# Foundation: recursos conservados entre sesiones

Esta base contiene los repositorios ECR de Paideia. Se conserva cuando retiramos
el futuro clúster sandbox. Actualmente se opera desde el PC, en AWS real y en
`us-east-2`, utilizando el perfil `default` y la sesión de `aws login`.

El módulo reutilizable vive en `paideia-infra-terraform`. El catálogo de
repositorios está en `terraform/locals.tf`. Agregar una entrada no publica una
imagen: Terraform crea el repositorio; Docker construye y publica su contenido.

## Revisar y aplicar infraestructura

Desde PowerShell:

```powershell
Set-Location C:\paideia\infra\paideia-infra-environments
$env:AWS_PROFILE = "default"

aws sts get-caller-identity --profile default --region us-east-2

terraform -chdir=foundation/terraform init
terraform -chdir=foundation/terraform fmt
terraform -chdir=foundation/terraform validate
terraform -chdir=foundation/terraform plan
```

Revisar el plan antes de ejecutar `terraform -chdir=foundation/terraform apply`.
Un `plan` correcto no garantiza que la cuenta permita todas las operaciones de
escritura del `apply`.

El estado todavía es local: conservar `terraform/terraform.tfstate` fuera de
Git y mantener un respaldo privado. Más adelante lo migraremos a S3. Versionar
el `.terraform.lock.hcl` de esta configuración raíz. Esta base no utiliza el
estado ni los endpoints del laboratorio Floci.

## Publicar una imagen manualmente

Ejecutar los pasos en la misma sesión PowerShell, con Docker Desktop iniciado.
Detenerse si un comando falla; los comandos nativos no siempre detienen por sí
solos una secuencia PowerShell.

### 1. Preparar aplicación, repositorio y etiqueta

```powershell
Set-Location C:\paideia\templates\paideia-template-nest-layered

$appName = "paideia-template-nest-layered"
$foundationPath = "C:\paideia\infra\paideia-infra-environments\foundation\terraform"
$repositoriesJson = terraform "-chdir=$foundationPath" output -json container_repositories
if ($LASTEXITCODE -ne 0) { throw "No se pudieron consultar los outputs de Terraform." }

$repositories = $repositoriesJson | ConvertFrom-Json
$repositorio = $repositories.$appName
if (-not $repositorio) { throw "La aplicación no tiene un repositorio ECR en estos outputs." }
$registro = ($repositorio -split "/", 2)[0]

$pendingChanges = git status --porcelain
if ($LASTEXITCODE -ne 0) { throw "No se pudo consultar el repositorio Git." }
if ($pendingChanges) { throw "Revisa y guarda los cambios en Git antes de usar una etiqueta basada en el commit." }

$commit = git rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw "No se pudo consultar el commit." }
$etiqueta = "sha-$commit"
$imagen = "${repositorio}:$etiqueta"
```

La URL se obtiene de los outputs, sin copiar el número de cuenta al documento.
La etiqueta identifica el commit del código. El digest identifica el contenido
construido: reconstruir el mismo commit con dependencias externas actualizadas
puede producir un digest diferente. ECR tiene etiquetas inmutables; no se puede
sobrescribir una etiqueta existente con una imagen diferente.

### 2. Construir

```powershell
docker build --tag $imagen .
```

La imagen queda en el motor Docker local. El nombre ECR no la publica.

### 3. Autenticar Docker

El procedimiento habitual es:

```powershell
aws ecr get-login-password --profile default --region us-east-2 |
    docker login --username AWS --password-stdin $registro
```

Si la sesión AWS expiró, renovarla con
`aws login --profile default --region us-east-2`.

**Alternativa temporal para Windows:** si aparece `The stub received bad data`
al guardar credenciales, utilizar una configuración Docker separada. El error
es compatible con el problema documentado del almacén de credenciales de Windows
y contraseñas ECR largas; no demuestra un bloqueo de permisos AWS.

```powershell
$dockerEndpoint = docker context inspect --format '{{.Endpoints.docker.Host}}'
if ($LASTEXITCODE -ne 0) { throw "No se pudo consultar el endpoint de Docker." }

$dockerTemporal = Join-Path $env:TEMP ("paideia-ecr-" + [guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $dockerTemporal | Out-Null

$temporaryConfig = @{ auths = @{ $registro = @{} } }
$temporaryConfig | ConvertTo-Json -Depth 4 |
    Set-Content -LiteralPath (Join-Path $dockerTemporal "config.json") -Encoding ascii

aws ecr get-login-password --profile default --region us-east-2 |
    docker --config $dockerTemporal login --username AWS --password-stdin $registro
```

Esperar `Login Succeeded`. Esta alternativa guarda el token temporal codificado
en base64, **sin cifrar**, en la carpeta temporal. El token dura hasta 12 horas;
borrar la configuración al terminar, incluso si falla la publicación. No copiar
el archivo a Git ni compartir su contenido. No modifica la configuración Docker
habitual. Una solución duradera a evaluar es el Amazon ECR credential helper.

### 4. Publicar

Si funcionó el login habitual:

```powershell
docker push $imagen
```

Si se utilizó la configuración temporal de Windows:

```powershell
docker --config $dockerTemporal --host $dockerEndpoint push $imagen
```

`--config` selecciona las credenciales temporales. `--host` mantiene la conexión
con el motor Docker que contiene la imagen, porque esa configuración separada
no contiene los contextos de Docker Desktop.

### 5. Comprobar y limpiar

```powershell
aws ecr describe-images `
    --profile default `
    --region us-east-2 `
    --repository-name $appName `
    --query "imageDetails[].{Etiqueta:imageTags[0],Digest:imageDigest}" `
    --output table
```

Si se utilizó la alternativa temporal, ejecutar la limpieza también si el push
falló. Estos comandos eliminan únicamente el archivo y su carpeta vacía:

```powershell
Remove-Item -LiteralPath (Join-Path $dockerTemporal "config.json")
Remove-Item -LiteralPath $dockerTemporal
```

Publicar una imagen no modifica el despliegue Kubernetes ni crea EKS.

## Qué queda manual y qué se puede automatizar

GitHub Actions ya puede ejecutar CI y construir imágenes. El acceso AWS mediante
el proveedor OIDC que planificamos está bloqueado por las políticas de esta
modalidad simplificada. Esto afecta al camino previsto para publicar en ECR o
ejecutar Terraform desde runners alojados por GitHub, no a los comandos Docker
ni a Terraform en general. Otras autenticaciones tienen requisitos y riesgos
distintos; por ahora mantenemos las operaciones AWS en el PC con sesión temporal.

## Referencias

- [Publicar en ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).
- [Autenticación ECR](https://docs.aws.amazon.com/AmazonECR/latest/userguide/registry_auth.html).
- [Docker: almacenamiento de credenciales](https://docs.docker.com/reference/cli/docker/login/).
- [Problema documentado del helper de Windows](https://github.com/docker/docker-credential-helpers/issues/190).
- [Amazon ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper).
- [Políticas de la modalidad simplificada](https://docs.aws.amazon.com/accounts/latest/reference/scps-and-rcps-for-projects.html).
