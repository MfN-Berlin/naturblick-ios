//
// Copyright © 2023 Museum für Naturkunde Berlin.
// This code is licensed under MIT license (see LICENSE.txt for details)


import SwiftUI

struct FieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: .smallCornerRadius, height: .smallCornerRadius)).cgPath)
    }
}

struct OnSecondaryFieldView<Field: View>: View {
    let image: Image
    @ViewBuilder let field: () -> Field
    
    init(image: Image, @ViewBuilder field: @escaping () -> Field) {
        self.field = field
        self.image = image
    }
    
    init(icon: String, @ViewBuilder field: @escaping () -> Field) {
        self.init(image: Image(icon), field: field)
    }
    
    var body: some View {
        HStack(alignment: .center) {
           image
                .observationProperty()
            field()
                .font(.nbBody1)
                .foregroundColor(.onSecondaryMediumEmphasis)
                .frame(maxHeight: .editTextIconSize)
            Spacer()
        }
        .frame(height: .editTextFieldHeight)
        .frame(maxWidth: .infinity)
        .padding(.trailing, .defaultPadding)
        .overlay(alignment: .bottom) {
            Divider()
                .frame(height: 1)
                .overlay(Color.onSecondarySignalLow)
        }
        .background(Color.onSecondaryMinimumEmphasis)
        .clipShape(FieldShape())
    }
}

struct OnSecondaryFieldView_Previews: PreviewProvider {
    static var previews: some View {
        OnSecondaryFieldView(icon: "placeholder") {
            TextField("Test", text: .constant("test"))
        }
    }
}
