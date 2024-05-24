//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import Foundation
import SnowplowTracker
import UIKit

class AnalyticsTracker {
    
    private static var tracker: TrackerController? = nil
    
    static func initalizeTracker() {
        let deviceId = Settings.deviceId()
        let subjectConfig = SubjectConfiguration()
            .userId( deviceId )
        
        let emitterConfig = EmitterConfiguration()
              .bufferOption(BufferOption.single)
              .emitRange(25)

        let networkConfig = NetworkConfiguration(endpoint: Configuration.analyticsUrl)
        
        let trackerConfig = TrackerConfiguration()
            .sessionContext(true)
            .platformContext(true)
            .lifecycleAutotracking(false)
            .screenViewAutotracking(true)
            .screenContext(true)
            .applicationContext(true)
            .exceptionAutotracking(true)
            .installAutotracking(true)
            .userAnonymisation(false)
        
        let sessionConfig = SessionConfiguration(
            foregroundTimeout: Measurement(value: 15, unit: .minutes),
            backgroundTimeout: Measurement(value: 15, unit: .minutes)
        )
        
        AnalyticsTracker.tracker = Snowplow.createTracker(
            namespace: "iosTracker",
            network: networkConfig,
            configurations: [subjectConfig, emitterConfig, trackerConfig, sessionConfig]
        )
    }
    
    static func trackStartEvent() {
        let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let display = UIScreen.main.bounds
        let displayData = "{\"width\":\(Int(display.width)), \"height\":\(Int(display.height))}"
        let event = Structured(category: "Init", action: "startNaturblick")
            .label(appVersion)
            .property(displayData)

        AnalyticsTracker.tracker?.track(event)
    }

    static func trackSpeciesSelection(filter: SpeciesListFilter, viewType: GroupsViewType? = nil) {
        switch filter {
        case .characters( _, let query):
            let selection: [Int64] = query.filter{ $0.1 > 0.0 }.map{ $0.0 }
            
            if let selectionString = try? JSONSerialization.data(withJSONObject: selection) {
                let event = Structured(category: "UI", action: "resultSpeciesList")
                    .label("MKey")
                    .property(String(data: selectionString, encoding: String.Encoding.utf8))
                
                AnalyticsTracker.tracker?.track(event)
            }
        case .group(let group):
            if let view = viewType {
                let action: String = view == .portraitGroups ? "pickSpeciesGroup" : "pickSpeciesMKey"
                let event = Structured(category: "UI", action: action)
                    .label(group.id)
                    .property(group.gerName)
                
                AnalyticsTracker.tracker?.track(event)
            }
        }
    }
        
    static func trackPortrait(species: SpeciesListItem) {
        let event = Structured(category: "UI", action: "speciesPortrait")
            .label(String(species.id))
            .property(species.sciname)
            .value(NSNumber(value: species.speciesId))
        
        AnalyticsTracker.tracker?.track(event)
    }
    
    static func trackPortraitSound(speciesId: Int64, url: String) {
        let event = Structured(category: "UI", action: "playSpeciesPortraitSound")
            .label(String(speciesId))
            .property(url)
            .value(NSNumber(value: speciesId))
        
        AnalyticsTracker.tracker?.track(event)
    }
    
    static func trackError(error: Error) {
        let event = SNOWError(message: "\(error)")
            .stackTrace("\(Thread.callStackSymbols)")
        AnalyticsTracker.tracker?.track(event)
    }
    
    static func trackError(message: String) {
        let event = SNOWError(message: message)
        AnalyticsTracker.tracker?.track(event)
    }
}

