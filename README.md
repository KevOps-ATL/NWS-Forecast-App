# Weather Forecast CLI

This is a simple command-line interface (CLI) application written in Go that fetches and prints the current weather data for a list of cities.

## How it works

The application uses the National Weather Service API to fetch weather data for specific geographical points (latitude, longitude). It prints the humidity, temperature, and dew point for each city.

## Code Structure

The code is organized into two main parts:

1. [`GetWeatherData(url string) (WeatherData, error)`](command:_github.copilot.openSymbolFromReferences?%5B%7B%22%24mid%22%3A1%2C%22path%22%3A%22%2FUsers%2Ftrapbook%2Factions-cicd%2Fforecast.go%22%2C%22scheme%22%3A%22file%22%7D%2C%7B%22line%22%3A31%2C%22character%22%3A5%7D%5D "forecast.go"): This function takes a URL as input, sends a GET request to the National Weather Service API, and returns the weather data for the geographical point represented by the URL.

2. [`main()`](command:_github.copilot.openSymbolFromReferences?%5B%7B%22%24mid%22%3A1%2C%22path%22%3A%22%2FUsers%2Ftrapbook%2Factions-cicd%2Fforecast.go%22%2C%22scheme%22%3A%22file%22%7D%2C%7B%22line%22%3A77%2C%22character%22%3A5%7D%5D "forecast.go"): This function creates a map of city names to URLs, then iterates over the map. For each city, it calls [`GetWeatherData(url)`](command:_github.copilot.openSymbolFromReferences?%5B%7B%22%24mid%22%3A1%2C%22path%22%3A%22%2FUsers%2Ftrapbook%2Factions-cicd%2Fforecast.go%22%2C%22scheme%22%3A%22file%22%7D%2C%7B%22line%22%3A31%2C%22character%22%3A5%7D%5D "forecast.go") to fetch the weather data, then prints the humidity, temperature, and dew point.

## Usage

To run the application, use the `go run` command:

```bash
go run forecast.go
```

## Output

The output will look something like this:

```
The current humidity for the area of Los Angeles is 58%
The current temperature for the area of Los Angeles is 72 F
The current dew point for the area of Los Angeles is -73.33
The current humidity for the area of Atlanta is 36%
The current temperature for the area of Atlanta is 90 F
The current dew point for the area of Atlanta is 15.00
```

## Error Handling

The application includes basic error handling. If it fails to fetch the weather data for a city, it will print an error message and continue with the next city. If the API response does not contain a forecast URL for a city, the application will terminate with an error.

## Future Improvements

Future improvements could include unit and BDD tests, support for more cities, and additional weather data such as wind speed and precipitation.