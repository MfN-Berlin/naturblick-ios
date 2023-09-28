//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct ObservationInfoView: View {
    let width: CGFloat
    @ObservedObject var observationInfoVM: ObservationInfoViewModel
    
    let navigate: (UIViewController) -> Void
    
    private func avatar(image: UIImage) -> some View {
        return Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: width * 0.4, height: width * 0.4)
            .padding(.bottom, .defaultPadding)
    }
    
    var body: some View {
        VStack() {
            if let thumbnail = observationInfoVM.thumbnail?.image {
                if let fullScreen = observationInfoVM.fullscreenImage {
                    avatar(image: thumbnail).overlay(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.onPrimaryButtonPrimary)
                                .frame(width: 40, height: 40)
                            Image("zoom")
                                .foregroundColor(.onPrimaryHighEmphasis)
                        }.onTapGesture {
                            navigate(FullscreenView(imageId: fullScreen.id).setUpViewController())
                        }
                    }
                } else if let sound = observationInfoVM.sound {
                    avatar(image: thumbnail)
                        .overlay(alignment: .bottomTrailing) {
                            SoundButton(url: sound.url)
                        }
                } else {
                    avatar(image: thumbnail)
                }
            } else  {
                Image("placeholder")
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: width * 0.4, height: width * 0.4)
                    .padding(.bottom, .defaultPadding)
            } 
            if let sciname = observationInfoVM.species?.sciname {
                Text(sciname)
                    .font(.nbOverline)
                    .foregroundColor(.onPrimarySignalHigh)
                    .multilineTextAlignment(TextAlignment.center)
            }
            Text(observationInfoVM.species?.name ?? "Unknown species")
                .font(.nbHeadline2)
                .foregroundColor(.onPrimaryHighEmphasis)
                .multilineTextAlignment(TextAlignment.center)
            Text(observationInfoVM.created.date, formatter: .dateTime)
                .font(.caption)
                .foregroundColor(.onPrimarySignalLow)
                .multilineTextAlignment(TextAlignment.center)
        }
        .padding(.defaultPadding)
        .background(Color(uiColor: .onPrimaryButtonSecondary))
    }
}
