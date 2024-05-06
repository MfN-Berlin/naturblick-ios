//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)

import SwiftUI
import Photos

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

    override func viewDidAppear(_ animated: Bool) {
        if !UserDefaults.standard.bool(forKey: "agb") {
            let agb = PopAwareNavigationController(rootViewController: AGBViewController())
            agb.modalPresentationStyle = .fullScreen
            self.present(agb, animated: true)
        }
    }
    
    @objc func openMenu(sender: AnyObject) {
        let menuVC = MenuController(entries: [
            MenuEntry(title: String(localized: "help"), image: UIImage(systemName: "questionmark.circle")!) {
                let view = HelpView().setUpViewController()
                self.navigationController?.pushViewController(view, animated: true)
            },
            MenuEntry(title: String(localized: "account"), image: UIImage(systemName: "person")!) {
                let view = AccountView().setUpViewController()
                self.navigationController?.pushViewController(view, animated: true)
            },
            MenuEntry(title: String(localized: "action_settings"), image: UIImage(named: "settings")!) {
                let view = SettingsView().setUpViewController()
                self.navigationController?.pushViewController(view, animated: true)
            },
            MenuEntry(title: String(localized: "feedback"), image: UIImage(systemName: "square.and.pencil")!) {
                let view = FeedbackView().setUpViewController()
                self.navigationController?.pushViewController(view, animated: true)
            },
            MenuEntry(title: String(localized: "imprint"), image: UIImage(systemName: "shield")!) {
                let view = ImprintView().setUpViewController()
                self.navigationController?.pushViewController(view, animated: true)
            },
            MenuEntry(title: String(localized: "about_nb"), image: UIImage(systemName: "info.circle")!) {
                let view = AboutView().setUpViewController()
                self.navigationController?.pushViewController(view, animated: true)
            }
           ], width: 200);
           
           menuVC.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
           navigationController?.present(menuVC, animated: true)
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
        item.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .plain, target: viewController, action: #selector(HomeViewController.openMenu))
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
                VStack(spacing: .zero) {
                    Image("Kingfisher")
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .ignoresSafeArea()
                        .padding(.bottom, -geo.safeAreaInsets.top)
                    Spacer()
                }
                VStack(spacing: .zero) {
                    Image("logo24")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width / 4, alignment: .center)
                        .foregroundColor(.onPrimaryHighEmphasis)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .bottomLeading) {
                            Image("mfn_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width / 5)
                            .foregroundColor(.gray)
                            .padding(.defaultPadding)
                    }
                    RoundBottomView(color: .primaryColor)
                        .frame(height: .roundBottomHeight)
                    
                    VStack(spacing: .defaultPadding) {
                        Text("home_identify_animals_and_plants")
                            .headline6()
                        
                        HStack(alignment: .top) {
                            Spacer()
                            
                            HomeViewButton(
                                text: String(localized: "record_a_bird"),
                                color: Color.onPrimaryButtonPrimary,
                                image: Image("audio24"),
                                size: topRowSize)
                            .onTapGesture {
                                createFlow.recordSound()
                            }
                            Spacer()
                            HomeViewButton(text: String(localized: "select_characteristics"),
                                           color: Color.onPrimaryButtonPrimary,
                                           image: Image("characteristics24"),
                                           size: topRowSize
                            )
                            .onTapGesture {
                                createFlow.selectCharacteristics()
                            }
                            Spacer()
                            
                            HomeViewButton(text: String(localized: "photograph_a_plant"),
                                           color: Color.onPrimaryButtonPrimary,
                                           image: Image("photo24"),
                                           size: topRowSize
                            )
                            .onTapGesture {
                                createFlow.takePhoto()
                            }
                            Spacer()
                        }
                        
                        HStack(alignment: .top) {
                            Spacer()
                            HomeViewButton(
                                text: String(localized: "field_book"),
                                color: Color.onPrimaryButtonSecondary,
                                image: Image("feldbuch24"),
                                size: bottomRowSize
                            )
                            .onTapGesture {
                                withNavigation { navigation in
                                    navigation.pushViewController(ObservationListViewController(persistenceController: persistenceController), animated: true)
                                }
                            }
                            Spacer()
                            HomeViewButton(text: String(localized: "species_portraits"),
                                           color: Color.onPrimaryButtonSecondary,
                                           image: Image("ic_specportraits"),
                                           size: bottomRowSize
                            ).onTapGesture {
                                let nextViewController = GroupsView(
                                    viewType: .portraitGroups,
                                    groups: Group.groups,
                                    destination: { group in
                                        SpeciesListView(filter: .group(group), flow: createFlow)
                                    }).setUpViewController()
                                viewController?.navigationController?.pushViewController(nextViewController, animated: true)
                            }
                            Spacer()
                        }
                        .padding(.defaultPadding)
                        .padding(.bottom, geo.safeAreaInsets.bottom + .defaultPadding)
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
        .permissionSettingsDialog(isPresented: $createFlow.showOpenSettings, presenting: createFlow.openSettingsMessage)
    }
}

