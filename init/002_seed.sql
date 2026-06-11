SET search_path TO proyecto;

-- Catalogs
INSERT INTO tipo_rol (id_tipo, nombre) VALUES
  (1, 'Administrativo'),
  (2, 'Academico')
ON CONFLICT (id_tipo) DO NOTHING;

INSERT INTO rol (id_rol, id_tipo, tipo) VALUES
  (1, 1, 'Admin'),
  (2, 2, 'Investigador')
ON CONFLICT (id_rol) DO NOTHING;

INSERT INTO institucion (id_institucion, nombre) VALUES
  (1, 'Universidad Demo'),
  (2, 'Instituto de Innovacion')
ON CONFLICT (id_institucion) DO NOTHING;

-- Personas
INSERT INTO persona (
  id_persona,
  nombre,
  programa,
  documento,
  correo,
  nivel_academico,
  semestre,
  activo,
  usuario,
  clave_hash
) VALUES
  (
    1,
    'Admin Sistema',
    'Administracion',
    '1000000000',
    'admin@example.com',
    'Administrador',
    NULL,
    TRUE,
    'admin',
    '$2b$12$PdNnTKEN0jKU9LFPdk9YaOgn1emXQEScOL970Aj6eh4YzrU2wlHDW'
  ),
  (
    2,
    'Investigador Demo',
    'Ingenieria de Sistemas',
    '1000000001',
    'investigador@example.com',
    'Estudiante',
    8,
    TRUE,
    'investigador',
    '$2b$12$PdNnTKEN0jKU9LFPdk9YaOgn1emXQEScOL970Aj6eh4YzrU2wlHDW'
  )
ON CONFLICT (id_persona) DO NOTHING;

-- Proyecto
INSERT INTO proyecto (id_proyecto, codigo_proyecto, nombre, entidad_financiadora, tipo) VALUES
  ('PRJ-001', 'PRJ-001', 'Sistema de gestion laboratorio', 'Universidad Demo', 'investigacion')
ON CONFLICT (id_proyecto) DO NOTHING;

-- Trabajo de grado
INSERT INTO trabajo_grado (id_trabajo, id_proyecto, nombre, facultad) VALUES
  (1, 'PRJ-001', 'Plataforma de seguimiento de proyectos', 'Ingenieria')
ON CONFLICT (id_trabajo) DO NOTHING;

-- Producto
INSERT INTO producto (id_producto, descripcion) VALUES
  (1, 'Articulo cientifico inicial')
ON CONFLICT (id_producto) DO NOTHING;

-- Relaciones
INSERT INTO proyecto_persona (
  id,
  id_proyecto,
  persona_id,
  id_rol,
  horas_semanales,
  fecha_inicio,
  fecha_fin
) VALUES
  (1, 'PRJ-001', 1, 1, 20, '2026-01-01', NULL),
  (2, 'PRJ-001', 2, 2, 12, '2026-02-01', NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO persona_institucion (id, id_persona, id_institucion) VALUES
  (1, 1, 1),
  (2, 2, 1),
  (3, 2, 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO proyecto_institucion (id, id_proyecto, id_institucion) VALUES
  (1, 'PRJ-001', 1),
  (2, 'PRJ-001', 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO contrato (id, id_proyecto, id_persona) VALUES
  (1, 'PRJ-001', 1),
  (2, 'PRJ-001', 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO trabajo_persona (id, id_trabajo, id_persona, id_rol) VALUES
  (1, 1, 2, 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO proyecto_producto (id, id_proyecto, id_producto) VALUES
  (1, 'PRJ-001', 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO producto_trabajo (id, id_trabajo, id_producto) VALUES
  (1, 1, 1)
ON CONFLICT (id) DO NOTHING;

-- Sync sequences after explicit ids
SELECT setval('proyecto.tipo_rol_id_tipo_seq', (SELECT COALESCE(MAX(id_tipo), 1) FROM proyecto.tipo_rol));
SELECT setval('proyecto.rol_id_rol_seq', (SELECT COALESCE(MAX(id_rol), 1) FROM proyecto.rol));
SELECT setval('proyecto.institucion_id_institucion_seq', (SELECT COALESCE(MAX(id_institucion), 1) FROM proyecto.institucion));
SELECT setval('proyecto.persona_id_persona_seq', (SELECT COALESCE(MAX(id_persona), 1) FROM proyecto.persona));
SELECT setval('proyecto.trabajo_grado_id_trabajo_seq', (SELECT COALESCE(MAX(id_trabajo), 1) FROM proyecto.trabajo_grado));
SELECT setval('proyecto.producto_id_producto_seq', (SELECT COALESCE(MAX(id_producto), 1) FROM proyecto.producto));
SELECT setval('proyecto.proyecto_persona_id_seq', (SELECT COALESCE(MAX(id), 1) FROM proyecto.proyecto_persona));
SELECT setval('proyecto.persona_institucion_id_seq', (SELECT COALESCE(MAX(id), 1) FROM proyecto.persona_institucion));
SELECT setval('proyecto.proyecto_institucion_id_seq', (SELECT COALESCE(MAX(id), 1) FROM proyecto.proyecto_institucion));
SELECT setval('proyecto.contrato_id_seq', (SELECT COALESCE(MAX(id), 1) FROM proyecto.contrato));
SELECT setval('proyecto.trabajo_persona_id_seq', (SELECT COALESCE(MAX(id), 1) FROM proyecto.trabajo_persona));
SELECT setval('proyecto.proyecto_producto_id_seq', (SELECT COALESCE(MAX(id), 1) FROM proyecto.proyecto_producto));
SELECT setval('proyecto.producto_trabajo_id_seq', (SELECT COALESCE(MAX(id), 1) FROM proyecto.producto_trabajo));
