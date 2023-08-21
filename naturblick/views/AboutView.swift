//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct AboutView: View {
    var body: some View {
        BaseView {
            ScrollView {
                VStack {
                    Text("**Über Naturblick**\n\nIn einem interdisziplinären Team erforschen und entwickeln wir am Museum für Naturkunde Berlin digitale Werkzeuge für die urbane Naturerfahrung. Beispielsweise erproben wir den Einsatz von Mustererkennung in der Artbestimmung.\n\nMit unserer Smartphone-App Naturblick unterstützen wir die direkte Naturerfahrung in der Stadt. Mit vielfältigen Funktionen kannst du die Natur in der Stadt erkunden, Tiere und Pflanzen bestimmen und deine Beobachtungen speichern. Schau auch auf unsere [Plattform](https://naturblick.museumfuernaturkunde.berlin/). Dort findest du z.B. eine Karte mit bestätigten Beobachtungen anderer Nutzer:innen und die Rubrik “WissensWeiten” mit informierenden und inspirierenden Inhalte für alle, die sich näher mit der Natur um sie herum beschäftigen wollen.\n\n**Lauterkennung**\n\nDie Ergebnisse der automatisierten Artbestimmung werden durch den Vergleich mit Daten (in diesem Fall Audioaufnahmen von Vögeln), mit denen der Algorithmus trainiert wurde, erzeugt.\n\nDas bedeutet \n1) es können nur Arten erkannt werden, die auch trainiert wurden, \n2) die Erkennung funktioniert am besten, wenn eine große Ähnlichkeit zu der Aufnahmesituation und -qualität besteht (z.B. Mikrofonqualität).\n\nDer Naturblick Algorithmus wurde mit Audiomaterial aus dem Tierstimmenarchiv des Museum für Naturkunde Berlin, der kollaborativen Online-Datenbank Xeno-Canto und verifizierten Naturblick-Aufnahmen trainiert. Die Liste der Arten, die bestimmt werden können findest du [hier](https://naturblick.museumfuernaturkunde.berlin/speciesaudiorecognition).\n\n**Bilderkennung**\n\nDie Ergebnisse der automatisierten Artbestimmung werden durch den Vergleich mit Daten (in diesem Fall Fotos von Pflanzen), mit denen der Algorithmus trainiert wurde, erzeugt.\n\nDie Ergebnisse der automatisierten Artbestimmung werden durch den Vergleich mit Daten (in diesem Fall Fotos von Pflanzen), mit denen der Algorithmus trainiert wurde, erzeugt.\n\nDas bedeutet\n1) es können nur Arten erkannt werden, die auch trainiert wurden,\n2) die Erkennung funktioniert am besten, wenn eine große Ähnlichkeit zu der Aufnahmesituation und -qualität besteht (z.B. Pflanzen in der freien Natur).\n\nDer Naturblick Algorithmus wurde mit Bildmaterial von naturgucker, den LIFECLEF Challenges und iNaturalist trainiert. Die Liste der Arten, die bestimmt werden können findest du [hier](https://naturblick.museumfuernaturkunde.berlin/speciesimagerecognition)\n\nWir sind auf deine Unterstützung und dein Feedback angewiesen. Wir danken allen, die uns auf Fehler oder Probleme hinweisen oder Verbesserungsvorschläge machen.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    Button {
                        let deviceName = "ios"
                        let appVersion = UIApplication.appVersion
                        let survey = "https://survey.naturkundemuseum-berlin.de/de/Feedback%20Naturblick?device_name=\(deviceName)&version=\(appVersion)"
                        if let url = URL(string: survey) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Nutze unser Feedbackformular")
                            .button()
                            .padding()
                    }.background(Color.onSecondaryButtonPrimary)
                        .padding()
                    Button {
                        let email = "naturblick@mfn-berlin.de"
                        if let url = URL(string: "mailto:\(email)") {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Sende eine E-Mail")
                            .button()
                            .padding()
                    }.background(Color.onSecondaryButtonPrimary)
                        .padding()
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
