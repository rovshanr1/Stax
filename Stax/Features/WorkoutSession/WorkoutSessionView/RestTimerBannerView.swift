import UIKit
import SnapKit

private final class RestProgressBar: UIView {
    private let fillView = UIView()
    
    var progress: Float = 1 {
        didSet {
            progress = min(max(progress, 0), 1)
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .label.withAlphaComponent(0.12)
        fillView.backgroundColor = .activeItems
        clipsToBounds = true
        addSubview(fillView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        fillView.frame = CGRect(x: 0,
                                y: 0,
                                width: bounds.width * CGFloat(progress),
                                height: bounds.height)
    }
}

final class RestTimerBannerView: UIView {
    
    var onBannerTapped: (() -> Void)?
    var onSkipTapped: (() -> Void)?
    
    private var isShown = false
    private var areControlsVisible = true
    private static let hiddenTransform = CGAffineTransform(translationX: 0, y: 40)
    
    //MARK: - UI Elements
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedDigitSystemFont(ofSize: 40, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let progressBar = RestProgressBar()
    
    private let skipButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .activeItems
        config.baseForegroundColor = .label
        config.title = "Skip"
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 15, weight: .semibold)
            return outgoing
        }
        return UIButton(configuration: config)
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabel, progressBar, skipButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(16, after: progressBar)
        return stack
    }()
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        alpha = 0
        transform = Self.hiddenTransform
        isUserInteractionEnabled = false
        
        addSubview(mainStack)
        
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20))
        }
        
        progressBar.snp.makeConstraints { make in
            make.width.equalTo(mainStack)
            make.height.equalTo(6)
        }
        
        skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    //MARK: - Public
    func apply(_ state: RestTimerState) {
        switch state {
        case .idle:
            setVisible(false)
            
        case .running(_, let progress, let timeString):
            timeLabel.text = timeString
            progressBar.progress = progress
            setControlsVisible(true)
            setVisible(true)
            
        case .finished:
            timeLabel.text = "Rest complete"
            progressBar.progress = 0
            setControlsVisible(false)
            setVisible(true)
        }
    }
    
    //MARK: - Private Methods
    private func setControlsVisible(_ visible: Bool) {
        guard visible != areControlsVisible else { return }
        areControlsVisible = visible
        
        let changes = {
            self.progressBar.isHidden = !visible
            self.skipButton.isHidden = !visible
            self.progressBar.alpha = visible ? 1 : 0
            self.skipButton.alpha = visible ? 1 : 0
            self.superview?.layoutIfNeeded()
        }
        
        if isShown {
            UIView.animate(withDuration: 0.25,
                           delay: 0,
                           options: [.beginFromCurrentState, .allowUserInteraction],
                           animations: changes)
        } else {
            changes()
        }
    }
    
    private func setVisible(_ visible: Bool) {
        guard visible != isShown else { return }
        isShown = visible
        isUserInteractionEnabled = visible
        
        UIView.animate(withDuration: 0.35,
                       delay: 0,
                       usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.alpha = visible ? 1 : 0
            self.transform = visible ? .identity : Self.hiddenTransform
        }
    }
    
    @objc private func handleSkip() { onSkipTapped?() }
    @objc private func handleTap() { onBannerTapped?() }
}
