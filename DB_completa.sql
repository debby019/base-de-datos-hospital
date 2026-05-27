-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: hospitalDB
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `hospitalDB`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `hospitalDB` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `hospitalDB`;

--
-- Table structure for table `bitacora`
--

DROP TABLE IF EXISTS `bitacora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bitacora` (
  `id_bitacora` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `informacion` text NOT NULL,
  `fecha_movimiento` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_bitacora`),
  KEY `idx_bitacora_clinica_fecha` (`id_clinica_tenant`,`fecha_movimiento`),
  CONSTRAINT `bitacora_ibfk_1` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bitacora`
--

LOCK TABLES `bitacora` WRITE;
/*!40000 ALTER TABLE `bitacora` DISABLE KEYS */;
INSERT INTO `bitacora` VALUES (0x11F1580E23456B4BACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'Bloqueo de horario creado | ID Bloqueo: 11f1580e-2345-53d0-acaa-b0227ae077e2 | ID Doctor: 11f1580e-2338-9d7b-acaa-b0227ae077e2 | Inicio: 2026-05-28 12:00:00 | Fin: 2026-05-28 14:00:00','2026-05-25 00:48:36'),(0x11F1580E2347A74EACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'Base de datos inicializada correctamente con datos de prueba.','2026-05-25 00:48:36');
/*!40000 ALTER TABLE `bitacora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bloqueo_horario`
--

DROP TABLE IF EXISTS `bloqueo_horario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bloqueo_horario` (
  `id_bloqueo` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `id_doctor` binary(16) NOT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime NOT NULL,
  PRIMARY KEY (`id_bloqueo`),
  KEY `id_doctor` (`id_doctor`),
  KEY `idx_bloqueo_doctor_fecha` (`id_clinica_tenant`,`id_doctor`,`fecha_inicio`,`fecha_fin`),
  CONSTRAINT `bloqueo_horario_ibfk_1` FOREIGN KEY (`id_doctor`) REFERENCES `doctores` (`id_doctor`) ON DELETE CASCADE,
  CONSTRAINT `bloqueo_horario_ibfk_2` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`),
  CONSTRAINT `bloqueo_horario_chk_1` CHECK ((`fecha_fin` > `fecha_inicio`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bloqueo_horario`
--

LOCK TABLES `bloqueo_horario` WRITE;
/*!40000 ALTER TABLE `bloqueo_horario` DISABLE KEYS */;
INSERT INTO `bloqueo_horario` VALUES (0x11F1580E234553D0ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,0x11F1580E23389D7BACAAB0227AE077E2,'2026-05-28 12:00:00','2026-05-28 14:00:00');
/*!40000 ALTER TABLE `bloqueo_horario` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_insert_bloqueo` BEFORE INSERT ON `bloqueo_horario` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_insert_bloqueo` AFTER INSERT ON `bloqueo_horario` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_update_bloqueo` BEFORE UPDATE ON `bloqueo_horario` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_update_bloqueo` AFTER UPDATE ON `bloqueo_horario` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `cita`
--

DROP TABLE IF EXISTS `cita`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cita` (
  `id_cita` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `fecha` date NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `motivo` text NOT NULL,
  `id_estado` char(12) NOT NULL,
  `id_paciente` binary(16) NOT NULL,
  `id_doctor` binary(16) NOT NULL,
  PRIMARY KEY (`id_cita`),
  KEY `id_paciente` (`id_paciente`),
  KEY `id_doctor` (`id_doctor`),
  KEY `id_estado` (`id_estado`),
  KEY `idx_cita_doctor_fecha` (`id_clinica_tenant`,`id_doctor`,`fecha`,`id_estado`,`hora_inicio`,`hora_fin`),
  KEY `idx_cita_paciente_fecha` (`id_clinica_tenant`,`id_paciente`,`fecha`,`id_estado`,`hora_inicio`,`hora_fin`),
  KEY `idx_cita_fecha` (`id_clinica_tenant`,`fecha`),
  KEY `idx_cita_estado` (`id_clinica_tenant`,`id_estado`),
  CONSTRAINT `cita_ibfk_1` FOREIGN KEY (`id_paciente`) REFERENCES `paciente` (`id_paciente`) ON DELETE CASCADE,
  CONSTRAINT `cita_ibfk_2` FOREIGN KEY (`id_doctor`) REFERENCES `doctores` (`id_doctor`) ON DELETE CASCADE,
  CONSTRAINT `cita_ibfk_3` FOREIGN KEY (`id_estado`) REFERENCES `estado_cita` (`id_estado`),
  CONSTRAINT `cita_ibfk_4` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`),
  CONSTRAINT `cita_chk_1` CHECK ((`hora_fin` > `hora_inicio`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cita`
--

LOCK TABLES `cita` WRITE;
/*!40000 ALTER TABLE `cita` DISABLE KEYS */;
INSERT INTO `cita` VALUES (0x11F1580E2340A4A2ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'2026-05-25','09:00:00','09:30:00','Dolor de cabeza','232871ea580e',0x11F1580E233B2F3DACAAB0227AE077E2,0x11F1580E23389D7BACAAB0227AE077E2),(0x11F1580E23415778ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'2026-05-26','11:00:00','11:30:00','Consulta pediatrica','23287521580e',0x11F1580E233BAFEAACAAB0227AE077E2,0x11F1580E233955AFACAAB0227AE077E2);
/*!40000 ALTER TABLE `cita` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_insert_cita` BEFORE INSERT ON `cita` FOR EACH ROW BEGIN
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

    -- =========================================
    -- VALIDAR FECHA PASADA
    -- =========================================

    IF NEW.fecha < CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MYSQL_ERRNO = 1008,
            MESSAGE_TEXT = 'No se pueden crear citas en fechas pasadas';
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
    -- VALIDAR HORARIO DOCTOR
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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_update_cita` BEFORE UPDATE ON `cita` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_update_estado_cita` AFTER UPDATE ON `cita` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `clinica`
--

DROP TABLE IF EXISTS `clinica`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clinica` (
  `id_clinica_tenant` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `activo` tinyint(1) DEFAULT '1',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_clinica_tenant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clinica`
--

LOCK TABLES `clinica` WRITE;
/*!40000 ALTER TABLE `clinica` DISABLE KEYS */;
INSERT INTO `clinica` VALUES (0x11F1580E232A531CACAAB0227AE077E2,1,'2026-05-25 00:48:36');
/*!40000 ALTER TABLE `clinica` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `datos_clinica`
--

DROP TABLE IF EXISTS `datos_clinica`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `datos_clinica` (
  `id_datos_clinica` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `direccion` varchar(255) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `horario_atencion` varchar(100) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id_datos_clinica`),
  UNIQUE KEY `id_clinica_tenant` (`id_clinica_tenant`),
  CONSTRAINT `datos_clinica_ibfk_1` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `datos_clinica`
--

LOCK TABLES `datos_clinica` WRITE;
/*!40000 ALTER TABLE `datos_clinica` DISABLE KEYS */;
INSERT INTO `datos_clinica` VALUES (0x11F1580E232BECD4ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'Clinica San Rafael','Av. Reforma 1200, Ensenada, Baja California','6461112233','Lunes a Viernes 08:00 - 18:00','contacto@sanrafael.com');
/*!40000 ALTER TABLE `datos_clinica` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctores`
--

DROP TABLE IF EXISTS `doctores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctores` (
  `id_doctor` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(150) NOT NULL,
  `curp` varchar(18) NOT NULL,
  `activo` tinyint(1) DEFAULT '1',
  `fecha_baja` datetime DEFAULT NULL,
  `id_usuario` binary(16) NOT NULL,
  `id_especialidad` char(12) NOT NULL,
  PRIMARY KEY (`id_doctor`),
  UNIQUE KEY `curp` (`curp`),
  UNIQUE KEY `id_usuario` (`id_usuario`),
  KEY `id_especialidad` (`id_especialidad`),
  KEY `idx_doctor_clinica_activo` (`id_clinica_tenant`,`activo`),
  KEY `idx_doctor_especialidad` (`id_clinica_tenant`,`id_especialidad`),
  CONSTRAINT `doctores_ibfk_1` FOREIGN KEY (`id_especialidad`) REFERENCES `especialidades` (`id_especialidad`),
  CONSTRAINT `doctores_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  CONSTRAINT `doctores_ibfk_3` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctores`
--

LOCK TABLES `doctores` WRITE;
/*!40000 ALTER TABLE `doctores` DISABLE KEYS */;
INSERT INTO `doctores` VALUES (0x11F1580E23389D7BACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'Carlos','Hernandez Soto','HECS900101HBCXXX01',1,NULL,0x11F1580E23347C85ACAAB0227AE077E2,'232785f6580e'),(0x11F1580E233955AFACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'Patricia','Lopez Vega','LOVP920202MBCXXX02',1,NULL,0x11F1580E23354B08ACAAB0227AE077E2,'232783f6580e');
/*!40000 ALTER TABLE `doctores` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_update_doctor` AFTER UPDATE ON `doctores` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_delete_doctor` AFTER DELETE ON `doctores` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `especialidades`
--

DROP TABLE IF EXISTS `especialidades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `especialidades` (
  `id_especialidad` char(12) NOT NULL DEFAULT (substr(replace(uuid(),_utf8mb3'-',_utf8mb4''),1,12)),
  `especialidad` varchar(100) NOT NULL,
  PRIMARY KEY (`id_especialidad`),
  UNIQUE KEY `especialidad` (`especialidad`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `especialidades`
--

LOCK TABLES `especialidades` WRITE;
/*!40000 ALTER TABLE `especialidades` DISABLE KEYS */;
INSERT INTO `especialidades` VALUES ('232780d5580e','Cardiología'),('2327850a580e','Dermatología'),('232785f6580e','Medicina General'),('23278581580e','Neurología'),('232783f6580e','Pediatría');
/*!40000 ALTER TABLE `especialidades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `estado_cita`
--

DROP TABLE IF EXISTS `estado_cita`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `estado_cita` (
  `id_estado` char(12) NOT NULL DEFAULT (substr(replace(uuid(),_utf8mb3'-',_utf8mb4''),1,12)),
  `estado` varchar(20) NOT NULL,
  PRIMARY KEY (`id_estado`),
  UNIQUE KEY `estado` (`estado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `estado_cita`
--

LOCK TABLES `estado_cita` WRITE;
/*!40000 ALTER TABLE `estado_cita` DISABLE KEYS */;
INSERT INTO `estado_cita` VALUES ('2328762f580e','cancelada'),('23287521580e','completada'),('232871ea580e','pendiente');
/*!40000 ALTER TABLE `estado_cita` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `horarios_doctor`
--

DROP TABLE IF EXISTS `horarios_doctor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `horarios_doctor` (
  `id_horario` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `dia` tinyint unsigned NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `id_doctor` binary(16) NOT NULL,
  PRIMARY KEY (`id_horario`),
  KEY `id_doctor` (`id_doctor`),
  KEY `idx_horario_doctor_dia` (`id_clinica_tenant`,`id_doctor`,`dia`,`hora_inicio`,`hora_fin`),
  CONSTRAINT `horarios_doctor_ibfk_1` FOREIGN KEY (`id_doctor`) REFERENCES `doctores` (`id_doctor`) ON DELETE CASCADE,
  CONSTRAINT `horarios_doctor_ibfk_2` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`),
  CONSTRAINT `horarios_doctor_chk_1` CHECK ((`hora_fin` > `hora_inicio`)),
  CONSTRAINT `horarios_doctor_chk_2` CHECK ((`dia` between 1 and 7))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `horarios_doctor`
--

LOCK TABLES `horarios_doctor` WRITE;
/*!40000 ALTER TABLE `horarios_doctor` DISABLE KEYS */;
INSERT INTO `horarios_doctor` VALUES (0x11F1580E233E37D3ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,1,'08:00:00','14:00:00',0x11F1580E23389D7BACAAB0227AE077E2),(0x11F1580E233E4650ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,2,'08:00:00','14:00:00',0x11F1580E23389D7BACAAB0227AE077E2),(0x11F1580E233E4C28ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,3,'08:00:00','14:00:00',0x11F1580E23389D7BACAAB0227AE077E2),(0x11F1580E233E50D9ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,4,'08:00:00','14:00:00',0x11F1580E23389D7BACAAB0227AE077E2),(0x11F1580E233E55C2ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,5,'08:00:00','14:00:00',0x11F1580E23389D7BACAAB0227AE077E2),(0x11F1580E233E5AA6ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,1,'10:00:00','16:00:00',0x11F1580E233955AFACAAB0227AE077E2),(0x11F1580E233E5EBBACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,2,'10:00:00','16:00:00',0x11F1580E233955AFACAAB0227AE077E2),(0x11F1580E233E6327ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,3,'10:00:00','16:00:00',0x11F1580E233955AFACAAB0227AE077E2);
/*!40000 ALTER TABLE `horarios_doctor` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_insert_horario_doctor` BEFORE INSERT ON `horarios_doctor` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_update_horario_doctor` BEFORE UPDATE ON `horarios_doctor` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `nota_medica`
--

DROP TABLE IF EXISTS `nota_medica`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nota_medica` (
  `id_nota` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `id_cita` binary(16) NOT NULL,
  `nota` text NOT NULL,
  PRIMARY KEY (`id_nota`),
  UNIQUE KEY `id_cita` (`id_cita`),
  KEY `id_clinica_tenant` (`id_clinica_tenant`),
  CONSTRAINT `nota_medica_ibfk_1` FOREIGN KEY (`id_cita`) REFERENCES `cita` (`id_cita`) ON DELETE CASCADE,
  CONSTRAINT `nota_medica_ibfk_2` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nota_medica`
--

LOCK TABLES `nota_medica` WRITE;
/*!40000 ALTER TABLE `nota_medica` DISABLE KEYS */;
INSERT INTO `nota_medica` VALUES (0x11F1580E23442888ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,0x11F1580E23415778ACAAB0227AE077E2,'Paciente estable. Se recomienda seguimiento en 6 meses.');
/*!40000 ALTER TABLE `nota_medica` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificacion`
--

DROP TABLE IF EXISTS `notificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notificacion` (
  `id_notificacion` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `id_cita` binary(16) NOT NULL,
  `id_tipo` char(12) NOT NULL,
  `mensaje` text NOT NULL,
  `fecha_enviada` datetime NOT NULL,
  `estado` enum('pendiente','enviada','fallida') NOT NULL DEFAULT 'pendiente',
  `destinatario` enum('paciente','doctor') NOT NULL,
  PRIMARY KEY (`id_notificacion`),
  KEY `id_cita` (`id_cita`),
  KEY `id_tipo` (`id_tipo`),
  KEY `idx_notificacion_estado` (`id_clinica_tenant`,`estado`,`fecha_enviada`),
  CONSTRAINT `notificacion_ibfk_1` FOREIGN KEY (`id_cita`) REFERENCES `cita` (`id_cita`) ON DELETE CASCADE,
  CONSTRAINT `notificacion_ibfk_2` FOREIGN KEY (`id_tipo`) REFERENCES `tipo_notificacion` (`id_tipo`),
  CONSTRAINT `notificacion_ibfk_3` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificacion`
--

LOCK TABLES `notificacion` WRITE;
/*!40000 ALTER TABLE `notificacion` DISABLE KEYS */;
INSERT INTO `notificacion` VALUES (0x11F1580E2346AFDEACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,0x11F1580E2340A4A2ACAAB0227AE077E2,'232967d3580e','Recordatorio de cita para mañana a las 09:00','2026-05-25 00:48:36','enviada','paciente');
/*!40000 ALTER TABLE `notificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paciente`
--

DROP TABLE IF EXISTS `paciente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paciente` (
  `id_paciente` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(150) NOT NULL,
  `sexo` enum('masculino','femenino','otro') NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `curp` varchar(18) NOT NULL,
  `activo` tinyint(1) DEFAULT '1',
  `fecha_baja` datetime DEFAULT NULL,
  `id_usuario` binary(16) NOT NULL,
  `id_parentesco` char(12) NOT NULL,
  PRIMARY KEY (`id_paciente`),
  UNIQUE KEY `curp` (`curp`),
  KEY `id_usuario` (`id_usuario`),
  KEY `id_parentesco` (`id_parentesco`),
  KEY `idx_paciente_usuario` (`id_clinica_tenant`,`id_usuario`,`activo`),
  KEY `idx_paciente_activo` (`id_clinica_tenant`,`activo`),
  CONSTRAINT `paciente_ibfk_1` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE,
  CONSTRAINT `paciente_ibfk_2` FOREIGN KEY (`id_parentesco`) REFERENCES `parentesco` (`id_parentesco`),
  CONSTRAINT `paciente_ibfk_3` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paciente`
--

LOCK TABLES `paciente` WRITE;
/*!40000 ALTER TABLE `paciente` DISABLE KEYS */;
INSERT INTO `paciente` VALUES (0x11F1580E233B2F3DACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'Maria','Gonzalez Ruiz','femenino','1998-05-10','GORM980510MBCXXX01',1,NULL,0x11F1580E2335F2F3ACAAB0227AE077E2,'232688f5580e'),(0x11F1580E233BAFEAACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'Juan','Perez Diaz','masculino','2001-08-20','PEDJ010820HBCXXX02',1,NULL,0x11F1580E2336D2F5ACAAB0227AE077E2,'232688f5580e');
/*!40000 ALTER TABLE `paciente` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_limite_pacientes` BEFORE INSERT ON `paciente` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_update_paciente` AFTER UPDATE ON `paciente` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_delete_paciente` AFTER DELETE ON `paciente` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `parentesco`
--

DROP TABLE IF EXISTS `parentesco`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parentesco` (
  `id_parentesco` char(12) NOT NULL DEFAULT (substr(replace(uuid(),_utf8mb3'-',_utf8mb4''),1,12)),
  `parentesco` varchar(50) NOT NULL,
  PRIMARY KEY (`id_parentesco`),
  UNIQUE KEY `parentesco` (`parentesco`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `parentesco`
--

LOCK TABLES `parentesco` WRITE;
/*!40000 ALTER TABLE `parentesco` DISABLE KEYS */;
INSERT INTO `parentesco` VALUES ('23268dd5580e','conyuge'),('23268cd2580e','hijo'),('232688f5580e','titular');
/*!40000 ALTER TABLE `parentesco` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `precios_consulta`
--

DROP TABLE IF EXISTS `precios_consulta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `precios_consulta` (
  `id_precio` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `id_doctor` binary(16) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id_precio`),
  UNIQUE KEY `id_doctor` (`id_doctor`),
  KEY `id_clinica_tenant` (`id_clinica_tenant`),
  CONSTRAINT `precios_consulta_ibfk_1` FOREIGN KEY (`id_doctor`) REFERENCES `doctores` (`id_doctor`) ON DELETE CASCADE,
  CONSTRAINT `precios_consulta_ibfk_2` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`),
  CONSTRAINT `precios_consulta_chk_1` CHECK ((`monto` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `precios_consulta`
--

LOCK TABLES `precios_consulta` WRITE;
/*!40000 ALTER TABLE `precios_consulta` DISABLE KEYS */;
INSERT INTO `precios_consulta` VALUES (0x11F1580E233FAF8CACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,0x11F1580E23389D7BACAAB0227AE077E2,700.00),(0x11F1580E233FB4AFACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,0x11F1580E233955AFACAAB0227AE077E2,850.00);
/*!40000 ALTER TABLE `precios_consulta` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_update_precio` AFTER UPDATE ON `precios_consulta` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id_rol` char(12) NOT NULL DEFAULT (substr(replace(uuid(),_utf8mb3'-',_utf8mb4''),1,12)),
  `rol` varchar(20) NOT NULL,
  PRIMARY KEY (`id_rol`),
  UNIQUE KEY `rol` (`rol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES ('232524df580e','admin'),('23252c38580e','cliente'),('23252a6a580e','doctor'),('23252bc2580e','recepcionista');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tipo_notificacion`
--

DROP TABLE IF EXISTS `tipo_notificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tipo_notificacion` (
  `id_tipo` char(12) NOT NULL DEFAULT (substr(replace(uuid(),_utf8mb3'-',_utf8mb4''),1,12)),
  `tipo` varchar(50) NOT NULL,
  PRIMARY KEY (`id_tipo`),
  UNIQUE KEY `tipo` (`tipo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tipo_notificacion`
--

LOCK TABLES `tipo_notificacion` WRITE;
/*!40000 ALTER TABLE `tipo_notificacion` DISABLE KEYS */;
INSERT INTO `tipo_notificacion` VALUES ('23296ab6580e','cambio'),('23296ba8580e','cancelacion'),('232967d3580e','recordatorio');
/*!40000 ALTER TABLE `tipo_notificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id_usuario` binary(16) NOT NULL DEFAULT (uuid_to_bin(uuid(),1)),
  `id_clinica_tenant` binary(16) NOT NULL,
  `correo` varchar(100) NOT NULL,
  `telefono` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `id_rol` char(12) NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `correo` (`correo`),
  UNIQUE KEY `telefono` (`telefono`),
  KEY `id_rol` (`id_rol`),
  KEY `idx_usuario_rol` (`id_clinica_tenant`,`id_rol`),
  CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`id_rol`) REFERENCES `roles` (`id_rol`),
  CONSTRAINT `usuario_ibfk_2` FOREIGN KEY (`id_clinica_tenant`) REFERENCES `clinica` (`id_clinica_tenant`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
INSERT INTO `usuario` VALUES (0x11F1580E2333D11AACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'admin@sanrafael.com','6461000001','$2b$12$CSilKailS/nE/3SdRdVra.RnHQOqyEjEg4czB2fZUzyq8YX39Lm96','232524df580e'),(0x11F1580E23347C85ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'doctor1@sanrafael.com','6461000002','$2b$12$CSilKailS/nE/3SdRdVra.RnHQOqyEjEg4czB2fZUzyq8YX39Lm96','23252a6a580e'),(0x11F1580E23354B08ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'doctor2@sanrafael.com','6461000003','$2b$12$CSilKailS/nE/3SdRdVra.RnHQOqyEjEg4czB2fZUzyq8YX39Lm96','23252a6a580e'),(0x11F1580E2335F2F3ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'maria@gmail.com','6461000004','$2b$12$CSilKailS/nE/3SdRdVra.RnHQOqyEjEg4czB2fZUzyq8YX39Lm96','23252c38580e'),(0x11F1580E2336D2F5ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'juan@gmail.com','6461000005','$2b$12$CSilKailS/nE/3SdRdVra.RnHQOqyEjEg4czB2fZUzyq8YX39Lm96','23252c38580e'),(0x11F159963DBF3BB4ACAAB0227AE077E2,0x11F1580E232A531CACAAB0227AE077E2,'recepcion@sanrafael.com','6462010005','$2b$12$CSilKailS/nE/3SdRdVra.RnHQOqyEjEg4czB2fZUzyq8YX39Lm96','23252bc2580e');
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_bitacora_delete_usuario` AFTER DELETE ON `usuario` FOR EACH ROW BEGIN

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

END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `vw_agenda_doctor`
--

DROP TABLE IF EXISTS `vw_agenda_doctor`;
/*!50001 DROP VIEW IF EXISTS `vw_agenda_doctor`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_agenda_doctor` AS SELECT 
 1 AS `id_cita`,
 1 AS `id_doctor`,
 1 AS `doctor`,
 1 AS `fecha`,
 1 AS `hora_inicio`,
 1 AS `hora_fin`,
 1 AS `paciente`,
 1 AS `estado`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_citas_completas`
--

DROP TABLE IF EXISTS `vw_citas_completas`;
/*!50001 DROP VIEW IF EXISTS `vw_citas_completas`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_citas_completas` AS SELECT 
 1 AS `id_cita`,
 1 AS `id_clinica`,
 1 AS `fecha`,
 1 AS `hora_inicio`,
 1 AS `hora_fin`,
 1 AS `motivo`,
 1 AS `estado`,
 1 AS `id_doctor`,
 1 AS `doctor`,
 1 AS `especialidad`,
 1 AS `id_paciente`,
 1 AS `paciente`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'hospitalDB'
--

--
-- Dumping routines for database 'hospitalDB'
--

--
-- Current Database: `hospitalDB`
--

USE `hospitalDB`;

--
-- Final view structure for view `vw_agenda_doctor`
--

/*!50001 DROP VIEW IF EXISTS `vw_agenda_doctor`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `vw_agenda_doctor` AS select bin_to_uuid(`c`.`id_cita`) AS `id_cita`,bin_to_uuid(`c`.`id_doctor`) AS `id_doctor`,concat(`d`.`nombre`,' ',`d`.`apellido`) AS `doctor`,`c`.`fecha` AS `fecha`,`c`.`hora_inicio` AS `hora_inicio`,`c`.`hora_fin` AS `hora_fin`,concat(`p`.`nombre`,' ',`p`.`apellido`) AS `paciente`,`ec`.`estado` AS `estado` from (((`cita` `c` join `doctores` `d` on((`c`.`id_doctor` = `d`.`id_doctor`))) join `paciente` `p` on((`c`.`id_paciente` = `p`.`id_paciente`))) join `estado_cita` `ec` on((`c`.`id_estado` = `ec`.`id_estado`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_citas_completas`
--

/*!50001 DROP VIEW IF EXISTS `vw_citas_completas`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `vw_citas_completas` AS select bin_to_uuid(`c`.`id_cita`) AS `id_cita`,bin_to_uuid(`c`.`id_clinica_tenant`) AS `id_clinica`,`c`.`fecha` AS `fecha`,`c`.`hora_inicio` AS `hora_inicio`,`c`.`hora_fin` AS `hora_fin`,`c`.`motivo` AS `motivo`,`ec`.`estado` AS `estado`,bin_to_uuid(`d`.`id_doctor`) AS `id_doctor`,concat(`d`.`nombre`,' ',`d`.`apellido`) AS `doctor`,`e`.`especialidad` AS `especialidad`,bin_to_uuid(`p`.`id_paciente`) AS `id_paciente`,concat(`p`.`nombre`,' ',`p`.`apellido`) AS `paciente` from ((((`cita` `c` join `estado_cita` `ec` on((`c`.`id_estado` = `ec`.`id_estado`))) join `doctores` `d` on((`c`.`id_doctor` = `d`.`id_doctor`))) join `especialidades` `e` on((`d`.`id_especialidad` = `e`.`id_especialidad`))) join `paciente` `p` on((`c`.`id_paciente` = `p`.`id_paciente`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-26 23:36:15
