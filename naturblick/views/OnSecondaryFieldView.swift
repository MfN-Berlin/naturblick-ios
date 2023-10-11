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
    let label: String
    let image: Image
    let isSet: Bool
    @ViewBuilder let field: (String) -> Field
    @FocusState var focus: Bool
    init(label: String, image: Image, isSet: Bool, @ViewBuilder field: @escaping (String) -> Field) {
        self.field = field
        self.image = image
        self.label = label
        self.isSet = isSet
    }
    
    init(label: String, icon: String, isSet: Bool, @ViewBuilder field: @escaping (String) -> Field) {
        self.init(label: label, image: Image(icon), isSet: isSet, field: field)
    }
    
    var body: some View {
        HStack(alignment: .center) {
           image
                .observationProperty()
            VStack(alignment: .leading, spacing: .zero) {
                if focus || isSet {
                    Text(label)
                            .caption(color: .onSecondarySignalLow)
                }
                field(focus ? "" : label)
                    .focused($focus)
                    .font(.nbBody1)
                    .foregroundColor(.onSecondaryMediumEmphasis)
            }
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
        .onTapGesture {
            focus = true
        }
    }
}

struct OnSecondaryFieldView_Previews: PreviewProvider {
    static var previews: some View {
        OnSecondaryFieldView(label: "Label", icon: "placeholder", isSet: true) { label in
            TextField(label, text: .constant("test"))
        }
    }
}
