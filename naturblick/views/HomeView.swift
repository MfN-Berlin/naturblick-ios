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
                let view = SettingsViewController()
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
        item.rightBarButtonItem?.accessibilityLabel = String(localized: "acc_settings")
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var persistenceController: ObservationPersistenceController
    @ObservedObject var createFlow: CreateFlowViewModel

    func header(width: CGFloat) -> some View {
            ZStack {
                Image("logo24")
                    .resizable()
                    .scaledToFit()
                    .frame(width: width / 3)
                    .foregroundColor(.onPrimaryHighEmphasis)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                Image("mfn_logo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray)
                    .padding(.defaultPadding)
                    .frame(width: width / 3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.bottom, .roundBottomHeight)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Image("Kingfisher")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .clipShape(RoundBottomShape())
            .nbShadow()
            .ignoresSafeArea()
            .accessibility(hidden: true)
        }
    
    func topRow(width: CGFloat) -> some View {
        let topRowSize = width * .topRowFactor
        return HStack(alignment: .top) {
            Spacer()
            
            HomeViewButton(
                text: String(localized: "record_a_bird"),
                color: Color.onPrimaryButtonPrimary,
                image: Image("audio24"),
                size: topRowSize) {
                createFlow.recordSound()
            }
            Spacer()
            HomeViewButton(text: String(localized: "select_characteristics"),
                           color: Color.onPrimaryButtonPrimary,
                           image: Image("characteristics24"),
                           size: topRowSize
            ) {
                createFlow.selectCharacteristics()
            }
            Spacer()
            
            HomeViewButton(text: String(localized: "photograph_a_plant"),
                           color: Color.onPrimaryButtonPrimary,
                           image: Image("photo24"),
                           size: topRowSize
            ) {
                createFlow.takePhoto()
            }
            Spacer()
        }
        .frame(maxWidth: width)
    }
    
    func bottomRow(width: CGFloat) -> some View {
        let bottomRowSize = width * .bottomRowFactor
        return HStack(alignment: .top) {
            Spacer()
            HomeViewButton(
                text: String(localized: "field_book"),
                color: Color.onPrimaryButtonSecondary,
                image: Image("feldbuch24"),
                size: bottomRowSize
            ) {
                withNavigation { navigation in
                    navigation.pushViewController(ObservationListViewController(persistenceController: persistenceController), animated: true)
                }
            }
            Spacer()
            HomeViewButton(text: String(localized: "species_portraits"),
                           color: Color.onPrimaryButtonSecondary,
                           image: Image("specportraits"),
                           size: bottomRowSize
            ) {
                createFlow.createFromPortrait()
            }
            Spacer()
        }
        .frame(maxWidth: width, alignment: .bottom)
        .padding(.defaultPadding)
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = min(geo.size.width, .maxContentWidth)

            VStack(spacing: 0) {
                header(width: width)
                VStack(spacing: .defaultPadding) {
                    Text("home_identify_animals_and_plants")
                        .headline6()
                        .padding(.defaultPadding)
                    
                    topRow(width: width)
                    bottomRow(width: width)
                }
                .frame(maxWidth: .infinity)

            }
        }
        .background(Color.primaryColor)
    }
}
