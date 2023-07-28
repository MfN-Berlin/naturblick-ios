//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct HelpView: View {
    var body: some View {
        BaseView {
            ScrollView {
                VStack {
                    Text("**How can I use Naturblick?**\n\nTake photos of plants and identify them with our automatic image recognition. Record bird sounds and identify which bird is singing with automatic sound recognition. Identify animals and plants by characteristics with our identification keys. Save and share your observations. Or learn more about species in the species portraits.\n\n**Image identification plants**\n\nThe quadratic image crop is used for the image identification. You can adjust the image crop by moving the square or dragging it smaller/larger. With the button \"submit\" you send the cropped image to the servers of the Museum für Naturkunde Berlin for automatic identification. The identification works best when there is a high similarity to the photo situation and quality (e.g. plants in the outdoors).\n\nWe display the three most probable results of the pattern recognition. The percentage value indicates the probability with which the algorithm has identified a species. The closer the number is to 100%, the more likely the match is. Only those species are recognized that have been trained by us (information about the species selection can be found in the menu \"About Naturblick\". Therefore it can happen that none of the suggested species is correct.\n\nThe Naturblick algorithm was trained with image material from naturgucker, the LIFECLEF Challenges and iNaturalist. The list of species that can be identified can be found [here](https://naturblick.museumfuernaturkunde.berlin/speciesimagerecognition?lang=en).\n\n**Sound recognition birds**\n\nThe white box is used for sound recognition. You can adjust the section by moving the square or dragging it smaller/wider. Please select a section that best represents the bird\'s sound. Our pattern recognition gives the best results for recordings that are under 10 seconds. With the button \"submit\" you send the section to the servers of the Museum für Naturkunde Berlin for automatic identification.\n\nWe display the three most probable results of the pattern recognition. The percentage value indicates the probability with which the algorithm has identified a species. The closer the number is to 100%, the more likely the match is. Only those species are recognized that have been trained by us (information about the species selection can be found in the menu \"About Naturblick\". Therefore it can happen that none of the suggested species is correct.\n\nThe Naturblick algorithm was trained with audio material from the Animal Sound Archive of the Museum für Naturkunde Berlin, the collaborative online database Xeno-Canto and verified Naturblick recordings. The list of species that can be identified can be found [here](https://naturblick.museumfuernaturkunde.berlin/speciesaudiorecognition?lang=en).\n\n**Identify with characteristics**\n\nIn our identification tools, you can choose which characteristics you want to select. Simply skip all characteristics that you cannot determine. In the short explanation text for each characteristic, you will find information if more than one answer can be selected. A list shows all the species that are possible based on your selection.\n\n**Fieldbook**\n\nYour observations are stored in the fieldbook and can be edited by you. You can also manually set or improve the location of your observation on the map. Scroll and zoom the map to place the pin at the location. You can add more observations using the plus symbol at the bottom right.")
                        .tint(Color.onSecondaryButtonPrimary)
                        .font(.nbBody1)
                        .padding()
                }
            }
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
    }
}
