//
//  CLPlaceMark+compactAddress.swift
//  MediaFinder11
//
//  Created by mohamed saad on 23/12/2022.
//

import MapKit

extension CLPlacemark{
    var compactAddress : String? {
        if let name = name{
            var result = name
            if let street = thoroughfare{
                result += ", \(street)"
            }
            if let city = locality {
                result += ", \(city)"
            }
            if let country = country {
                result += ", \(country)"
            }
            return result
            
        }
        return nil
    }
}
