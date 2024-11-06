import requests
from bs4 import BeautifulSoup
# from flask import Flask, jsonify
# from flask_cors import CORS
import re

# app = Flask(__name__)
# CORS(app)

# @app.route('/')
# def home():
#     return "Welcome to Web Crawler!"

# @app.route('/scrape', methods=['GET'])
# def scrape():
#     try:    
        # Replace with the URL of the weather page you want to scrape

url = 'https://weather.com/weather/today/l/25.02,121.45'

    # Send a request to the website
response = requests.get(url)

# Check if the request was successful (status code 200)
if response.status_code == 200:
    # Parse the HTML content
    soup = BeautifulSoup(response.text, 'html.parser')
    
    # print(soup)
    # Find the specific weather data (you need to inspect the page's HTML)
    temperature_element = soup.find('span', class_=re.compile(r'CurrentConditions--tempValue--.*')).text
    
    humidity_element = soup.find('div', {'class': 'CurrentConditions--phraseValue--mZC_p'}).text
    address_element = soup.find('h1',{'class':'CurrentConditions--location--yub4l'}).text
    # humidty ='humidity'
    # address='address'
    # Check if elements were found
   

    print(f'Temperature: {temperature_element}')
    print(f'Humidity: {humidity_element}')
    print(f'Address: {address_element}')
    # return jsonify({
    #     'temperature': temperature,
    #     'humidity': humidity,
    #     'address': address
    # })
    
    # result = temperature + ', ' + humidity + ', ' + address
    # return result

else:
    print('Failed to retrieve the page')
    # return jsonify({
    #     'error': 'Failed to retrieve the page'
    # }), 500
# except Exception as e:
#     return jsonify({'error': str(e)}),500

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=8080)