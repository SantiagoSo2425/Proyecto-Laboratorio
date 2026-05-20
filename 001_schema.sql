CREATE SCHEMA IF NOT EXISTS proyecto;
SET search_path TO proyecto;

CREATE TABLE tipo_rol (
  id_tipo SERIAL PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE rol (
  id_rol SERIAL PRIMARY KEY,
  id_tipo INT NOT NULL REFERENCES tipo_rol(id_tipo),
  tipo VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE persona (
  id_persona SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  programa VARCHAR(150) NOT NULL,
  documento VARCHAR(40) NOT NULL UNIQUE,
  correo VARCHAR(150) NOT NULL UNIQUE,
  institucion VARCHAR(150) NOT NULL,
  nivel_academico VARCHAR(80) NOT NULL,
  semestre INT NULL,
  activo BOOLEAN NOT NULL DEFAULT TRUE,
  usuario VARCHAR(80) NOT NULL UNIQUE,
  clave_hash TEXT NOT NULL
);

CREATE TABLE proyecto (
  id_proyecto VARCHAR(40) PRIMARY KEY,
  nombre VARCHAR(200) NOT NULL,
  entidad_financiadora VARCHAR(150) NOT NULL
);

CREATE TABLE producto (
  id_producto SERIAL PRIMARY KEY,
  descripcion VARCHAR(250) NOT NULL
);

CREATE TABLE trabajo_grado (
  id_trabajo SERIAL PRIMARY KEY,
  id_proyecto VARCHAR(40) NOT NULL REFERENCES proyecto(id_proyecto),
  nombre VARCHAR(200) NOT NULL,
  facultad VARCHAR(120) NOT NULL
);

CREATE TABLE proyecto_persona (
  id SERIAL PRIMARY KEY,
  id_proyecto VARCHAR(40) NOT NULL REFERENCES proyecto(id_proyecto),
  persona_id INT NOT NULL REFERENCES persona(id_persona),
  id_rol INT NOT NULL REFERENCES rol(id_rol),
  horas_semanales INT NOT NULL CHECK (horas_semanales > 0),
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NULL
);

CREATE TABLE contrato (
  id SERIAL PRIMARY KEY,
  id_proyecto VARCHAR(40) NOT NULL REFERENCES proyecto(id_proyecto),
  id_persona INT NOT NULL REFERENCES persona(id_persona)
);

CREATE TABLE trabajo_persona (
  id SERIAL PRIMARY KEY,
  id_trabajo INT NOT NULL REFERENCES trabajo_grado(id_trabajo),
  id_persona INT NOT NULL REFERENCES persona(id_persona),
  id_rol INT NOT NULL REFERENCES rol(id_rol)
);

CREATE TABLE proyecto_producto (
  id SERIAL PRIMARY KEY,
  id_proyecto VARCHAR(40) NOT NULL REFERENCES proyecto(id_proyecto),
  id_producto INT NOT NULL REFERENCES producto(id_producto)
);

CREATE TABLE producto_trabajo (
  id SERIAL PRIMARY KEY,
  id_trabajo INT NOT NULL REFERENCES trabajo_grado(id_trabajo),
  id_producto INT NOT NULL REFERENCES producto(id_producto)
);
