# Definición de la capa pg8000
resource "aws_lambda_layer_version" "pg8000" {
  layer_name    = "pg8000_tmp"
  description   = "Capa pg8000"
  compatible_runtimes = ["python3.10"]
  filename      = data.archive_file.pg8000.output_path
}

# Definición de la capa dependencias
resource "aws_lambda_layer_version" "dependencias" {
  layer_name    = "dependencias_tmp"
  description   = "Capa de dependencias"
  compatible_runtimes = ["python3.10"]
  filename      = data.archive_file.dependencias.output_path
  source_code_hash    = data.archive_file.dependencias.output_base64sha256
}
