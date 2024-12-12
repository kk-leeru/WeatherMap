from typing import Union
from fastapi import FastAPI
import requests
import dotenv
import os

app = FastAPI()
dotenv.load_dotenv()
API_KEY = os.getenv("WEATHER_API_KEY")


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/weather/")
async def read_weather(lat:float, lng: float):
    #lat, lng are required parameters
    units = 'metric'
    url = f'https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lng}&units={units}&appid={API_KEY}'
    response = requests.get(url)
    #response successful (200)
    if response.status_code == 200:
        data = response.json()
        # return jsonify(
        #     {'hi': 'get api url is correct'}
        # ), 200
        # return jsonify(data),200
        forecast = str(data['weather'][0]['description']).capitalize()
        weatherIcon = str(data['weather'][0]['icon'])

        temperature = data['main']['temp']
        temperature = str(format(temperature, '.1f')) #convert from Kelvin to celsius 
        humidity = str(data['main']['humidity'])

        return {
            "forecast": forecast, 
            "temperature": temperature,
            "humidity": humidity,
            "weatherIcon": weatherIcon, 
        }

        # return jsonify(
        #     {"forecast": forecast, 
        #     "temperature": temperature,
        #     "humidity": humidity,
        #     "weatherIcon": weatherIcon, 
        #     }),200

    else:
        return {'error': 'Failed to retrieve the weather info'}
        # return jsonify({
        #     'error': 'Failed to retrieve the weather page'
        # }), 500

