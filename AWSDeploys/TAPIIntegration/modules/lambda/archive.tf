data "archive_file" "dependencias" {
  #depends_on  = [null_resource.rebuild_trigger]
  type        = "zip"
  source_dir  = "resources/layers/dependencias"
  output_path = "resources/layers/dependencias.zip"
}

data "archive_file" "pg8000" {
  type        = "zip"
  source_dir  = "resources/layers/pg8000"
  output_path = "resources/layers/pg8000.zip"
}

resource "null_resource" "rebuild_trigger" {
  triggers = {
    always_run = "${timestamp()}"
  }
}