-- 1. Tabla de Candidatos
CREATE TABLE candidatos (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  partido VARCHAR(150) NOT NULL,
  logo_url TEXT NOT NULL,
  votos INT DEFAULT 0
);

-- 2. Tabla de Alumnos (Padrón Electoral)
CREATE TABLE alumnos (
  dni VARCHAR(15) PRIMARY KEY,
  nombre_completo VARCHAR(150) NOT NULL,
  grado_seccion VARCHAR(50),
  ha_votado BOOLEAN DEFAULT FALSE
);

-- 3. Función segura (RPC) para registrar el voto en una sola transacción
CREATE OR REPLACE FUNCTION emitir_voto(p_dni VARCHAR, p_candidato_id INT)
RETURNS TEXT AS $$
DECLARE
  v_ya_voto BOOLEAN;
BEGIN
  -- Verificar si el alumno existe y si ya votó
  SELECT ha_votado INTO v_ya_voto FROM alumnos WHERE dni = p_dni;
  
  IF NOT FOUND THEN
    RETURN 'NO_EXISTE';
  END IF;

  IF v_ya_voto = TRUE THEN
    RETURN 'YA_VOTO';
  END IF;

  -- Registrar que el alumno ya votó y sumar 1 voto al candidato
  UPDATE alumnos SET ha_votado = TRUE WHERE dni = p_dni;
  UPDATE candidatos SET votos = votos + 1 WHERE id = p_candidato_id;

  RETURN 'EXITO';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Habilitar acceso público desde la API (para uso escolar rápido)
ALTER TABLE candidatos ENABLE ROW LEVEL SECURITY;
ALTER TABLE alumnos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Acceso total candidatos" ON candidatos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acceso total alumnos" ON alumnos FOR ALL USING (true) WITH CHECK (true);