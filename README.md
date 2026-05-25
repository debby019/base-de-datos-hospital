# HospitalDB

Base de datos desarrollada en MySQL 8.0.46

## Requisitos

- MySQL Server 8.0 o superior
- MySQL Workbench (opcional)

## Configuración usada

```sql
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;
```

## Cómo importar la base de datos

### Opción 1 — MySQL Workbench

1. Abrir MySQL Workbench
2. Ir a:
   Server → Data Import

3. Seleccionar:
   Import from Self-Contained File

4. Elegir:
   DB_completa.sql

5. Presionar:
   Start Import

---

### Opción 2 — Para crear solamente la estructura:
Ejecuta los siguientes archivos en el orden mostrado:
1. tablas.sql → creación de la base de datos y tablas
2. indices.sql → creación de índices
3. triggers.sql → triggers y validaciones
4. vistas.sql→ vistas de apoyo
5. (Opcional) inserts.sql  → datos de prueba para llenar tablas.

## Usuarios existentes
Los datos de prueba incluidos utilizan la contraseña:  
```text
123456
```

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
