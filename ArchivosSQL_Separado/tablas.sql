CREATE DATABASE hospitalDB
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

USE hospitalDB;


CREATE TABLE Roles (
    id_rol CHAR(12) PRIMARY KEY 
        DEFAULT (SUBSTRING(REPLACE(UUID(), '-', ''), 1, 12)),
    rol VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE Parentesco (
    id_parentesco CHAR(12) PRIMARY KEY 
        DEFAULT (SUBSTRING(REPLACE(UUID(), '-', ''), 1, 12)),
    parentesco VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Especialidades (
    id_especialidad CHAR(12) PRIMARY KEY 
        DEFAULT (SUBSTRING(REPLACE(UUID(), '-', ''), 1, 12)),
    especialidad VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Estado_Cita (
    id_estado CHAR(12) PRIMARY KEY 
        DEFAULT (SUBSTRING(REPLACE(UUID(), '-', ''), 1, 12)),
    estado VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE Tipo_Notificacion (
    id_tipo CHAR(12) PRIMARY KEY
        DEFAULT (SUBSTRING(REPLACE(UUID(), '-', ''), 1, 12)),
    tipo VARCHAR(50) UNIQUE NOT NULL
);


-- TABLA TENANT

CREATE TABLE Clinica (
    id_clinica_tenant BINARY(16) PRIMARY KEY
        DEFAULT (UUID_TO_BIN(UUID(), 1)),

    activo BOOLEAN DEFAULT TRUE,

    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- tabla Bitacora
CREATE TABLE Bitacora (
    id_bitacora BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1)),
    id_clinica_tenant BINARY(16) NOT NULL,

    informacion TEXT NOT NULL, 

    fecha_movimiento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant) ON DELETE CASCADE
);

CREATE TABLE Datos_Clinica (
    id_datos_clinica BINARY(16) PRIMARY KEY
        DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL UNIQUE,

    nombre VARCHAR(150) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    telefono VARCHAR(20),
    horario_atencion VARCHAR(100),
    correo VARCHAR(100),

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant) ON DELETE CASCADE
);


CREATE TABLE Usuario (
    id_usuario BINARY(16) PRIMARY KEY
        DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    correo VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    id_rol CHAR(12) NOT NULL,
    FOREIGN KEY (id_rol) REFERENCES Roles(id_rol),

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant)
);


CREATE TABLE Paciente (
    id_paciente BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(150) NOT NULL,

    sexo ENUM('masculino','femenino','otro') NOT NULL,

    fecha_nacimiento DATE NOT NULL,

    curp VARCHAR(18) UNIQUE NOT NULL,

    activo BOOLEAN DEFAULT TRUE,
    fecha_baja DATETIME NULL,

    id_usuario BINARY(16) NOT NULL,
    id_parentesco CHAR(12) NOT NULL,

    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE,

    FOREIGN KEY (id_parentesco) REFERENCES Parentesco(id_parentesco),

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant)
);


CREATE TABLE Doctores (
    id_doctor BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(150) NOT NULL,

    curp VARCHAR(18) UNIQUE NOT NULL,

    activo BOOLEAN DEFAULT TRUE,
    fecha_baja DATETIME NULL,

    id_usuario BINARY(16) UNIQUE NOT NULL,
    id_especialidad CHAR(12) NOT NULL,

    FOREIGN KEY (id_especialidad) REFERENCES Especialidades(id_especialidad),

    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario) ON DELETE CASCADE,

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant)
);


CREATE TABLE Horarios_Doctor (
    id_horario BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    dia TINYINT UNSIGNED NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,

    id_doctor BINARY(16) NOT NULL,

    FOREIGN KEY (id_doctor) REFERENCES Doctores(id_doctor) ON DELETE CASCADE,

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant),

    CHECK (hora_fin > hora_inicio),
    CHECK (dia BETWEEN 1 AND 7)
);


CREATE TABLE Cita (
    id_cita BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    fecha DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,

    motivo TEXT NOT NULL,

    id_estado CHAR(12) NOT NULL,
    id_paciente BINARY(16) NOT NULL,
    id_doctor BINARY(16) NOT NULL,

    FOREIGN KEY (id_paciente) REFERENCES Paciente(id_paciente) ON DELETE CASCADE,

    FOREIGN KEY (id_doctor) REFERENCES Doctores(id_doctor) ON DELETE CASCADE,

    FOREIGN KEY (id_estado) REFERENCES Estado_Cita(id_estado),

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant),

    CHECK (hora_fin > hora_inicio)
);


CREATE TABLE Nota_Medica (
    id_nota BINARY(16) PRIMARY KEY
        DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    id_cita BINARY(16) NOT NULL UNIQUE,

    nota TEXT NOT NULL,

    FOREIGN KEY (id_cita) REFERENCES Cita(id_cita) ON DELETE CASCADE,

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant)
);


CREATE TABLE Bloqueo_horario (
    id_bloqueo BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    id_doctor BINARY(16) NOT NULL,

    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,

    FOREIGN KEY (id_doctor) REFERENCES Doctores(id_doctor)
        ON DELETE CASCADE,

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant),

    CHECK (fecha_fin > fecha_inicio)
);


CREATE TABLE Precios_Consulta (
    id_precio BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    id_doctor BINARY(16) NOT NULL UNIQUE,

    monto DECIMAL(10,2) NOT NULL,

    FOREIGN KEY (id_doctor) REFERENCES Doctores(id_doctor) ON DELETE CASCADE,

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant),

    CHECK (monto >= 0)
);


CREATE TABLE Notificacion (
    id_notificacion BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1)),

    id_clinica_tenant BINARY(16) NOT NULL,

    id_cita BINARY(16) NOT NULL,
    id_tipo CHAR(12) NOT NULL,

    mensaje TEXT NOT NULL,

    fecha_enviada DATETIME NOT NULL,

    estado ENUM('pendiente', 'enviada', 'fallida') NOT NULL DEFAULT 'pendiente',

    destinatario ENUM('paciente','doctor') NOT NULL,

    FOREIGN KEY (id_cita) REFERENCES Cita(id_cita) ON DELETE CASCADE,

    FOREIGN KEY (id_tipo) REFERENCES Tipo_Notificacion(id_tipo),

    FOREIGN KEY (id_clinica_tenant) REFERENCES Clinica(id_clinica_tenant)
);
