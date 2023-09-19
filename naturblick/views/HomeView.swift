//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

class HomeViewController: HostingController<HomeView> {
    let persistenceController: ObservationPersistenceController
    let createFlow: CreateFlowViewModel
    init() {
        persistenceController = ObservationPersistenceController()
        createFlow = CreateFlowViewModel(persistenceController: persistenceController)
        let view = HomeView(persistenceController: persistenceController, createFlow: createFlow)
        view.viewController?.view.backgroundColor = .primaryHome
        super.init(rootView: view)
        createFlow.setViewController(controller: self)
    }
}

struct HomeView: HostedView {
    var holder: ViewControllerHolder = ViewControllerHolder()
    
    var viewName: String? {
        "Home"
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        let appearance = item.standardAppearance?.copy()
        appearance?.configureWithTransparentBackground()
        item.standardAppearance = appearance
        item.compactAppearance = nil
        item.scrollEdgeAppearance = nil
        item.compactScrollEdgeAppearance = nil
        item.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), menu: UIMenu(children: [
            UIAction(title: "Help", image: UIImage(named: "questionmark.circle")) {_ in
                let helpViewController = HelpView().setUpViewController()
                navigationController?.pushViewController(helpViewController, animated: true)
            },
            UIAction(title: "Account", image: UIImage(named: "person")) {_ in
                let accountViewController = AccountView().setUpViewController()
                navigationController?.pushViewController(accountViewController, animated: true)
            },
            UIAction(title: "Settings", image: UIImage(named: "gearshape")) {_ in
                let settingViewController = SettingsView().setUpViewController()
                navigationController?.pushViewController(settingViewController, animated: true)
                
            },
            UIAction(title: "Feedback", image:  UIImage(named: "square.and.pencil")) {_ in
                print("Here comes the feedback-view")
            },
            UIAction(title: "Imprint", image:  UIImage(named: "shield")) {_ in
                let imprintViewController = ImprintView().setUpViewController()
                navigationController?.pushViewController(imprintViewController, animated: true)
            },
            UIAction(title: "About Naturblick", image:  UIImage(named: "info.circle")) {_ in
                let aboutViewController = AboutView().setUpViewController()
                navigationController?.pushViewController(aboutViewController, animated: true)
            }
        ]))
    }
    
    let firstRowWidthFactor: CGFloat = 4.5
    let secondRowWidthFactor: CGFloat = 5
    @Environment(\.colorScheme) var colorScheme

    @State var isShowingPortrait = false
    @State var speciesId: Int64? = nil
    
    @State var isShowingResetPassword = false
    @State var token: String? = nil
    
    @State var isShowingLogin = false
    @AppStorage("activated") var activated: Bool = false
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var createFlow: CreateFlowViewModel

    var body: some View {
        GeometryReader { geo in
            
            let topRowSize = geo.size.width * 0.25
            let bottomRowSize = geo.size.width * 0.2
            
            ZStack {
                VStack {
                    Image("Kingfisher")
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .ignoresSafeArea()
                        .padding(.bottom, -geo.safeAreaInsets.top)
                    Spacer()
                }
                VStack {
                    VStack {
                        Image("logo24")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width / 4, alignment: .center)
                            .foregroundColor(.onPrimaryHighEmphasis)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(alignment: .bottomLeading) {
                        Image("mfn_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width / 5)
                            .foregroundColor(.gray)
                            .padding(.defaultPadding)
                    }
                    RoundBottomView()
                        .frame(height: .roundBottomHeight)
                    
                    VStack {
                        Text("Identify animals and plants")
                            .foregroundColor(.onPrimaryHighEmphasis)
                            .font(.nbHeadline6)
                            .padding(.defaultPadding)
                        
                        HStack(alignment: .top) {
                            Spacer()

                                    HomeViewButton(
                                        text: "Record a bird sound",
                                        color: Color.onPrimaryButtonPrimary,
                                        image: Image("microphone"),
                                        size: topRowSize)
                                    .onTapGesture {
                                        createFlow.recordSound()
                                    }
                            Spacer()
                                HomeViewButton(text: "Select characteristics",
                                               color: Color.onPrimaryButtonPrimary,
                                               image: Image("characteristics24"),
                                               size: topRowSize
                                )
                                .onTapGesture {
                                    let nextViewController = GroupsView(
                                        groups: Group.characterGroups,
                                        destination: { group in
                                            CharactersView(group: group)
                                        }
                                    ).setUpViewController()
                                    viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                                }
                            Spacer()
                           
                                    HomeViewButton(text: "Photograph a plant",
                                                   color: Color.onPrimaryButtonPrimary,
                                                   image: Image("photo24"),
                                                   size: topRowSize
                                    )
                                    .onTapGesture {
                                        createFlow.takePhoto()
                                    }
                            Spacer()
                        }
                        .padding(.bottom, .defaultPadding)
                        
                        HStack(alignment: .top) {
                            Spacer()
                            HomeViewButton(
                                text: "Fieldbook",
                                color: Color.onPrimaryButtonSecondary,
                                image: Image("feldbuch24"),
                                size: bottomRowSize
                            )
                            .onTapGesture {
                                withNavigation { navigation in
                                    navigation.pushViewController(ObservationListViewController(), animated: true)
                                }
                            }
                            Spacer()
                            HomeViewButton(text: "Learn about species",
                                           color: Color.onPrimaryButtonSecondary,
                                           image: Image("ic_specportraits"),
                                           size: bottomRowSize
                            ).onTapGesture {
                                let nextViewController = GroupsView(
                                    groups: Group.groups,
                                    destination: { group in
                                        SpeciesListView(filter: .group(group))
                                    }).setUpViewController()
                                viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                            }
                            Spacer()
                        }
                        .padding(.bottom, .defaultPadding * 2)
                    }
                    .frame(width: geo.size.width)
                    .background {
                        Rectangle()
                            .foregroundColor(.primaryColor)
                    }
                }
            }
        }.edgesIgnoringSafeArea([.bottom])
    }
}

