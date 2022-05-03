//
//  DragThenPress.swift
//  Choose
//
//  Created by Devin Lehmacher on 4/26/22.
//

import SwiftUI

struct DragThenPress: View {
    struct DragState {
        var pos1: CGPoint?
        var pos2: CGPoint?
    }

    @GestureState var dragState: DragState = DragState(pos1: nil, pos2: nil)

    var body: some View {
        let dragThenPressGesture = DragGesture()
            .simultaneously(with: DragGesture())
            .updating($dragState) { value, state, transition in
                state.pos1 = value.first?.location
                state.pos2 = value.second?.location
            }


        ZStack {
            Color.black
                .gesture(dragThenPressGesture)
            if let location = dragState.pos1 {
                Bubble(color: Color.red)
                    .position(x: location.x, y: location.y)
            }
            if let location = dragState.pos2 {
                Bubble(color: Color.blue)
                    .position(x: location.x, y: location.y)
            }
        }
    }
}

struct DragThenPress_Previews: PreviewProvider {
    static var previews: some View {
        DragThenPress()
            .navigationBarHidden(true)
    }
}
