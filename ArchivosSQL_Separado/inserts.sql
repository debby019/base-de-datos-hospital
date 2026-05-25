USE hospitalDB;

-- ROLES
INSERT INTO Roles (rol) VALUES 
('admin'),
('doctor'),
('recepcionista'),
('cliente');

-- PARENTESCO
INSERT INTO Parentesco (parentesco) VALUES
('titular'),
('hijo'),
('conyuge');

-- ESPECIALIDADES
INSERT INTO Especialidades (especialidad) VALUES
('Cardiología'),
('Pediatría'),
('Dermatología'),
('Neurología'),
('Medicina General');

-- ESTADOS
INSERT INTO Estado_Cita (estado) VALUES
('pendiente'),
('completada'),
('cancelada');

-- Notificaciones
INSERT INTO Tipo_Notificacion (tipo) VALUES
('recordatorio'),
('cambio'),
('cancelacion');
-- =========================================================
-- CLINICA
-- =========================================================

SET @id_clinica = UUID_TO_BIN(UUID(), 1);

INSERT INTO Clinica (
    id_clinica_tenant,
    activo
)
VALUES (
    @id_clinica,
    TRUE
);

INSERT INTO Datos_Clinica (
    id_clinica_tenant,
    nombre,
    direccion,
    telefono,
    horario_atencion,
    correo
)
VALUES (
    @id_clinica,
    'Clinica San Rafael',
    'Av. Reforma 1200, Ensenada, Baja California',
    '6461112233',
    'Lunes a Viernes 08:00 - 18:00',
    'contacto@sanrafael.com'
);

-- =========================================================
-- OBTENER IDS CATALOGO
-- =========================================================

SET @rol_admin = (
    SELECT id_rol FROM Roles
    WHERE rol = 'admin'
    LIMIT 1
);

SET @rol_doctor = (
    SELECT id_rol FROM Roles
    WHERE rol = 'doctor'
    LIMIT 1
);

SET @rol_cliente = (
    SELECT id_rol FROM Roles
    WHERE rol = 'cliente'
    LIMIT 1
);

SET @parentesco_titular = (
    SELECT id_parentesco FROM Parentesco
    WHERE parentesco = 'titular'
    LIMIT 1
);

SET @especialidad_general = (
    SELECT id_especialidad FROM Especialidades
    WHERE especialidad = 'Medicina General'
    LIMIT 1
);

SET @especialidad_pediatria = (
    SELECT id_especialidad FROM Especialidades
    WHERE especialidad = 'Pediatría'
    LIMIT 1
);

SET @estado_pendiente = (
    SELECT id_estado FROM Estado_Cita
    WHERE estado = 'pendiente'
    LIMIT 1
);

SET @estado_completada = (
    SELECT id_estado FROM Estado_Cita
    WHERE estado = 'completada'
    LIMIT 1
);

SET @tipo_recordatorio = (
    SELECT id_tipo FROM Tipo_Notificacion
    WHERE tipo = 'recordatorio'
    LIMIT 1
);

-- =========================================================
-- USUARIOS
-- password real bcrypt = "123456"
-- =========================================================

SET @user_admin = UUID_TO_BIN(UUID(), 1);
SET @user_doc1  = UUID_TO_BIN(UUID(), 1);
SET @user_doc2  = UUID_TO_BIN(UUID(), 1);
SET @user_cli1  = UUID_TO_BIN(UUID(), 1);
SET @user_cli2  = UUID_TO_BIN(UUID(), 1);

INSERT INTO Usuario (
    id_usuario,
    id_clinica_tenant,
    correo,
    telefono,
    password,
    id_rol
)
VALUES
(
    @user_admin,
    @id_clinica,
    'admin@sanrafael.com',
    '6461000001',
    '$2b$12$KbQiM6KzJ7V5mM2P6RzQzO0Kx8mK4K1bR7bA8P6pS8eA6tF2nQ1j2',
    @rol_admin
),
(
    @user_doc1,
    @id_clinica,
    'doctor1@sanrafael.com',
    '6461000002',
    '$2b$12$KbQiM6KzJ7V5mM2P6RzQzO0Kx8mK4K1bR7bA8P6pS8eA6tF2nQ1j2',
    @rol_doctor
),
(
    @user_doc2,
    @id_clinica,
    'doctor2@sanrafael.com',
    '6461000003',
    '$2b$12$KbQiM6KzJ7V5mM2P6RzQzO0Kx8mK4K1bR7bA8P6pS8eA6tF2nQ1j2',
    @rol_doctor
),
(
    @user_cli1,
    @id_clinica,
    'maria@gmail.com',
    '6461000004',
    '$2b$12$KbQiM6KzJ7V5mM2P6RzQzO0Kx8mK4K1bR7bA8P6pS8eA6tF2nQ1j2',
    @rol_cliente
),
(
    @user_cli2,
    @id_clinica,
    'juan@gmail.com',
    '6461000005',
    '$2b$12$KbQiM6KzJ7V5mM2P6RzQzO0Kx8mK4K1bR7bA8P6pS8eA6tF2nQ1j2',
    @rol_cliente
);

-- =========================================================
-- DOCTORES
-- =========================================================

SET @doctor1 = UUID_TO_BIN(UUID(), 1);
SET @doctor2 = UUID_TO_BIN(UUID(), 1);

INSERT INTO Doctores (
    id_doctor,
    id_clinica_tenant,
    nombre,
    apellido,
    curp,
    id_usuario,
    id_especialidad
)
VALUES
(
    @doctor1,
    @id_clinica,
    'Carlos',
    'Hernandez Soto',
    'HECS900101HBCXXX01',
    @user_doc1,
    @especialidad_general
),
(
    @doctor2,
    @id_clinica,
    'Patricia',
    'Lopez Vega',
    'LOVP920202MBCXXX02',
    @user_doc2,
    @especialidad_pediatria
);

-- =========================================================
-- PACIENTES
-- =========================================================

SET @paciente1 = UUID_TO_BIN(UUID(), 1);
SET @paciente2 = UUID_TO_BIN(UUID(), 1);

INSERT INTO Paciente (
    id_paciente,
    id_clinica_tenant,
    nombre,
    apellido,
    sexo,
    fecha_nacimiento,
    curp,
    id_usuario,
    id_parentesco
)
VALUES
(
    @paciente1,
    @id_clinica,
    'Maria',
    'Gonzalez Ruiz',
    'femenino',
    '1998-05-10',
    'GORM980510MBCXXX01',
    @user_cli1,
    @parentesco_titular
),
(
    @paciente2,
    @id_clinica,
    'Juan',
    'Perez Diaz',
    'masculino',
    '2001-08-20',
    'PEDJ010820HBCXXX02',
    @user_cli2,
    @parentesco_titular
);

-- =========================================================
-- HORARIOS DOCTOR
-- =========================================================

INSERT INTO Horarios_Doctor (
    id_clinica_tenant,
    dia,
    hora_inicio,
    hora_fin,
    id_doctor
)
VALUES
(@id_clinica,1,'08:00:00','14:00:00',@doctor1),
(@id_clinica,2,'08:00:00','14:00:00',@doctor1),
(@id_clinica,3,'08:00:00','14:00:00',@doctor1),
(@id_clinica,4,'08:00:00','14:00:00',@doctor1),
(@id_clinica,5,'08:00:00','14:00:00',@doctor1),

(@id_clinica,1,'10:00:00','16:00:00',@doctor2),
(@id_clinica,2,'10:00:00','16:00:00',@doctor2),
(@id_clinica,3,'10:00:00','16:00:00',@doctor2);

-- =========================================================
-- PRECIOS
-- =========================================================

INSERT INTO Precios_Consulta (
    id_clinica_tenant,
    id_doctor,
    monto
)
VALUES
(@id_clinica, @doctor1, 700.00),
(@id_clinica, @doctor2, 850.00);

-- =========================================================
-- CITAS
-- =========================================================

SET @cita1 = UUID_TO_BIN(UUID(), 1);
SET @cita2 = UUID_TO_BIN(UUID(), 1);

INSERT INTO Cita (
    id_cita,
    id_clinica_tenant,
    fecha,
    hora_inicio,
    hora_fin,
    motivo,
    id_estado,
    id_paciente,
    id_doctor
)
VALUES
(
    @cita1,
    @id_clinica,
    '2026-05-25',
    '09:00:00',
    '09:30:00',
    'Dolor de cabeza',
    @estado_pendiente,
    @paciente1,
    @doctor1
),
(
    @cita2,
    @id_clinica,
    '2026-05-26',
    '11:00:00',
    '11:30:00',
    'Consulta pediatrica',
    @estado_completada,
    @paciente2,
    @doctor2
);

-- =========================================================
-- NOTAS MEDICAS
-- =========================================================

INSERT INTO Nota_Medica (
    id_clinica_tenant,
    id_cita,
    nota
)
VALUES
(
    @id_clinica,
    @cita2,
    'Paciente estable. Se recomienda seguimiento en 6 meses.'
);

-- =========================================================
-- BLOQUEO HORARIO
-- =========================================================

INSERT INTO Bloqueo_horario (
    id_clinica_tenant,
    id_doctor,
    fecha_inicio,
    fecha_fin
)
VALUES
(
    @id_clinica,
    @doctor1,
    '2026-05-28 12:00:00',
    '2026-05-28 14:00:00'
);

-- =========================================================
-- NOTIFICACIONES
-- =========================================================

INSERT INTO Notificacion (
    id_clinica_tenant,
    id_cita,
    id_tipo,
    mensaje,
    fecha_enviada,
    estado,
    destinatario
)
VALUES
(
    @id_clinica,
    @cita1,
    @tipo_recordatorio,
    'Recordatorio de cita para mañana a las 09:00',
    NOW(),
    'enviada',
    'paciente'
);

-- =========================================================
-- BITACORA
-- =========================================================

INSERT INTO Bitacora (
    id_clinica_tenant,
    informacion
)
VALUES
(
    @id_clinica,
    'Base de datos inicializada correctamente con datos de prueba.'
);