DELIMITER $$

CREATE TRIGGER trg_insert_cita
BEFORE INSERT ON Cita
FOR EACH ROW
BEGIN
    DECLARE v_dia INT;

    DECLARE v_cancelado CHAR(12);
    DECLARE v_pendiente CHAR(12);

    DECLARE v_doctor_tenant BINARY(16);
    DECLARE v_paciente_tenant BINARY(16);

    DECLARE v_doctor_activo BOOLEAN;
    DECLARE v_paciente_activo BOOLEAN;

    SET v_dia = DAYOFWEEK(NEW.fecha);

    SELECT id_estado
    INTO v_cancelado
    FROM Estado_Cita
    WHERE estado = 'cancelada'
    LIMIT 1;

    SELECT id_estado
    INTO v_pendiente
    FROM Estado_Cita
    WHERE estado = 'pendiente'
    LIMIT 1;

  
    -- VALIDAR FECHA PASADA


    IF NEW.fecha < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1008,
            MESSAGE_TEXT = 'No se pueden crear citas en fechas pasadas';
    END IF;


    -- VALIDAR TENANT DOCTOR


    SELECT id_clinica_tenant, activo
    INTO v_doctor_tenant, v_doctor_activo
    FROM Doctores
    WHERE id_doctor = NEW.id_doctor;

    IF v_doctor_tenant <> NEW.id_clinica_tenant THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1009,
            MESSAGE_TEXT = 'El doctor no pertenece a la clinica';
    END IF;

 
    -- VALIDAR TENANT PACIENTE


    SELECT id_clinica_tenant, activo
    INTO v_paciente_tenant, v_paciente_activo
    FROM Paciente
    WHERE id_paciente = NEW.id_paciente;

    IF v_paciente_tenant <> NEW.id_clinica_tenant THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1010,
            MESSAGE_TEXT = 'El paciente no pertenece a la clinica';
    END IF;

  
    -- VALIDAR DOCTOR ACTIVO
  

    IF v_doctor_activo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1011,
            MESSAGE_TEXT = 'El doctor esta inactivo';
    END IF;


    -- VALIDAR PACIENTE ACTIVO


    IF v_paciente_activo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1012,
            MESSAGE_TEXT = 'El paciente esta inactivo';
    END IF;


    -- VALIDAR HORARIO DOCTOR


    IF NOT EXISTS (
        SELECT 1
        FROM Horarios_Doctor
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND dia = v_dia
          AND NEW.hora_inicio >= hora_inicio
          AND NEW.hora_fin <= hora_fin
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1001,
            MESSAGE_TEXT = 'Fuera del horario del doctor';

    END IF;

    -- =========================================
    -- VALIDAR BLOQUEOS
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Bloqueo_horario
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND NOT (
                TIMESTAMP(NEW.fecha, NEW.hora_fin) <= fecha_inicio
                OR
                TIMESTAMP(NEW.fecha, NEW.hora_inicio) >= fecha_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1002,
            MESSAGE_TEXT = 'Horario bloqueado';

    END IF;

    -- =========================================
    -- CONFLICTO DOCTOR
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Cita
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND fecha = NEW.fecha
          AND id_estado <> v_cancelado
          AND NOT (
                NEW.hora_fin <= hora_inicio
                OR
                NEW.hora_inicio >= hora_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1003,
            MESSAGE_TEXT = 'Conflicto con otra cita del doctor';

    END IF;

    -- =========================================
    -- CONFLICTO PACIENTE
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Cita
        WHERE id_paciente = NEW.id_paciente
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND fecha = NEW.fecha
          AND id_estado <> v_cancelado
          AND NOT (
                NEW.hora_fin <= hora_inicio
                OR
                NEW.hora_inicio >= hora_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1004,
            MESSAGE_TEXT = 'Conflicto con otra cita del paciente';

    END IF;

    -- =========================================
    -- DOBLE CITA PENDIENTE
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Cita
        WHERE id_paciente = NEW.id_paciente
          AND id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND fecha = NEW.fecha
          AND id_estado = v_pendiente
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1005,
            MESSAGE_TEXT = 'Ya existe una cita pendiente con este doctor ese día';

    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_update_cita
BEFORE UPDATE ON Cita
FOR EACH ROW
BEGIN

    DECLARE v_dia INT;

    DECLARE v_cancelado CHAR(12);
    DECLARE v_completada CHAR(12);
    DECLARE v_pendiente CHAR(12);

    DECLARE v_doctor_tenant BINARY(16);
    DECLARE v_paciente_tenant BINARY(16);

    DECLARE v_doctor_activo BOOLEAN;
    DECLARE v_paciente_activo BOOLEAN;

    SET v_dia = DAYOFWEEK(NEW.fecha);

    SELECT id_estado
    INTO v_cancelado
    FROM Estado_Cita
    WHERE estado = 'cancelada'
    LIMIT 1;

    SELECT id_estado
    INTO v_completada
    FROM Estado_Cita
    WHERE estado = 'completada'
    LIMIT 1;

    SELECT id_estado
    INTO v_pendiente
    FROM Estado_Cita
    WHERE estado = 'pendiente'
    LIMIT 1;

    -- =========================================
    -- VALIDAR FECHA PASADA
    -- =========================================

    IF NEW.fecha < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1008,
            MESSAGE_TEXT = 'No se pueden asignar citas en fechas pasadas';
    END IF;

    -- =========================================
    -- VALIDAR TENANT DOCTOR
    -- =========================================

    SELECT id_clinica_tenant, activo
    INTO v_doctor_tenant, v_doctor_activo
    FROM Doctores
    WHERE id_doctor = NEW.id_doctor;

    IF v_doctor_tenant <> NEW.id_clinica_tenant THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1009,
            MESSAGE_TEXT = 'El doctor no pertenece a la clinica';
    END IF;

    -- =========================================
    -- VALIDAR TENANT PACIENTE
    -- =========================================

    SELECT id_clinica_tenant, activo
    INTO v_paciente_tenant, v_paciente_activo
    FROM Paciente
    WHERE id_paciente = NEW.id_paciente;

    IF v_paciente_tenant <> NEW.id_clinica_tenant THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1010,
            MESSAGE_TEXT = 'El paciente no pertenece a la clinica';
    END IF;

    -- =========================================
    -- VALIDAR DOCTOR ACTIVO
    -- =========================================

    IF v_doctor_activo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1011,
            MESSAGE_TEXT = 'El doctor esta inactivo';
    END IF;

    -- =========================================
    -- VALIDAR PACIENTE ACTIVO
    -- =========================================

    IF v_paciente_activo = FALSE THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1012,
            MESSAGE_TEXT = 'El paciente esta inactivo';
    END IF;

    -- =========================================
    -- NO MODIFICAR COMPLETADAS
    -- =========================================

    IF OLD.id_estado = v_completada
       AND NEW.id_estado <> v_completada THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1013,
            MESSAGE_TEXT = 'Una cita completada no puede modificarse';

    END IF;

    -- =========================================
    -- CANCELADA -> PENDIENTE
    -- =========================================

    IF OLD.id_estado = v_cancelado
       AND NEW.id_estado = v_pendiente THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1014,
            MESSAGE_TEXT = 'Una cita cancelada no puede volver a pendiente';

    END IF;

    -- =========================================
    -- VALIDAR HORARIO
    -- =========================================

    IF NOT EXISTS (
        SELECT 1
        FROM Horarios_Doctor
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND dia = v_dia
          AND NEW.hora_inicio >= hora_inicio
          AND NEW.hora_fin <= hora_fin
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1001,
            MESSAGE_TEXT = 'Fuera del horario del doctor';

    END IF;

    -- =========================================
    -- VALIDAR BLOQUEO
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Bloqueo_horario
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND NOT (
                TIMESTAMP(NEW.fecha, NEW.hora_fin) <= fecha_inicio
                OR
                TIMESTAMP(NEW.fecha, NEW.hora_inicio) >= fecha_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1002,
            MESSAGE_TEXT = 'Horario bloqueado';

    END IF;

    -- =========================================
    -- CONFLICTO DOCTOR
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Cita
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND fecha = NEW.fecha
          AND id_estado <> v_cancelado
          AND id_cita <> OLD.id_cita
          AND NOT (
                NEW.hora_fin <= hora_inicio
                OR
                NEW.hora_inicio >= hora_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1003,
            MESSAGE_TEXT = 'Conflicto con otra cita del doctor';

    END IF;

    -- =========================================
    -- CONFLICTO PACIENTE
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Cita
        WHERE id_paciente = NEW.id_paciente
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND fecha = NEW.fecha
          AND id_estado <> v_cancelado
          AND id_cita <> OLD.id_cita
          AND NOT (
                NEW.hora_fin <= hora_inicio
                OR
                NEW.hora_inicio >= hora_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1004,
            MESSAGE_TEXT = 'Conflicto con otra cita del paciente';

    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_limite_pacientes
BEFORE INSERT ON Paciente
FOR EACH ROW
BEGIN

    DECLARE v_count INT;
    DECLARE v_usuario_tenant BINARY(16);


    -- VALIDAR TENANT USUARIO

    SELECT id_clinica_tenant
    INTO v_usuario_tenant
    FROM Usuario
    WHERE id_usuario = NEW.id_usuario;

    IF v_usuario_tenant <> NEW.id_clinica_tenant THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1015,
            MESSAGE_TEXT = 'El usuario no pertenece a la clinica';

    END IF;
    -- VALIDAR LIMITE PACIENTES

    SELECT COUNT(*)
    INTO v_count
    FROM Paciente
    WHERE id_usuario = NEW.id_usuario
      AND id_clinica_tenant = NEW.id_clinica_tenant
      AND activo = TRUE;

    IF v_count >= 5 THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1007,
            MESSAGE_TEXT = 'El usuario ya tiene el máximo de 5 pacientes registrados';

    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_insert_horario_doctor
BEFORE INSERT ON Horarios_Doctor
FOR EACH ROW
BEGIN

    DECLARE v_doctor_tenant BINARY(16);


    -- VALIDAR TENANT DOCTOR

    SELECT id_clinica_tenant
    INTO v_doctor_tenant
    FROM Doctores
    WHERE id_doctor = NEW.id_doctor;

    IF v_doctor_tenant <> NEW.id_clinica_tenant THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1016,
            MESSAGE_TEXT = 'El doctor no pertenece a la clinica';

    END IF;
    -- VALIDAR HORARIO TRASLAPADO

    IF EXISTS (
        SELECT 1
        FROM Horarios_Doctor
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND dia = NEW.dia
          AND NOT (
                NEW.hora_fin <= hora_inicio
                OR
                NEW.hora_inicio >= hora_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1017,
            MESSAGE_TEXT = 'El horario se traslapa con otro horario del doctor';

    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_update_horario_doctor
BEFORE UPDATE ON Horarios_Doctor
FOR EACH ROW
BEGIN

    DECLARE v_doctor_tenant BINARY(16);


    -- VALIDAR TENANT DOCTOR

    SELECT id_clinica_tenant
    INTO v_doctor_tenant
    FROM Doctores
    WHERE id_doctor = NEW.id_doctor;

    IF v_doctor_tenant <> NEW.id_clinica_tenant THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1016,
            MESSAGE_TEXT = 'El doctor no pertenece a la clinica';

    END IF;

    -- VALIDAR HORARIO TRASLAPADO


    IF EXISTS (
        SELECT 1
        FROM Horarios_Doctor
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND dia = NEW.dia
          AND id_horario <> OLD.id_horario
          AND NOT (
                NEW.hora_fin <= hora_inicio
                OR
                NEW.hora_inicio >= hora_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1017,
            MESSAGE_TEXT = 'El horario se traslapa con otro horario del doctor';

    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_insert_bloqueo
BEFORE INSERT ON Bloqueo_horario
FOR EACH ROW
BEGIN

    DECLARE v_cancelado CHAR(12);
    DECLARE v_doctor_tenant BINARY(16);

    SELECT id_estado
    INTO v_cancelado
    FROM Estado_Cita
    WHERE estado = 'cancelada'
    LIMIT 1;

    -- =========================================
    -- VALIDAR TENANT DOCTOR
    -- =========================================

    SELECT id_clinica_tenant
    INTO v_doctor_tenant
    FROM Doctores
    WHERE id_doctor = NEW.id_doctor;

    IF v_doctor_tenant <> NEW.id_clinica_tenant THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1018,
            MESSAGE_TEXT = 'El doctor no pertenece a la clinica';

    END IF;

    -- =========================================
    -- VALIDAR CITAS ACTIVAS
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Cita
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND id_estado <> v_cancelado
          AND NOT (
                TIMESTAMP(fecha, hora_fin) <= NEW.fecha_inicio
                OR
                TIMESTAMP(fecha, hora_inicio) >= NEW.fecha_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1006,
            MESSAGE_TEXT = 'No se puede crear el bloqueo: existen citas activas en ese rango';

    END IF;

END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_update_bloqueo
BEFORE UPDATE ON Bloqueo_horario
FOR EACH ROW
BEGIN

    DECLARE v_cancelado CHAR(12);
    DECLARE v_doctor_tenant BINARY(16);

    SELECT id_estado
    INTO v_cancelado
    FROM Estado_Cita
    WHERE estado = 'cancelada'
    LIMIT 1;

    -- =========================================
    -- VALIDAR TENANT DOCTOR
    -- =========================================

    SELECT id_clinica_tenant
    INTO v_doctor_tenant
    FROM Doctores
    WHERE id_doctor = NEW.id_doctor;

    IF v_doctor_tenant <> NEW.id_clinica_tenant THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1018,
            MESSAGE_TEXT = 'El doctor no pertenece a la clinica';

    END IF;

    -- =========================================
    -- VALIDAR CITAS ACTIVAS
    -- =========================================

    IF EXISTS (
        SELECT 1
        FROM Cita
        WHERE id_doctor = NEW.id_doctor
          AND id_clinica_tenant = NEW.id_clinica_tenant
          AND id_estado <> v_cancelado
          AND NOT (
                TIMESTAMP(fecha, hora_fin) <= NEW.fecha_inicio
                OR
                TIMESTAMP(fecha, hora_inicio) >= NEW.fecha_fin
          )
    ) THEN

        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1006,
            MESSAGE_TEXT = 'No se puede modificar el bloqueo: conflicto con citas existentes';

    END IF;

END$$

DELIMITER ;

-- =====================================================
-- BITACORA USUARIO ELIMINADO
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_bitacora_delete_usuario
AFTER DELETE ON Usuario
FOR EACH ROW
BEGIN

    INSERT INTO Bitacora (
        id_clinica_tenant,
        informacion
    )
    VALUES (
        OLD.id_clinica_tenant,

        CONCAT(
            'Usuario eliminado | ID Usuario: ',
            BIN_TO_UUID(OLD.id_usuario),
            ' | Correo: ',
            OLD.correo,
            ' | Telefono: ',
            OLD.telefono
        )
    );

END$$

DELIMITER ;


-- =====================================================
-- BITACORA PACIENTE ACTIVADO/DESACTIVADO
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_bitacora_update_paciente
AFTER UPDATE ON Paciente
FOR EACH ROW
BEGIN

    IF OLD.activo <> NEW.activo THEN

        INSERT INTO Bitacora (
            id_clinica_tenant,
            informacion
        )
        VALUES (
            NEW.id_clinica_tenant,

            CONCAT(
                'Paciente ',
                IF(NEW.activo = TRUE, 'activado', 'desactivado'),
                ' | ID Paciente: ',
                BIN_TO_UUID(NEW.id_paciente),
                ' | Nombre: ',
                NEW.nombre,
                ' ',
                NEW.apellido,
                ' | CURP: ',
                NEW.curp
            )
        );

    END IF;

END$$

DELIMITER ;


-- =====================================================
-- BITACORA PACIENTE ELIMINADO
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_bitacora_delete_paciente
AFTER DELETE ON Paciente
FOR EACH ROW
BEGIN

    INSERT INTO Bitacora (
        id_clinica_tenant,
        informacion
    )
    VALUES (
        OLD.id_clinica_tenant,

        CONCAT(
            'Paciente eliminado | ID Paciente: ',
            BIN_TO_UUID(OLD.id_paciente),
            ' | Nombre: ',
            OLD.nombre,
            ' ',
            OLD.apellido,
            ' | CURP: ',
            OLD.curp
        )
    );

END$$

DELIMITER ;


-- =====================================================
-- BITACORA DOCTOR ACTIVADO/DESACTIVADO
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_bitacora_update_doctor
AFTER UPDATE ON Doctores
FOR EACH ROW
BEGIN

    IF OLD.activo <> NEW.activo THEN

        INSERT INTO Bitacora (
            id_clinica_tenant,
            informacion
        )
        VALUES (
            NEW.id_clinica_tenant,

            CONCAT(
                'Doctor ',
                IF(NEW.activo = TRUE, 'activado', 'desactivado'),
                ' | ID Doctor: ',
                BIN_TO_UUID(NEW.id_doctor),
                ' | Nombre: ',
                NEW.nombre,
                ' ',
                NEW.apellido,
                ' | CURP: ',
                NEW.curp
            )
        );

    END IF;

END$$

DELIMITER ;


-- =====================================================
-- BITACORA DOCTOR ELIMINADO
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_bitacora_delete_doctor
AFTER DELETE ON Doctores
FOR EACH ROW
BEGIN

    INSERT INTO Bitacora (
        id_clinica_tenant,
        informacion
    )
    VALUES (
        OLD.id_clinica_tenant,

        CONCAT(
            'Doctor eliminado | ID Doctor: ',
            BIN_TO_UUID(OLD.id_doctor),
            ' | Nombre: ',
            OLD.nombre,
            ' ',
            OLD.apellido,
            ' | CURP: ',
            OLD.curp
        )
    );

END$$

DELIMITER ;


-- =====================================================
-- BITACORA INSERT BLOQUEO HORARIO
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_bitacora_insert_bloqueo
AFTER INSERT ON Bloqueo_horario
FOR EACH ROW
BEGIN

    INSERT INTO Bitacora (
        id_clinica_tenant,
        informacion
    )
    VALUES (
        NEW.id_clinica_tenant,

        CONCAT(
            'Bloqueo de horario creado | ID Bloqueo: ',
            BIN_TO_UUID(NEW.id_bloqueo),
            ' | ID Doctor: ',
            BIN_TO_UUID(NEW.id_doctor),
            ' | Inicio: ',
            NEW.fecha_inicio,
            ' | Fin: ',
            NEW.fecha_fin
        )
    );

END$$

DELIMITER ;


-- =====================================================
-- BITACORA UPDATE BLOQUEO HORARIO
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_bitacora_update_bloqueo
AFTER UPDATE ON Bloqueo_horario
FOR EACH ROW
BEGIN

    INSERT INTO Bitacora (
        id_clinica_tenant,
        informacion
    )
    VALUES (
        NEW.id_clinica_tenant,

        CONCAT(
            'Bloqueo de horario actualizado | ID Bloqueo: ',
            BIN_TO_UUID(NEW.id_bloqueo),
            ' | Inicio anterior: ',
            OLD.fecha_inicio,
            ' | Fin anterior: ',
            OLD.fecha_fin,
            ' | Nuevo inicio: ',
            NEW.fecha_inicio,
            ' | Nuevo fin: ',
            NEW.fecha_fin
        )
    );

END$$

DELIMITER ;


-- =====================================================
-- BITACORA UPDATE PRECIO CONSULTA
-- =====================================================

DELIMITER $$

CREATE TRIGGER trg_bitacora_update_precio
AFTER UPDATE ON Precios_Consulta
FOR EACH ROW
BEGIN

    IF OLD.monto <> NEW.monto THEN

        INSERT INTO Bitacora (
            id_clinica_tenant,
            informacion
        )
        VALUES (
            NEW.id_clinica_tenant,

            CONCAT(
                'Precio de consulta actualizado | ID Doctor: ',
                BIN_TO_UUID(NEW.id_doctor),
                ' | Precio anterior: ',
                OLD.monto,
                ' | Nuevo precio: ',
                NEW.monto
            )
        );

    END IF;

END$$

DELIMITER ;

-- BITACORA CANCELAR / CAMBIAR ESTADO CITA


DELIMITER $$

CREATE TRIGGER trg_bitacora_update_estado_cita
AFTER UPDATE ON Cita
FOR EACH ROW
BEGIN

    DECLARE v_estado_anterior VARCHAR(20);
    DECLARE v_estado_nuevo VARCHAR(20);

    IF OLD.id_estado <> NEW.id_estado THEN

        SELECT estado
        INTO v_estado_anterior
        FROM Estado_Cita
        WHERE id_estado = OLD.id_estado;

        SELECT estado
        INTO v_estado_nuevo
        FROM Estado_Cita
        WHERE id_estado = NEW.id_estado;

        INSERT INTO Bitacora (
            id_clinica_tenant,
            informacion
        )
        VALUES (
            NEW.id_clinica_tenant,

            CONCAT(
                'Estado de cita actualizado | ID Cita: ',
                BIN_TO_UUID(NEW.id_cita),
                ' | Estado anterior: ',
                v_estado_anterior,
                ' | Nuevo estado: ',
                v_estado_nuevo
            )
        );

    END IF;

END$$

DELIMITER ;