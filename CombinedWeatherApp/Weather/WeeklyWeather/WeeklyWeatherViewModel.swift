/// Copyright (c) 2019 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI
import Combine

class WeeklyWeatherViewModel: ObservableObject {
	@Published var city: String = ""
	@Published var dataSource: [DailyWeatherRowViewModel] = []
	
	let weatherFetcher: WeatherFetcher
	private var disposables = Set<AnyCancellable>()
	
	init(
		weatherFetcher: WeatherFetcher,
		scheduler: DispatchQueue = DispatchQueue(label: "WeatherViewModel")
	) {
		self.weatherFetcher = weatherFetcher
		_ = $city
			.dropFirst(1)
			.debounce(for: .seconds(0.5), scheduler: scheduler)
			.sink(receiveValue: fetchWeather(forCity:))
	}
}

// MARK: - Action
extension WeeklyWeatherViewModel {
	
	func fetchWeather(forCity city: String) {
		weatherFetcher.weeklyWeatherForecast(forCity: city)
			.map { response in
				response.list.map(DailyWeatherRowViewModel.init)
		}
		.map(Array.removeDuplicates)
		.receive(on: DispatchQueue.main)
		.sink(
			receiveCompletion: { [weak self] value in
				guard let self = self else { return }
				switch value {
				case .failure:
					self.dataSource = []
				case .finished:
					break
				}
			},
			receiveValue: { [weak self] forecast in
				guard let self = self else { return }
				self.dataSource = forecast
		})
			.store(in: &disposables)
	}
}
