
import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

# Localizar a pasta principal do projeto
BASE_DIR = Path(__file__).resolve().parent.parent

# Carregar as configurações do arquivo .env
load_dotenv(BASE_DIR / ".env")

senha = os.getenv("POSTGRES_PASSWORD")

if not senha:
    raise ValueError("A senha do PostgreSQL não foi encontrada no .env")

# Montar a URL de conexão
url = URL.create(
    drivername="postgresql+psycopg2",
    username="postgres",
    password=senha,
    host="localhost",
    port=5432,
    database="credit_intelligence",
)

# Criar a conexão
engine = create_engine(url)

# Testar a conexão com o banco
with engine.connect() as conexao:
    resultado = conexao.execute(text("SELECT version()"))
    print("Conexão estabelecida com sucesso!")
    print(resultado.scalar())
