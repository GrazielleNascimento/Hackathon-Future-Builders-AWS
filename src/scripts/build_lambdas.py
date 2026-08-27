import os
import shutil
import subprocess
import zipfile
import sys

# Configurações das funções Lambda
LAMBDA_FUNCTIONS = {
    "hello_terraform": {
        "src_dir": os.path.join("src", "lambdas", "lambda_hello"),
        "dist_file": "hello_terraform_lambda.zip",
    },
    "lead_capture": {
        "src_dir": os.path.join("src", "lambdas", "shopping_list", "add_item"),
        "dist_file": "lead_capture.zip",
    },
    "shopping_list_update_item": {
        "src_dir": os.path.join("src", "lambdas", "shopping_list", "update_item"),
        "dist_file": "update_item.zip",
    },
    "shopping_list_delete_item": {
        "src_dir": os.path.join("src", "lambdas", "shopping_list", "delete_item"),
        "dist_file": "delete_item.zip",
    },
    "shopping_list_list_items": {
    "src_dir": os.path.join("src", "lambdas", "shopping_list", "list_items"),
    "dist_file": "list_items.zip",
},

}

DIST_DIR = "dist"
TMP_DIR = "tmp"
REQUIREMENTS_FILE = "requirements.txt"


def install_dependencies(target_path):
    """Instala as dependências do requirements.txt na pasta target_path."""
    if not os.path.isfile(REQUIREMENTS_FILE):
        print(f"Aviso: {REQUIREMENTS_FILE} não encontrado, pulando instalação de dependências.")
        return

    print(f"Instalando dependências em {target_path}...")
    try:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "-r", REQUIREMENTS_FILE, "-t", target_path],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except subprocess.CalledProcessError as e:
        print(f"❌ Erro ao instalar dependências:\n{e.stderr.decode()}")
        sys.exit(1)


def create_zip(zip_path, source_dir):
    """Cria arquivo zip a partir da pasta source_dir."""
    print(f"Criando arquivo ZIP {zip_path} ...")
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zipf:
        for root, _, files in os.walk(source_dir):
            for file in files:
                full_path = os.path.join(root, file)
                arcname = os.path.relpath(full_path, source_dir)
                zipf.write(full_path, arcname)


def copy_source_files(src_dir, dest_dir):
    """Copia arquivos .py da src_dir para dest_dir."""
    if not os.path.isdir(src_dir):
        print(f"⚠️ Diretório de origem não encontrado: {src_dir}")
        return
    print(f"Copiando arquivos Python de {src_dir} para {dest_dir} ...")
    for item in os.listdir(src_dir):
        if item.endswith(".py"):
            shutil.copy2(os.path.join(src_dir, item), os.path.join(dest_dir, item))


def main():
    print("📦 Iniciando build dos arquivos ZIP das funções Lambda...")
    os.makedirs(DIST_DIR, exist_ok=True)
    os.makedirs(TMP_DIR, exist_ok=True)

    target = sys.argv[1] if len(sys.argv) > 1 else None
    found = False

    for name, config in LAMBDA_FUNCTIONS.items():
        if target and name != target:
            continue

        found = True
        print(f"\n📁 Empacotando função Lambda '{name}'...")

        func_tmp_path = os.path.join(TMP_DIR, name)
        if os.path.exists(func_tmp_path):
            shutil.rmtree(func_tmp_path)
        os.makedirs(func_tmp_path, exist_ok=True)

        copy_source_files(config["src_dir"], func_tmp_path)
        install_dependencies(func_tmp_path)

        zip_path = os.path.join(DIST_DIR, config["dist_file"])
        create_zip(zip_path, func_tmp_path)

        print(f"✅ Função '{name}' empacotada com sucesso: {zip_path}")

    shutil.rmtree(TMP_DIR, ignore_errors=True)

    if not found and target:
        print(f"❌ Função '{target}' não encontrada na configuração.")

    print(f"\n🎉 Todos os pacotes foram criados em '{DIST_DIR}/'")


if __name__ == "__main__":
    main()
