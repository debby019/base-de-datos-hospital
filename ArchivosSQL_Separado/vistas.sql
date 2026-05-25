CREATE VIEW vw_citas_completas AS
SELECT
    BIN_TO_UUID(c.id_cita) AS id_cita,

    BIN_TO_UUID(c.id_clinica_tenant) AS id_clinica,

    c.fecha,
    c.hora_inicio,
    c.hora_fin,

    c.motivo,

    ec.estado,

    BIN_TO_UUID(d.id_doctor) AS id_doctor,
    CONCAT(d.nombre, ' ', d.apellido) AS doctor,

    e.especialidad,

    BIN_TO_UUID(p.id_paciente) AS id_paciente,
    CONCAT(p.nombre, ' ', p.apellido) AS paciente

FROM Cita c

INNER JOIN Estado_Cita ec
    ON c.id_estado = ec.id_estado

INNER JOIN Doctores d
    ON c.id_doctor = d.id_doctor

INNER JOIN Especialidades e
    ON d.id_especialidad = e.id_especialidad

INNER JOIN Paciente p
    ON c.id_paciente = p.id_paciente;

CREATE VIEW vw_agenda_doctor AS
SELECT
    BIN_TO_UUID(c.id_cita) AS id_cita,

    BIN_TO_UUID(c.id_doctor) AS id_doctor,

    CONCAT(d.nombre, ' ', d.apellido) AS doctor,

    c.fecha,
    c.hora_inicio,
    c.hora_fin,

    CONCAT(p.nombre, ' ', p.apellido) AS paciente,

    ec.estado

FROM Cita c

INNER JOIN Doctores d
    ON c.id_doctor = d.id_doctor

INNER JOIN Paciente p
    ON c.id_paciente = p.id_paciente

INNER JOIN Estado_Cita ec
    ON c.id_estado = ec.id_estado;