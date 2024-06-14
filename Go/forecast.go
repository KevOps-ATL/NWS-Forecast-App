package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

// We create a struct to hold the STRUCTure of the data. It includes a nested struct for the properties.
type GetForecastUrl struct {
	Properties struct {
		Forecast string `json:"forecast"`
	} `json:"properties"`
}

type WeatherData struct {
	Properties struct {
		Periods []struct {
			RelativeHumidity struct {
				Value int `json:"value"`
			} `json:"relativeHumidity"`
			Temperature int `json:"temperature"`
			Dewpoint    struct {
				Value float64 `json:"value"`
			} `json:"dewpoint"`
		} `json:"periods"`
	} `json:"properties"`
}

func FetchURL(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to get URL: %v", err)
	}
	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %v", err)
	}

	return body, nil
}

func UnmarshalJSON[T any](data []byte) (T, error) {
	var obj T
	err := json.Unmarshal(data, &obj)
	if err != nil {
		return obj, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}
	return obj, nil
}

func GetWeatherData(url string) (WeatherData, error) {
	body, err := FetchURL(url)
	if err != nil {
		return WeatherData{}, err
	}

	getForecastUrl, err := UnmarshalJSON[GetForecastUrl](body)
	if err != nil {
		return WeatherData{}, err
	}

	if getForecastUrl.Properties.Forecast == "" {
		return WeatherData{}, fmt.Errorf("forecast URL is empty")
	}

	body, err = FetchURL(getForecastUrl.Properties.Forecast)
	if err != nil {
		return WeatherData{}, err
	}

	weatherData, err := UnmarshalJSON[WeatherData](body)
	if err != nil {
		return WeatherData{}, err
	}

	if len(weatherData.Properties.Periods) == 0 {
		return WeatherData{}, fmt.Errorf("no weather data available")
	}

	return weatherData, nil
}

func main() {
	urls := make(map[string]string)

	urls["Los Angeles"] = "https://api.weather.gov/points/34.0522,-118.2437"
	urls["Atlanta"] = "https://api.weather.gov/points/33.6362,-84.4294"
	urls["New York"] = "https://api.weather.gov/points/40.7833,-73.9666"
	urls["Chicago"] = "https://api.weather.gov/points/41.8376,-87.6818"

	for city, url := range urls {
		WeatherData, err := GetWeatherData(url)
		if err != nil {
			fmt.Printf("Failed to get weather data for %s: %v\n", city, err)
			continue
		}

		humidity := WeatherData.Properties.Periods[0].RelativeHumidity.Value
		temp := WeatherData.Properties.Periods[0].Temperature
		dewpoint := WeatherData.Properties.Periods[0].Dewpoint.Value

		fmt.Printf("The current humidity for the area of %s is %d%%\n", city, humidity)
		fmt.Printf("The current temperature for the area of %s is %d F\n", city, temp)
		fmt.Printf("The current dew point for the area of %s is %.2f\n", city, dewpoint)
	}
}
