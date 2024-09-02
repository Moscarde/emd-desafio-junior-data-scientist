# import basedosdados as bd
import pandas as pd
import requests

project_id = "desafio-tecnico-433722"


def get_bq_data() -> None:
    """
    Recebe os dados do basedosdados e salva em arquivos CSV.
    """
    queries = {
        "eventos": """
        SELECT *
        FROM `datario.turismo_fluxo_visitantes.rede_hoteleira_ocupacao_eventos`;
    """,
        "bairro": """
        SELECT *
        FROM `datario.dados_mestres.bairro`;
    """,
        "1746_2022_2024": """
        SELECT *
        FROM `datario.adm_central_atendimento_1746.chamado`
        WHERE DATE(data_inicio) >= '2022-01-01';
    """,
    }


    for key, query in queries.items():
        try:
            print(f'Obtendo dados de "{key}"')
            df = bd.read_sql(query, billing_project_id=project_id)
            df.to_csv(f'/data/{key}.csv', index=False)
        except Exception as e:
            print(f'Erro ao obter dados de "{key}": {e}')
            
    
def get_weather_data() -> None:
    """
    Recebe os dados da API open-meteo e salva em um arquivo CSV.
    """
    url_weather = "https://archive-api.open-meteo.com/v1/archive?latitude=-22.9064&longitude=-43.1822&start_date=2024-01-01&end_date=2024-08-01&hourly=temperature_2m&daily=weather_code&timezone=America%2FSao_Paulo"

    response = requests.get(url=url_weather)

    if response.status_code != 200:
        print(f"Erro ao fazer a requisição: {response.status_code}")
        return None

    response = response.json()

    df_hourly_temperatures = pd.DataFrame(response["hourly"])
    df_hourly_temperatures["date"] = pd.to_datetime(
        df_hourly_temperatures["time"]
    ).dt.date

    df_daily_weather = pd.DataFrame(response["daily"])
    df_daily_weather["date"] = pd.to_datetime(df_daily_weather["time"]).dt.date

    df_merged = df_hourly_temperatures.merge(df_daily_weather, on="date", how="outer")
    df_merged = df_merged[["time_x", "temperature_2m", "weather_code"]]

    df_merged.columns = ["datetime", "temperature", "weather_code"]
    df_merged["datetime"] = pd.to_datetime(df_merged["datetime"])

    df_merged.to_csv("data/weather.csv", index=False)

def get_holidays_data() -> None:

    url_holidays = "https://date.nager.at/api/v3/publicholidays/2024/BR"

    response = requests.get(url=url_holidays)

    if response.status_code != 200:
        print(f"Erro ao fazer a requisição: {response.status_code}")
        return None

    response = response.json()

    df_holidays = pd.DataFrame(response)
    df_holidays["date"] = pd.to_datetime(df_holidays["date"])
    df_holidays["month"] = df_holidays["date"].dt.month_name()

    df_holidays.to_csv("data/holidays.csv", index=False)

if __name__ == "__main__":
    get_bq_data()
    get_weather_data()
    get_holidays_data()
