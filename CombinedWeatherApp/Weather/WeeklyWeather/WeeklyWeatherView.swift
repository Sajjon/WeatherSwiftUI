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

struct WeeklyWeatherView {
	@ObservedObject var viewModel: WeeklyWeatherViewModel
	
	init(viewModel: WeeklyWeatherViewModel) {
		self.viewModel = viewModel
	}
}

// MARK: - View
extension WeeklyWeatherView: View {
	var body: some View {
		NavigationView {
			List {
				searchField
				
				if viewModel.dataSource.isEmpty {
					emptySection
				} else {
					cityHourlyWeatherSection
					forecastSection
				}
			}
			.listStyle(GroupedListStyle())
			.navigationBarTitle("Weather ⛅️")
		}
	}
}

// MARK: - Subviews
private extension WeeklyWeatherView {
	var searchField: some View {
		HStack(alignment: .center) {
			TextField("e.g. Cupertino", text: $viewModel.city)
		}
	}
	
	var forecastSection: some View {
		Section {
			ForEach(viewModel.dataSource, content: DailyWeatherRow.init(viewModel:))
		}
	}
	
	var cityHourlyWeatherSection: some View {
		Section {
			NavigationLink(destination: self.currentWeatherView) {
				VStack(alignment: .leading) {
					Text(viewModel.city)
					Text("Weather today")
						.font(.caption)
						.foregroundColor(.gray)
				}
			}
		}
	}
	
	var emptySection: some View {
		Section {
			Text("No results")
				.foregroundColor(.gray)
		}
	}
	
	var currentWeatherView: some View {
		return WeeklyWeatherBuilder.makeCurrentWeatherView(
			withCity: viewModel.city,
			weatherFetcher: viewModel.weatherFetcher
		)
	}
}
