//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import UIKit

protocol SheetContainerViewControllerDelegate: AnyObject {
    func sheetContainer(_ viewController: SheetContainerViewController,
                        willTransitionTo state: SheetContainerViewController.State,
                        animated: Bool)
    func sheetContainer(_ viewController: SheetContainerViewController,
                        didTransitionTo state: SheetContainerViewController.State,
                        animated: Bool)
}

protocol SheetContentViewController: UIViewController {
    // A layout guide representing the portion of the presented view's content that is visible
    // when the sheet is in the partially expanded state
    var sheetPartialContentGuide: UILayoutGuide { get }

    func sheetContainerDidBeginDrag(_ viewController: SheetContainerViewController)
    func sheetContainer(_ viewController: SheetContainerViewController,
                        willTransitionTo state: SheetContainerViewController.State,
                        animated: Bool)
    func sheetContainer(_ viewController: SheetContainerViewController,
                        didTransitionTo state: SheetContainerViewController.State,
                        animated: Bool)
}

class SheetContainerViewController: UIViewController {
    weak var delegate: SheetContainerViewControllerDelegate?
    var isExpandedStateAllowed: Bool = true {
        didSet {
            if isViewLoaded {
                configureForExpandedStateAllowed()
            }
        }
    }

    private let contentViewController: SheetContentViewController
    private var contentView: UIView { contentViewController.view }

    enum State {
        case collapsed
        case partial
        case expanded
    }
    private(set) var state = State.collapsed

    private let cornerRadius: CGFloat = 16
    private let headerView = UIView()
    private let headerHeight: CGFloat = 32
    private let footerView = UIView()

    private var collapsedConstraint: NSLayoutConstraint!
    private var partialConstraint: NSLayoutConstraint!
    private var expandedConstraint: NSLayoutConstraint!
    private var sameHeightConstraint: NSLayoutConstraint!

    private struct DragStartState {
        let state: State
        let initialPosition: CGFloat
    }
    private var dragStartState: DragStartState?
    private var dragPositionConstraint: NSLayoutConstraint!
    private let dragDistanceThreshold: CGFloat = 50
    private let dragVelocityThreshold: CGFloat = 1300
    private var dragGestureRecognizer: UIPanGestureRecognizer!
    private var dragHandleImageView: UIImageView!

    init(content: SheetContentViewController) {
        contentViewController = content
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Header
        headerView.backgroundColor = .clear
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            headerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        dragHandleImageView = UIImageView(image: UIImage.handlebar)
        dragHandleImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(dragHandleImageView)
        NSLayoutConstraint.activate([
            dragHandleImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            dragHandleImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10)
        ])

        // Content
        addChild(contentViewController)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        contentViewController.didMove(toParent: self)

        // Footer
        footerView.backgroundColor = .white
        footerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerView)
        NSLayoutConstraint.activate([
            footerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            footerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        // Gesture recognizer
        dragGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onDrag))
        headerView.addGestureRecognizer(dragGestureRecognizer)
    }

    private func updateCornerRadius() {
        view.layer.cornerRadius = min(view.frame.origin.y, cornerRadius)
    }
}

// MARK: State handling

extension SheetContainerViewController {

    private func position(for state: State) -> CGFloat {
        guard let superview = view.superview else { return 0 }
        switch state {
        case .collapsed:
            return superview.bounds.height
        case .partial:
            let height = contentViewController.sheetPartialContentGuide.layoutFrame.height
            return superview.bounds.height - superview.safeAreaInsets.bottom - height - headerHeight
        case .expanded:
            return 0
        }
    }

    private func targetState(for position: CGPoint,
                             translation: CGPoint,
                             velocity: CGPoint,
                             startState: State) -> State {
        if velocity.y <= -dragVelocityThreshold {
            // Quick drag towards the top
            return isExpandedStateAllowed ? .expanded : state
        }
        if velocity.y >= dragVelocityThreshold {
            // Quick drag towards the bottom
            if state == .expanded {
                return .partial
            }
            return .collapsed
        }

        if translation.y <= 0 {
            // Drag towards the top
            let threshold = self.position(for: .partial) - dragDistanceThreshold
            if position.y <= threshold {
                return isExpandedStateAllowed ? .expanded : state
            }
        }
        if translation.y > 0 {
            // Drag towards the bottom
            let collapsedThreshold = self.position(for: .partial) + dragDistanceThreshold
            if position.y >= collapsedThreshold {
                return .collapsed
            }
            let partialThreshold = self.position(for: .expanded) + dragDistanceThreshold
            if position.y >= partialThreshold {
                return .partial
            }
        }

        // Restore the initial state
        return state
    }

    private func activateConstraintsForCurrentState() {
        guard let partialConstraint, let collapsedConstraint, let expandedConstraint else { return }
        switch state {
        case .collapsed:
            NSLayoutConstraint.deactivate([
                partialConstraint,
                expandedConstraint
            ])
            collapsedConstraint.isActive = true
        case .partial:
            NSLayoutConstraint.deactivate([
                collapsedConstraint,
                expandedConstraint
            ])
            partialConstraint.isActive = true
        case .expanded:
            NSLayoutConstraint.deactivate([
                collapsedConstraint,
                partialConstraint
            ])
            expandedConstraint.isActive = true
        }
    }

    private func configureForExpandedStateAllowed() {
        if isExpandedStateAllowed {
            sameHeightConstraint = view.heightAnchor.constraint(equalTo: view.superview!.heightAnchor)
            sameHeightConstraint.isActive = true
        } else {
            sameHeightConstraint?.isActive = false
            sameHeightConstraint = nil
        }
        dragHandleImageView!.isHidden = !isExpandedStateAllowed
    }

    private func setState(_ newState: State,
                          animated: Bool,
                          initialSpringVelocity: CGFloat = 0.0,
                          completion: (() -> Void)? = nil) {
        contentViewController.sheetContainer(self, willTransitionTo: newState, animated: animated)
        delegate?.sheetContainer(self, willTransitionTo: newState, animated: animated)

        state = newState
        activateConstraintsForCurrentState()
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.95,
                           initialSpringVelocity: initialSpringVelocity) {
                self.view.superview?.layoutIfNeeded()
                self.contentView.layoutIfNeeded()
                self.updateCornerRadius()
            } completion: { _ in
                self.contentViewController.sheetContainer(self, didTransitionTo: newState, animated: true)
                self.delegate?.sheetContainer(self, didTransitionTo: newState, animated: true)
                completion?()
            }
        } else {
            updateCornerRadius()

            contentViewController.sheetContainer(self, didTransitionTo: newState, animated: false)
            delegate?.sheetContainer(self, didTransitionTo: newState, animated: false)
            completion?()
        }
    }

    @objc
    private func onDrag(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)

        switch sender.state {
        case .began:
            // Store the initial state
            let initialPosition = view.frame.minY
            dragStartState = DragStartState(state: state, initialPosition: initialPosition)

            // Setup a new constraint for dragging
            NSLayoutConstraint.deactivate([
                collapsedConstraint,
                partialConstraint,
                expandedConstraint
            ])
            dragPositionConstraint = view.topAnchor.constraint(equalTo: view.superview!.topAnchor,
                                                               constant: initialPosition)
            dragPositionConstraint.isActive = true

            contentViewController.sheetContainerDidBeginDrag(self)
        case .changed:
            // Update the drag constraint
            let newPosition: CGFloat
            if !isExpandedStateAllowed && translation.y < 0 {
                newPosition = dragStartState!.initialPosition
            } else {
                newPosition = dragStartState!.initialPosition + translation.y
            }
            dragPositionConstraint.constant = newPosition
            updateCornerRadius()
        case .ended:
            // Remove the drag constraint
            let currentPosition = dragPositionConstraint.constant
            dragPositionConstraint.isActive = false
            dragPositionConstraint = nil

            // Calculate the final state
            let velocity = sender.velocity(in: view)
            let newState = targetState(for: view.frame.origin,
                                       translation: translation,
                                       velocity: velocity,
                                       startState: dragStartState!.state)

            // Animate to the final state
            let distanceToAnimate = position(for: state) - currentPosition
            let springVelocity = abs(velocity.y / distanceToAnimate)
            if newState != .collapsed {
                setState(newState, animated: true, initialSpringVelocity: springVelocity)
            } else {
                dismiss(animated: true, initialSpringVelocity: springVelocity)
            }

            dragStartState = nil
        default:
            break
        }
    }

    func present(in viewController: UIViewController, presentingView: UIView? = nil, animated: Bool = true) {
        guard state == .collapsed else { return }

        let superview = presentingView != nil ? presentingView! : viewController.view!
        superview.addSubview(view)
        viewController.addChild(self)

        // Setup constraints
        let partialContentBottomAnchor = contentViewController.sheetPartialContentGuide.bottomAnchor
        collapsedConstraint = view.topAnchor.constraint(equalTo: superview.bottomAnchor)
        partialConstraint = superview.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: partialContentBottomAnchor)
        expandedConstraint = view.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor)
        let footerTopConstraint = footerView.topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor)
        footerTopConstraint.priority = .required - 1
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: superview.leftAnchor),
            view.rightAnchor.constraint(equalTo: superview.rightAnchor),
            footerTopConstraint,
            footerView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            footerView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
        configureForExpandedStateAllowed()
        activateConstraintsForCurrentState()
        superview.layoutIfNeeded()

        setState(.partial, animated: animated) {
            self.didMove(toParent: viewController)
        }
    }

    func dismiss(animated: Bool = true) {
        dismiss(animated: animated, initialSpringVelocity: 0)
    }

    private func dismiss(animated: Bool, initialSpringVelocity: CGFloat) {
        guard state != .collapsed else { return }

        willMove(toParent: nil)
        setState(.collapsed, animated: animated, initialSpringVelocity: initialSpringVelocity) {
            self.collapsedConstraint = nil
            self.partialConstraint = nil
            self.expandedConstraint = nil
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
}
