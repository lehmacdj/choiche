//
//  TouchCanvas.swift
//  Choose
//
//  Created by Devin Lehmacher on 4/26/22.
//

import SwiftUI
import Combine

typealias TouchId = Int

let allColors: [Color] = [
    .blue,
    .red,
    .green,
    .yellow,
    .orange,
    .brown,
    .purple,
    .cyan,
    .primary
]

func randomColor() -> Color {
    return allColors.randomElement()!
}

struct TouchInfo: Identifiable {
    let id: TouchId
    let color: Color
    var position: CGPoint

    static func withRandomColor(id: TouchId, position: CGPoint) -> Self {
        return TouchInfo(id: id, color: randomColor(), position: position)
    }
}

enum ChoiceState {
    case notEnoughFingers
    case waitingToChoose(timer: Cancellable)
    case chosen(choice: [TouchId], timer: Cancellable)

    func notIsChosen() -> Bool {
        switch self {
        case .chosen(choice: _, timer: _):
            return false
        default:
            return true
        }
    }

    func isWaitingToChoose() -> Bool {
        switch self {
        case .waitingToChoose(timer: _):
            return true
        default:
            return false
        }
    }

    static func waitToChooseThen(action: @escaping () -> ()) -> Self {
         return .waitingToChoose(
            timer:
                Timer.publish(
                    every: 2,
                    on: .main,
                    in: .common)
                .autoconnect()
                .sink { _ in
                    action()
                }
            )
    }

    static func chooseWinnerThen(
        choice: [TouchId],
        action: @escaping () -> ()
    ) -> Self {
        return .chosen(
            choice: choice,
            timer:
                Timer.publish(
                    every: 3,
                    on: .main,
                    in: .common)
                .autoconnect()
                .sink { _ in
                    action()
                }
            )
    }
}

struct TouchArea: View {
    func chooseWinner() {
        guard state.isWaitingToChoose() else {
            print("warning: bad state: \(state)")
            return
        }

        guard let winner = touches.values.randomElement() else {
            print("warning: wasn't able to determine winner")
            return
        }

        state = .chooseWinnerThen(choice: [winner.id]) {
            if touches.count >= 2 {
                state = .waitToChooseThen(action: chooseWinner)
            } else {
                state = .notEnoughFingers
            }
        }
    }

    @State var touches = [TouchId:TouchInfo]()
    @State var state: ChoiceState = .notEnoughFingers

    var body: some View {
        ZStack {
            TouchRecognizer(
                upsertTouch: upsertTouch,
                removeTouch: removeTouch
            )
            ForEach([TouchInfo](touches.values)) { touch in
                if case let .chosen(choice: winners, timer: _) = state {
                    if winners.contains(touch.id) {
                        Bubble(color: touch.color)
                            .position(x: touch.position.x, y: touch.position.y)
                    }
                } else {
                    Bubble(color: touch.color)
                        .position(x: touch.position.x, y: touch.position.y)
                }
            }
        }
    }

    func upsertTouch(id: TouchId, location: CGPoint) {
        guard touches[id] == nil else {
            touches[id]?.position = location
            // we don't need to update the timer if it isn't a new touch
            return
        }

        touches[id] = TouchInfo.withRandomColor(id: id, position: location)

        switch state {
        case .notEnoughFingers:
            guard touches.count >= 2 else {
                return
            }
            fallthrough
        case .waitingToChoose(timer: _):
            state = .waitToChooseThen(action: chooseWinner)
        case .chosen(choice: _, timer: _):
            return
        }
    }

    func removeTouch(id: TouchId) {
        touches.removeValue(forKey: id)
        switch state {
        case .notEnoughFingers:
            return
        case .waitingToChoose(timer: _):
            state = .waitToChooseThen(action: chooseWinner)
        case .chosen(choice: _, timer: _):
            return
        }
    }
}

struct Bubble: View {
    let color: Color

    var body: some View {
        let diameter: CGFloat = 100
        Circle()
            .fill(color)
            .frame(width: diameter, height: diameter)
    }
}

struct TouchCanvas_Previews: PreviewProvider {
    static var previews: some View {
        TouchArea(touches:
          [
            0: TouchInfo(
                id: 0,
                color: .blue,
                position: CGPoint(x: 250, y: 400)),
            1: TouchInfo(
                id: 1,
                color: .red,
                position: CGPoint(x: 100, y: 150))
          ]
        )
    }
}
