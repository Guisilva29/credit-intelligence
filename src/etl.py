
import os
from pathlib import Path
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.engine import URL


# =====================================================
# CONFIGURAÇÕES
# =====================================================

BASE_DIR = Path(__file__).resolve().parent.parent

load_dotenv(BASE_DIR / ".env")

ARQUIVO_ORIGEM = (
    BASE_DIR
    / "data"
    / "raw"
    / "default of credit card clients.xls"
)

ARQUIVO_TRATADO = (
    BASE_DIR
    / "data"
    / "processed"
    / "default_of_credit_card_clients.csv"
)


# =====================================================
# CONEXÃO COM O POSTGRESQL
# =====================================================

def criar_engine():
    senha = os.getenv("POSTGRES_PASSWORD")

    if not senha:
        raise ValueError(
            "Senha do PostgreSQL não encontrada no arquivo .env."
        )

    url = URL.create(
        drivername="postgresql+psycopg2",
        username="postgres",
        password=senha,
        host="localhost",
        port=5432,
        database="credit_intelligence",
    )

    return create_engine(url)


# =====================================================
# EXTRAÇÃO
# =====================================================

def extrair_dados(arquivo):
    if not arquivo.exists():
        raise FileNotFoundError(
            f"Arquivo de origem não encontrado: {arquivo}"
        )

    df = pd.read_excel(arquivo, header=1)

    print(f"Registros extraídos: {df.shape[0]}")
    print(f"Colunas extraídas: {df.shape[1]}")

    return df


# =====================================================
# VALIDAÇÃO
# =====================================================

def validar_dados(df):

    colunas_esperadas = [
        "ID",
        "LIMIT_BAL",
        "SEX",
        "EDUCATION",
        "MARRIAGE",
        "AGE",
        "PAY_0",
        "PAY_2",
        "PAY_3",
        "PAY_4",
        "PAY_5",
        "PAY_6",
        "BILL_AMT1",
        "BILL_AMT2",
        "BILL_AMT3",
        "BILL_AMT4",
        "BILL_AMT5",
        "BILL_AMT6",
        "PAY_AMT1",
        "PAY_AMT2",
        "PAY_AMT3",
        "PAY_AMT4",
        "PAY_AMT5",
        "PAY_AMT6",
        "default payment next month",
    ]

    # Verificar se todas as colunas obrigatórias existem.
    for coluna in colunas_esperadas:
        if coluna not in df.columns:
            raise ValueError(
                f"Coluna obrigatória ausente: {coluna}"
            )

    # Verificar valores nulos.
    if df[colunas_esperadas].isnull().values.any():
        raise ValueError(
            "O DataFrame contém valores nulos."
        )

    # Verificar IDs duplicados.
    if df["ID"].duplicated().any():
        raise ValueError(
            "Existem IDs de clientes duplicados."
        )

    # Verificar registros totalmente duplicados.
    if df.duplicated().any():
        raise ValueError(
            "O DataFrame contém registros duplicados."
        )

    print("Validação concluída com sucesso!")


# =====================================================
# TRANSFORMAÇÃO
# =====================================================

def transformar_dados(df):

    # Padronizar a escolaridade.
    escolaridade_tratada = {
        1: "Pós-graduação",
        2: "Ensino superior",
        3: "Ensino médio",
        4: "Outros",
        0: "Não informado",
        5: "Não informado",
        6: "Não informado",
    }

    df["escolaridade_tratada"] = df["EDUCATION"].map(
        escolaridade_tratada
    )

    # Padronizar o estado civil.
    estado_civil_tratado = {
        0: "Não informado",
        1: "Casado",
        2: "Solteiro",
        3: "Outros",
    }

    df["estado_civil_tratado"] = df["MARRIAGE"].map(
        estado_civil_tratado
    )

    # Verificar se algum código ficou sem classificação.
    if df["escolaridade_tratada"].isnull().any():
        raise ValueError(
            "Existem códigos de escolaridade sem classificação."
        )

    if df["estado_civil_tratado"].isnull().any():
        raise ValueError(
            "Existem códigos de estado civil sem classificação."
        )

    # Padronizar os nomes das colunas.
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_", regex=False)
    )

    print("Transformação concluída com sucesso!")

    return df


# =====================================================
# CARREGAMENTO
# =====================================================

def carregar_dados(df):

    # Criar a pasta de destino, se necessário.
    ARQUIVO_TRATADO.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    engine = criar_engine()

    try:
        # A carga no banco ocorre dentro de uma transação.
        with engine.begin() as conexao:

            tabela_existe = inspect(conexao).has_table(
                "clientes_credito",
                schema="public",
            )

            # Se a tabela existir, remover os registros antigos.
            # A estrutura e as restrições existentes são preservadas.
            if tabela_existe:
                conexao.execute(
                    text(
                        "DELETE FROM public.clientes_credito"
                    )
                )

            # Inserir os dados tratados.
            # Se a tabela não existir, o pandas irá criá-la.
            df.to_sql(
                name="clientes_credito",
                con=conexao,
                schema="public",
                if_exists="append",
                index=False,
                chunksize=1000,
                method="multi",
            )

        # Salvar o CSV após a carga no banco ser concluída.
        df.to_csv(
            ARQUIVO_TRATADO,
            index=False,
        )

    finally:
        engine.dispose()

    print("Carga concluída com sucesso!")
    print(f"CSV salvo em: {ARQUIVO_TRATADO}")
    print(f"Total de registros carregados: {len(df)}")


# =====================================================
# EXECUÇÃO DO PIPELINE
# =====================================================

if __name__ == "__main__":

    df = extrair_dados(ARQUIVO_ORIGEM)

    validar_dados(df)

    df = transformar_dados(df)

    print("\nDistribuição por escolaridade:")
    print(df["escolaridade_tratada"].value_counts())

    print("\nDistribuição por estado civil:")
    print(df["estado_civil_tratado"].value_counts())

    carregar_dados(df)
