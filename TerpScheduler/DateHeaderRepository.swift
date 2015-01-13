//
//  DailyTasksCollection.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/7/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit
import CoreData

struct SchoolDate {
    var Date : NSDate
    var Schedule : String
}

class DateHeaderRepository: NSObject {
    var managedContext : NSManagedObjectContext
    var allTasks = Dictionary<Int, [DailyTask]>()
    var weekID = -1
    var dates : [SchoolDate] = []
    var firstDate : NSDate {
        get { return dates[0].Date }
    }
    var lastDate : NSDate {
        get { return dates[dates.count - 1 ].Date }
    }
    
    init(context: NSManagedObjectContext){
        managedContext = context
        super.init()
        if weekID < 0 {
            weekID = FetchWeekID(NSDate()) //focus on current week
        }
        LoadCurrentWeek()
    }
    
    func FetchWeekID(today: NSDate) ->Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(NSCalendarUnit.CalendarUnitWeekOfYear, fromDate: today)
        return components.weekOfYear
    }

    func LoadNextWeek()
    {
        weekID += 1
        //switch out to next week
        LoadCurrentWeek()
        return
    }
    
    func LoadPreviousWeek()
    {
        weekID -= 1
        //switch out to previous week
        LoadCurrentWeek()
    }
    
    func LoadCurrentWeek()
    {
        //called to populate the UI elements with current week's data

        var fetchRequest = NSFetchRequest(entityName: "Week")
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "weekID = %i", weekID)
        var error : NSError?
        if let results = managedContext.executeFetchRequest(fetchRequest, error: nil) as? [WeekModel]{
            var weekData = results[0]
            let firstDay = weekData.firstWeekDay
            let scheduleString = weekData.weekSchedules
            let scheduleArray = scheduleString.componentsSeparatedByString(" ")
            var dateFormatter = NSDateFormatter()
            for (index, schedule) in enumerate(scheduleArray) {
                let date = GetDateByOffset(firstDay, byOffset: index)
                dates.append(SchoolDate(Date: date, Schedule: schedule))
            }
        }
    }
    
    func GetDateByOffset(date : NSDate, byOffset index : Int)->NSDate{
        var offset = NSDateComponents()
        offset.day = index
        return NSCalendar.currentCalendar().dateByAddingComponents(offset, toDate: date, options: nil)!
    }
}