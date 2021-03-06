//
// Coronalert
//
// Devside and all other contributors
// copyright owners license this file to you under the Apache
// License, Version 2.0 (the "License"); you may not use this
// file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
//

import XCTest
import ExposureNotification
@testable import ENA

class BEURLRequestTests: XCTestCase {

	func testPayloadSize() throws {
		
		var keys:[ENTemporaryExposureKey] = []
		var countries:[BECountry] = []
		let dayCount = 14
		let startDate = Calendar.current.date(byAdding: .day, value: -dayCount, to: Date(), wrappingComponents: true)!
		let country = BECountry(code3: "BEL", name: ["nl":"België","fr":"Belgique","en":"Belgium","de":"Belgien"])

		for x in 0..<dayCount+1 {
			let date = Calendar.current.date(byAdding: .day, value: x, to: startDate, wrappingComponents: true)!
			let key = ENTemporaryExposureKey.random(date)

			keys.append(key)
			countries.append(country)
		}

		
		let emptyRequest = try URLRequest.submitKeysRequest(
			configuration: HTTPClient.Configuration.fake,
			mobileTestId: BEMobileTestId.random,
			testResult: TestResult.positive,
			keys: [],
			countries: [])

		let emptyBody = emptyRequest.httpBody!

		for x in 1..<dayCount {
			let keyRequest = try URLRequest.submitKeysRequest(
				configuration: HTTPClient.Configuration.fake,
				mobileTestId: BEMobileTestId.random,
				testResult: TestResult.positive,
				keys: Array(keys.prefix(upTo: x)),
				countries: Array(countries.prefix(upTo: x))
			)
			
			let keyBody = keyRequest.httpBody!
			
			XCTAssertEqual(emptyBody.count, keyBody.count)
		}
	}
}
