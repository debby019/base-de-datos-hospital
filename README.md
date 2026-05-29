# Base de datos HospitalDB
### Desarrollador
**Devorah Alonso Hernandez**   
Numero Control: 22760237

## Acceso y gestión de la base de datos

### Requisitos

* Tener acceso autorizado a la VPN de Tailscale del proyecto.
* Contar con credenciales SSH válidas.
* Tener permisos para acceder al servidor y al contenedor Docker de MySQL.

### Tecnologías utilizadas
* MySQL 8.0.46
* Docker
* Docker Compose

### Configuración utilizada

```sql
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
```
### Conexión al servidor

Desde la terminal local, conectarse al servidor mediante SSH:

```bash
ssh db@100.73.30.52
```

Ingresar la contraseña proporcionada por el administrador del proyecto.

### Ubicación del repositorio

Una vez dentro del servidor, acceder al repositorio de la base de datos:

```bash
cd /opt/clinica-app/Base-de-datos-Hospital
```

### Archivos principales del repositorio:

```text
DB_completa.sql
README.md
```
## Gestión de la base de datos con Docker

Verificar los contenedores activos:

```bash
docker ps
```

Ingresar al contenedor de MySQL:

```bash
docker exec -it mysql_db bash
```

Acceder al cliente MySQL:

```bash
mysql -u root -p
```

Ingresar la contraseña del usuario root proporcionada por el administrador.


### Seleccionar la base de datos
Una vez dentro de mysql seleccionar hospitaldb:   
```sql
USE hospitaldb;
```

A partir de este punto ya es posible:

* Ejecutar consultas SQL
* Modificar tablas
* Crear o eliminar triggers
* Importar archivos `.sql`
* Administrar la base de datos
* Los cambios realizados en MySQL se guardan automáticamente.



### Respaldos automáticos

El servidor realiza respaldos automáticos de la base de datos diariamente a las **2:00 AM**.

---

## Estructura general de la base de datos

La base de datos está diseñada bajo una arquitectura multi-tenant, donde cada clínica mantiene aislamiento lógico mediante el campo:

```sql
id_clinica_tenant
```

Las principales entidades del sistema son:

* usuario
* paciente
* doctores
* cita
* horarios_doctor
* bloqueo_horario
* precios_consulta
* estado_cita
* bitacora

## Características implementadas

La base de datos incluye:

* Validaciones mediante triggers
* Control de traslape de horarios
* Restricciones de citas
* Sistema de bitácora automática
* Validación de pertenencia por tenant
* Control de estados de citas
* UUIDs almacenados en formato `BINARY(16)`


## Códigos de error de triggers

| Código | Significado |
|---|---|
| 1001 | Fuera del horario del doctor |
| 1002 | Horario bloqueado |
| 1003 | Conflicto con otra cita del doctor |
| 1004 | Conflicto con otra cita del paciente |
| 1005 | Ya existe una cita pendiente con este doctor ese día |
| 1006 | Existen citas activas dentro del rango del bloqueo |
| 1007 | El usuario alcanzó el máximo de pacientes permitidos |
| 1008 | No se permiten citas en fechas pasadas |
| 1009 | El doctor no pertenece a la clínica |
| 1010 | El paciente no pertenece a la clínica |
| 1011 | El doctor está inactivo |
| 1012 | El paciente está inactivo |
| 1013 | Una cita completada no puede modificarse |
| 1014 | Una cita cancelada no puede volver a pendiente |
| 1015 | El usuario no pertenece a la clínica |
| 1016 | El doctor no pertenece a la clínica para el horario |
| 1017 | El horario se traslapa con otro horario del doctor |
| 1018 | El doctor no pertenece a la clínica para el bloqueo |


---
