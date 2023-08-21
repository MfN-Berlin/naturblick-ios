//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ImprintView: View {
    
    private let appVersion: String = UIApplication.appVersion
    
    var body: some View {
        BaseView {
            ScrollView {
                VStack {
                    Text("**Imprint**\n\nMuseum für Naturkunde\nLeibniz Institute for Evolution and Biodiversity Science\nInvalidenstraße 43\n10115 Berlin, Germany\n\nLandesunmittelbare rechtsfähige Stiftung des öffentlichen Rechts\n\nTelefon: +49 (0)30 2093-8591\nFax: +49 (0)30 2093-8561\n\nE-Mail: [naturblick(at)mfn.berlin](mailto:naturblick@mfn.berlin)\nInternet: [http://www.naturkundemuseum-berlin.de](http://www.naturkundemuseum-berlin.de)\n\nAuthorized representative person\nProf. Johannes Vogel, PhD (Director General),\nStephan Junker (Managing Director)\n\nControlling authority\nSenatsverwaltung für Wirtschaft, Technologie und Forschung\nMartin-Luther-Straße 105, 10825 Berlin\n\nContent responsibility (German law § 55 Abs. 2 RStV)\nUlrike Sturm\n\nUVAT-ID (German law § 27 a Umsatzsteuergesetz) Bank account\nDeutsche Bank\naccount number: 512 087 800\nbank code: 100 708 48\nIBAN: DE40 1007\n0848 051 2087 800\nBIC/SWIFT: DEUTDEDB110\n\nFunding 2016-2021: German Federal Ministry for the Environment, Nature Conservation and Nuclear Safety (BMU)\n\nFurther information [here](https://naturblick.museumfuernaturkunde.berlin/about?lang=en)\n\nApp-Version: \(appVersion)\n\n**Sources**\n\nThe sources for the image and sound materials are indicated in the respective species portraits. Image and sound materials of species that do not yet have a species portrait or from other contexts of the app, such as identification tools, are given under other sources. German and English names taken in part from GBIF.org (2022), GBIF Home Page. Available from: [https://www.gbif.org](https://www.gbif.org) [28 September 2022].")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                    NavigationLink(destination: FurtherSourcesView()) {
                        Text("More sources")
                            .padding()
                            .foregroundColor(.onSecondaryButtonPrimary)
                
                    }
                    Text("**Additional Regulations**\n\nCopyright\n\nAll parts of the Website of the Museum für Naturkunde Berlin are copyrighted. You may not copy, reproduce, republish, download, post, broadcast, transmit, adapt or otherwise use any material on the Site other than for your own personal non-commercial use.\n\nDisclaimer\n\nFor all information published on the site of the Museum für Naturkunde Berlin the following conditions apply:\n\nUse of the material provided is bound by the following agreement: The Museum für Naturkunde Berlin makes every effort to provide timely and accurate information. Nevertheless, mistakes and confusions may occur. Therefore the publishers make no guarantee about the correctness, completeness, quality or suitability for any purpose of the information provided or linked to by this site. Information is provided \"as is\" without warranty of any kind, either expressed or implied, including, but not limited to warranties of fitness for a particular purpose. Under no circumstances shall the publishers be liable for any special, indirect, consequential or incidental damages or any damages whatsoever resulting from use of information provided by this site. If misleading, incorrect or otherwise inappropriate information is brought to our attention, a reasonable effort will be made to redress the problems.\n\nThe Museum für Naturkunde Berlin reserves the right to change, supplement, or delete some or all of the information on its Internet web site without notice. Similarly, the Museum für Naturkunde Berlin also reserves the right to temporarily or permanently discontinue the Internet web site.\n\nAny claims relating to the materials or the WWW site will be governed by German law.\n\nThe general disclaimer is part of [this disclaimer](https://www.disclaimer.de/disclaimer.htm).\n\nThis disclaimer is to be considered as part of the internet publication from which you were referred. If individual terms or sections of this statement are not legal or correct, the validity and content of the other parts remain uninfluenced by this fact.\n\nSource: [www.datenschutzbeauftragter-info.de](https://www.disclaimer.de/disclaimer.htm)\n\n© Museum für Naturkunde Berlin")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                }
            }
        }
    }
}

struct ImprintView_Previews: PreviewProvider {
    static var previews: some View {
        ImprintView()
    }
}
