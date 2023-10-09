//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI

enum DeepLink : Equatable {
    case resetPasswort(token: String)
    case speciesPortrait(speciesId: Int64)
    case activateAccount(token: String)
}

class HomeViewController: HostingController<HomeView> {
    let persistenceController: ObservationPersistenceController
    let createFlow: CreateFlowViewModel
    let deepLink: DeepLink?
    
    init(deepLink: DeepLink? = nil) {
        self.deepLink = deepLink
        persistenceController = ObservationPersistenceController()
        createFlow = CreateFlowViewModel(persistenceController: persistenceController)
        let view = HomeView(deepLink: deepLink, persistenceController: persistenceController, createFlow: createFlow)
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
    
    @State var deepLink: DeepLink?
    
    func configureNavigationItem(item: UINavigationItem) {
        
        let appearance = item.standardAppearance?.copy()
        appearance?.configureWithTransparentBackground()
        item.standardAppearance = appearance
        item.compactAppearance = nil
        item.scrollEdgeAppearance = nil
        item.compactScrollEdgeAppearance = nil
        
        item.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), primaryAction: UIAction(image:  UIImage(systemName: "gearshape")) { action in
            let menuVC = MenuController(entries: [
                MenuEntry(title: "Help", image: UIImage(systemName: "questionmark.circle")!) {
                    let view = HelpView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: "Account", image: UIImage(systemName: "person")!) {
                    let view = AccountView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: "Settings", image: UIImage(named: "settings")!) {
                    let view = SettingsView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: "Feedback", image: UIImage(systemName: "square.and.pencil")!) {
                    let view = FeedbackView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: "Imprint", image: UIImage(systemName: "shield")!) {
                    let view = ImprintView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: "About Naturblick", image: UIImage(systemName: "info.circle")!) {
                    let view = AboutView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                }
            ]);
            
            menuVC.popoverPresentationController?.barButtonItem = action.sender as? UIBarButtonItem
            navigationController?.present(menuVC, animated: true)
        })
    }
    
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
            
            let topRowSize = geo.size.width * .topRowFactor
            let bottomRowSize = geo.size.width * .bottomRowFactor
            
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
                                image: Image("audio24"),
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
        }
        .edgesIgnoringSafeArea([.bottom])
        .onAppear {
            switch deepLink {
            case .activateAccount(let token):
                Task {
                    do {
                        try await BackendClient().activateAccount(token: token)
                        activated = true
                        navigationController?.pushViewController(AccountView().setUpViewController(), animated: true)
                    } catch {
                        preconditionFailure(error.localizedDescription)
                    }
                }
            case .resetPasswort(let token):
                navigationController?.pushViewController(ResetPasswordView(token: token).setUpViewController(), animated: true)
            case .speciesPortrait(let speciesId):
                let species = try? SpeciesListItem.find(speciesId: speciesId)
                if let species = species {
                    navigationController?.pushViewController(PortraitViewController(species: species, inSelectionFlow: true), animated: true)
                }
            case .none:
                return
            }
            deepLink = nil
        }
    }
}

