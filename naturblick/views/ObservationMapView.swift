//
// Copyright © 2024 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI
import MapKit

struct ObservationMapView: UIViewRepresentable {
    let backend: Backend
    @ObservedObject var persistenceController: ObservationPersistenceController
    @Binding var userTrackingMode: MKUserTrackingMode

    let initial: Observation?
    let toDetails: (Observation) -> Void

    init(backend: Backend, userTrackingMode: Binding<MKUserTrackingMode>, initial: Observation?, toDetails: @escaping (Observation) -> Void) {
        self.backend = backend
        self.persistenceController = backend.persistence
        self._userTrackingMode = userTrackingMode
        self.initial = initial
        self.toDetails = toDetails
    }
    
    private func setAnnotations(map: MKMapView) {
        var annotations = persistenceController.observations
            .compactMap { observation in
                guard let coords = observation.observation.coords else {
                    return nil as (Observation, Coordinates)?
                }
                return (observation, coords)
            }
            .map { (observation, coordinates) in
                ObservationAnnotation(observation: observation, coordinates: coordinates)
            }
        let oldAnnotations = map.annotations
        var deletedAnnotations = oldAnnotations
        deletedAnnotations.removeAll(where: { annotation in
            if let annotation = annotation as? ObservationAnnotation {
                return annotations.contains(annotation)
            } else {
                return false
            }
        })
        annotations.removeAll(where: { annotation in
            return oldAnnotations.contains(where: { old in
                if let old = old as? ObservationAnnotation {
                    return old == annotation
                } else {
                    return false
                }
            })
        })
        map.removeAnnotations(deletedAnnotations)
        map.addAnnotations(annotations)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.showsCompass = false
        map.delegate = context.coordinator
        map.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(ObservationAnnotation.self))
        
        setAnnotations(map: map)
        if let observation = initial, let annotation = map.annotations
            .compactMap({annotation in annotation as? ObservationAnnotation})
            .first(where: { annotation in
                return annotation.observation.id == observation.id
            }) {
            map.setRegion(annotation.coordinates.region, animated: false)
            map.selectAnnotation(annotation, animated: false)
        } else {
            map.setRegion(.defaultRegion, animated: false)
        }
        return map
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.setUserTrackingMode(userTrackingMode, animated: true)
        let _ = setAnnotations(map: view)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        private var parent: ObservationMapView

        init(_ parent: ObservationMapView) {
            self.parent = parent
        }
        private func popup(_ mapView: MKMapView) -> PopupContainer? {
            mapView.subviews.first { view in
                view is PopupContainer
            } as? PopupContainer
        }
        func showObservation(_ mapView: MKMapView, annotation: ObservationAnnotation) {
            let point = mapView.convert(annotation.coordinate, toPointTo: mapView)
            let infoBox = MapInfoBox(observation: annotation.observation, backend: parent.backend, toDetails: parent.toDetails)
            let controller = UIHostingController(rootView: infoBox)
            let popup = PopupContainer(frame: CGRect(x: point.x - 224 / 2, y: point.y - 224, width: 224, height: 224), subview: controller.view)
            mapView.addSubview(popup)
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView){
            parent.userTrackingMode = mapView.userTrackingMode
            
            if let annotation = mapView.selectedAnnotations.first, let popup = popup(mapView) {
                let point = mapView.convert(annotation.coordinate, toPointTo: mapView)
                popup.frame = CGRect(x: point.x - 224 / 2, y: point.y - 224, width: 224, height: 224)
            }
        }

        private func setupObservationAnnotationView(for annotation: ObservationAnnotation, on mapView: MKMapView) -> MKAnnotationView {
            let reuseIdentifier = NSStringFromClass(ObservationAnnotation.self)
            let testAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
            testAnnotationView.canShowCallout = false
            
            // Provide the annotation view's image.
            let image = UIImage(named: annotation.observation.species?.group.mapIcon ?? "map_undefined_spec")
            testAnnotationView.image = image
            return testAnnotationView
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else {
                // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
                return nil
            }
            var annotationView: MKAnnotationView?
            if let annotation = annotation as? ObservationAnnotation {
                annotationView = setupObservationAnnotationView(for: annotation, on: mapView)
            }
            return annotationView
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation, let observationAnnotation = annotation as? ObservationAnnotation else {
                return
            }
            if popup(mapView) == nil {
                showObservation(mapView, annotation: observationAnnotation)
            }
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            if let popup = popup(mapView) {
                popup.removeFromSuperview()
            }
        }
    }

    class ObservationAnnotation: NSObject, MKAnnotation {
        let observation: Observation
        let coordinates: Coordinates
        @objc dynamic var coordinate: CLLocationCoordinate2D
        
        init(observation: Observation, coordinates: Coordinates) {
            self.observation = observation
            self.coordinates = coordinates
            self.coordinate = coordinates.location
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            if let other = object as? ObservationAnnotation {
                return self.observation.observation == other.observation.observation
            } else {
                return false
            }
        }
    }
    
    class PopupContainer: UIView {
        init(frame: CGRect, subview: UIView) {
            super.init(frame: frame)
            subview.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            subview.backgroundColor = UIColor(Color.blackFullyTransparent)
            addSubview(subview)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
