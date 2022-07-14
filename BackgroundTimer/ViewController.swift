//
//  ViewController.swift
//  BackgroundTimer
//
//  Created by Nir on 7/7/22.
//

import UIKit

class ViewController: UIViewController {
    
    //MARK: - Outlets
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var resetButton: UIButton!
	
    //MARK: - Private properties
	private var isTimerCounting : Bool = false
	private var startTime       : Date?
	private var stopTime        : Date?
	
	private let userDefaults    = UserDefaults.standard
    
    private struct Keys {
        static let START_TIME_KEY         = "START_TIME_KEY"
        static let STOP_TIME_KEY          = "STOP_TIME_KEY"
        static let IS_TIMER_COUNTING_KEY  = "IS_TIMER_COUNTING_KEY"
    }
	
    private var scheduledTimer: Timer!
	
    //MARK: - LifeCycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
        startTime = userDefaults.object(forKey: Keys.START_TIME_KEY) as? Date
        stopTime = userDefaults.object(forKey: Keys.STOP_TIME_KEY) as? Date
        isTimerCounting = userDefaults.bool(forKey: Keys.IS_TIMER_COUNTING_KEY)
        handleTimer()
	}

    //MARK: - Actions
	@IBAction func startStopAction(_ sender: Any) {
		if isTimerCounting {
			setStopTime(date: Date())
			stopTimer()
            
		} else {
			if let stop = stopTime {
				let restartTime = calcRestartTime(start: startTime!, stop: stop)
				setStopTime(date: nil)
				setStartTime(date: restartTime)
			} else {
				setStartTime(date: Date())
			}
			
			startTimer()
		}
	}
    
    @IBAction func resetAction(_ sender: Any) {
        setStopTime(date: nil)
        setStartTime(date: nil)
        timeLabel.text = makeTimeString(hour: 0, min: 0, sec: 0)
        stopTimer()
    }
	
    //MARK: - Private methods
    private func handleTimer() {
        if isTimerCounting {
            startTimer()
            
        } else {
            stopTimer()
            if let start = startTime, let stop = stopTime {
                let time = calcRestartTime(start: start, stop: stop)
                let diff = Date().timeIntervalSince(time)
                setTimeLabel(Int(diff))
            }
        }
    }
    
    private func startTimer() {
        scheduledTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateValue), userInfo: nil, repeats: true)
        setIsTimerCounting(true)
        startStopButton.setTitle("STOP", for: .normal)
        startStopButton.setTitleColor(UIColor.red, for: .normal)
    }
    
    private func stopTimer() {
        if scheduledTimer != nil {
            scheduledTimer.invalidate()
        }
        setIsTimerCounting(false)
        startStopButton.setTitle("START", for: .normal)
        startStopButton.setTitleColor(UIColor.systemGreen, for: .normal)
    }
    
    @objc func updateValue() {
        if let start = startTime {
            let diff = Date().timeIntervalSince(start)
            setTimeLabel(Int(diff))
            
        } else {
            stopTimer()
            setTimeLabel(0)
        }
    }
    
    private func setTimeLabel(_ val: Int) {
        let time = secondsToHoursMinutesSeconds(val)
        timeLabel.text = makeTimeString(hour: time.0, min: time.1, sec: time.2)
    }
    
    private func secondsToHoursMinutesSeconds(_ ms: Int) -> (Int, Int, Int) {
        let hour = ms / 3600
        let min = (ms % 3600) / 60
        let sec = (ms % 3600) % 60
        return (hour, min, sec)
    }
    
    private func makeTimeString(hour: Int, min: Int, sec: Int) -> String {
        return String(format: "%02d:%02d:%02d", hour, min, sec)
    }
    
    private func calcRestartTime(start: Date, stop: Date) -> Date {
		let diff = start.timeIntervalSince(stop)
		return Date().addingTimeInterval(diff)
	}
	
	private func setStartTime(date: Date?) {
		startTime = date
        userDefaults.set(startTime, forKey: Keys.START_TIME_KEY)
	}
	
    private func setStopTime(date: Date?) {
		stopTime = date
        userDefaults.set(stopTime, forKey: Keys.STOP_TIME_KEY)
	}
	
    private func setIsTimerCounting(_ val: Bool) {
		isTimerCounting = val
        userDefaults.set(isTimerCounting, forKey: Keys.IS_TIMER_COUNTING_KEY)
	}
}

