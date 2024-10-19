//
//  PartiesView.swift
//  polCal
//
//  Created by Lukas on 28/08/2024.
//

import SwiftUI

struct PassingABillView: View {
    var body: some View {
        Text("This future feature will allow users to simulate whether or not a legislative vote passes in a custom parliamentary setting.\n\nBesides custom scenarios, the available source of real-time data on legislative voting is easy to retrieve from nrsr.sk, so this app could one day better visualise real voting as well. Currently, the available format is practical but not user-friendly:\n \nPrítomní:  121\nHlasujúcich:  121 \n[Z] Za hlasovalo:  17\n[P] Proti hlasovalo:  31\n[?] Zdržalo sa hlasovania:  73\n[N] Nehlasovalo:  0\n[0] Neprítomní:  29\n\n[Z / P / ? / N / 0] Priezvisko, Meno\n\nUsing modern visualisation methods, the legislative process can be presented in a way that provides a more digestible explanation along with greater insight.")
            .padding()
    }
}

#Preview {
    PassingABillView()
}
