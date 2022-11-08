
CREATE SCHEMA IF NOT EXISTS centro_medico;

USE centro_medico;

-- CREACION DE TABLAS --
CREATE TABLE IF NOT EXISTS obra_social (
	id_os INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    cuit_os BIGINT NOT NULL CONSTRAINT ElevenDigits CHECK(cuit_os between 30000000000 AND 39999999999) UNIQUE, -- USO CHECK PARA LIMITAR EL CUIT A 11 DIGITOS UNICAMENTE
    razon_social VARCHAR(255) NOT NULL,
    direccion VARCHAR(255),
    precio INT NOT NULL
    );

CREATE TABLE IF NOT EXISTS especialidad (
	id_especialidad INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(40) NOT NULL UNIQUE
    );

CREATE TABLE IF NOT EXISTS consultorio (
	id_consultorio INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    direccion VARCHAR(255) NOT NULL,
    telefono INT NOT NULL
    );

CREATE TABLE IF NOT EXISTS paciente (
	id_paciente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    dni_paciente BIGINT NOT NULL CONSTRAINT chk_dni CHECK(dni_paciente between 04000000 AND 90000000) UNIQUE,
	nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
	telefono INT NOT NULL,
    id_os INT NOT NULL,
    FOREIGN KEY (id_os) REFERENCES obra_social(id_os)
    );

CREATE TABLE IF NOT EXISTS medico (
	id_medico INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    matricula INT NOT NULL CONSTRAINT chk_mat CHECK(matricula between 1 AND 9999) UNIQUE,
    id_especialidad INT NOT NULL,
    id_consultorio INT NOT NULL,
	FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad),
    FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio));
   
CREATE TABLE IF NOT EXISTS cita (
	id_cita INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    id_medico INT NOT NULL,
    id_paciente INT NOT NULL,
    FOREIGN KEY(id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY(id_paciente) REFERENCES paciente(id_paciente)
    );
    
    CREATE TABLE IF NOT EXISTS medico_obrasocial (
	id_mos INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    id_medico INT NOT NULL,
    id_os INT NOT NULL,
	FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_os) REFERENCES obra_social(id_os)
    );
    
 -- INSERCION DE REGISTROS --

INSERT INTO consultorio
VALUES
(NULL, "Libertador 123", 4202020),
(NULL, "Aberastain 321", 4202222),
(NULL, "Santa Fe 456", 4202020);
    
INSERT INTO especialidad
VALUES 
(NULL, "PEDIATRIA"),
(NULL, "TRAUMATOLOGIA"),
(NULL, "GINECOLOGIA");

INSERT INTO medico
VALUES
(NULL, "Carlos","Macias", 8019, 1, 1),
(NULL, "Matias","Arce", 9091, 2, 2),
(NULL, "Carla","Vallejos", 1120, 3, 3);

INSERT INTO obra_social
VALUES 
(NULL, 30358526358, "OSDE",  "Rawson 987", 1800),
(NULL, 30700768601, "SANCOR", "Cordoba 789", 1500),
(NULL, 30405230202, "OSECAC",  "Rawson 987", 800);

INSERT INTO paciente
VALUES
(NULL, 35852635,"Franco", "Gomez",26410120, 1),
(NULL, 20332231,"Elisa", "Carrera",26420132, 2),
(NULL, 25234231,"Maria", "Becerra",26420134, 3);

INSERT INTO medico_obrasocial
VALUES
(NULL, 1, 2),
(NULL, 2, 3),
(NULL, 3, 1);

INSERT INTO cita
VALUES
(NULL, "2022/01/07", 2, 1),
(NULL, "2022/01/05", 1, 1),
(NULL, "2022/01/25", 1, 2);

-- CREACION DE 5 VISTAS
CREATE VIEW medico_especialidad AS -- VISTA DE QUE ESPECIALIDAD TIENE CADA MEDICO CONSULTADO
SELECT medico.id_medico, medico.apellido, especialidad.nombre
FROM medico
INNER JOIN especialidad
ON medico.id_especialidad = especialidad.id_especialidad;

SELECT * FROM medico_especialidad WHERE apellido = "Arce";  -- PRUEBA DE VISTA medico_especialidad
    
CREATE VIEW pac_os AS -- VISTA DE LA OBRA SOCIAL CON LA QUE CUENTA EL PACIENTE
SELECT paciente.nombre, paciente.apellido, obra_social.razon_social
FROM paciente 
INNER JOIN obra_social
ON paciente.id_os = obra_social.id_os;

SELECT * FROM pac_os WHERE apellido = "Becerra"; -- PRUEBA DE VISTA pac_os

CREATE VIEW cita_info AS  -- VISTA DE LA INFORMACION ACERCA DE LA CITA MEDICA
SELECT cita.fecha, medico.apellido AS doctor, paciente.nombre AS paciente
FROM cita
INNER JOIN medico ON cita.id_medico = medico.id_medico
INNER JOIN paciente ON cita.id_paciente = paciente.id_paciente;

SELECT * FROM cita_info WHERE doctor= "Macias"; -- PRUEBA DE VISTA cita_info

CREATE VIEW especialidades AS -- VISTA DE LAS ESPECIALIDADES
SELECT * FROM especialidad;

SELECT * FROM especialidades WHERE nombre = "PEDIATRIA"; -- PRUEBA VISTA especialidades

CREATE VIEW os_recibidas AS -- VISTA DE LAS OS QUE SE RECIBEN
SELECT id_os, razon_social
FROM obra_social;
SELECT * FROM os_recibidas; -- PRUEBA VISTA os_recibidas


-- CREACION DE 2 FUNCIONES 
-- FUNCION 1 : costo_consulta_os DEVUELVE EL PRECIO DE CADA OS QUE RECIBE EL CENTRO MEDICO
DELIMITER $$
CREATE FUNCTION `costo_consulta_os` (ob_social VARCHAR(250))
RETURNS INT
READS SQL DATA
BEGIN
	DECLARE n_os VARCHAR(250);
    SET n_os = (SELECT DISTINCT precio FROM obra_social WHERE obra_social.razon_social = ob_social); -- OBTIENE EL PRECIO DE CADA OBRA SOCIAL
    RETURN n_os;
    
END;
$$
SELECT `costo_consulta_os`("SANCOR"); -- CHEQUEO DE LA FUNCION CON LA CONSULTA SOBRE PRECIO DE CONSULTA CON OSDE

-- FUNCION 2 : SELECCION DEL MEDICO ESPECIALISTA DE ACUERDO A LA ESPECIALIDAD REQUERIDA POR EL PACIENTE
DELIMITER $$
CREATE FUNCTION `med_esp` (especialidad VARCHAR(40))
RETURNS VARCHAR(40)
DETERMINISTIC
BEGIN
	DECLARE esp_name VARCHAR(255);
    DECLARE med_esp VARCHAR(255);
	SET esp_name = (SELECT especialidad.id_especialidad FROM especialidad WHERE especialidad.nombre = UPPER(especialidad) );
	SET med_esp = (SELECT CONCAT(medico.apellido," ",medico.nombre) FROM medico WHERE id_medico = esp_name);
    RETURN med_esp;
END;
$$
SELECT `med_esp`("pediatria");  -- CHEQUEO DE LA CONSULTA DEL MEDICO POR ESPECIALIDAD (CASO EN QUE HUBIERA UNO SOLO POR ESPECIALIDAD)

-- CREACION DE 2 STORED PROCEDURES --

-- STORED PROCEDURE 1: CAMPO DE ORDENAMIENTO Y ORDEN ASCENDENTE O DESCENDENTE
-- LISTA LOS PACIENTES DE ACUERDO A UN ORDEN DADO Y EN FORMA DESCENDENTE O ASCENDENTE--
delimiter $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_listar_pacientes`(IN camp_ordenamiento VARCHAR(30),IN ascordesc VARCHAR(30) )
BEGIN
IF camp_ordenamiento <> '' AND ascordesc <> ''
THEN 
SET @ordencampo = concat('ORDER BY ',' ', camp_ordenamiento, ' ', ascordesc);
ELSE
SELECT "Error no se pudo ordenar la tabla, por favor ingrese los parametros solicitados" as "";
END IF;
SET @clausula = concat('SELECT * FROM paciente ', @ordencampo);
PREPARE ejecutar_sql FROM @clausula;
EXECUTE ejecutar_sql;
DEALLOCATE PREPARE ejecutar_sql;
END$$
delimiter $$

CALL `sp_listar_pacientes`("nombre", "desc"); -- PRUEBA DEL STORED PROCEDURE

-- STORED PROCEDURE 2: AGREGA REGISTROS
-- SE USA PARA AGREGAR ESPECIALIDADES --
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_especialidad`(IN espec VARCHAR(30))
BEGIN
IF espec <> ""
THEN 
INSERT INTO especialidad(id_especialidad, nombre)
VALUES(NULL, espec);
ELSE
SELECT "Error no se pudo crear la especialidad indicado" as "";
END IF;
END $$
DELIMITER $$

CALL `sp_add_especialidad`("OTORRINOLARINGOLOGIA"); -- INTENTAMOS AGREGAR UNA NUEVA ESPECIALIDAD
SELECT * FROM especialidad; -- CHEQUEAMOS QUE LA TABLA DE ESPECIALIDAD HAYA SIDO ACTUALIZADA


-- CREACION DE TABLA RECEPTORA DE CAMBIOS DE CITAS
CREATE TABLE historial_citas (
id_movimiento INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
fecha DATE NOT NULL,
hora TIME NOT NULL,
usuario VARCHAR(30) NOT NULL,
id_cita INT NOT NULL,
fecha_cita DATE NOT NULL);

-- CREACION DE TRIGGER ins_citas CON FINALIDAD DE DETERMINAR QUIEN Y CUANDO CONCERTO UNA CITA A EFECTOS DE 
-- POSTERIORMENTE SI HAY ALGUN MAL ENTENDIDO EN CUANTO A FECHAS Y HORARIO DE CITAS

DELIMITER $$
CREATE TRIGGER `ins_citas`
AFTER INSERT ON `cita`
FOR EACH ROW
BEGIN
INSERT INTO historial_citas(id_movimiento, fecha, hora, usuario, id_cita, fecha_cita)
VALUES (NULL, current_date(), current_time(), SESSION_USER(), NEW.id_cita, NEW.fecha);
END$$

INSERT INTO cita VALUES(NULL, "2022/01/25", 1, 3) -- INSERTO UN NUEVO REGISTRO PARA VER SI EL TRIGGER SE DISPARA
SELECT * FROM historial_citas; -- CHEQUEO SI EL TRIGGER EFECTIVAMENTE GUARDO LA DATA ANTE LA CREACION DE LA CITA

-- CREACION DE TABLA RECEPTORA DE CAMBIOS DE
CREATE TABLE historial_os (
id_movimiento INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
fecha DATE NOT NULL,
hora TIME NOT NULL,
usuario VARCHAR(30) NOT NULL,
os_razon_social VARCHAR(30) NOT NULL,
os_precio INT NOT NULL);

-- CREACION DE TRIGGER upd_precio_os CON LA FINALIDAD DE SABER EL USUARIO Y FECHA DE LA ACTUALIZACIÓN DE PRECIOS DE LAS OS
-- CON LA FINALIDAD DE SABER EN QUE MOMENTO FUERON LAS ACTUALIZACIONES DE PRECIOS PARA PODER LUEGO DETERMINAR ANUALMENTE EL % TOTAL DE VARIACION
-- Y PODER CHEQUEAR SI EL USARIO ENCARGADO DE ACTUALIZAR LOS VALORES LO HIZO EN TIEMPO Y FORMA.

DELIMITER $$
CREATE TRIGGER `actualizarHistorialPreci`
AFTER UPDATE ON `obra_social`
FOR EACH ROW
BEGIN
INSERT INTO historial_os( fecha, hora, usuario, os_razon_social, os_precio)
VALUES (current_date(),current_time(), SESSION_USER(), NEW.razon_social, NEW.precio);
END$$
UPDATE obra_social SET razon_social='OSPEDYC' WHERE id_os=1; -- MODIFICO UNA OBRA SOCIAL PARA VER SI EL TRIGGER SE DISPARA
SELECT * FROM historial_os;-- CHEQUE LA TABLA BITACORA PARA VER SI EL UPDATE FUE REGISTRADO


-- CREAR 2 USUARIOS  : UserOne y UserTwo
USE MYSQL;
SELECT * FROM mysql.user;
SELECT * FROM mysql.user WHERE User="UserTwo";
CREATE USER `UserOne`@`localhost` IDENTIFIED BY "123456";   -- CREACION DEL USUARIO UserOne

-- CONCEDIENDO PERMISO SELECT EN TODAS LAS TABLAS AL USUARIO UserOne.

GRANT SELECT ON proy_centro_medico.cita TO `UserOne`@`localhost`;
GRANT SELECT ON proy_centro_medico.consultorio TO `UserOne`@`localhost`;
GRANT SELECT ON proy_centro_medico.especialidad TO `UserOne`@`localhost`;
GRANT SELECT ON proy_centro_medico.historial_citas TO `UserOne`@`localhost`;
GRANT SELECT ON proy_centro_medico.historial_os TO `UserOne`@`localhost`;
GRANT SELECT ON proy_centro_medico.medico TO `UserOne`@`localhost`;
GRANT SELECT ON proy_centro_medico.medico_obrasocial TO `UserOne`@`localhost`;
GRANT SELECT ON proy_centro_medico.obra_social TO `UserOne`@`localhost`;
GRANT SELECT ON proy_centro_medico.paciente TO `UserOne`@`localhost`;

-- REVOCANDO PERMISO DELETE EN TODAS LAS TABLAS AL USUARIO UserOne.

REVOKE DELETE ON proy_centro_medico.cita FROM `UserOne`@`localhost`;
REVOKE DELETE ON proy_centro_medico.consultorio FROM `UserOne`@`localhost`;
REVOKE DELETE ON proy_centro_medico.especialidad FROM `UserOne`@`localhost`;
REVOKE DELETE ON proy_centro_medico.historial_citas FROM `UserOne`@`localhost`;
REVOKE DELETE ON proy_centro_medico.historial_os FROM `UserOne`@`localhost`;
REVOKE DELETE ON proy_centro_medico.medico FROM`UserOne`@`localhost`;
REVOKE DELETE ON proy_centro_medico.medico_obrasocial FROM`UserOne`@`localhost`;
REVOKE DELETE ON proy_centro_medico.obra_social FROM `UserOne`@`localhost`;
REVOKE DELETE ON proy_centro_medico.paciente FROM `UserOne`@`localhost`;

CREATE USER `UserTwo`@`localhost` IDENTIFIED BY "654321";   -- CREACION DEL USUARIO UserTwo

-- CONCEDIENDO PERMISO SELECT, INSERT, UPDATE EN TODAS LAS TABLAS AL USUARIO UserTwo.

GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.cita TO `UserTwo`@`localhost`;
GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.consultorio TO `UserTwo`@`localhost`;
GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.especialidad TO `UserTwo`@`localhost`;
GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.historial_citas TO `UserTwo`@`localhost`;
GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.historial_os TO `UserTwo`@`localhost`;
GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.medico TO `UserTwo`@`localhost`;
GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.medico_obrasocial TO `UserTwo`@`localhost`;
GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.obra_social TO `UserTwo`@`localhost`;
GRANT SELECT, INSERT, UPDATE ON proy_centro_medico.paciente TO `UserTwo`@`localhost`;

-- REVOCANDO PERMISO DELETE EN TODAS LAS TABLAS AL USUARIO UserTwo.

REVOKE DELETE ON proy_centro_medico.cita FROM `UserTwo`@`localhost`;
REVOKE DELETE ON proy_centro_medico.consultorio FROM `UserTwo`@`localhost`;
REVOKE DELETE ON proy_centro_medico.especialidad FROM `UserTwo`@`localhost`;
REVOKE DELETE ON proy_centro_medico.historial_citas FROM `UserTwo`@`localhost`;
REVOKE DELETE ON proy_centro_medico.historial_os FROM `UserTwo`@`localhost`;
REVOKE DELETE ON proy_centro_medico.medico FROM `UserTwo`@`localhost`;
REVOKE DELETE ON proy_centro_medico.medico_obrasocial FROM`UserTwo`@`localhost`;
REVOKE DELETE ON proy_centro_medico.obra_social FROM `UserTwo`@`localhost`;
REVOKE DELETE ON proy_centro_medico.paciente FROM `UserTwo`@`localhost`;


SELECT * FROM cita;
SET AUTOCOMMIT = 0;
-- TRANSACCION 1: ELIMINAR REGISTROS DE TABLA CITA Y HACERLES ROLLBACK
START TRANSACTION;
DELETE FROM cita WHERE id_medico = 1; -- ESTE STATEMENT ELIMINARIA 2 REGISTROS
SELECT * FROM cita;
ROLLBACK;
SELECT * FROM cita;
COMMIT;

-- TRANSACCION 2: INSERCION DE REGISTROS Y UTLIZACION DE SAVEPOINTS
START TRANSACTION;
INSERT INTO obra_social VALUES
(NULL, 30123213421, "GALENO", "Nuche 2123", 1400),
(NULL, 30421312311, "OMINT", "Sivori 2223", 2300),
(NULL, 30153453232, "MEDICUS", "Alem 21135", 1200),
(NULL, 30543634523, "ODSIPP", "Cordoba 5674", 1700);
SAVEPOINT lote_1_4;
INSERT INTO obra_social VALUES
(NULL, 30654656434, "APSOT", "Central 6885", 1600),
(NULL, 30345345321, "ACA SALUD", "Santa Fe 2145", 1200),
(NULL, 30657565647, "SIMECO", "Vidart 8876", 2100),
(NULL, 30978789789, "TV SALUD", "Libano 6743", 1100);
SAVEPOINT lote_5_8;
RELEASE SAVEPOINT lote_1_4;
COMMIT;
SELECT * FROM obra_social;











