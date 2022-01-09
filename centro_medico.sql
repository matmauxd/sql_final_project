CREATE SCHEMA IF NOT EXISTS proyecto_centro_medico;

USE proyecto_centro_medico;

CREATE TABLE IF NOT EXISTS obra_social (
	id_os INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    razon_social VARCHAR(255) NOT NULL,
    cuit BIGINT NOT NULL,
    direccion VARCHAR(255) 
    );
    
CREATE TABLE IF NOT EXISTS especialidad (
	id_especialidad INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL
    );
CREATE TABLE IF NOT EXISTS consultorio (
	id_consultorio INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    direccion VARCHAR(255) NOT NULL,
    cp INT NOT NULL,
    telefono INT NOT NULL,
    email VARCHAR(255) NOT NULL
    );
    
CREATE TABLE IF NOT EXISTS paciente (
	id_paciente INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
   apellido VARCHAR(255) NOT NULL,
   fecha_nacim DATE NOT NULL,
   mail VARCHAR(255) NOT NULL,
   direccion VARCHAR(255),
   id_os INT NOT NULL,
   FOREIGN KEY (id_os) REFERENCES obra_social(id_os)
    );
    
CREATE TABLE IF NOT EXISTS medico (
	id_medico INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    fecha_nacim DATE NOT NULL,
    matricula INT NOT NULL,
    id_especialidad INT NOT NULL,
	FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad)
    );
    
CREATE TABLE IF NOT EXISTS cita (
	id_cita INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    fecha DATE NOT NULL,
    id_medico INT NOT NULL,
    id_paciente INT NOT NULL,
    id_consultorio INT NOT NULL,
    id_especialidad INT NOT NULL,
    FOREIGN KEY(id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY(id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY(id_consultorio) REFERENCES consultorio(id_consultorio),
    FOREIGN KEY(id_especialidad) REFERENCES especialidad(id_especialidad)
    );
    
    CREATE TABLE IF NOT EXISTS medico_obrasocial (
	id_medico INT NOT NULL,
    id_os INT NOT NULL,
	FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_os) REFERENCES obra_social(id_os)
    );
    
    INSERT INTO consultorio
VALUES
(NULL, "Libertador 123", 5400, 4202020, "lib_123@gmail.com"),
(NULL, "Aberastain 321", 5425, 4202222, "aber_321@gmail.com"),
(NULL, "Santa Fe 456", 5400, 4202020, "sfe_456@gmail.com");
    
INSERT INTO especialidad
VALUES 
(NULL, "PEDIATRIA"),
(NULL, "TRAUMATOLOGIA"),
(NULL, "GINECOLOGIA");

INSERT INTO medico
VALUES
(NULL, "Carlos","Macias", '1976/01/19', 8019, 1),
(NULL, "Matias","Arce", '1980/11/10', 9091, 2),
(NULL, "Carla","Vallejos", '1990/03/01', 11200, 3);

INSERT INTO obra_social
VALUES 
(NULL, "OSDE", 30358526358, "Rawson 987"),
(NULL, "SANCOR", 30700768601, "Cordoba 789"),
(NULL, "OSECAC", 30405230202, "Rawson 987");

INSERT INTO paciente
VALUES
(NULL, "Franco", "Gomez", "1990/04/14", "fragom@gmail.com", "Vidart 121" ,1),
(NULL, "Elisa", "Carrera", "1999/06/10", "elicar@gmail.com", "Alem 242",2),
(NULL, "Maria", "Becerra", "2000/06/15", "mabec@gmail.com", "Brasil 114",3);

ALTER TABLE medico_obrasocial
ADD id_mos INT NOT NULL PRIMARY KEY AUTO_INCREMENT;

INSERT INTO medico_obrasocial
VALUES
(1, 2, NULL),
(2, 3, NULL),
(3, 1, NULL);

INSERT INTO cita
VALUES
(1, "2022/01/05", 1, 2, 1, 2);
    
    
    
    
    
    
    
    
    
    
    
