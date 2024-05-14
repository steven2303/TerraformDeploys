CREATE SCHEMA IF NOT EXISTS modelos_matrix;


CREATE TABLE IF NOT EXISTS modelos_matrix.recomendador_producto_perfil (
	cod_persona text NOT NULL,
	participacion_puntos float NULL,
	participacion_frec float NULL,
	participacion_rec float NULL,
	numero_socios_unicos float NULL,
	participacion_canje float NULL,
	participacion_frec_canje float NULL,
	participacion_rec_canje float NULL,
	perfil decimal,
	sku_1 text NULL,
	sku_2 text NULL,
	sku_3 text NULL,
	sku_4 text NULL,
	sku_5 text NULL,
	sku_6 text NULL,
	sku_7 text NULL,
	sku_8 text NULL,
	sku_9 text NULL,
	sku_10 text NULL,
	sku_11 text NULL,
	sku_12 text NULL,
	sku_13 text NULL,
	sku_14 text NULL,
	sku_15 text NULL,
	fec_proceso TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'America/Lima')
);

CREATE INDEX idx_cod_persona ON modelos_matrix.recomendador_producto_perfil (cod_persona);

CREATE TABLE IF NOT EXISTS modelos_matrix.desercion_reingreso_cross (
	cod_persona text NOT NULL,
	socio text NOT NULL,
	mes_nuevo_socio float NULL,
	prob_nuevo_socio float NULL,
	pred_nuevo_socio float NULL,
	cat_nuevo_socio text NULL,
	tiempo_bonus float NULL,
	mes_reingreso float NULL,
	prob_reingreso float NULL,
	pred_reingreso float NULL,
	meses_inactivos float NULL,
	cat_reingreso text NULL,
	mes_desercion float NULL,
	prob_desercion float NULL,
	pred_desercion float NULL,
	cat_desercion text NULL,
	fec_proceso TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'America/Lima')
);

CREATE INDEX idx_cod_persona_socio ON modelos_matrix.desercion_reingreso_cross (cod_persona, socio);


CREATE TABLE IF NOT EXISTS modelos_matrix.recomendador_clientes (
	cod_persona text NOT NULL PRIMARY KEY,
	tip_cliente text NOT NULL,
	nro_modelo int NOT NULL,
	sku_1 text NULL,
	sku_2 text NULL,
	sku_3 text NULL,
	sku_4 text NULL,
	sku_5 text NULL,
	sku_6 text NULL,
	sku_7 text NULL,
	sku_8 text NULL,
	sku_9 text NULL,
	sku_10 text NULL,
	sku_11 text NULL,
	sku_12 text NULL,
	sku_13 text NULL,
	sku_14 text NULL,
	sku_15 text NULL,
	fec_proceso TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'America/Lima')
);

CREATE INDEX idx_cod_cliente ON modelos_matrix.recomendador_clientes (cod_persona);