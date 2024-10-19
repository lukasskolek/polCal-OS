import Foundation
import SwiftUI
import SwiftData

func loadScenarios1998() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby1998", withExtension: "json") else {
        print("Could not find mockVolby1998.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

func loadScenarios2002() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby2002", withExtension: "json") else {
        print("Could not find mockVolby2002.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

func loadScenarios2006() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby2006", withExtension: "json") else {
        print("Could not find mockVolby2006.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

func loadScenarios2010() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby2010", withExtension: "json") else {
        print("Could not find mockVolby2010.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

func loadScenarios2012() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby2012", withExtension: "json") else {
        print("Could not find mockVolby2012.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

func loadScenarios2016() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby2016", withExtension: "json") else {
        print("Could not find mockVolby2016.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

func loadScenarios2020() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby2020", withExtension: "json") else {
        print("Could not find mockVolby2020.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}

func loadScenarios2023() -> [Scenario]? {
    // Locate the JSON file in the bundle
    guard let url = Bundle.main.url(forResource: "mockVolby2023", withExtension: "json") else {
        print("Could not find mockVolby2023.json in the bundle.")
        return nil
    }
    
    do {
        // Load the data from the JSON file
        let data = try Data(contentsOf: url)
        
        // Decode the JSON data into an array of Scenario structs
        let decodedScenarios = try JSONDecoder().decode([Scenario].self, from: data)
        
        return decodedScenarios
    } catch {
        print("Failed to load and parse JSON: \(error)")
        return nil
    }
}
