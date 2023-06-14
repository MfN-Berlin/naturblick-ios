//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct IndividualsView: View {
    @Binding var individuals: Int64
    var body: some View {
        Stepper  {
            if individuals == 1 {
                Text("1 individual")
            } else {
                Text("\(individuals) individuals")
            }
        } onIncrement: {
            individuals += 1
        } onDecrement: {
            if individuals > 1 {
                individuals -= 1
            }
        }
    }
}

struct IndividualsView_Previews: PreviewProvider {
    static var previews: some View {
        IndividualsView(individuals: .constant(2))
    }
}
