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
        String(localized: "home")
    }
    
    func configureNavigationItem(item: UINavigationItem) {
        
        let appearance = item.standardAppearance?.copy()
        appearance?.configureWithTransparentBackground()
        item.standardAppearance = appearance
        item.compactAppearance = nil
        item.scrollEdgeAppearance = nil
        item.compactScrollEdgeAppearance = nil
        
        item.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), primaryAction: UIAction(image:  UIImage(systemName: "gearshape")) { action in
            let menuVC = MenuController(entries: [
                MenuEntry(title: String(localized: "help"), image: UIImage(systemName: "questionmark.circle")!) {
                    let view = HelpView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: String(localized: "account"), image: UIImage(systemName: "person")!) {
                    let view = AccountView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: String(localized: "action_settings"), image: UIImage(named: "settings")!) {
                    let view = SettingsView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: String(localized: "feedback"), image: UIImage(systemName: "square.and.pencil")!) {
                    let view = FeedbackView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: String(localized: "imprint"), image: UIImage(systemName: "shield")!) {
                    let view = ImprintView().setUpViewController()
                    navigationController?.pushViewController(view, animated: true)
                },
                MenuEntry(title: String(localized: "about_nb"), image: UIImage(systemName: "info.circle")!) {
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
                        Image("logo48")
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
                        Text("home_identify_animals_and_plants")
                            .headline6()
                            .padding(.defaultPadding)
                        
                        HStack(alignment: .top) {
                            Spacer()
                            
                            HomeViewButton(
                                text: String(localized: "record_a_bird"),
                                color: Color.onPrimaryButtonPrimary,
                                image: Image("audio48"),
                                size: topRowSize)
                            .onTapGesture {
                                createFlow.recordSound()
                            }
                            Spacer()
                            HomeViewButton(text: String(localized: "select_characteristics"),
                                           color: Color.onPrimaryButtonPrimary,
                                           image: Image("characteristics48"),
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
                            
                            HomeViewButton(text: String(localized: "photograph_a_plant"),
                                           color: Color.onPrimaryButtonPrimary,
                                           image: Image("photo48"),
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
                                text: String(localized: "field_book"),
                                color: Color.onPrimaryButtonSecondary,
                                image: Image("feldbuch48"),
                                size: bottomRowSize
                            )
                            .onTapGesture {
                                withNavigation { navigation in
                                    navigation.pushViewController(ObservationListViewController(), animated: true)
                                }
                            }
                            Spacer()
                            HomeViewButton(text: String(localized: "species_portraits"),
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
    }
}

