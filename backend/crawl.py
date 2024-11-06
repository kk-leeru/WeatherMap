from numpy import double
import requests
from bs4 import BeautifulSoup
from flask import Flask, jsonify, request
from flask_cors import CORS
import re


app = Flask(__name__)
CORS(app)

@app.route('/')
def home():
    return "Welcome to Web Crawler!"

# ONLY GET WEATHER
@app.route('/get_weather', methods=['GET'])
def get_weather():
    try:
        
        lat = request.args.get('lat')
        lng = request.args.get('lng')
        units = 'metric'
        API_key = '38f33ed494f4d613172c435d00620a54'
        
        url = f'https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lng}&units={units}&appid={API_key}'

        print(f"for mnaul test: https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lng}&units={units}&appid={API_key}")
        #test: https://api.openweathermap.org/data/2.5/weather?lat=25.0&lon=121.5&appid=38f33ed494f4d613172c435d00620a54
        
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
            print(f'HERE weatherIcon: {weatherIcon}')
            temperature = data['main']['temp']
            temperature = str(format(temperature, '.1f')) #convert from Kelvin to celsius 
            humidity = str(data['main']['humidity'])
            return jsonify(
                {"forecast": forecast, 
                "temperature": temperature,
                "humidity": humidity,
                "weatherIcon": weatherIcon, 
                }),200

        else:
            print('Failed to retrieve the weather page')
            return jsonify({
                'error': 'Failed to retrieve the weather page'
            }), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
    # try:
    #     address_url = 'https://nominatim.openstreetmap.org/reverse?lat={value}&lon={value}&{params}'
    #     address_response = requests.get(address_url)
    #     if address_response.status_code == 200:
    #         data = address_response

    #     else: 
    #         print('Failed to fetch address')
    # except Exception as e:
    #     return jsonify({'fetch address error': str(e) }),500

@app.route('/scrape', methods=['GET'])
def scrape():
    try:    
        # lat = request.args.get('lat')
        # lng = request.args.get('lng')
        # Replace with the URL of the weather page you want to scrape
        # url = f'https://weather.com/weather/today/l/{lat},{lng}'
        # url = f'https://weather.com/weather/today/l/121.5,25.04'
        url = f'http://google.com'
        # Send a request to the website
        response = requests.get(url)

        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            # return jsonify(
            #     {'hello': 'can seen'}
            # ), 200
            
            # Parse the HTML content
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # print(soup)
            # Find the specific weather data (you need to inspect the page's HTML)
            temperature = soup.find('span', class_=re.compile(r'CurrentConditions--tempValue--.*')).text            
            humidity = soup.find('div', class_=re.compile(r'CurrentConditions--phraseValue--.*')).text
            address = soup.find('h1', class_=re.compile(r'CurrentConditions--location--.*')).text
            
            if temperature != "N/A":
                temperature = double(temperature.replace('°', ''))  # Remove the degree symbol
                temperature = (temperature - 32) * 5 / 9  # Convert to Celsius

            temperature = str(temperature)
            print(f'Temperature: {temperature}')
            print(f'Humidity: {humidity}')
            print(f'Address: {address}')

            # url = f'https://nominatim.openstreetmap.org/reverse?lat={lat}&lon={lng}&format=json'
            # places_url = f'https://places.googleapis.com/v1/places:searchText'
            # #TODO
            # geojson = None
            # response = requests.get(url)
            # if response.status_code == 200:
            #     data = response.json()
            #     if 'address' in data:
            #         address = data['display_name']
            #         region = data['address'].get('state', None)

            #     if 'osm_id' in data:
            #         osm_id = data['osm_id']
            #         geojson_url = f'https://nominatim.openstreetmap.org/lookup?osm_ids='R'+{osm_id}&format=jsonv2&polygon_geojson=1'
            #         response = requests.get(geojson_url)
            #         if 'geojson' in data:
            #             geojson = (data['geojson'])
            #         else:
            #             print(f"can't get geojson")
            #     else:
            #         print(f"Error: can't get osm_id")

            # print(f"""Nominatim's Address: {address}
            #       Geojson: {geojson}
            #       """)
            return jsonify({
                'temperature': temperature,
                'humidity': humidity,
                'address': address,
                # 'region': region
            })
            
    
        else:
            print('Failed to retrieve the page')
            return jsonify({
                'error': 'Failed to retrieve the page'
            }), 500
    except Exception as e:
        return jsonify({'error': str(e)}),500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)

    