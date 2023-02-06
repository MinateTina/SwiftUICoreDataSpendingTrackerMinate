//
//  DeviceIdiomView.swift
//  SwiftUICoreDataSpendingTrackerMinate
//
//  Created by Tina Tung on 2/5/23.
//

import SwiftUI

struct DeviceIdiomView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            MainPadDeviceView()
        } else {
            if horizontalSizeClass == .compact
            {
                Color.red
            } else {
                Color.green
            }
        }
    }
}

struct DeviceIdiomView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceIdiomView()
        
        if #available(iOS 15.0, *) {
            DeviceIdiomView().previewDevice(PreviewDevice(rawValue: "ipad pro (11-inch) (5th generation)"))
                .environment(\.horizontalSizeClass, .regular)
                .previewInterfaceOrientation(.landscapeLeft)
        } else {
            //Fallback on earlier versions
        }
        
        DeviceIdiomView()
            .previewDevice(PreviewDevice(rawValue: "ipad pro (11-inch) (5th generation)"))
                .environment(\.horizontalSizeClass, .compact)
        
    }
}
