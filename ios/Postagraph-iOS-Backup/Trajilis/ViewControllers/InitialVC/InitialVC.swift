//
//  InitialVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
let USERDETAILKEY = "USERDETAILKEY"
class InitialVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.setWhiteAppearance()
        
        guard let userId = UserDefaults.standard.string(forKey: USERID) else {
            let controller = SplashVC.instantiate(fromAppStoryboard: .onboarding)
            navigationController?.pushViewController(controller, animated: true)
            return
        }
        if userId.isEmpty {
            let controller = SplashVC.instantiate(fromAppStoryboard: .onboarding)
            navigationController?.pushViewController(controller, animated: true)
            return
        }
        DataStorage.shared.dataStorage.async.object(forKey: USERDETAILKEY) { [weak self] (response) in
            DispatchQueue.main.async {
                guard let self = self else {return}
                switch response {
                case .error(_):
                    self.getUser(navigate: true)
                case .value(let result):
                    guard let json = try? JSONSerialization.jsonObject(with: result, options: []) as? JSONDictionary,
                        let data = json?["data"] as? JSONDictionary else { return }
                    let user = User.init(json: data)
                    UserDefaults.standard.set(user.id, forKey: USERID)
                    (UIApplication.shared.delegate as? AppDelegate)?.user = user
                    self.getUser(navigate: false)
                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    kAppDelegate.window?.rootViewController = controller
                    //self.navigationController?.present(controller!, animated: true, completion: nil)
                    return
                }
            }
        }
    }
    
    private func getUser(navigate: Bool) {
        Helpers.getCurrentUser { [weak self](success) in
            if navigate {
                if success {
                    let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
                    kAppDelegate.window?.rootViewController = controller
                    //self.navigationController?.pushViewController(controller!, animated: true)
                } else {
                    let controller = SplashVC.instantiate(fromAppStoryboard: .onboarding)
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
            }
           
        }
    }
    deinit {
        print("deinit")
    }
}

