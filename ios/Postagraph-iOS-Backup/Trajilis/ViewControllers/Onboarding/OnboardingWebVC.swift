//
//  OnboardingWebVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 30/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import WebKit

final class OnboardingWebVC: UIViewController {
    var web: WKWebView!
    
    var url: URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let jscript = "var meta = document.createElement('meta');" +
        "meta.setAttribute('name', 'viewport');" +
            "meta.setAttribute('content', 'width=device-width');" +
        "document.getElementsByTagName('head')[0].appendChild(meta); scrollTo(0, 0);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        web = WKWebView(frame: view.bounds, configuration: wkWebConfig)
        view.addSubview(web)
        web.load(URLRequest.init(url: url))
        web.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavigationBar()
    }
}
