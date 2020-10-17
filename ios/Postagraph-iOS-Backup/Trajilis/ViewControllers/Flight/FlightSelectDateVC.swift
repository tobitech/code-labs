//
//  FlightSelectDateVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 06/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import FSCalendar

final class FlightSelectDateVC: BaseVC {


    @IBOutlet var calenderContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var chooseDatesButton: UIButton!
    
    let header: FlightOutboundReturnView = FlightOutboundReturnView.fromNib()
    
    var selectedDate:((Date, Date?) -> Void)?
    
    var travelersData: TravelersData?
    
    var isSelectingDepartDate: Bool = true
    var departDate: Date? {
        didSet {
            if let _ = departDate {
                isSelectingDepartDate = false
            }
            header.setDate(isOutbound: true, date: departDate)
        }
    }
    
    var returnDate: Date? {
        didSet {
            header.setDate(isOutbound: false, date: returnDate)
        }
    }
    
    var origin: Airport?
    var destination: Airport?
    
    var tripType = FlightTrip.roundTrip {
        didSet {
            if calendar != nil {
                calendar.allowsMultipleSelection = tripType == .roundTrip
            }
        }
    }
    
    // MARK: - Calendar Properties
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd"
        return formatter
    }()
    fileprivate weak var calendar: FSCalendar!

    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "\(origin?.iata.uppercased() ?? "") - \(destination?.iata.uppercased() ?? "")"
        self.travelersData = (self.navigationController as? BookingNavigationController)?.travelersData
        
        self.showNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = false
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        capitalizedMonth(calendar: self.calendar)
    }
    
    // MARK: - Helper Methods
    
    fileprivate func setupViews() {
        headerView.addSubview(header)
        header.fillSuperview()
        header.flightTypeSegmentedControl.addTarget(self, action: #selector(handleFlighTypeChanged), for: .valueChanged)
        header.departureDateButton.addTarget(self, action: #selector(handleDepartureDateTapped), for: .touchUpInside)
        header.returnDateButton.addTarget(self, action: #selector(handleReturnDateTapped), for: .touchUpInside)
        
        setupCalendar()
        
        chooseDatesButton.makeCornerRadius(cornerRadius: 4.0)
        chooseDatesButton.addTarget(self, action: #selector(handleChooseDatesTapped), for: .touchUpInside)
    }

    private func setupCalendar() {
        let calendar = FSCalendar(frame: calenderContainerView.frame)
        calendar.allowsMultipleSelection = tripType == .roundTrip
        calendar.delegate = self
        calendar.dataSource = self
        calenderContainerView.addSubview(calendar)
        calendar.fillSuperview(padding: .init(top: 0, left: 8, bottom: 0, right: 8))
        self.calendar = calendar

        calendar.calendarHeaderView.backgroundColor = UIColor.clear
        calendar.calendarWeekdayView.backgroundColor = UIColor.clear
        calendar.appearance.selectionColor = UIColor.appRed
        calendar.appearance.titlePlaceholderColor = UIColor.appBlack
        calendar.appearance.weekdayTextColor = UIColor.appBlack
        calendar.appearance.headerTitleColor = UIColor.appBlack
        calendar.appearance.headerTitleFont = UIFont.ptSansBold(with: 16)
        calendar.appearance.borderRadius = 0
        calendar.today = nil
        
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "cell")
        
        calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
        calendar.scrollDirection = .horizontal
    }
    
    fileprivate func capitalizedMonth(calendar: FSCalendar) {
        
        let collectionView = calendar.calendarHeaderView.value(forKey: "collectionView") as! UICollectionView
        collectionView.visibleCells.forEach{ (cells) in
            let c = cells as! FSCalendarHeaderCell
            c.titleLabel.text = c.titleLabel.text?.uppercased()
        }
    
    }
    
    // MARK: - Actions Methods
    
    @objc fileprivate func handleFlighTypeChanged(_ sender: CustomSegmentedControl) {
        self.tripType = sender.selectedSegmentIndex == 0 ? .roundTrip : .oneway
        resetCalendar()
    }
    
    fileprivate func resetCalendar() {
        self.departDate = nil
        self.returnDate = nil
        self.isSelectingDepartDate = true
        for date in calendar.selectedDates {
            calendar.deselect(date)
        }
        calendar.reloadData()
    }
    
    @objc fileprivate func handleDepartureDateTapped() {
        if let date = departDate {
            calendar.deselect(date)
            calendar.reloadData()
        }
    }
    
    @objc fileprivate func handleReturnDateTapped() {
        if let date = returnDate {
            calendar.deselect(date)
            calendar.reloadData()
        }
    }
    
    fileprivate func handleDatesSelected() {
        if departDate != nil, returnDate != nil {
            chooseDatesButton.isEnabled = true
            chooseDatesButton.backgroundColor = UIColor.appRed
        } else {
            chooseDatesButton.isEnabled = false
            chooseDatesButton.backgroundColor = UIColor.disabledButtonRed
        }
    }
    
    @objc fileprivate func handleChooseDatesTapped() {
        
        if origin == nil || destination == nil {
            showAlert(message: "Please select valid origin and destination.")
            return
        }
        
        if origin?.iata == destination?.iata {
            showAlert(message: "Please select different origin or destination.")
            return
        }
        
        if let depDate = self.departDate {
            if !depDate.isFuture {
                showAlert(message: "Departure date must be in future.")
                return
            }
        } else {
            showAlert(message: "Please select departure date.")
            return
        }
        
        
        if tripType == .roundTrip {
            if let arriDate = self.returnDate {
                if !arriDate.isFuture {
                    showAlert(message: "Return date must be in future.")
                    return
                }
            } else {
                showAlert(message: "Please select return date.")
                return
            }
        }
        
        let controller = FlightSearchResultsVC.instantiate(fromAppStoryboard: .flight)
        
        controller.destination = self.destination
        controller.origin = self.origin
        controller.departureDate = self.departDate
        controller.returnDate = self.returnDate
        controller.tripType = self.tripType
        
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }

}

extension FlightSelectDateVC : FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        if returnDate != nil && departDate != nil && date > departDate! && date < returnDate! {
            return UIColor.appRed.withAlphaComponent(0.9)
        }
        return .clear
    }
   
}

// MARK: - FSCalendar Data source and Delegates
extension FlightSelectDateVC: FSCalendarDelegate, FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.configure(cell: cell, for: date, at: monthPosition)
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        if tripType == .roundTrip {
            if let date = departDate {
                return date
            }
        }
        return Date()
    }

    func maximumDate(for calendar: FSCalendar) -> Date {
        if tripType == .roundTrip {
            if let date = returnDate {
                return date
            }
        }
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .year, value: 1, to: Date())
        return newDate!
    }
 

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        return 2.0
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if returnDate != nil && departDate != nil {
            return false
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        capitalizedMonth(calendar: self.calendar)
    }
    
    private func selectInBetweenDates(from date: Date) {
        guard let departDate = self.departDate,
            let startDate = self.gregorian.date(byAdding: .day, value: 1, to: departDate) else { return }
        let datesInBetween = Date.dates(from: startDate, to: date, in: gregorian)
        for date in datesInBetween {
            print(formatter.string(from: date))
            calendar.select(date, scrollToDate: false)
        }
    }
    
    private func deselectInBetweenDates(from date: Date) {
        guard let departDate = self.departDate,
            let startDate = self.gregorian.date(byAdding: .day, value: 1, to: departDate) else { return }
        let datesInBetween = Date.dates(from: startDate, to: date, in: calendar.gregorian)
        for date in datesInBetween {
            print(formatter.string(from: date))
            calendar.deselect(date)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.formatter.string(from: date))")
        
        if tripType == .oneway {
            departDate = date
        } else {
            if isSelectingDepartDate {
                departDate = date
            } else {
                returnDate = date
                self.selectInBetweenDates(from: date)
            }
        }
        
        self.configureVisibleCells()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did deselect date \(self.formatter.string(from: date))")
        
        if tripType == .oneway {
            departDate = nil
        } else {
            if !isSelectingDepartDate && calendar.gregorian.isDate(date, inSameDayAs: departDate ?? Date()) {
                departDate = nil
                isSelectingDepartDate = true
            } else if gregorian.isDate(date, inSameDayAs: returnDate ?? Date()) {
                self.deselectInBetweenDates(from: date)
                returnDate = nil
            } else {
                if calendar.selectedDates.count > 1 {
                    returnDate = calendar.selectedDates.last
                } else {
                    returnDate = nil
                }
            }
        }
        
        self.configureVisibleCells()
    }
    
    // MARK: - Private functions
    
    private func configureVisibleCells() {
        calendar.visibleCells().forEach { (cell) in
            let date = calendar.date(for: cell)
            let position = calendar.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }
    
    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        
        let customCell = (cell as! CustomCalendarCell)
        
        if position == .current {
            var selectionType = DateSelectionType.none
            
            // set date selection type
            if calendar.selectedDates.contains(date) {
                let previousDate = self.gregorian.date(byAdding: .day, value: -1, to: date)!
                let nextDate = self.gregorian.date(byAdding: .day, value: 1, to: date)!
                if calendar.selectedDates.contains(date) {
                    if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(nextDate) {
                        selectionType = .middle
                    } else if calendar.selectedDates.contains(previousDate) && calendar.selectedDates.contains(date) {
                        selectionType = .rightBorder
                    } else if calendar.selectedDates.contains(nextDate) {
                        selectionType = .leftBorder
                    } else {
                        selectionType = .single
                    }
                }
            } else {
                selectionType = .none
            }
            
            // hide selection layer for none selectionType
            if selectionType == .none {
                customCell.selectionLayer.isHidden = true
                return
            }
            
            customCell.selectionLayer.isHidden = false
            customCell.selectionType = selectionType
        } else {
            // hide selection layer if not in current month
            customCell.selectionLayer.isHidden = true
        }
    }
}
