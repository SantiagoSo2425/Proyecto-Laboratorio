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
  codigo_proyecto VARCHAR(80) NOT NULL UNIQUE,
  nombre VARCHAR(200) NOT NULL,
  entidad_financiadora VARCHAR(150) NOT NULL,
  tipo VARCHAR(30) NOT NULL DEFAULT 'investigacion',
  CONSTRAINT proyecto_tipo_chk CHECK (tipo IN ('investigacion', 'extension'))
);

CREATE TABLE institucion (
  id_institucion SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL UNIQUE
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

CREATE TABLE persona_institucion (
  id SERIAL PRIMARY KEY,
  id_persona INT NOT NULL REFERENCES persona(id_persona),
  id_institucion INT NOT NULL REFERENCES institucion(id_institucion),
  CONSTRAINT persona_institucion_unique UNIQUE (id_persona, id_institucion)
);

CREATE TABLE proyecto_institucion (
  id SERIAL PRIMARY KEY,
  id_proyecto VARCHAR(40) NOT NULL REFERENCES proyecto(id_proyecto),
  id_institucion INT NOT NULL REFERENCES institucion(id_institucion),
  CONSTRAINT proyecto_institucion_unique UNIQUE (id_proyecto, id_institucion)
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
