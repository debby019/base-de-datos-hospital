CREATE INDEX idx_cita_doctor_fecha
ON Cita (
    id_clinica_tenant,
    id_doctor,
    fecha,
    id_estado,
    hora_inicio,
    hora_fin
);

CREATE INDEX idx_cita_paciente_fecha
ON Cita (
    id_clinica_tenant,
    id_paciente,
    fecha,
    id_estado,
    hora_inicio,
    hora_fin
);

CREATE INDEX idx_cita_fecha
ON Cita (
    id_clinica_tenant,
    fecha
);

CREATE INDEX idx_horario_doctor_dia
ON Horarios_Doctor (
    id_clinica_tenant,
    id_doctor,
    dia,
    hora_inicio,
    hora_fin
);

CREATE INDEX idx_bloqueo_doctor_fecha
ON Bloqueo_horario (
    id_clinica_tenant,
    id_doctor,
    fecha_inicio,
    fecha_fin
);

CREATE INDEX idx_paciente_usuario
ON Paciente (
    id_clinica_tenant,
    id_usuario,
    activo
);

CREATE INDEX idx_paciente_activo
ON Paciente (
    id_clinica_tenant,
    activo
);

CREATE INDEX idx_doctor_clinica_activo
ON Doctores (
    id_clinica_tenant,
    activo
);

CREATE INDEX idx_doctor_especialidad
ON Doctores (
    id_clinica_tenant,
    id_especialidad
);

CREATE INDEX idx_notificacion_estado
ON Notificacion (
    id_clinica_tenant,
    estado,
    fecha_enviada
);

CREATE INDEX idx_bitacora_clinica_fecha
ON Bitacora (
    id_clinica_tenant,
    fecha_movimiento
);

CREATE INDEX idx_usuario_rol
ON Usuario (
    id_clinica_tenant,
    id_rol
);

CREATE INDEX idx_cita_estado
ON Cita (
    id_clinica_tenant,
    id_estado
);

CREATE INDEX idx_usuario_rol
ON Usuario (
    id_clinica_tenant,
    id_rol
);