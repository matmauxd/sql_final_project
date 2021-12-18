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
    
    
    
    
    
    
    
    
    
    
    
    
    