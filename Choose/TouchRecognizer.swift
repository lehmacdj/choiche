//
//  TouchRecognizer.swift
//  Choose
//
//  Created by Devin Lehmacher on 4/26/22.
//

import UIKit
import SwiftUI

struct TouchRecognizer: UIViewRepresentable {
    let upsertTouch: (TouchId, CGPoint) -> ()
    let removeTouch: (TouchId) -> ()

    typealias UIViewType = TouchView

    func makeUIView(context: Context) -> TouchView {
        return TouchView(upsertTouch: upsertTouch, removeTouch: removeTouch)
    }

    func updateUIView(_ touchView: TouchView, context: Context) {}
}

class TouchView: UIView {
    let upsertTouch: (TouchId, CGPoint) -> ()
    let removeTouch: (TouchId) -> ()

    required init(coder: NSCoder) {
        fatalError("init via coder not supported")
    }

    init(upsertTouch: @escaping (TouchId, CGPoint) -> (), removeTouch: @escaping (TouchId) -> ()) {
        self.upsertTouch = upsertTouch
        self.removeTouch = removeTouch
        super.init(frame: .zero)
        self.isMultipleTouchEnabled = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch began")
        for touch in touches {
            upsertTouch(touch.hash, touch.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch moved")
        for touch in touches {
            upsertTouch(touch.hash, touch.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch ended")
        for touch in touches {
            removeTouch(touch.hash)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touch cancelled")
        for touch in touches {
            removeTouch(touch.hash)
        }
    }
}
